function [X, stress_history] = stress_mds_smacof(D, k, maxIter, tol)

if nargin < 2, k = 2; end
if nargin < 3, maxIter = 1000; end
if nargin < 4, tol = 1e-7; end

rng(42);

n = size(D, 1);

W = ones(n, n);
W(1:n+1:end) = 0;

X = randn(n, k);
X = X - mean(X, 1);

stress_history = zeros(maxIter, 1);
prev_stress = inf;

for iter = 1:maxIter

    DX = squareform_dist(X);

    B = zeros(n, n);

    mask = DX > 1e-12;
    B(mask) = -W(mask) .* D(mask) ./ DX(mask);

    B(1:n+1:end) = 0;
    B(1:n+1:end) = -sum(B, 2);

    Xnew = (1 / n) * B * X;
    Xnew = Xnew - mean(Xnew, 1);

    s = stress_value(D, W, Xnew);

    stress_history(iter) = s;

    if abs(prev_stress - s) < tol
        stress_history = stress_history(1:iter);
        fprintf('Convergió en iteración %d\n', iter);
        break;
    end

    X = Xnew;
    prev_stress = s;
end
end


function D = squareform_dist(X)

G = X * X';
q = diag(G);

D2 = q + q' - 2 * G;
D2(D2 < 0) = 0;

D = sqrt(D2);
end


function s = stress_value(D, W, X)

DX = squareform_dist(X);

E = DX - D;
E(1:size(D,1)+1:end) = 0;

s = sum(sum(W .* E.^2)) / 2;
end
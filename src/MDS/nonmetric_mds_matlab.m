function [X, stress_history] = nonmetric_mds_matlab(D, k, maxIter, lr, tol)

    if nargin < 2, k = 2; end
    if nargin < 3, maxIter = 1000; end
    if nargin < 4, lr = 0.01; end
    if nargin < 5, tol = 1e-7; end

    rng(42);

    n = size(D, 1);

    % Inicialización aleatoria
    X = randn(n, k);
    X = X - mean(X, 1);

    % Índices de la parte triangular superior
    [I, J] = find(triu(ones(n), 1));

    delta = D(sub2ind([n n], I, J));

    % Ordenar disimilitudes
    [delta_sorted, order] = sort(delta);

    stress_history = zeros(maxIter, 1);
    prev_stress = inf;

    for iter = 1:maxIter

        % Distancias actuales en el embedding
        DX = squareform_dist(X);
        dvec = DX(sub2ind([n n], I, J));

        % Aplicar regresión isotónica sobre distancias ordenadas
        d_sorted = dvec(order);
        dhat_sorted = pava(d_sorted);

        % Regresar al orden original
        dhat = zeros(size(dvec));
        dhat(order) = dhat_sorted;

        % Matriz de disparidades ajustadas
        DHAT = zeros(n, n);
        DHAT(sub2ind([n n], I, J)) = dhat;
        DHAT = DHAT + DHAT';

        % Evitar división entre cero
        DX_safe = DX;
        DX_safe(DX_safe < 1e-12) = 1e-12;

        % Gradiente matricial
        R = (DX - DHAT) ./ DX_safe;
        R(1:n+1:end) = 0;

        L = diag(sum(R, 2)) - R;

        grad = 2 * L * X;

        % Actualización
        X = X - lr * grad;

        % Centrar embedding
        X = X - mean(X, 1);

        % Stress normalizado
        num = sum((dvec - dhat).^2);
        den = sum(dvec.^2) + 1e-12;
        stress = sqrt(num / den);

        stress_history(iter) = stress;

        if abs(prev_stress - stress) < tol
            stress_history = stress_history(1:iter);
            fprintf('Convergió en iteración %d\n', iter);
            break;
        end

        prev_stress = stress;
    end
end


function D = squareform_dist(X)

    G = X * X';
    sq = diag(G);

    D2 = sq + sq' - 2 * G;
    D2(D2 < 0) = 0;

    D = sqrt(D2);
end


function y = pava(x)

    % Pool Adjacent Violators Algorithm
    n = length(x);

    y = x(:);
    w = ones(n, 1);

    i = 1;

    while i < n
        if y(i) <= y(i + 1)
            i = i + 1;
        else
            new_y = (w(i) * y(i) + w(i + 1) * y(i + 1)) / ...
                    (w(i) + w(i + 1));

            y(i) = new_y;
            w(i) = w(i) + w(i + 1);

            y(i + 1) = [];
            w(i + 1) = [];
            n = n - 1;

            if i > 1
                i = i - 1;
            end
        end
    end

    % Expandir bloques
    y_expanded = [];
    for i = 1:length(y)
        y_expanded = [y_expanded; repmat(y(i), w(i), 1)];
    end

    y = y_expanded;
end
function X = metric_mds(D, k)

if nargin < 2
    k = 2;
end

n = size(D, 1); % 4

% Paso 1. Elevar distancias al cuadrado
E = D.^2;

% 2. Matriz de centrado
H = eye(n) - (1/n) * ones(n, n);

% 3. Doble centrado
K = -0.5 * H * E * H;

% 4. Autovalores y autovectores
[V, Lambda] = eig(K);

eigenvalues = diag(Lambda);

% 5. Ordenar autovalores de mayor a menor
[eigenvalues, idx] = sort(eigenvalues, 'descend');
V = V(:, idx);

% 6. Tomar los k autovalores positivos principales
eigenvalues_k = eigenvalues(1:k);
V_k = V(:, 1:k);

eigenvalues_k(eigenvalues_k < 0) = 0;

% 7. Coordenadas finales
X = V_k * diag(sqrt(eigenvalues_k));
end
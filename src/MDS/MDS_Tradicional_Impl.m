
D = [
    0 1 2 3;
    1 0 1 2;
    2 1 0 1;
    3 2 1 0
    ];
k = 2; % 2 o 3
X = metric_mds(D, k);

disp(X)

scatter(X(:,1), X(:,2), 80, 'filled')
text(X(:,1), X(:,2), string(1:size(X,1)))
title('MDS métrico clásico')
grid on
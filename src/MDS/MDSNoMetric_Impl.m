D = [
    0 1 2 4 7;
    1 0 3 5 8;
    2 3 0 6 9;
    4 5 6 0 10;
    7 8 9 10 0
    ];

[X, stress] = nonmetric_mds_matlab(D, 2, 1000, 0.01, 1e-7);

disp(X)

scatter(X(:,1), X(:,2), 80, 'filled')
text(X(:,1), X(:,2), string(1:size(X,1)))
title('MDS no métrico')
grid on
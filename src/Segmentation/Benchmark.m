% Cargar tu imagen de prueba (ej. granos de frijol)
I = imread('C:\Users\jose_\OneDrive\Documents\CIDEA\CaféCereza\TIFF\M1-1-7.tif');
Lab = rgb2lab(I);
x = 100; y = 100; % Punto de prueba
dist = 20;

% 1. Probar tu código original
tic;
R1 = ColorRegionGrowingLab(I, Lab, dist, x, y);
t1 = toc;
fprintf('Tiempo Original: %.4f segundos\n', t1);

% 2. Probar versión optimizada con Cola
tic;
R2 = ColorRegionGrowingOptimized(I, Lab, dist, x, y);
t2 = toc;
fprintf('Tiempo con Cola: %.4f segundos\n', t2);

% 3. Probar versión Vectorizada (bwselect)
tic;
R3 = ColorRegionGrowingVectorized(I, Lab, dist, x, y);
t3 = toc;
fprintf('Tiempo Vectorizado: %.4f segundos\n', t3);
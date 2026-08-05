%% DEMOSTRACION DE SEGMENTACION RAPIDA DE FRIJOLES
% Coloque PV-08_002.tif en la misma carpeta que estos archivos .m o cambie
% la variable archivo por la ruta correspondiente.

clear;
clc;
close all;

archivo = 'D:/CIDEA/Pob de friijol 2026/TIF/FCA-12_001.tif';

if exist(archivo, 'file') ~= 2
    error(['No se encontro %s. Coloque la imagen en la carpeta actual ' ...
           'o escriba su ruta completa en la variable archivo.'], archivo);
end

I = imread(archivo);

% Parametros recomendados para la imagen proporcionada.
% para semillas negras el valor recomendado es 10;

umbral = 10;       % Probar aproximadamente entre 15 y 20.
usarGPU = true;    % Detecta GPU; si falla, utiliza CPU automaticamente.
areaMinima = [];   % [] calcula el valor en funcion de la resolucion.
limpiar = true;    % Apertura, cierre, relleno y eliminacion de ruido.

[BW, info] = SegmentarFrijolesRapido( ...
    I, umbral, usarGPU, areaMinima, limpiar);

fprintf('\n--- RESULTADOS ---\n');
fprintf('Dispositivo de segmentacion : %s\n', info.ExecutionDevice);
fprintf('Conversion RGB-Lab          : %s\n', info.LabConversionDevice);
fprintf('Umbral a*b*                 : %.2f\n', info.Threshold);
fprintf('Fondo estimado [a*, b*]     : [%.3f, %.3f]\n', ...
    info.BackgroundAB(1), info.BackgroundAB(2));
fprintf('Objetos encontrados          : %d\n', info.ObjectCount);
fprintf('Pixeles de primer plano      : %d\n', info.ForegroundPixels);
fprintf('Tiempo de conversion Lab     : %.4f s\n', info.LabConversionSeconds);
fprintf('Tiempo total                 : %.4f s\n\n', info.TotalSeconds);

% Guardar la mascara completa.
[carpeta, nombre, ~] = fileparts(archivo);
if isempty(carpeta)
    carpeta = pwd;
end
archivoMascara = fullfile(carpeta, [nombre '_mascara.png']);
imwrite(BW, archivoMascara);
fprintf('Mascara guardada en:\n%s\n', archivoMascara);

% Reducir solo para visualizar con menor consumo de memoria.
escala = min(1, 1600 / size(I,2));
Ivisual = imresize(I, escala);
BWvisual = imresize(BW, escala, 'nearest');

figure('Name','Segmentacion rapida de frijoles', ...
       'NumberTitle','off', 'Color','w');

subplot(1,3,1);
imshow(Ivisual);
title('Imagen original');

subplot(1,3,2);
imshow(BWvisual);
title(sprintf('Mascara: %d objetos', info.ObjectCount));

subplot(1,3,3);
superpuesta = labeloverlay(Ivisual, BWvisual, ...
    'Colormap', [0 1 0], 'Transparency', 0.65);
imshow(superpuesta);
title(sprintf('Resultado, umbral = %.1f', umbral));

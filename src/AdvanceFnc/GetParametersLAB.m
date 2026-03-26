function T = GetParametersLAB(pathImg, filePattern, dirOut)
    % Valida entradas
    if nargin < 3
        error('Uso: GetParametersLAB(pathImg, filePattern, dirOut)');
    end

    % Asegurar que las rutas sean strings/char correctos
    pathImg = char(pathImg);
    dirOut = char(dirOut);

    % 1. Lógica de archivos más robusta
    % En lugar de confiar en que maskFiles(k) coincida con imgList(k), 
    % buscaremos la máscara específica para cada imagen.
    if isempty(filePattern)
        imgList = dir(fullfile(pathImg, '*.tif'));
    else
        imgList = dir(fullfile(pathImg, filePattern));
    end

    if isempty(imgList)
        warning('No se encontraron imágenes en la ruta especificada.');
        T = table(); return;
    end

    % 2. Pre-asignación de arrays (numéricos son más rápidos que celdas para promedios)
    n = numel(imgList);
    muestra = cell(n, 1);
    L = zeros(n, 1);
    a = zeros(n, 1);
    b = zeros(n, 1);
    croma = zeros(n, 1);
    hue = zeros(n, 1);

    if ~exist(dirOut, 'dir'), mkdir(dirOut); end

    fprintf('Iniciando procesamiento de %d imágenes...\n', n);

    for k = 1:n
        imgName = imgList(k).name;
        [~, populationName, ~] = fileparts(imgName); % Extrae nombre sin extensión
        
        try
            % 3. Carga de Máscara vinculada por nombre
            maskPath = fullfile(pathImg, 'Masks', [populationName, '.mat']);
            if ~exist(maskPath, 'file')
                warning('Máscara no encontrada para %s. Omitiendo.', imgName);
                continue;
            end
            
            S = load(maskPath);
            if ~isfield(S, 'Mask')
                warning('Archivo %s no contiene variable "Mask".', maskPath);
                continue;
            end
            Mask = S.Mask;

            % 4. Lectura y Procesamiento
            imgPath = fullfile(pathImg, imgName);
            I_rgb = imread(imgPath);
            
            % Calibración y conversión
            I_Lab = ColorCalibration(I_rgb); 
            
            % Extracción de valores ROI
            [Lab_Values, ~] = ROILab(I_Lab, Mask);
            
            if isempty(Lab_Values)
                warning('ROI vacía para %s.', populationName);
                continue;
            end

            % Cálculo de Croma y Hue
            [~, c1, h1] = CromaHueChannel1(Lab_Values);
            
            % 5. Almacenamiento directo (evitamos cell anidadas innecesarias)
            muestra{k} = populationName;
            L(k) = mean(Lab_Values(:,1));
            a(k) = mean(Lab_Values(:,2));
            b(k) = mean(Lab_Values(:,3));
            croma(k) = mean(c1);
            hue(k) = mean(h1);
            
            fprintf('[%s] Procesado: %s\n', datestr(now, 'HH:MM:SS'), populationName);

        catch ME
            warning('Error en %s: %s', populationName, ME.message);
        end
    end

    % 6. Creación de Tabla y Limpieza
    T = table(muestra, L, a, b, croma, hue);
    
    % Opcional: Eliminar filas vacías si hubo errores/omisiones
    T(cellfun(@isempty, T.muestra), :) = [];
    
    % Guardar resultados
    save(fullfile(dirOut, 'ResultadosLAB.mat'), 'T');
    writetable(T, fullfile(dirOut, 'ResultadosLAB.xls'));
    fprintf('Proceso finalizado. Resultados guardados en %s\n', dirOut);
end
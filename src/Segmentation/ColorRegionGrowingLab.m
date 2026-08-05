function [REGION, info] = ColorRegionGrowingLab(I, Lab, maxdist, x, y, useWeightedDistance)
%COLORREGIONGROWINGLAB Segmentacion vectorizada por crecimiento de region.
%
%   REGION = ColorRegionGrowingLab(I, Lab, maxdist, x, y)
%   [REGION, INFO] = ColorRegionGrowingLab(...)
%   [...] = ColorRegionGrowingLab(..., useWeightedDistance)
%
% Entradas
%   I       : imagen usada para seleccionar interactivamente la semilla.
%   Lab     : imagen MxNx3 en el espacio CIE L*a*b*.
%   maxdist : distancia maxima respecto al color de la semilla. Si vale 0,
%             se seleccionan automaticamente el umbral y los pesos.
%   x, y    : fila y columna de la semilla. Si se omiten, se solicitan con
%             el raton.
%   useWeightedDistance : opcional. false conserva el comportamiento
%             numerico efectivo del codigo original (distancia euclidiana
%             sin pesos). true aplica los pesos definidos para cada fondo.
%
% Salidas
%   REGION  : mascara logica MxN correspondiente al componente de 8 vecinos
%             que contiene al pixel semilla.
%   info    : estructura con el dispositivo y parametros utilizados.
%
% Optimizaciones principales
%   1) Calcula simultaneamente la distancia de todos los pixeles.
%   2) Compara distancias al cuadrado y evita calcular sqrt.
%   3) Extrae el componente conectado mediante imreconstruct.
%   4) Usa GPU automaticamente cuando esta disponible; si falla, usa CPU.
%
% Requiere Image Processing Toolbox para imreconstruct. El uso de GPU
% requiere Parallel Computing Toolbox y una GPU compatible.

    narginchk(3, 6);

    if nargin < 6 || isempty(useWeightedDistance)
        % El codigo original calcula una distancia ponderada, pero la
        % sobrescribe inmediatamente con la distancia no ponderada.
        % false mantiene el resultado efectivo de esa implementacion.
        useWeightedDistance = false;
    end

    validateattributes(Lab, {'single', 'double'}, ...
        {'real', 'nonsparse', 'nonempty'}, mfilename, 'Lab', 2);

    if size(Lab, 3) ~= 3
        error('ColorRegionGrowingLab:InvalidLab', ...
            'Lab debe ser una matriz MxNx3.');
    end

    validateattributes(maxdist, {'numeric'}, ...
        {'real', 'finite', 'scalar', 'nonnegative'}, ...
        mfilename, 'maxdist', 3);
    validateattributes(useWeightedDistance, {'logical', 'numeric'}, ...
        {'real', 'finite', 'scalar'}, mfilename, 'useWeightedDistance', 6);
    useWeightedDistance = logical(useWeightedDistance);

    nRows = size(Lab, 1);
    nCols = size(Lab, 2);
    interactiveSeed = nargin < 5 || isempty(x) || isempty(y);

    if interactiveSeed
        if isempty(I)
            error('ColorRegionGrowingLab:MissingImage', ...
                'I no puede estar vacia cuando la semilla es interactiva.');
        end
        if size(I, 1) ~= nRows || size(I, 2) ~= nCols
            error('ColorRegionGrowingLab:SizeMismatch', ...
                'I y Lab deben tener el mismo numero de filas y columnas.');
        end

        hFigure = figure('Name', 'SEGMENTACION', 'NumberTitle', 'off');
        imshow(I);
        title('Seleccione el pixel semilla');

        % getpts entrega primero columna y despues fila.
        [selectedColumn, selectedRow] = getpts(hFigure);
        if isempty(selectedRow)
            if isgraphics(hFigure), close(hFigure); end
            error('ColorRegionGrowingLab:SeedNotSelected', ...
                'No se selecciono ningun pixel semilla.');
        end

        x = round(selectedRow(1));
        y = round(selectedColumn(1));
        if isgraphics(hFigure), close(hFigure); end
    end

    validateattributes(x, {'numeric'}, ...
        {'real', 'finite', 'scalar', 'integer', '>=', 1, '<=', nRows}, ...
        mfilename, 'x', 4);
    validateattributes(y, {'numeric'}, ...
        {'real', 'finite', 'scalar', 'integer', '>=', 1, '<=', nCols}, ...
        mfilename, 'y', 5);

    seed = reshape(Lab(x, y, :), 1, 3);
    weights = [1, 1, 1];
    automaticParameters = (maxdist == 0);

    if automaticParameters
        [maxdist, automaticWeights, validSeed] = localAutomaticParameters(seed);

        if ~validSeed
            REGION = false(nRows, nCols);
            info = localInfo(false, maxdist, weights, [x, y], ...
                useWeightedDistance, automaticParameters, nnz(REGION));
            warning('ColorRegionGrowingLab:InvalidAutomaticSeed', ...
                ['No fue posible clasificar el fondo a partir de la semilla. ', ...
                 'Seleccione una semilla alejada del grano y use fondo ', ...
                 'negro, blanco o azul claro.']);
            return;
        end

        if useWeightedDistance
            weights = automaticWeights;
        end
    end

    useGPU = localCanUseGPU();
    usedGPU = false;

    if useGPU
        try
            REGION = localSegmentGPU(Lab, seed, weights, maxdist, x, y);
            usedGPU = true;
        catch gpuException
            warning('ColorRegionGrowingLab:GPUFallback', ...
                ['La ejecucion en GPU fallo y se continuara en CPU. ', ...
                 'Detalle: %s'], gpuException.message);
            REGION = localSegmentCPU(Lab, seed, weights, maxdist, x, y);
        end
    else
        REGION = localSegmentCPU(Lab, seed, weights, maxdist, x, y);
    end

    info = localInfo(usedGPU, maxdist, weights, [x, y], ...
        useWeightedDistance, automaticParameters, nnz(REGION));
end

function REGION = localSegmentCPU(Lab, seed, weights, maxdist, x, y)
% Calcula el mapa completo de similitud de forma vectorizada.
    localWeights = cast(weights, 'like', Lab);
    thresholdSquared = cast(maxdist .* maxdist, 'like', Lab);

    dL = Lab(:, :, 1) - seed(1);
    da = Lab(:, :, 2) - seed(2);
    db = Lab(:, :, 3) - seed(3);

    distanceSquared = localWeights(1) .* (dL .* dL) + ...
                      localWeights(2) .* (da .* da) + ...
                      localWeights(3) .* (db .* db);

    candidateMask = distanceSquared < thresholdSquared;

    % Conserva unicamente el componente de 8 vecinos que contiene la semilla.
    marker = false(size(candidateMask));
    marker(x, y) = true;
    REGION = imreconstruct(marker, candidateMask, 8);
    REGION = logical(REGION);
end

function REGION = localSegmentGPU(Lab, seed, weights, maxdist, x, y)
% La parte numericamente intensiva y la reconstruccion se ejecutan en GPU.
    LabGPU = gpuArray(Lab);
    seedGPU = gpuArray(cast(seed, 'like', Lab));
    weightsGPU = gpuArray(cast(weights, 'like', Lab));
    thresholdSquaredGPU = gpuArray(cast(maxdist .* maxdist, 'like', Lab));

    dL = LabGPU(:, :, 1) - seedGPU(1);
    da = LabGPU(:, :, 2) - seedGPU(2);
    db = LabGPU(:, :, 3) - seedGPU(3);

    distanceSquared = weightsGPU(1) .* (dL .* dL) + ...
                      weightsGPU(2) .* (da .* da) + ...
                      weightsGPU(3) .* (db .* db);

    candidateMask = distanceSquared < thresholdSquaredGPU;

    marker = gpuArray(false(size(candidateMask)));
    marker(x, y) = true;
    regionGPU = imreconstruct(marker, candidateMask, 8);

    REGION = logical(gather(regionGPU));
end

function tf = localCanUseGPU()
% Compatible con versiones recientes y anteriores de MATLAB.
    tf = false;

    if exist('canUseGPU', 'file') ~= 0
        try
            tf = canUseGPU;
            return;
        catch
            % Se intenta el metodo compatible con versiones anteriores.
        end
    end

    if exist('gpuDeviceCount', 'file') ~= 0
        try
            tf = gpuDeviceCount('available') > 0;
        catch
            try
                tf = gpuDeviceCount > 0;
            catch
                tf = false;
            end
        end
    end
end

function [maxdist, weights, validSeed] = localAutomaticParameters(seed)
% Mantiene el orden y los intervalos del codigo proporcionado.
    L = double(seed(1));
    a = double(seed(2));
    b = double(seed(3));

    maxdist = 0;
    weights = [1, 1, 1];
    validSeed = true;

    if L > 29 && L < 85 && a > -5.20 && a < 15 && b > -17.58 && b < 8
        maxdist = 20;
        weights = [0.2422, 1.3760, 0.8780];
    elseif L > 0 && L < 43 && a > -7 && a < 12 && b > -10 && b < 29
        maxdist = 25;
        weights = [0.6264, 1.3282, 0.9493];
    elseif L > 0 && L < 90 && a > -130 && a < 5 && b > -130 && b < 9
        maxdist = 20;
        weights = [0.3241, 1.1672, 0.8521];
    elseif L > 0 && L < 94 && a > -26 && a < 12 && b > -26 && b < 29
        maxdist = 30;
        weights = [0.1934, 0.9295, 1.2818];
    else
        validSeed = false;
    end
end

function info = localInfo(usedGPU, maxdist, weights, seedPosition, ...
        useWeightedDistance, automaticParameters, pixelCount)
    info = struct( ...
        'UsedGPU', logical(usedGPU), ...
        'ExecutionDevice', localDeviceName(usedGPU), ...
        'MaxDistance', maxdist, ...
        'Weights', weights, ...
        'DistanceMode', localDistanceMode(useWeightedDistance), ...
        'AutomaticParameters', logical(automaticParameters), ...
        'SeedRowColumn', seedPosition, ...
        'SegmentedPixelCount', pixelCount);
end

function name = localDeviceName(usedGPU)
    if usedGPU
        name = 'GPU';
    else
        name = 'CPU';
    end
end

function mode = localDistanceMode(useWeightedDistance)
    if useWeightedDistance
        mode = 'Weighted squared Euclidean';
    else
        mode = 'Euclidean (compatible with original code)';
    end
end

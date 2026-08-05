function [BW, info] = SegmentarFrijolesLabRapido(Lab, umbral, usarGPU, areaMinima, limpiar)
%SEGMENTARFRIJOLESLABRAPIDO Segmentacion vectorizada desde una imagen CIELAB.
%
%   BW = SegmentarFrijolesLabRapido(Lab)
%   [BW,INFO] = SegmentarFrijolesLabRapido(Lab,UMBRAL,USARGPU,...
%                                           AREAMINIMA,LIMPIAR)
%
% La segmentacion utiliza la distancia cromatica respecto al fondo:
%
%   D2 = (a - aFondo)^2 + (b - bFondo)^2
%
% y evita sqrt comparando D2 directamente con UMBRAL^2. Esto separa todos
% los granos como una unica clase, independientemente de que sean negros,
% morados, rojos, amarillos, blancos, rosados o cafes.

    if nargin < 2 || isempty(umbral)
        umbral = 17;
    end
    if nargin < 3 || isempty(usarGPU)
        usarGPU = true;
    end
    if nargin < 4
        areaMinima = [];
    end
    if nargin < 5 || isempty(limpiar)
        limpiar = true;
    end

    if ~isa(Lab,'gpuArray')
        validateattributes(Lab, {'numeric'}, ...
            {'nonempty','real','nonsparse'}, mfilename, 'Lab', 1);
    end

    if ndims(Lab) ~= 3 || size(Lab,3) ~= 3
        error('SegmentarFrijolesLabRapido:ImagenLabInvalida', ...
            'Lab debe tener dimensiones filas x columnas x 3.');
    end

    validateattributes(umbral, {'numeric'}, ...
        {'scalar','real','finite','positive'}, mfilename, 'umbral', 2);
    validateattributes(usarGPU, {'numeric','logical'}, ...
        {'scalar'}, mfilename, 'usarGPU', 3);
    validateattributes(limpiar, {'numeric','logical'}, ...
        {'scalar'}, mfilename, 'limpiar', 5);

    usarGPU = logical(usarGPU);
    limpiar = logical(limpiar);

    [alto, ancho, ~] = size(Lab);

    if isempty(areaMinima)
        % Para la imagen de referencia produce aproximadamente 500 pixeles.
        % Se puede aumentar cuando existan manchas grandes en el fondo.
        areaMinima = max(100, round(double(alto) * double(ancho) * 2.5e-5));
    else
        validateattributes(areaMinima, {'numeric'}, ...
            {'scalar','real','finite','nonnegative'}, ...
            mfilename, 'areaMinima', 4);
        areaMinima = round(areaMinima);
    end

    totalTimer = tic;

    % La mediana robusta de muestras de los cuatro bordes modela el fondo.
    backgroundTimer = tic;
    [aFondo, bFondo, fondoInfo] = EstimarFondoAB(Lab, 0.03, 8);
    backgroundSeconds = toc(backgroundTimer);

    gpuDisponible = localCanUseGPU();
    gpuSolicitada = usarGPU && gpuDisponible;
    gpuUsada = false;
    gpuFallback = '';

    distanceTimer = tic;

    if gpuSolicitada
        try
            if isa(Lab,'gpuArray')
                A = single(Lab(:,:,2));
                B = single(Lab(:,:,3));
            else
                A = gpuArray(single(Lab(:,:,2)));
                B = gpuArray(single(Lab(:,:,3)));
            end

            a0 = gpuArray(single(aFondo));
            b0 = gpuArray(single(bFondo));
            t2 = gpuArray(single(umbral * umbral));

            % Operacion completamente vectorizada en GPU.
            D2 = (A - a0).^2 + (B - b0).^2;
            BW = gather(D2 > t2);
            gpuUsada = true;

            clear A B D2 a0 b0 t2
        catch ME
            gpuFallback = ME.message;
            LabCPU = localGather(Lab);
            A = single(LabCPU(:,:,2));
            B = single(LabCPU(:,:,3));
            D2 = (A - single(aFondo)).^2 + (B - single(bFondo)).^2;
            BW = D2 > single(umbral * umbral);
            clear A B D2 LabCPU
        end
    else
        LabCPU = localGather(Lab);
        A = single(LabCPU(:,:,2));
        B = single(LabCPU(:,:,3));
        D2 = (A - single(aFondo)).^2 + (B - single(bFondo)).^2;
        BW = D2 > single(umbral * umbral);
        clear A B D2 LabCPU
    end

    distanceSeconds = toc(distanceTimer);

    cleanupTimer = tic;

    if limpiar
        % Radios pequenos para preservar la forma y los bordes de los granos.
        BW = imopen(BW, strel('disk', 1, 0));
        BW = imclose(BW, strel('disk', 3, 0));
        BW = imfill(BW, 8, 'holes');

        if areaMinima > 0
            BW = bwareaopen(BW, areaMinima, 8);
        end
    end

    BW = logical(BW);
    cleanupSeconds = toc(cleanupTimer);

    % Conteo eficiente mediante componentes conectados.
    CC = bwconncomp(BW, 8);

    info = struct();
    info.ExecutionDevice = ternary(gpuUsada, 'GPU', 'CPU');
    info.GPURequested = usarGPU;
    info.GPUAvailable = gpuDisponible;
    info.GPUFallback = gpuFallback;
    info.Threshold = double(umbral);
    info.ThresholdSquared = double(umbral) ^ 2;
    info.BackgroundAB = [double(aFondo), double(bFondo)];
    info.BackgroundEstimation = fondoInfo;
    info.MinimumArea = double(areaMinima);
    info.CleanupEnabled = limpiar;
    info.ObjectCount = CC.NumObjects;
    info.ForegroundPixels = nnz(BW);
    info.ForegroundFraction = nnz(BW) / numel(BW);
    info.BackgroundEstimationSeconds = backgroundSeconds;
    info.DistanceSeconds = distanceSeconds;
    info.CleanupSeconds = cleanupSeconds;
    info.TotalSeconds = toc(totalTimer);
end

function x = localGather(x)
% gather solo se invoca cuando la entrada realmente esta en GPU.
    if isa(x,'gpuArray')
        x = gather(x);
    end
end

function tf = localCanUseGPU()
    tf = false;

    if exist('canUseGPU','file') == 2
        try
            tf = canUseGPU;
            return;
        catch
            tf = false;
        end
    end

    if exist('gpuDeviceCount','file') == 2
        try
            tf = gpuDeviceCount > 0;
        catch
            tf = false;
        end
    end
end

function value = ternary(condition, trueValue, falseValue)
    if condition
        value = trueValue;
    else
        value = falseValue;
    end
end

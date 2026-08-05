function [BW, info] = SegmentarFrijolesRapido(I, umbral, usarGPU, areaMinima, limpiar)
%SEGMENTARFRIJOLESRAPIDO Segmenta granos de distintos colores sobre fondo uniforme.
%
%   BW = SegmentarFrijolesRapido(I)
%   [BW,INFO] = SegmentarFrijolesRapido(I,UMBRAL,USARGPU,AREAMINIMA,LIMPIAR)
%
% Entradas
%   I           : imagen RGB, uint8, uint16, single o double.
%   umbral      : distancia cromatica en CIELAB a*b*. Valor inicial: 17.
%   usarGPU     : true para detectar y utilizar GPU automaticamente.
%   areaMinima  : area minima en pixeles. [] calcula un valor automatico.
%   limpiar     : true para aplicar apertura, cierre, relleno y area minima.
%
% Salidas
%   BW          : mascara logica de los granos.
%   info        : estructura con dispositivo, tiempos y parametros.
%
% Ejemplo
%   I = imread('PV-08_002.tif');
%   [BW,info] = SegmentarFrijolesRapido(I,17,true,[],true);
%   imshow(BW);
%   disp(info);
%
% Requiere Image Processing Toolbox. El uso de GPU requiere Parallel
% Computing Toolbox y una GPU compatible.

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

    validateattributes(I, {'numeric','logical'}, ...
        {'nonempty','real','nonsparse'}, mfilename, 'I', 1);

    if ndims(I) ~= 3 || size(I,3) ~= 3
        error('SegmentarFrijolesRapido:ImagenNoRGB', ...
            'La entrada I debe ser una imagen RGB de filas x columnas x 3.');
    end

    validateattributes(umbral, {'numeric'}, ...
        {'scalar','real','finite','positive'}, mfilename, 'umbral', 2);
    validateattributes(usarGPU, {'numeric','logical'}, ...
        {'scalar'}, mfilename, 'usarGPU', 3);
    validateattributes(limpiar, {'numeric','logical'}, ...
        {'scalar'}, mfilename, 'limpiar', 5);

    usarGPU = logical(usarGPU);
    limpiar = logical(limpiar);

    info = struct();
    info.GPURequested = usarGPU;
    info.GPUAvailable = localCanUseGPU();
    info.LabConversionDevice = 'CPU';
    info.LabConversionFallback = '';

    totalTimer = tic;
    conversionTimer = tic;

    % Se intenta hacer tambien la conversion RGB -> Lab en GPU. Si la
    % version de MATLAB, la memoria o el controlador no lo permiten, se
    % convierte en CPU y la distancia cromatica todavia puede usar GPU.
    if usarGPU && info.GPUAvailable
        try
            Iwork = gpuArray(im2single(I));
            Lab = rgb2lab(Iwork);
            info.LabConversionDevice = 'GPU';
            clear Iwork
        catch ME
            info.LabConversionFallback = ME.message;
            clear Iwork
            Lab = rgb2lab(im2single(I));
            info.LabConversionDevice = 'CPU';
        end
    else
        Lab = rgb2lab(im2single(I));
    end

    info.LabConversionSeconds = toc(conversionTimer);

    [BW, segmentInfo] = SegmentarFrijolesLabRapido( ...
        Lab, umbral, usarGPU, areaMinima, limpiar);

    info.Segmentation = segmentInfo;
    info.ExecutionDevice = segmentInfo.ExecutionDevice;
    info.Threshold = segmentInfo.Threshold;
    info.BackgroundAB = segmentInfo.BackgroundAB;
    info.MinimumArea = segmentInfo.MinimumArea;
    info.ObjectCount = segmentInfo.ObjectCount;
    info.ForegroundPixels = segmentInfo.ForegroundPixels;
    info.TotalSeconds = toc(totalTimer);
end

function tf = localCanUseGPU()
% Devuelve true solamente cuando MATLAB puede usar una GPU compatible.
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

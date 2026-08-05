function [aFondo, bFondo, info] = EstimarFondoAB(Lab, fraccionMargen, paso)
%ESTIMARFONDOAB Estima robustamente el fondo usando los cuatro bordes.
%
%   [aFondo,bFondo] = EstimarFondoAB(Lab)
%   [aFondo,bFondo,INFO] = EstimarFondoAB(Lab,FRACCIONMARGEN,PASO)
%
% Se extraen muestras dispersas de los bordes superior, inferior, izquierdo
% y derecho. Primero se obtiene una mediana preliminar y despues se conserva
% el 75 por ciento de las muestras cromaticamente mas cercanas. Esto reduce
% la influencia de un grano que aparezca cerca de un borde.

    if nargin < 2 || isempty(fraccionMargen)
        fraccionMargen = 0.03;
    end
    if nargin < 3 || isempty(paso)
        paso = 8;
    end

    if ~isa(Lab,'gpuArray')
        validateattributes(Lab, {'numeric'}, ...
            {'nonempty','real','nonsparse'}, mfilename, 'Lab', 1);
    end

    if ndims(Lab) ~= 3 || size(Lab,3) ~= 3
        error('EstimarFondoAB:ImagenLabInvalida', ...
            'Lab debe tener dimensiones filas x columnas x 3.');
    end

    validateattributes(fraccionMargen, {'numeric'}, ...
        {'scalar','real','finite','>',0,'<=',0.25}, ...
        mfilename, 'fraccionMargen', 2);
    validateattributes(paso, {'numeric'}, ...
        {'scalar','real','finite','integer','positive'}, ...
        mfilename, 'paso', 3);

    [alto, ancho, ~] = size(Lab);
    margen = round(min(alto, ancho) * fraccionMargen);
    margen = max(10, margen);
    margen = min(margen, floor(min(alto, ancho) / 4));

    A = Lab(:,:,2);
    B = Lab(:,:,3);

    filasSup = 1:paso:margen;
    filasInf = (alto - margen + 1):paso:alto;
    colsIzq = 1:paso:margen;
    colsDer = (ancho - margen + 1):paso:ancho;
    todasFilas = 1:paso:alto;
    todasCols = 1:paso:ancho;

    a1 = localGather(A(filasSup, todasCols));
    a2 = localGather(A(filasInf, todasCols));
    a3 = localGather(A(todasFilas, colsIzq));
    a4 = localGather(A(todasFilas, colsDer));

    b1 = localGather(B(filasSup, todasCols));
    b2 = localGather(B(filasInf, todasCols));
    b3 = localGather(B(todasFilas, colsIzq));
    b4 = localGather(B(todasFilas, colsDer));

    muestrasA = single([a1(:); a2(:); a3(:); a4(:)]);
    muestrasB = single([b1(:); b2(:); b3(:); b4(:)]);

    validas = isfinite(muestrasA) & isfinite(muestrasB);
    muestrasA = muestrasA(validas);
    muestrasB = muestrasB(validas);

    if numel(muestrasA) < 16
        error('EstimarFondoAB:MuestrasInsuficientes', ...
            'No se obtuvieron suficientes muestras validas del fondo.');
    end

    aInicial = median(muestrasA);
    bInicial = median(muestrasB);

    D2 = (muestrasA - aInicial).^2 + (muestrasB - bInicial).^2;
    [~, orden] = sort(D2, 'ascend');

    cantidadConservada = max(16, floor(0.75 * numel(orden)));
    indices = orden(1:cantidadConservada);

    aFondo = median(muestrasA(indices));
    bFondo = median(muestrasB(indices));

    info = struct();
    info.MarginPixels = margen;
    info.SampleStep = paso;
    info.TotalSamples = numel(muestrasA);
    info.RetainedSamples = cantidadConservada;
    info.InitialAB = [double(aInicial), double(bInicial)];
    info.FinalAB = [double(aFondo), double(bFondo)];
end

function x = localGather(x)
    if isa(x,'gpuArray')
        x = gather(x);
    end
end

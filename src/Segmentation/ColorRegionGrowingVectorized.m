function REGION = ColorRegionGrowingVectorized(I, Lab, maxdist, x, y)
    [rows, cols, ~] = size(I);
    REGION = false(rows, cols);
    
    % --- Configuración Inicial ---
    if nargin < 4 || isempty(x) || isempty(y)
        % (Mantenemos la selección de punto si es necesario)
        imshow(I); [y_c, x_c] = getpts(gcf);
        x = round(x_c(1)); y = round(y_c(1));
    end
    
    % Obtener parámetros (pesos y maxdist)
    [w, maxdist] = obtenerParametros(squeeze(Lab(x,y,:)), maxdist);
    
    % --- Pre-cálculo de Distancia (Paso Crítico de Rendimiento) ---
    % Calculamos la distancia de TODA la imagen al pixel semilla de una vez.
    % Esto es mucho más rápido que calcularlo pixel por pixel en un bucle.
    dL = (Lab(:,:,1) - Lab(x,y,1)).^2;
    dA = (Lab(:,:,2) - Lab(x,y,2)).^2;
    dB = (Lab(:,:,3) - Lab(x,y,3)).^2;
    
    % Mapa de candidatos: píxeles que CUMPLEN la condición de color
    DIST_MAP = sqrt(w(1)*dL + w(2)*dA + w(3)*dB);
    CANDIDATOS = DIST_MAP < maxdist;
    
    % --- Crecimiento por Componentes Conectados ---
    % De todos los candidatos, solo queremos los que están conectados a (x,y)
    % bwselect es extremadamente rápido para esta tarea específica.
    REGION = bwselect(CANDIDATOS, y, x, 8); 
end

function [w, d] = obtenerParametros(SEED, d)
    % Lógica de pesos original encapsulada
    L = SEED(1); A = SEED(2); B = SEED(3);
    w = [1 1 1];
    if d == 0
        if (L>29 && L<85) && (A>-5.2 && A<15) && (B>-17.58 && B<8)
            d = 20; w = [0.2422, 1.3760, 0.8780];
        elseif (L>0 && L<43) && (A>-7 && A<12) && (B>-10 && B<29)
            d = 25; w = [0.6264, 1.3282, 0.9493];
        % ... (agregar el resto de tus condiciones aquí)
        else
            d = 20; % Default
        end
    end
end
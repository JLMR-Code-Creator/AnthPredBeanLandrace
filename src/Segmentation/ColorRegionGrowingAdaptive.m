function REGION = ColorRegionGrowingAdaptive(I, Lab, maxdist, x, y)
    [rows, cols, ~] = size(I);
    REGION = false(rows, cols);
    visitados = false(rows, cols);
    
    % 1. Manejo de semilla
    if nargin < 4 || isempty(x) || isempty(y)
        h1 = figure('Name', 'Selección de Semilla'); imshow(I);
        [y_c, x_c] = getpts(h1); x = round(x_c(1)); y = round(y_c(1)); close(h1);
    end

    % 2. Inicialización de la Media de la Región
    % La media inicial es el color del píxel semilla
    media_region = squeeze(Lab(x, y, :))'; 
    num_pixeles = 1;

    % 3. Preparación de la Cola (Queue)
    max_pts = rows * cols;
    queue = zeros(max_pts, 2);
    head = 1; tail = 1;

    queue(tail, :) = [x, y];
    tail = tail + 1;
    REGION(x, y) = true;
    visitados(x, y) = true;

    neigb = [-1, 0; 1, 0; 0, -1; 0, 1]; % 4-conectividad es más precisa para gradientes

    % --- Bucle de Crecimiento Adaptativo ---
    while head < tail
        currX = queue(head, 1);
        currY = queue(head, 2);
        head = head + 1;

        for i = 1:4
            xn = currX + neigb(i, 1);
            yn = currY + neigb(i, 2);

            if xn >= 1 && xn <= rows && yn >= 1 && yn <= cols && ~visitados(xn, yn)
                
                % COMPARACIÓN CONTRA LA MEDIA DE LA REGIÓN
                pixel_color = squeeze(Lab(xn, yn, :))';
                diff = pixel_color - media_region;
                dist_eucl = sqrt(sum(diff.^2));

                if dist_eucl < maxdist
                    REGION(xn, yn) = true;
                    queue(tail, :) = [xn, yn];
                    tail = tail + 1;
                    
                    % ACTUALIZACIÓN DINÁMICA DE LA MEDIA
                    % Esto permite que la "firma de color" evolucione con el objeto
                    num_pixeles = num_pixeles + 1;
                    media_region = media_region + (pixel_color - media_region) / num_pixeles;
                end
                visitados(xn, yn) = true;
            end
        end
        
        % Optimización: Si la región es muy grande, podrías actualizar la media 
        % cada N píxeles para ganar velocidad, pero la fórmula anterior es muy eficiente.
    end
    
    REGION = imfill(REGION, 'holes');
end
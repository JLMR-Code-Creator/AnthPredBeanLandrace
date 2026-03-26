function REGION = ColorRegionGrowing2Lab(I, Lab, maxdist, x, y)
    % Optimización: Uso de buffer circular para la cola y vectorización
    
    I = im2double(I);
    [rows, cols, ~] = size(I);
    
    % Manejo de entrada interactiva
    if nargin < 4 || isempty(x) || isempty(y)
        h1 = figure('Name', 'Seleccione Semilla', 'NumberTitle', 'off');
        imshow(I);
        [y_click, x_click] = getpts(h1);
        x = round(x_click(1));
        y = round(y_click(1));
        close(h1);
    end

    SEED = squeeze(Lab(x, y, :)); % Vector 3x1 para facilitar cálculos
    
    % Lógica de pesos y distancias (Se mantiene tu lógica original)
    w = [1, 1, 1]; % Pesos por defecto
    if maxdist == 0
        % Simplificación de la lógica de umbrales para legibilidad
        L = SEED(1); A = SEED(2); B = SEED(3);
        
        if (L > 29 && L < 85) && (A > -5.2 && A < 15) && (B > -17.58 && B < 8)
            maxdist = 20; w = [0.2422, 1.3760, 0.8780];
        elseif (L > 0 && L < 43) && (A > -7 && A < 12) && (B > -10 && B < 29)
            maxdist = 25; w = [0.6264, 1.3282, 0.9493];
        elseif (L > 0 && L < 90) && (A > -130 && A < 5) && (B > -130 && B < 9)
            maxdist = 20; w = [0.3241, 1.1672, 0.8521];
        elseif (L > 0 && L < 94) && (A > -26 && A < 12) && (B > -26 && B < 29)
            maxdist = 30; w = [0.1934, 0.9295, 1.2818];
        else
            msgbox('Intente con nueva semilla. Fondo sugerido: negro, blanco o azul claro.');
            REGION = false(rows, cols);
            return;
        end
    end

    % --- SEGMENTACIÓN OPTIMIZADA ---
    REGION = false(rows, cols); 
    visitados = false(rows, cols);
    
    % Pre-asignación de memoria para la cola (Evita realocación lenta)
    % Usamos un tamaño máximo estimado, si se llena se puede redimensionar
    max_pts = rows * cols;
    queue = zeros(max_pts, 2);
    head = 1;
    tail = 1;

    % Insertar semilla
    queue(tail, :) = [x, y];
    tail = tail + 1;
    REGION(x, y) = true;
    visitados(x, y) = true;

    % Vecindad 8 (Vectorizada para mayor rapidez)
    neigb = [-1, -1; -1, 0; -1, 1; 0, -1; 0, 1; 1, -1; 1, 0; 1, 1];

    while head < tail
        % Extraer pixel actual
        currX = queue(head, 1);
        currY = queue(head, 2);
        head = head + 1;

        for i = 1:8
            xn = currX + neigb(i, 1);
            yn = currY + neigb(i, 2);

            % Verificación de límites y si ya fue visitado
            if xn >= 1 && xn <= rows && yn >= 1 && yn <= cols && ~visitados(xn, yn)
                
                % Cálculo de distancia Euclidiana ponderada
                % Nota: En tu código original 'ac' se sobreescribía ignorando los pesos.
                % He aplicado los pesos (w) según tus condiciones iniciales.
                diff = squeeze(Lab(xn, yn, :)) - SEED;
                dist_sq = w(1)*diff(1)^2 + w(2)*diff(2)^2 + w(3)*diff(3)^2;
                
                if sqrt(dist_sq) < maxdist
                    REGION(xn, yn) = true;
                    queue(tail, :) = [xn, yn];
                    tail = tail + 1;
                end
                visitados(xn, yn) = true; % Marcar como visitado para no procesar de nuevo
            end
        end
    end
end
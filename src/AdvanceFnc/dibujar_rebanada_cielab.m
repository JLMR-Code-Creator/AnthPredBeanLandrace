function dibujar_rebanada_cielab(L, hue_rango)
% DIBUJAR_REBANADA_CIELAB Dibuja un círculo CIELAB y resalta una rebanada de color.
%   L: Valor de luminosidad (0 a 100)
%   hue_rango: Vector de dos elementos [hue_inicio, hue_fin] en grados

% Parámetros fijos del círculo
r = 40;           % Radio en el plano a*b*
num_points = 360; % Resolución del círculo

% 1. Generar el círculo completo de fondo
theta_ciclo = linspace(0, 2*pi, num_points);
a_ciclo = r * cos(theta_ciclo);
b_ciclo = r * sin(theta_ciclo);
Lab_ciclo = [repmat(L-20, num_points, 1), a_ciclo', b_ciclo'];
RGB_ciclo = lab2rgb(Lab_ciclo);

% Abrir figura y graficar círculo base desvanecido
figure;
scatter(a_ciclo, b_ciclo, r, RGB_ciclo, 'filled', 'MarkerEdgeAlpha', 0.1, 'MarkerFaceAlpha', 0.15);
hold on;

% 2. Generar y rellenar la rebanada (Slice) solicitada
h1 = hue_rango(1);
h2 = hue_rango(2);

% Manejar el caso si el rango cruza los 360 grados
if h2 < h1
    theta_rebanada = h1:360;
    theta_rebanada = [theta_rebanada, 0:h2];
else
    theta_rebanada = h1:h2;
end

% Asegurar que sea vector fila para la geometría del polígono
theta_rebanada = deg2rad(theta_rebanada(:)');

% Coordenadas del sector circular (comienza en el origen, barre el arco, vuelve al origen)
a_reb = [0; (r * cos(theta_rebanada))'; 0];
b_reb = [0; (r * sin(theta_rebanada))'; 0];

% Muestrear colores exactos del arco periférico (filas por vértice)
Lab_reb = [repmat(L, length(theta_rebanada), 1), (r * cos(theta_rebanada))', (r * sin(theta_rebanada))'];
RGB_reb = lab2rgb(Lab_reb);

% Color en el centro (origen) basado en la luminosidad L pura sin croma
RGB_centro = lab2rgb([L, 0, 0]);

% Construir matriz de color asignando un color RGB (fila) a cada vértice coordenado
RGB_parche = [RGB_centro; RGB_reb; RGB_centro];

% Dibujar la rebanada con interpolación de color activada ('interp')
vertices = [a_reb, b_reb];
faces = 1:size(vertices,1);
patch('Vertices', vertices, ...
    'Faces', faces, ...
    'FaceVertexCData', RGB_parche, ...
    'FaceColor', 'interp', ...
    'EdgeColor', 'none');


% 3. Dibujar las líneas negras límite desde el centro
plot([0, r*cos(deg2rad(h1))], [0, r*sin(deg2rad(h1))], 'k-', 'LineWidth', 2);
plot([0, r*cos(deg2rad(h2))], [0, r*sin(deg2rad(h2))], 'k-', 'LineWidth', 2);

% 4. Agregar números de ángulo de tono en el exterior
label_intervals = 0:30:330;
label_radius = r + 5;

for deg = label_intervals
    rad = deg2rad(deg);
    x_pos = label_radius * cos(rad);
    y_pos = label_radius * sin(rad);

    % Alineación dinámica del texto
    if cos(rad) > 0.1, ha = 'left'; elseif cos(rad) < -0.1, ha = 'right'; else, ha = 'center'; end
    if sin(rad) > 0.1, va = 'bottom'; elseif sin(rad) < -0.1, va = 'top'; else, va = 'middle'; end

    % Resaltar en negrita si es uno de los extremos del intervalo o cae dentro
    if deg == h1 || deg == h2
        txt_weight = 'bold';
        txt_color = 'r'; % Rojo para marcar tus límites exactos
    else
        txt_weight = 'normal';
        txt_color = 'k';
    end

    text(x_pos, y_pos, sprintf('%d^{\\circ}', deg), ...
        'HorizontalAlignment', ha, ...
        'VerticalAlignment', va, ...
        'FontSize', 10, ...
        'FontWeight', txt_weight, ...
        'Color', txt_color);
end

% 5. Formato de la gráfica
axis equal;
xlabel('a* (Verde a Rojo)');
ylabel('b* (Azul a Amarillo)');
title(sprintf('CIELAB (L^* = %d, Rango: %d^{\\circ} a %d^{\\circ})', L, h1, h2));
grid on;

% Centrar ejes en (0,0)
set(gca, 'XAxisLocation', 'origin', 'YAxisLocation', 'origin');
axis([-label_radius-10, label_radius+10, -label_radius-10, label_radius+10]);
hold off;
end

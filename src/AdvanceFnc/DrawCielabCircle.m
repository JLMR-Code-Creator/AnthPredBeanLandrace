% Define parameters for the CIELAB circle
L = 70;           % Lightness (0 to 100)
r = 40;           % Radius in the a*b* plane
num_points = 360; % Number of colors/segments

% Generate angles and corresponding a* and b* values
theta = linspace(0, 2*pi, num_points);
a = r * cos(theta);
b = r * sin(theta);

% Create the L*a*b* array [L, a, b]
Lab_colors = [repmat(L, num_points, 1), a', b'];

% Convert CIELAB to sRGB (RGB values will be between 0 and 1)
RGB_colors = lab2rgb(Lab_colors);

% Plot the points as a filled circle using scatter
figure;
scatter(a, b, 50, RGB_colors, 'filled');
hold on;

% Add hue angle numbers on the outside of the circle
label_intervals = 0:30:330; % Place labels every 30 degrees
label_radius = r + 5;       % Offset labels slightly outside the circle radius

for deg = label_intervals
    % Convert degree to radians for positioning
    rad = deg2rad(deg);
    x_pos = label_radius * cos(rad);
    y_pos = label_radius * sin(rad);

    % Determine text alignment to prevent overlap
    if cos(rad) > 0.1
        ha = 'left';
    elseif cos(rad) < -0.1
        ha = 'right';
    else
        ha = 'center';
    end

    if sin(rad) > 0.1
        va = 'bottom';
    elseif sin(rad) < -0.1
        va = 'top';
    else
        va = 'middle';
    end

    % Print the angle number
    text(x_pos, y_pos, sprintf('%d^{\\circ}', deg), ...
        'HorizontalAlignment', ha, ...
        'VerticalAlignment', va, ...
        'FontSize', 10, ...
        'FontWeight', 'bold');
end

% Formatting the plot
axis equal;
xlabel('a* (Green to Red)');
ylabel('b* (Blue to Yellow)');
title(sprintf('CIELAB Color Circle with Hue Angles (L^* = %d)', L));
grid on;

% Center axes at (0,0) and adjust limits to fit labels
set(gca, 'XAxisLocation', 'origin', 'YAxisLocation', 'origin');
axis([-label_radius-10, label_radius+10, -label_radius-10, label_radius+10]);

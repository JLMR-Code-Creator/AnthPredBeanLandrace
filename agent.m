opts = {'Visualizar histograma 2D de población de frijol','Remove','Update'};
f = @(s) fprintf('You chose: %s\n', s);
chooseOptionAndCall('Select action', opts, f);
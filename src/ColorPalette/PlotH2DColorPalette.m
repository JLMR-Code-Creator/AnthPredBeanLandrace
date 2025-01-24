function PlotH2DColorPalette(pathMAT, target)
mat_file = dir(strcat(pathMAT,'*.mat')); % Load set of files                     
color_Palette_ab = [];
color_Palette_Lab = [];
num_elements_of_H2D = 65536;
labels = {};

splitLabel = split(mat_file(1).folder, '\');
clase =  splitLabel{3};
parfor k = 1:length(mat_file)
    archivo = mat_file(k).name;         % Name of image
    db = load(strcat(pathMAT,archivo), '-mat'); % Load file mask
    % histograma 2D convert of matrix to array
    pixLab = db.Lab_Values;
    [cie_ab, cie_la, cie_lb, ~] = Pixel2DABLALB(pixLab);
    cieab = reshape(cie_ab, num_elements_of_H2D, 1)';
    ciela = reshape(cie_la, num_elements_of_H2D, 1)';
    cielb = reshape(cie_lb, num_elements_of_H2D, 1)';
    color_Palette_ab = [color_Palette_ab;cieab];
    colorDistribution = [cieab, ciela, cielb];
    color_Palette_Lab = [color_Palette_Lab; colorDistribution];
    labels = [labels; clase];
end % end for matfiles

file = strcat(target, splitLabel{3});
save(file, "color_Palette_Lab", "labels", "color_Palette_ab", '-v7.3');
% reduction of dimensionallity

% X =  color_Palette_ab;
% y = categorical(labels);
% classifier = fitcdiscr(X,y);
% 
% labels = categories(y);
% 
% predicted = predict(classifier,X);
% x1range = 0:.01:1;
% x2range = 0:.01:1;
% [xx1, xx2] = meshgrid(x1range,x2range);
% 
% figure();
% gscatter(xx1(:), xx2(:), predicted,'rgb');
% 
% title('Plot')
% legend off, axis tight
% 
% legend(labels,'Location',[0.35,0.01,0.35,0.05],'Orientation','Horizontal')

end


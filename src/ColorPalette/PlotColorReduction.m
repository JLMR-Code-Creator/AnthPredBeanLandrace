function PlotColorReduction(pathMAT, target)
    mat_file = dir(strcat(pathMAT,'*.mat')); % Cargar mascara de cada poblaci?n
    color_Palette_ab = [];
    color_Palette_Lab = [];
    labels = [];
    for k = 1:length(mat_file)   
        archivo = mat_file(k).name;         % Name of image
        db = load(strcat(pathMAT,archivo), '-mat'); % Load file mask
        color_Palette_ab = [color_Palette_ab; db.color_Palette_ab];
        color_Palette_Lab = [color_Palette_Lab; db.color_Palette_Lab];
        lbls = categorical(cellstr(db.labels{1}));
        labels = [labels; lbls];
    end

 X =  color_Palette_ab;
 y = categorical(labels);
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


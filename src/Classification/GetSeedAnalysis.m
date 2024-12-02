function  GetSeedAnalysis(pathImg, target)
    matfile = dir(strcat(pathImg,'Masks/*.mat'));                       % Cargar mascara de cada poblaci?n
     for k = 1:length(matfile)   
       archivo = matfile(k).name;        % Nombre del imagen
       populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
       nombre=strcat(pathImg,'Masks/');
       L = load(strcat(nombre,archivo)); % Carga el archivo de la m?scara        
       Mask = uint8(L.Mask);
       Mask = ~Mask;   
       % Limpieza de pixeles
       % Clean up small groups pixels
       [ML, ~]=bwlabel(Mask);         % Etiquetar granos de frijol conectados
       propied= regionprops(ML);      % Calcular propiedades de los objetos de la imagen
       s=find([propied.Area] < 1000); % grupos menores a 100 px
       for i1=1:size(s,2)              % eliminaci�n de pixeles
           index = ML == s(i1);
           Mask(index) = 0;
       end

       [ML, N] = bwlabel(Mask);         % Etiquetar granos de frijol conectados       
       propied = regionprops(ML);      % Calcular propiedades de los objetos de la imagen
       I = imread(strcat(pathImg,populationName,'.tif'));
       [I_Lab] = RGB2PCS(I, pathImg, strcat(populationName, '.tif'));
       I = uint8(I/256);
       figure('WindowState', 'maximized');       
       imshow(I);
       set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
       hold on;
       ML = uint8(ML);
       for i2=1:size(propied,1)              % eliminaci�n de pixeles           
          %drawrectangle('Position',propied(i).BoundingBox, LineWidth=0.5,MarkerSize=0.1,Color='r',Label=num2str(ML(round(propied(i).Centroid(2)),round(propied(i).Centroid(1)))));
          text(round(propied(i2).Centroid(1)),round(propied(i2).Centroid(2)),num2str(ML(round(propied(i2).Centroid(2)),round(propied(i2).Centroid(1)))),'FontSize',10,'color','red');
       end  

       prompt = {'Introduce los numeros','Enter colormap name:'};
       dlgtitle = 'Input';
       fieldsize = [1 45; 1 45];
       definput = {'',''};
       answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
       if isempty(answer)
           close all;
           continue;
       end
       a = answer{1};% list of numbers
       objects = split(a, ',');
       class = answer{2};
       
       
       for i3=1:length(objects)
          seedValue =  uint8(str2num(objects{i3})); 
          seeds = 1:N;
          seeds = uint8(seeds);
          seeds(seeds==seedValue) = [];
          Mask_tmp = Mask; 
          for j1=1:length(seeds)
            value = seeds(j1);
            index = ML == value;
            Mask_tmp(index) = 0;
          end
          Mask_tmp = ~Mask_tmp;
          [Lab_Values,~ ]= ROILab(I_Lab, Mask_tmp);
          %Lab_Values = Lab_Values';

          % remove outliers in 3D point data
          distance = sqrt(sum(Lab_Values.^2,2));
          indices = distance<(mean(distance)+std(distance)); %note I use smaller than instead of bigger
          remainingPoints = Lab_Values(indices,:);          

          % plot to 3D points
          PixelValues  =  remainingPoints'
          cform = makecform('lab2srgb','AdaptedWhitePoint',whitepoint('D65'));
          RGB = applycform(remainingPoints,cform); %3x....
          figure();
          scatter3(PixelValues(3,:),PixelValues(2,:),PixelValues(1,:),12,RGB,'fill');
          xlabel('b*'),ylabel('a*'),zlabel('L*');
          
          % Building bidimensional histograms 
          [cie_ab, cie_la, cie_lb, pixels] = Pixel2DABLALB(remainingPoints)
          figure; mesh(cie_lb);

          % apply gaussian filter with sigma = 3
          Iblur = imgaussfilt(cie_lb, 3);
          figure(); mesh(Iblur);
          
          % Sumas de filas de la matriz
          aabb= sum(Iblur');
          [pks, locs] = findpeaks(abs(aabb))
      
          % Find K-Nearest Neighbors in a Point Cloud
          ptCloud = pointCloud(pixels);
          point = [128,128,128];
          K = length(pks);
          [indices,dists] = findNearestNeighbors(ptCloud,point,K);
          figure();
          %pcshow(ptCloud)
          coorLAB = ptCloud.Location';
          scatter3(coorLAB(3,:),coorLAB(2,:),coorLAB(1,:),12,RGB,'fill');
          xlabel('b*'),ylabel('a*'),zlabel('L*');
          hold on
          scatter3(point(1),point(2),point(3),'or')
          scatter3(ptCloud.Location(indices,1),ptCloud.Location(indices,2),ptCloud.Location(indices,3),'*')
          legend('Point Cloud','Query Point','Nearest Neighbors','Location','southoutside','Color',[1 1 1])
          hold off

       end % end for objects
       close all;
     end % end for matfiles

end

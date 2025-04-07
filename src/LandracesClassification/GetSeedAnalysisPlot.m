function  GetSeedAnalysisPlot(pathImg, target)
    matfile = dir(strcat(pathImg,'Masks/*.mat'));    
    % Cargar mascara de cada poblaci?n
    % Folder tmp for validate name to each seed landraces
    folderLandraces = strcat(pathImg, '/tmpImages');
    if ~exist(folderLandraces, 'dir')
        mkdir(folderLandraces)
    end    
    [fitcknn_Models] = KNNModels(train_lab, classes);
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
       propied = regionprops(ML);       % Calcular propiedades de los objetos de la imagen
       I = imread(strcat(pathImg,populationName,'.tif'));
       [I_Lab] = RGB2PCS(I, pathImg, strcat(populationName, '.tif'));
       I = uint8(I/256);
       figure('WindowState', 'maximized');       
       imshow(I);
       set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
       hold on;
       ML = uint8(ML);
       for i2 = 1 : size(propied,1)              % eliminaci�n de pixeles           
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
          
          %plot3dpoints(Lab_Values);

          % remove outliers in 3D point data of seed bean
          distance = sqrt(sum(Lab_Values.^2, 2));
          indices = distance < (mean(distance) + std(distance)); %note I use smaller than instead of bigger
          remainingPoints = Lab_Values(indices, :);          

          plot3dpoints(remainingPoints);
          
         
          %[cie_ch, cie_lc, cie_lh, c1] = Pixels2Hist2DCHLCLH(remainingPoints);
          %figure; mesh(cie_lc);

          figure();
          v_x_axis = 1:25;
          a = histogram(remainingPoints(:,1),25);
          %figure();plot(a.Values);
          aabb = a.Values;
          [pks, locs] = findpeaks(abs(aabb), v_x_axis)
          figure();
          hold on;
          plot(aabb)
          plot(locs,pks,'rx');
          hold off;

         
          K = length(pks);
          pix = remainingPoints;%[remainingPoints(:,1),remainingPoints(:,3)];
          GMModel = fitgmdist(pix, K);
          %pix = [remainingPoints(:,1),remainingPoints(:,3)];
          %figure();scatter(pix(:,1),pix(:,2),10,'.') % Scatter plot with points of size 10
          %hold on
          %gmPDF = @(x,y) arrayfun(@(x0,y0) pdf(GMModel,[x0 y0]),x,y);
          %fcontour(gmPDF,[1 200])

          idx = cluster(GMModel,pix);
          figure();          
          unicos = unique(idx);
          hold on;
          for i=1:length(unicos)
            scatter3(remainingPoints(idx==i, 3),remainingPoints(idx==i, 2),remainingPoints(idx==i, 1),12,'fill')    
            xlabel('b*'),ylabel('a*'),zlabel('L*');
          end
          hold off;          
          
          % Histograms
          
          unicos = unique(idx);
          for i=1:length(unicos)
            dataPixeles = remainingPoints(idx==i, :);
            [cie_ab, cie_la, cie_lb, pixels] = Pixel2DABLALB(dataPixeles);
            figure(); mesh(cie_lb);                      
          end
          
            K = length(pks)
            if (K > 1) 
                pix = remainingPoints;
                GMModel = fitgmdist(pix, K);
                idx = cluster(GMModel,pix);
                unicos = unique(idx);
                [~, idxCategories] = sortArrayElements(idx);
                tmpName = {};
                totalPixels = size(remainingPoints, 1); % size all pixels
                %% Pixels distribution
                for i=1:length(unicos)
                    valIdx = str2double(idxCategories{i});
                    dataPixeles = remainingPoints(idx==valIdx, :);
                    if (size(dataPixeles, 1) / totalPixels) <= 0.10
                        continue;
                    end
                    [cie_ab, cie_la, cie_lb, ~] = Pixel2DABLALB(dataPixeles);
                    sizelab = size(cie_ab, 1) * size(cie_ab, 2);
                    cie_ab_e = reshape(cie_ab, sizelab, 1)';
                    cie_la_e = reshape(cie_la, sizelab, 1)';
                    cie_lb_e = reshape(cie_lb, sizelab, 1)';
                    seed_test_lab =  [cie_ab_e, cie_la_e, cie_lb_e];
                    clase_lab = KNNPrediction(fitcknn_Models, seed_test_lab);                    
                    Final_Lab_Values = [Final_Lab_Values; dataPixeles]; % Array of data colors
                    %% If class does not exist                       
                    if ~any(strcmp(tmpName,clase_lab)) 
                        tmpName = [tmpName; clase_lab];
                        if isempty(nameClassLandraces)
                           nameClassLandraces = strcat(nameClassLandraces, clase_lab);
                        else
                            nameClassLandraces = strcat(nameClassLandraces, '-', clase_lab);
                        end

                        listClasses = [listClasses; clase_lab]; 
                    end               
                end % end for
            else % Only one distribution
                [cie_ab, cie_la, cie_lb, ~] = Pixel2DABLALB(remainingPoints);
                sizelab = size(cie_ab, 1) * size(cie_ab, 2);
                cie_ab_e = reshape(cie_ab, sizelab, 1)';
                cie_la_e = reshape(cie_la, sizelab, 1)';
                cie_lb_e = reshape(cie_lb, sizelab, 1)';
                seed_test_lab =  [cie_ab_e, cie_la_e, cie_lb_e];
                clase_lab = KNNPrediction(fitcknn_Models, seed_test_lab);
                listClasses = [listClasses; clase_lab];              % label by different data color
                nameClassLandraces = clase_lab;
                Final_Lab_Values = [Final_Lab_Values; remainingPoints];  % Array of data colors

            end



            fileName = strcat(folderLandraces,'/',num2str(i3), string(nameClassLandraces));  
            Mask_tmp = ~Mask_tmp;
            [subimage] = cutImage(I,uint8(Mask_tmp));
            imwrite(subimage,strcat(fileName,".png"));           
          

       end % end for objects
       close all;
     end % end for matfiles

end

function plot3dpoints(remainingPoints)
   % plot to 3D points
   PixelValues  =  remainingPoints'
   cform = makecform('lab2srgb','AdaptedWhitePoint',whitepoint('icc'));
   RGB = applycform(remainingPoints,cform); %3x....
   figure();
   scatter3(PixelValues(3,:),PixelValues(2,:),PixelValues(1,:),12,RGB,'fill');
   xlabel('b*'),ylabel('a*'),zlabel('L*');
end

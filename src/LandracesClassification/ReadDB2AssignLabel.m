function ReadDB2AssignLabel(pathDB, pathImg1, nameDataSet)
   % firts step, read path of DB allocate
   [train_lab, train_median_lab, clase, train_ab] = loadTrainDataandClases(pathDB, nameDataSet);
   % Second step, load each landraces for classify grain and get superclase
   [clases]=iteraPoblacion(pathImg1, train_lab, train_median_lab, clase, train_ab);

end

function [clases]=iteraPoblacion(pathImg, train_lab, train_median_lab, clase, train_ab)
    %% loop to each landraces
    matfile = dir(strcat(pathImg,'Masks/*.mat'));  
    % checking if the dorectory exist
    folderClases = strcat(pathImg, 'Clases');
    if ~exist(folderClases, 'dir')
       mkdir(folderClases)
    end

    for ik = 1:length(matfile)             
        archivo = matfile(ik).name;        % File name
        populationName = strrep(archivo,'.mat','');
        rutadbFile = strcat(folderClases,filesep, populationName,'.mat');
        if isfile(rutadbFile)
            continue;
        end
        disp([datestr(datetime), ' Procesando poblacion ',populationName]);
        nombre=strcat(pathImg,'Masks/');
        L = load(strcat(nombre,populationName)); % load file mask
        Mask = L.Mask;
        disp([datestr(datetime), ' Procesando población ',populationName]);
        % Read each seed for classify
        Mask = ~Mask; % We verify that ROI has zero values for the correct labeled  
        % Clean up small groups pixels
        [ML, ~]=bwlabel(Mask);          % Etiquetar granos de frijol conectados
        propied= regionprops(ML);       % Calcular propiedades de los objetos de la imagen
        s=find([propied.Area] < 1000);  % grupos menores a 100 px
        for i1=1:size(s,2)              % eliminación de pixeles
            index = ML == s(i1);
            Mask(index) = 0;
        end
        
        [ML, N] = bwlabel(Mask);         % Etiquetar granos de frijol conectados       
        propied = regionprops(ML);      % Calcular propiedades de los objetos de la imagen
        I = imread(strcat(pathImg,populationName,'.tif'));
        [I_Lab] = RGB2PCS(I, pathImg, strcat(populationName, '.tif'));
        I = uint8(I/256); %% 16 to 8 bits 
        listClasses = {};
        Final_Lab_Values = []; %para el almacenamiento del conjunto de pixels
        se = strel("disk",15);
        M = Mask;
        Mask = imerode(M,se);
       %imshow(BW3)

        %% Folder tmp for validate name to each seed landraces
        folderLandraces = strcat(pathImg, populationName);
        if ~exist(folderLandraces, 'dir')
            mkdir(folderLandraces)
        end
         
        for i3=1:N % In each grain get the class
            seeds = 1:N;
            seedValue =  i3;
            seeds(seeds==seedValue) = [];
            Mask_tmp = Mask; 
            for j1=1:length(seeds)
                value = seeds(j1);
                index = ML == value;
                Mask_tmp(index) = 0;
            end

            Mask_tmp = ~Mask_tmp;
            [Lab_Values,~ ]= ROILab(I_Lab, Mask_tmp);

            % remove outliers in 3D point data of seed bean
            distance = sqrt(sum(Lab_Values.^2, 2));
            indices = distance < (median(distance)+ std(distance)); %note I use smaller than instead of bigger
            remainingPoints = Lab_Values(indices, :);          

            v_x_axis = 1:25;
            [counts, edges] = histcounts(remainingPoints(:,1), 25);
            %a = histogram(remainingPoints(:,1),25);
            %figure();plot(a.Values);
         
            [pks, locs] = findpeaks(abs(counts), v_x_axis, ...
                'MinPeakDistance',v_x_axis(5));
        
            K = length(pks)
            pix = remainingPoints;
            GMModel = fitgmdist(pix, K);

            idx = cluster(GMModel,pix);
            unicos = unique(idx)
            nameClassLandraces = '';
            totalPixels = size(remainingPoints, 1);
            for i=1:length(unicos)
                dataPixeles = remainingPoints(idx==i, :);
                if (size(dataPixeles, 1) / totalPixels)<=.10
                    continue;
                end
                [cie_ab, cie_la, cie_lb, pixels] = Pixel2DABLALB(dataPixeles);
                sizelab = size(cie_ab, 1) * size(cie_ab, 2);
                cie_ab_e = reshape(cie_ab, sizelab, 1)';
                %cie_la_e = reshape(cie_la, sizelab, 1)';
                %cie_lb_e = reshape(cie_lb, sizelab, 1)';
                %seed_test_lab =  [cie_ab_e, cie_la_e, cie_lb_e];
                seed_test_lab =  cie_ab_e;
                [clase_lab] = KNNEvaluation(train_ab, seed_test_lab, clase, 51); 
                listClasses = [listClasses; clase_lab];
                nameClassLandraces = strcat(nameClassLandraces, '-', clase_lab);
                Final_Lab_Values = [Final_Lab_Values; dataPixeles];
            end
            %% Guardar la imagen de la semilla para validar etiqueta
              fileName = strcat(folderLandraces,'/',num2str(i3), string(nameClassLandraces));  
              Mask_tmp = ~Mask_tmp;
              [subimage] = cutImage(I,uint8(Mask_tmp));
              imwrite(subimage,strcat(fileName,".png"));  
        end % for i3
        % Get class label using K-NN algorith
        % quantification of grain for coloration
        categoricItems = categorical(listClasses);
        ClassCategories = categories(categoricItems);
        Classquatities = countcats(categoricItems);
        tblPercantage = {};
        for m = 1:length(ClassCategories)
            val = ClassCategories{m};
            quantitie = Classquatities(m);
            percentage = quantitie/sum(Classquatities)
            tblPercantage = [tblPercantage; m, quantitie, percentage];
        end

        finalClass =  unique(listClasses);
        finalClass = string(finalClass);
        finalClass = sort(finalClass,"ascend");
        finalClass = strjoin(finalClass);
        %% Creación del histograma de la población
        %  será creado un archivo que contendrá triple histograma
        %  el nombre de archivo de la población, el histograma, la etiqueta de color  
        % Las carpetas de almacenado de histogramas será HistLAB HistLCH
        %[histLAB, histLCH] = BuildHistograms(Final_Lab_Values);

        %register = matfile(k);
        save(rutadbFile, "finalClass", "populationName", "Final_Lab_Values");
    
    end

end % end function
%% Algorithm of machine learning
function clases = KNNEvaluation(train, test, labeltraining, kvector)
    %= 9; %1, 3, 5 ,7,
   distance = 'cityblock';
   ponderar = 'squaredinverse';
   for K=1:length(kvector) 
     Model = fitcknn(train, labeltraining, 'NumNeighbors', kvector(K), ...
                     'Distance', distance, 'DistanceWeight', ponderar);
     clases = predict(Model, test);   
   end  
end
%% Building of histograms two-dimensionales
function [histLAB, histLCH] = BuildHistograms(ROIpixelValues)
    [cie_ab, cie_la, cie_lb, ~] = Pixel2DABLALB(ROIpixelValues);
    sizelab = size(cie_ab, 1) * size(cie_ab, 2);
    cie_ab_e = reshape(cie_ab, sizelab, 1)';
    cie_la_e = reshape(cie_la, sizelab, 1)';
    cie_lb_e = reshape(cie_lb, sizelab, 1)';
    histLAB =  [cie_ab_e, cie_la_e, cie_lb_e];
    
    [cie_ch, cie_lc, cie_lh, ~] = Pixels2Hist2DCHLCLH(ROIpixelValues);
    sizelch = size(cie_ch, 1) * size(cie_ch, 2);
    cie_ch_e = reshape(cie_ch, sizelch, 1)';
    cie_lc_e = reshape(cie_lc, sizelch, 1)';
    cie_lh_e = reshape(cie_lh, sizelch, 1)';
    histLCH =  [cie_ch_e, cie_lc_e, cie_lh_e];
end


%% Load mat file with color references
function [train_lab, train_median_lab, clase, train_ab] = loadTrainDataandClases(pathDB, nameDataSet)
   rootdir = pathDB;
   filename1 = strcat(rootdir,filesep, nameDataSet);
   db = load(filename1,'-mat');
   train_lab = db.train_3Hlab;
   clase =  db.clase;
   train_median_lab = db.train_median_lab;
   train_ab = db.train_1Hab;
end
%% Cut ROI of seed of landraces
function [subimage] =cutImage(Irgb,BI)
    %LB=bwlabel(BI);
    imgResult = Irgb .* cat(3, BI, BI, BI);
    BI2 = ~BI;
    imgResult = imgResult + uint8(255 * BI2);
    bound = regionprops(BI,'BoundingBox');
    coord = bound.BoundingBox;
    subimage = imcrop(imgResult,[coord(1),coord(2),coord(3),coord(4)]);
end
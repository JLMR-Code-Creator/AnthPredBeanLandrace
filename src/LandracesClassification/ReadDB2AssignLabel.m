%% Que se ordene por la clase de mayor frecuencia
%% Analizar la poblaciones de color amarillo variegado.
%% Verificar si es posible agrupar poblaciones por similitud.

function ReadDB2AssignLabel(pathDB, pathImg1, nameDataSet)
%% Firts step
   % firts step, read path of DB allocate
   [train_lab, classe] = loadTrainDataandClases(pathDB, nameDataSet);
   % Second step, load each landraces for classify grain and get superclase
   iteraPoblacion(pathImg1, train_lab, classe);

end

function iteraPoblacion(pathImg, train_lab, classes)
    %% loop to each landraces
    matfile = dir(strcat(pathImg,'Masks/*.mat'));  
    % checking if the dorectory exist
    folderClases = strcat(pathImg, 'Clases');
    if ~exist(folderClases, 'dir')
       mkdir(folderClases)
    end
    [fitcknn_Models] = KNNModels(train_lab, classes);
    for ik = 1:length(matfile)
    %for ik=length(matfile):-1:1
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
        se = strel("disk",15);
        M = Mask;
        Mask = imerode(M,se);
       %imshow(BW3)

        %% Folder tmp for validate name to each seed landraces
        folderLandraces = strcat(pathImg, populationName);
        if ~exist(folderLandraces, 'dir')
            mkdir(folderLandraces)
        end

        listClasses = {}; % All labesl
        Final_Lab_Values = []; % All pixels
        listClassesByLandraces = {}; % for label by seed


        for i3 = 1 : N  % In each grain get the class
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
            nameClassLandraces = '';

            % remove outliers in 3D point data of seed bean
            distance = sqrt(sum(Lab_Values.^2, 2));
            indices = distance < (median(distance)+ std(distance)); %note I use smaller than instead of bigger
            remainingPoints = Lab_Values(indices, :);          

            v_x_axis = 1:25;
            [counts, edges] = histcounts(remainingPoints(:,1), 25);
            % a = histogram(remainingPoints(:,1),25); figure();plot(a.Values);
         
            [pks, locs] = findpeaks(abs(counts), v_x_axis, ...
                'MinPeakDistance',v_x_axis(5), ...
                'MinPeakProminence',20);
        
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
            listClassesByLandraces = [listClassesByLandraces; nameClassLandraces]; % Labels by seed           
            fileName = strcat(folderLandraces,'/',num2str(i3), string(nameClassLandraces));  
            Mask_tmp = ~Mask_tmp;
            [subimage] = cutImage(I,uint8(Mask_tmp));
            imwrite(subimage,strcat(fileName,".png"));  
        end % for i3
        % Get class label using K-NN algorith
        % quantification of grain for coloration        
        % [Classquatities, ClassCategories] = sortArrayElements(listClasses);
        % tblLbl = {};
        % for m = 1:length(ClassCategories)
        %     val = ClassCategories{m};
        %     disp(val);
        %     quantitie = Classquatities(m);
        %     percentage = quantitie/sum(Classquatities)
        %     tblLbl = [tblLbl; val ,{m}, {quantitie}, {percentage}];
        % end
        % 
        % [Quatities, Categories] = sortArrayElements(listClassesByLandraces);
        % tblSeeds = {};
        % for m = 1:length(Categories)
        %     val = Categories{m};
        %     disp(val);
        %     quant = Quatities(m);
        %     percentage = quant/sum(Quatities);
        %     tblSeeds = [tblSeeds; val ,{m}, {quant}, {percentage}];
        % end

       
        parsave(rutadbFile, populationName, Final_Lab_Values, listClasses, listClassesByLandraces);
        %save(rutadbFile, "finalClass", "populationName", "Final_Lab_Values", "listClasses");
    
    end

end % end function
function [Classquatities, ClassCategories] = sortArrayElements(idx)
    categoricItems = categorical(idx);
    ClassCategories = categories(categoricItems);
    Classquatities = countcats(categoricItems);
    [Xsorted,Indx] = sort(Classquatities, "descend");
    Classquatities = Xsorted;
    ClassCategories = ClassCategories(Indx);
end
%% Algorithm of machine learning
function [fitcknn_Models] = KNNModels(trainData, labelTraining)
kvector= [9, 21, 31, 41, 51 ];
distance = 'cityblock';
ponderar = 'squaredinverse';
fitcknn_Models = [];
    for K=1:length(kvector)
        Model = ...
            fitcknn(trainData, labelTraining, 'NumNeighbors', ...
                    kvector(K), 'Distance', ...
                    distance, 'DistanceWeight', ponderar);
        s = struct('M', Model);
        fitcknn_Models = [fitcknn_Models; s];
    end
end
function clase = KNNPrediction(models, test)
classes = cell(1, length(models));
for i = 1:  length(models)
    s = models(i);
    Model = s.M;
    class = predict(Model, test);   
    classes(1, i) = class;
end
   %% Choose of class of maximal frecuence
   classesCat = categorical(classes);
   ClassCategories = categories(classesCat);
   Classquatities = countcats(classesCat);
   indx = find(max(Classquatities));
   clase = ClassCategories{indx};
end

% function clase = KNNEvaluation(train, test, labeltraining)
%    kvector= [9, 21, 31, 41, 51 ];
%    distance = 'cityblock';
%    ponderar = 'squaredinverse';
%    classes = cell(1, 9);
%    for K=1:length(kvector) 
%      Model = fitcknn(train, labeltraining, 'NumNeighbors', kvector(K), ...
%                      'Distance', distance, 'DistanceWeight', ponderar);
%      class = predict(Model, test);   
%      classes(1, K) = class;
%    end  
%    %% Choose of class of maximal frecuence
%    classesCat = categorical(classes);
%    ClassCategories = categories(classesCat);
%    Classquatities = countcats(classesCat);
%    indx = find(max(Classquatities));
%    clase = ClassCategories{indx};
% end

%% Load mat file with color references
function [train_lab, clase] = loadTrainDataandClases(pathDB, nameDataSet)
   rootdir = pathDB;
   filename1 = strcat(rootdir,filesep, nameDataSet);
   db = load(filename1,'-mat');
   train_lab = db.train_3Hlab;
   clase =  db.clase;
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
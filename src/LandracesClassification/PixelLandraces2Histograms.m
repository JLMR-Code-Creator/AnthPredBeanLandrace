function PixelLandraces2Histograms(pathDB)
% Load the dataset that containe the pixel values of set of seed of each
% landraces. Here creating diferents color characterizations for
% experiments of classification task.

  % The folders would be created in the principal folder.
    folderCC3_H2D_LAB = strcat(pathDB, 'CC3_H2D_LAB');
    if ~exist(folderCC3_H2D_LAB, 'dir')
       mkdir(folderCC3_H2D_LAB)
    end
    folderCC3_H2D_LCH = strcat(pathDB, 'CC3_H2D_LCH');
    if ~exist(folderCC3_H2D_LCH, 'dir')
       mkdir(folderCC3_H2D_LCH)
    end    
    folderH3D = strcat(pathDB, 'H3D');
    if ~exist(folderH3D, 'dir')
       mkdir(folderH3D)
    end

    matfile = dir(strcat(pathDB,'/*.mat'));
    for i = 1:length(matfile)  % Iteration to each sample landraces  
        archivo = matfile(i).name;        % File name
        rutadbFile = strcat(pathDB,filesep, archivo);
        L = load(rutadbFile); % load file mask
        Final_Lab_Values = L.Final_Lab_Values;
        finalClass = L.finalClass;
        listClasses = L.listClasses;
        populationName = L.populationName;
        %% Firts to delete outlayer labels
        categoricItems = categorical(listClasses);
        ClassCategories = categories(categoricItems);
        Classquatities = countcats(categoricItems);
        %tblPercantage = {};
        for m = 1:length(ClassCategories)
            val = ClassCategories{m};
            quantitie = Classquatities(m);
            percentage = quantitie/sum(Classquatities);
            %tblPercantage = [tblPercantage; m, quantitie, percentage];
            disp(['Clase: ',val,' Cantidad: ', num2str(quantitie), ' %: ', num2str(percentage) ]);
        end

        finalClass =  unique(listClasses);
        finalClass = string(finalClass);
        finalClass = sort(finalClass,"ascend");
        finalClass = strjoin(finalClass);
        clase =  strrep(finalClass, ' ', '-');
        %% Creación del histograma de la población
        %  será creado un archivo que contendrá triple histograma
        %  el nombre de archivo de la población, el histograma, la etiqueta de color  
        % Las carpetas de almacenado de histogramas será HistLAB HistLCH
        [CC3_H2D_LAB, CC3_H2D_LCH, H3D] = BuildHistograms(Final_Lab_Values);
        
       %% Saving differents files with color characterizations
       dirFile = strcat(folderCC3_H2D_LAB,'/', populationName);
       save(dirFile, 'CC3_H2D_LAB', 'clase', "populationName");

       dirFile = strcat(folderCC3_H2D_LCH,'/', populationName);
       save(dirFile, 'CC3_H2D_LCH', 'clase', "populationName");

       %dirFile = strcat(folderH3D,'/', populationName);
       %save(dirFile, 'H3D', 'clase');
       
    end


end

%% Building of histograms two-dimensionales and three-dimensional
function [histLAB, histLCH, H3D] = BuildHistograms(ROIpixelValues)
    %% two-dimensional histograms created using LAB values
    [cie_ab, cie_la, cie_lb, ~] = Pixel2DABLALB(ROIpixelValues);
    sizelab = size(cie_ab, 1) * size(cie_ab, 2);
    cie_ab_e = reshape(cie_ab, sizelab, 1)';
    cie_la_e = reshape(cie_la, sizelab, 1)';
    cie_lb_e = reshape(cie_lb, sizelab, 1)';
    histLAB =  [cie_ab_e, cie_la_e, cie_lb_e];
    
    %% two-dimensional histograms created using LCH values    
    [cie_ch, cie_lc, cie_lh, ~] = Pixels2Hist2DCHLCLH(ROIpixelValues);
    sizelch = size(cie_ch, 1) * size(cie_ch, 2);
    cie_ch_e = reshape(cie_ch, sizelch, 1)';
    cie_lc_e = reshape(cie_lc, sizelch, 1)';
    cie_lh_e = reshape(cie_lh, sizelch, 1)';
    histLCH =  [cie_ch_e, cie_lc_e, cie_lh_e];

    %% three-dimensional histograms created using LAB values
    [H3D] = Pixles2H3DLAB(ROIpixelValues);
end


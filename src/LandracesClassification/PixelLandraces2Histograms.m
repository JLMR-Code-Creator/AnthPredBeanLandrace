function PixelLandraces2Histograms(pathDB, folderOut, nameDataSet)
% Load the dataset that containe the pixel values of set of seed of each
% landraces. Here creating diferents color characterizations for
% experiments of classification task.

  % The folder would be created in folder.
    folderH1D = strcat(pathDB, 'H1D');
    if ~exist(folderH1D, 'dir')
       mkdir(folderH1D)
    end
    folderH3D = strcat(pathDB, 'H3D');
    if ~exist(folderH3D, 'dir')
       mkdir(folderH3D)
    end

    matfile = dir(strcat(pathDB,'/*.mat'))
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
        tblPercantage = {};
        for m = 1:length(ClassCategories)
            val = ClassCategories{m};
            quantitie = Classquatities(m);
            percentage = quantitie/sum(Classquatities);
            tblPercantage = [tblPercantage; m, quantitie, percentage];
            disp(['Clase: ',val,' Cantidad: ', num2str(quantitie), ' %: ', num2str(percentage) ]);
        end

        finalClass =  unique(listClasses);
        finalClass = string(finalClass);
        finalClass = sort(finalClass,"ascend");
        finalClass = strjoin(finalClass);
        %% Creación del histograma de la población
        %  será creado un archivo que contendrá triple histograma
        %  el nombre de archivo de la población, el histograma, la etiqueta de color  
        % Las carpetas de almacenado de histogramas será HistLAB HistLCH
        [histLAB, histLCH] = BuildHistograms(Final_Lab_Values);

    end


end


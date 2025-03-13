function Dataset_Split(pathDB, file, option, nExecutions)
    %% function for split data en training, validation, nd testing
    % Load datas
    dbPopulations = dir(strcat(pathDB,file)); % Load data
    folder_3H2D_LAB = strcat(pathDB, '3H2D_LAB');
    if ~exist(folder_3H2D_LAB, 'dir')
       mkdir(folder_3H2D_LAB)
    end
    folder_3H2D_LCH = strcat(pathDB, '3H2D_LCH');
    if ~exist(folder_3H2D_LCH, 'dir')
       mkdir(folder_3H2D_LCH)
    end
    folder_H3D = strcat(pathDB, '1H3D');
    if ~exist(folder_H3D, 'dir')
       mkdir(folder_H3D)
    end

    
    elements = 1 : length(dbPopulations);
    %matrixPermutations = zeros(nExecutions, length(elements));
    nSeeds = length(dbPopulations);
    pTrain = ceil(nSeeds*0.7);
    pVal   = floor(nSeeds*0.15);
    pTest  = nSeeds - (nSeeds*0.7-nSeeds*0.15);
    for i=1:nExecutions

        folder_corrida_3H2D_LAB = strcat(folder_3H2D_LAB, '/corrida_',num2str(i));
        if ~exist(folder_corrida_3H2D_LAB, 'dir')
            mkdir(folder_corrida_3H2D_LAB)
        end

        folder_corrida_3H2D_LCH = strcat(folder_3H2D_LCH, '/corrida_',num2str(i));
        if ~exist(folder_corrida_3H2D_LCH, 'dir')
            mkdir(folder_corrida_3H2D_LCH)
        end

        folder_corrida_H3D = strcat(folder_H3D, '/corrida_',num2str(i));
        if ~exist(folder_corrida_H3D, 'dir')
            mkdir(folder_corrida_H3D)
        end

        shuffled = elements(randperm(length(elements)));

        %% Train
        setSeeds = shuffled(1:pTrain);
        dataTrain = dbPopulations(setSeeds);
        SaveHistograms(dataTrain, folder_corrida_3H2D_LAB, ...
            folder_corrida_3H2D_LCH, folder_corrida_H3D, 'train');
        shuffled(1:pTrain) = [];
        %% Validation
        setSeeds = shuffled(1:pVal);
        dataVal   = dbPopulations(setSeeds);
        SaveHistograms(dataVal, folder_corrida_3H2D_LAB, ...
            folder_corrida_3H2D_LCH, folder_corrida_H3D, 'validation');
        shuffled(1:pVal) = [];
        %% Test
        setSeeds = shuffled(1:end);
        dataTest  = dbPopulations(setSeeds);
        SaveHistograms(dataTest, folder_corrida_3H2D_LAB, ...
            folder_corrida_3H2D_LCH, folder_corrida_H3D, 'test');
        shuffled(1:end) = [];
    end
end

function SaveHistograms(dbPopulations, pathDB_3H2D_LAB, ...
    pathDB_3H2D_LCH, pathDB_H3D, folder)

    rutaH3D = strcat(pathDB_H3D,'/',folder);
    if ~exist(rutaH3D, 'dir')
        mkdir(rutaH3D)
    end
    ruta3H2DLAB = strcat(pathDB_3H2D_LAB,'/',folder);
    if ~exist(ruta3H2DLAB, 'dir')
        mkdir(ruta3H2DLAB)
    end    
    ruta3H2DLCH = strcat(pathDB_3H2D_LCH,'/',folder);
    if ~exist(ruta3H2DLCH, 'dir')
        mkdir(ruta3H2DLCH)
    end  

    for j = 1 : length(dbPopulations)
        archivo = dbPopulations(j).name;            % Nombre del imagen
        populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
        disp([datestr(datetime), ' Procesando población ',populationName]);
        load(strcat(pathDB,archivo)); % Carga el archivo de la m?scara         
        clase = finalClass;
        [H3D] = Pixles2H3DLAB(Final_Lab_Values);           
        dirFile = strcat(rutaH3D,'/', populationName);
        save(dirFile, 'H3D', 'clase');
        [cie_ab, cie_la, cie_lb, pixels] = Pixel2DABLALB(Final_Lab_Values);
        dirFile = strcat(ruta3H2DLAB,'/', populationName);
        save(dirFile, 'cie_ab', 'cie_la', 'cie_lb', 'clase');
        [cie_ch, cie_lc, cie_lh, c1] = Pixels2Hist2DCHLCLH(Final_Lab_Values); 
        dirFile = strcat(ruta3H2DLCH,'/', populationName);
        save(dirFile, 'cie_ch', 'cie_lc', 'cie_lh', 'clase');
    end % for
end

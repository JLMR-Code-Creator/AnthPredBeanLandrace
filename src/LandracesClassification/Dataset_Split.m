function Dataset_Split(pathDB1, pathDB2, folderMat1, folderMat2, nExecutions)
    %% fourth (4th) function for split data en training, and testing
    %Dataset_Split('../Images/LANDRACES/Clases/3H2D_LAB_E210/Histograms/', 
    % '../Images/LANDRACES/Clases/3H2D_LCH_E210/Histograms/', 
    % '../Images/LANDRACES/Clases/3H2D_LAB_E210/', 
    % '../Images/LANDRACES/Clases/3H2D_LCH_E210/', 30)
    % Load datas
    dbFolders = dir(strcat(pathDB1)); % Load data
    dbFolders(strcmp({dbFolders.name}, '.'))  = [];
    dbFolders(strcmp({dbFolders.name}, '..'))  = [];

    dbFolders2 = dir(strcat(pathDB2)); % Load data
    dbFolders2(strcmp({dbFolders2.name}, '.'))  = [];
    dbFolders2(strcmp({dbFolders2.name}, '..'))  = [];
    

    for i_=1:nExecutions

        folder_corrida_folderMat1 = strcat(folderMat1, 'corridas/corrida_',num2str(i_));
        if ~exist(folder_corrida_folderMat1, 'dir')
            mkdir(folder_corrida_folderMat1)
        end

        folder_corrida_folderMat2 = strcat(folderMat2, 'corridas/corrida_',num2str(i_));
        if ~exist(folder_corrida_folderMat2, 'dir')
            mkdir(folder_corrida_folderMat2)
        end

         %% For each folder of color group
         for j_=1:length(dbFolders)
             pathLandraces = dbFolders(j_).name;
             pathFiles1 = dir(strcat(pathDB1, '/', pathLandraces,'/*.mat'));
             pathFiles2 = dir(strcat(pathDB2, '/', pathLandraces,'/*.mat'));
             elements = 1 : length(pathFiles1);
             nSeeds = length(elements);
             pTrain = ceil(nSeeds*0.5);
             %pTest  = nSeeds - (pTrain);

            shuffled = elements(randperm(length(elements)));
            %% Train
            setSeeds = shuffled(1:pTrain);
            
            dataTrain = pathFiles1(setSeeds);
            SaveHistograms(dataTrain, folder_corrida_folderMat1, strcat('train/',pathLandraces));


            dataTrain2 = pathFiles2(setSeeds);
            SaveHistograms(dataTrain2, folder_corrida_folderMat2, strcat('train/',pathLandraces));

            shuffled(1:pTrain) = [];
            %% Test
            setSeeds = shuffled(1:end);

            dataTest  = pathFiles1(setSeeds);
            SaveHistograms(dataTest, folder_corrida_folderMat1, strcat('test/',pathLandraces));

            dataTest2 = pathFiles2(setSeeds);
            SaveHistograms(dataTest2, folder_corrida_folderMat2, strcat('test/',pathLandraces));

            shuffled(1:end) = [];             
         end
    end % Executions
end

function SaveHistograms(dbPopulations, pathDB_3H2D, folder)

    ruta3H2D = strcat(pathDB_3H2D,'/',folder);
    if ~exist(ruta3H2D, 'dir')
        mkdir(ruta3H2D)
    end    

    for i_ = 1 : length(dbPopulations)
        folderLandraces = dbPopulations(i_).folder;
        landraces = dbPopulations(i_).name;

        fileMat = fullfile(strcat(folderLandraces,'/',landraces));
        fileOut = fullfile(strcat(ruta3H2D, '/'));
        copyfile(fileMat, fileOut);
    end % for
end

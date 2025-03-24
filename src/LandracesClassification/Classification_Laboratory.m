function Classification_Laboratory(folderRuns, folderOut,cs, epoch)
% the code is for experimentation of classification task, 
% the dataset used correspond to landraces of differents colorations
% ( Homogeneous and heterogeneous)

%% Reading folder
dbFoldersRuns = dir(folderRuns); 
dbFoldersRuns(strcmp({dbFoldersRuns.name}, '.'))  = [];
dbFoldersRuns(strcmp({dbFoldersRuns.name}, '..')) = [];
%% For each folder that containe train and test dataset
for i_=1:length(dbFoldersRuns)
    pathFoderRun = dbFoldersRuns(i_).name;
    pathMain = strcat(folderRuns, '/', pathFoderRun);
    pathDatasetFiles = dir(pathMain);
    pathDatasetFiles(strcmp({pathDatasetFiles.name}, '.'))  = [];
    pathDatasetFiles(strcmp({pathDatasetFiles.name}, '..')) = [];
    for j_=1:length(pathDatasetFiles)

        %% Train folder
        filelisttrain = dir(fullfile(strcat(pathMain, '/train/'), '**\*.mat'));
        filelisttrain = filelisttrain(~[filelisttrain.isdir]);

        [ X_train, Y_train] = Load_3H2D(filelisttrain, cs);
        
        %% Test Folder
        filelisttest = dir(fullfile(strcat(pathMain, '/test/'), '**\*.mat'));
        filelisttest = filelisttest(~[filelisttest.isdir]);
        [ X_test, Y_test] = Load_3H2D(filelisttest, cs);
        dirOut = strcat(folderOut, 'outEval_',num2str(i_));
        if strcmp(cs, 'LAB') == 1
            CNN_3H2D_LAB(X_train, Y_train, X_test, Y_test, epoch, dirOut)
        else
            CNN_3H2D_LCH(X_train, Y_train, X_test, Y_test, epoch, dirOut)
        end        
    end % end for j_

end % end for i_


end

function [ X_data, Y_label] = Load_3H2D(dbPopulations, cs)
    X_data = []; 
    Y_label = []; 
    for j = 1 : length(dbPopulations)
        file_l = dbPopulations(j).name;            % landarace name
        folder_file = dbPopulations(j).folder;
        populationName = strrep(file_l,'.mat',''); 
        disp([datestr(datetime), ...
            ' processing landraces information ',populationName]);
        load(strcat(folder_file,filesep,file_l)); % load file mat
        if strcmp(cs, 'LAB')== 1
            data3h2d = cat(3, cie_ab, cie_la, cie_lb);
        else
            data3h2d = cat(3, cie_ch, cie_lc, cie_lh);
        end
        X_data = cat(4, X_data, data3h2d);
        Y_label = [Y_label; clase];                         
    end % for
end
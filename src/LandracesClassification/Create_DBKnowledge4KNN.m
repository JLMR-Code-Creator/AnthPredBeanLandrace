function Create_DBKnowledge4KNN(pathDB)
% Step 1: Load mat files that correspond to each landraces choosen to
% create a db for knn algorithm
rootdir = pathDB;
filename1 = strcat(rootdir,filesep, 'db4knn.mat'); % Dataset for knn
 
if ~isfile(filename1)
    filelist = dir(fullfile(rootdir, '**\*.mat'));
    filelist = filelist(~[filelist.isdir]);
    folder_H3D = strcat(pathDB, '/DB_H3D_LAB');
    if ~exist(folder_H3D, 'dir')
        mkdir(folder_H3D)
    end 
    train_3Hlab = [];
    clases = [];
    for i = 1:numel(filelist)
        dbFilePath = filelist(i).folder;  % folder
        dbFileName =  filelist(i).name;   % file
        dbFullPath =  strcat(dbFilePath, filesep, dbFileName);  % path
        dbMatFile = load(dbFullPath,'-mat');
        %% Load Information
        labPixels = dbMatFile.rawPixels;
        processedPixels = dbMatFile.pixels; 
        clase= dbMatFile.class;
        %% Three dimensional histogram
        [H3D] = Pixles2H3DLAB(labPixels);
        %% Save in differents folders
        dirFile = strcat(folder_H3D,'/', dbFileName);        
        save(dirFile, 'H3D', 'clase');

        %% Three two-dimensional histogram
        [cie_ab, cie_la, cie_lb, pixels] = Pixel2DABLALB(labPixels);

        sizelab = size(cie_ab, 1) * size(cie_ab, 2);
        cie_ab_e = reshape(cie_ab, sizelab, 1)';
        cie_la_e = reshape(cie_la, sizelab, 1)';
        cie_lb_e = reshape(cie_lb, sizelab, 1)';
        train_lab = [cie_ab_e, cie_la_e, cie_lb_e];
        train_3Hlab = [train_3Hlab;train_lab];
        clases =[clases; {clase}];
        %train_1Hab = [train_1Hab;cie_ab_e];
        %train_median_lab = [train_median_lab;dbMatFile.mediana];
    end
    clase =  clases;
    urlDB = strcat(pathDB,filesep,'db4knn.mat');
    save(urlDB,"train_3Hlab","clase");
end
end


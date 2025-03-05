function Create_DBKnowledge4KNN(pathDB)
% Step 1: Load mat files that correspond to each landraces choosen to
% create a db for knn algorithm
rootdir = pathDB;
filename1 = strcat(rootdir,filesep, 'db5knn.mat'); % Dataset for knn
if isfile(filename1)
    db = load(filename1,'-mat');
    train_3Hlab = db.train_lab;
    clase =  db.clase;
    train_median_lab = db.train_median_lab;
else
    filelist = dir(fullfile(rootdir, '**\*.mat'));
    filelist = filelist(~[filelist.isdir]);
    train_3Hlab = [];
    train_1Hab = [];
    clase = [];
    train_median_lab = [];
    for i = 1:numel(filelist)
        dbFilePath = filelist(i).folder;  % folder
        if (contains(dbFilePath, 'Clases') || contains(dbFilePath, 'Variegado')|| contains(dbFilePath, 'Pink')) == 1
            continue;
        end
        dbFileName =  filelist(i).name   % file
        if contains(dbFileName, 'db') == 1
            continue
        end
        dbFullPath =  strcat(dbFilePath, filesep, dbFileName);  % path
        dbMatFile = load(dbFullPath,'-mat');
        sizelab = size(dbMatFile.cie_ab, 1) * size(dbMatFile.cie_ab, 2);
        cie_ab_e = reshape(dbMatFile.cie_ab, sizelab, 1)';
        cie_la_e = reshape(dbMatFile.cie_la, sizelab, 1)';
        cie_lb_e = reshape(dbMatFile.cie_lb, sizelab, 1)';
        train_lab = [cie_ab_e, cie_la_e, cie_lb_e];
        train_3Hlab = [train_3Hlab;train_lab];
        train_1Hab = [train_1Hab;cie_ab_e];
        clase =[clase; {dbMatFile.class}];
        train_median_lab = [train_median_lab;dbMatFile.mediana];
    end
    urlDB = strcat(pathDB,filesep,'db5knn.mat');
    save(urlDB,"train_3Hlab","clase","train_median_lab", "train_1Hab");
end
end


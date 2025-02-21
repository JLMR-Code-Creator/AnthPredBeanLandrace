function Create_DBKnowledge4KNN(pathDB)
% Step 1: Load mat files that correspond to each landraces choosen to
% create a db for knn algorithm
rootdir = pathDB;
filename1 = strcat(rootdir,filesep, 'db4knn.mat'); % Dataset for knn
if isfile(filename1)
    db = load(filename1,'-mat');
    train_lab = db.train_lab;
    clase =  db.clase;
    train_median_lab = db.train_median_lab;
else
    filelist = dir(fullfile(rootdir, '**\*.mat'));
    filelist = filelist(~[filelist.isdir]);
    train_lab = [];
    clase = [];
    train_median_lab = [];
    for i = 1:numel(filelist)
        dbFilePath = filelist(i).folder;  % folder
        if (contains(dbFilePath, 'Clases') || contains(dbFilePath, 'Variegado')) == 1
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
        train_3Hlab = [cie_ab_e, cie_la_e, cie_lb_e];
        train_lab = [train_lab;train_3Hlab];
        clase =[clase; {dbMatFile.class}];
        train_median_lab = [train_median_lab;dbMatFile.mediana];
    end
    urlDB = strcat(pathDB,filesep,'db4knn.mat');
    save(urlDB,"train_lab","clase","train_median_lab");
end
end


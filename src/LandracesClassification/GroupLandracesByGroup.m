function GroupLandracesByGroup(pathDBRead, folderMat1, folderMat2)
%% Third (3rd) step, group landras by color, in this step eachs MAT file contains histograms and classes.
matfile = dir(strcat(pathDBRead,'/*.mat'));

 %% 1. Get list of classes of color and landraces name
listClasses = cell(1, length(matfile));
listNames = cell(1,length(matfile));
for i = 1:length(matfile)  % Iteration to each sample landraces
    archivo = matfile(i).name;        % File name
    rutadbFile = strcat(pathDBRead,filesep, archivo);
    L = load(rutadbFile); % load file mask
    clase = L.clase;
    populationName = L.populationName;
    listClasses(1, i) = cellstr(clase);
    listNames(1, i) = cellstr(populationName);
end

%% Firts grouping classes by color
categoricItems = categorical(listClasses);
ClassCategories = categories(categoricItems);
Classquatities = countcats(categoricItems);
%% Stastitical for color
grupos = {};
colores = {};
for i = 1:length(ClassCategories)
    lblColor = ClassCategories{i};
    disp(lblColor);
    quantitie = Classquatities(i);
    index = find(strcmp(listClasses, lblColor));
    landracesByColor =  listNames(index);
    C    = cell(1, numel(landracesByColor));
    C(:) = {lblColor};
    grupos=[grupos, landracesByColor];
    colores =  [colores, C];
    %Grouping images
    folderOut1 = strcat(folderMat1, '/Histograms/',lblColor);
    if ~exist(folderOut1, 'dir')
       mkdir(folderOut1)
    end    
    folderOut2 = strcat(folderMat2, '/Histograms/',lblColor);
    if ~exist(folderOut2, 'dir')
       mkdir(folderOut2)
    end    
    
    for j =1:numel(landracesByColor)
        landrace = landracesByColor{j};
        fileMat1 = fullfile(strcat(folderMat1,'/',landrace,'.mat'));
        fileOut1 = fullfile(strcat(folderOut1, '/'));
        copyfile(fileMat1, fileOut1);
        fileMat2 = fullfile(strcat(folderMat2,'/',landrace,'.mat'));
        fileOut2 = fullfile(strcat(folderOut2, '/'));
        copyfile (fileMat2, fileOut2);        

    end
end

end


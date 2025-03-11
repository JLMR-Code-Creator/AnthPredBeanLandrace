function ConcentradoLandraces(pathDB, folderImage1, folderImage2)
%CONCENTRADOLANDRACES : Function for obtained the color labels of each
%landraces

matfile = dir(strcat(pathDB,'/*.mat'));
listClasses = cell(1, length(matfile));
listNames = cell(1,length(matfile));
for i = 1:length(matfile)  % Iteration to each sample landraces
    archivo = matfile(i).name;        % File name
    rutadbFile = strcat(pathDB,filesep, archivo);
    L = load(rutadbFile); % load file mask
    clase = L.clase;
    populationName = L.populationName;
    listClasses(1, i) = cellstr(clase);
    listNames(1, i) = cellstr(populationName);
end
%% Firts to delete outlayer labels
categoricItems = categorical(listClasses);
ClassCategories = categories(categoricItems);
Classquatities = countcats(categoricItems);
tblPercantage = {};
for i = 1:length(ClassCategories)
    val = ClassCategories{i};
    quantitie = Classquatities(i);
    percentage = quantitie/sum(Classquatities);
    tblPercantage = [tblPercantage; {val}, i, quantitie, percentage];
    disp(['#:',i,' Clase: ',val,' Cantidad: ', num2str(quantitie), ' %: ', num2str(percentage) ])
    ruta = strcat(pathDB, '/tblPercantage.csv');
    writecell(tblPercantage,ruta,'Delimiter',',')
end
%% Stastitical for color
grupos = {};
colores = {};
for i = 1:length(ClassCategories)
    val = ClassCategories{i};
    disp(val);
    quantitie = Classquatities(i);
    index = find(strcmp(listClasses, val));
    landracesByColor =  listNames(index);
    C    = cell(1, numel(landracesByColor));
    C(:) = {val};
    grupos=[grupos, landracesByColor];
    colores =  [colores, C];
    %Grouping images
    folderImagesVal = strcat(pathDB, '/images/',val);
    if ~exist(folderImagesVal, 'dir')
       mkdir(folderImagesVal)
    end    
    for j =1:numel(landracesByColor)
        landrace = landracesByColor{j};
        fullpath = '';
       if exist( strcat(folderImage1,landrace,'.tif'), 'file' ) == 2
          fullpath = strcat(folderImage1,landrace);
       else 
           fullpath = strcat(folderImage2,landrace);
       end
       I = imread(strcat(fullpath,'.tif'));       
       I = uint8(I/256); %% 16 to 8 bits 
       finalWrite = strcat(folderImagesVal, '/', landrace,'.jpg');
       imwrite(I, finalWrite,'jpg');

    end
end
colores = colores';
grupos = grupos';
tblGrupos = [colores, grupos];
ruta = strcat(pathDB, '/tblGrupos.csv');
writecell(tblGrupos,ruta,'Delimiter',',')


end


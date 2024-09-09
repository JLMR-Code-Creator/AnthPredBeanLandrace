function ReadDB2AssignLabel(pathDB, pathImg1, pathImg2)
   % firts step, read path of DB allocate
   [train_lab, train_median_lab, clase] = loadTrainDataandClases(pathDB);
   % Second step, load each landraces for classify grain and get superclase
  [clases]=iteraPoblacion(pathDB, pathImg1, train_lab, train_median_lab, clase);

end

function [clases]=iteraPoblacion(pathDB, pathImg, train_lab, train_median_lab, clase)
matfile = dir(strcat(pathImg,'Masks/*.mat'));  % Cargar mascara de cada poblaci?nl

 for k = 1:length(matfile)            % Recorrer las imagenes
    archivo = matfile(k).name;        % Nombre del imagen
    populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n

    rutadbFile = strcat(pathDB, filesep, 'Clases',filesep, populationName,'.mat');
    if isfile(rutadbFile)
        continue;
    end
    disp([datestr(datetime), ' Procesando poblacion ',populationName]);
    nombre=strcat(pathImg,'Masks/');
    L = load(strcat(nombre,populationName)); % Carga el archivo de la m?scara    
    Mask = L.Mask;
    disp([datestr(datetime), ' Procesando población ',populationName]);
    % Read each seed for classify
    % Clean up small groups pixels
    [ML, ~]=bwlabel(Mask);         % Etiquetar granos de frijol conectados
    propied= regionprops(ML);      % Calcular propiedades de los objetos de la imagen
    s=find([propied.Area] < 1000); % grupos menores a 100 px
    for i1=1:size(s,2)              % eliminaci�n de pixeles
        index = ML == s(i1);
        Mask(index) = 0;
    end
    Mask = ~Mask;
    [ML, N] = bwlabel(Mask);         % Etiquetar granos de frijol conectados       
    propied = regionprops(ML);      % Calcular propiedades de los objetos de la imagen
    I = imread(strcat(pathImg,populationName,'.tif'));
    [I_Lab] = RGB2PCS(I, pathImg, strcat(populationName, '.tif'));
    
    listClasses = [];
    test_lab = [];
    test_median_lab = [];

    % 
    for i3=1:N % In each grain get the class
        seeds = 1:N;
        seedValue =  i3;
        seeds(seeds==seedValue) = [];
        Mask_tmp = Mask; 
        for j1=1:length(seeds)
           value = seeds(j1);
           index = ML == value;
           Mask_tmp(index) = 0;
        end
        Mask_tmp = ~Mask_tmp;
        [cie_ab, cie_la, cie_lb, mediana] = Img2Hist2DABLALB_Median(I_Lab, Mask_tmp); 
        sizelab = size(cie_ab, 1) * size(cie_ab, 2);
        cie_ab_e = reshape(cie_ab, sizelab, 1)';
        cie_la_e = reshape(cie_la, sizelab, 1)';
        cie_lb_e = reshape(cie_lb, sizelab, 1)';

        seed_test_lab =  [cie_ab_e, cie_la_e, cie_lb_e];
        test_lab = [test_lab;seed_test_lab];

        %[mediana] = MedianaLAB(I_Lab, Mask_tmp);
        %test_median_lab = [test_median_lab;mediana];

    end % for i3
    % Get class label using K-NN algorith
    [clase_lab] = KNNEvaluation(train_lab, test_lab, clase);   % train_median_lab
    %[clase_lab] = KNNEvaluation(train_median_lab, test_median_lab, clase);    
    finalClass =  unique(clase_lab);
    finalClass = string(finalClass);
    finalClass = sort(finalClass,"ascend");

    register = matfile(k);
    save(rutadbFile, "finalClass", "register", "populationName");
    
end

end % end function
function clases = KNNEvaluation(train, test, labeltraining)
   kvector = 9; %1, 3, 5 ,7,
   distance = 'cityblock';
   ponderar = 'squaredinverse';
   for K=1:length(kvector) 
     Model = fitcknn(train,labeltraining,'NumNeighbors',kvector(K), 'Distance', distance, 'DistanceWeight', ponderar);
     clases = predict(Model,test);   
   end  
end

function [train_lab, train_median_lab, clase] = loadTrainDataandClases(pathDB)
rootdir = pathDB;
filename1 = strcat(rootdir,filesep, 'dbknn.mat');
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
        dbFilePath = filelist(i).folder; % folder
        dbFileName =  filelist(i).name; % file
        dbFullPath =  strcat(dbFilePath,filesep, dbFileName); %path
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
    urlDB = strcat(pathDB,filesep,'dbknn.mat');
    save(urlDB,"train_lab","clase","train_median_lab");
end

end

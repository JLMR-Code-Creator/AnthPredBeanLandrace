function [output] = Impl_ClasificacionKNN(pathImg, extension, dimensionType)
 directorio = strcat(pathImg,'DataBase','/');
 dbPopulations = dir(strcat(directorio,extension)); % Cargar todas las muestras de entrenamiento 
 N=length(dbPopulations);
 resAccuClase = [];
 resAccuSuperClase = [];
 for i = 1 : N
    dbfile = dbPopulations(i).name;       % Nombre de la db 
    disp([int2str(i), ' ', dbfile]);
    db = load(strcat(directorio, dbfile), '-mat');
    if(strcmp(dimensionType, 'Espectro'))
        train = db.train_espectro;
        test = db.test_espectro;
        train_clase = db.train_espectroClase;
        train_superClase = db.train_espectroSuperClase;
        test_clase = db.test_espectroClase;
        test_superClase = db.test_espectroSuperClase;
    elseif(strcmp(dimensionType, 'RGB'))    
        train = db.train_rgb;
        test = db.test_rgb;
        train_clase = db.train_Clase;
        train_superClase = db.train_SuperClase;  
        test_clase = db.test_Clase;
        test_superClase = db.test_SuperClase;
    elseif(strcmp(dimensionType, 'HSI'))    
        train = db.train_hsi;
        test = db.test_hsi;
        train_clase = db.train_Clase;
        train_superClase = db.train_SuperClase;
        test_clase = db.test_Clase;
        test_superClase = db.test_SuperClase;
    elseif(strcmp(dimensionType, 'LAB'))    
        train = db.train_lab;
        test = db.test_lab;
        train_clase = db.train_Clase;
        train_superClase = db.train_SuperClase;   
        test_clase = db.test_Clase;
        test_superClase = db.test_SuperClase;        
    elseif(strcmp(dimensionType, 'HSILABRGB'))    
        train = [db.train_hsi, db.train_lab, db.train_rgb];
        test = [db.test_hsi, db.test_lab, db.test_rgb];
        train_clase = db.train_Clase;
        train_superClase = db.train_SuperClase;
        test_clase = db.test_Clase;
        test_superClase = db.test_SuperClase;        
    elseif(strcmp(dimensionType, 'HSILAB'))    
        train = [db.training_hsi, db.training_lab];
        test = [db.test_hsi, db.test_lab];
        train_clase = db.training_Clase;
        train_superClase = db.training_SuperClase;   
    elseif(strcmp(dimensionType, 'HSAB'))    
        train = [db.training_hsi(:,1:2), db.training_lab(:,1:2)];
        test = [db.test_hsi(:,1:2), db.test_lab(:,1:2)];
        train_clase = db.training_Clase;
        train_superClase = db.training_SuperClase;          
    else     
        [train, test, train_clase, train_superClase] = structDB2TrainingandTest(db,1,size(db.dataset,1), dimensionType);
    end
    %%
    accuracyClase = [];
    accuracySuperClase = [];
    kvector = [1, 3, 5 ,7, 9];
    distance = 'cityblock';
    ponderar = 'squaredinverse';
   for K=1:length(kvector) % para k1, k3
         [Accu1] = knn_Matlab(train, test, train_clase, test_clase, distance, kvector(K), ponderar);
         [Accu2] = knn_Matlab(train, test, train_superClase,test_superClase, distance,kvector(K), ponderar);
          accuracyClase = [accuracyClase,(Accu1)];       
          accuracySuperClase = [accuracySuperClase,(Accu2)];       
   end
%    
%        Model = fitcecoc(train,train_clase,'ClassNames',train_clase');
%        out = predict(Model,test);
%        accuracyClase = sum(string(train_clase) == string(out),'all')/numel(out)
%        Model = fitcecoc(train,train_superClase,'ClassNames',train_superClase');
%        out = predict(Model,test);
%        accuracySuperClase = sum(string(train_superClase) == string(out),'all')/numel(out);


   resAccuClase = [resAccuClase;accuracyClase];
   resAccuSuperClase = [resAccuSuperClase;accuracySuperClase];

end   

  resAccuClase=[resAccuClase;mean(resAccuClase);std(resAccuClase)]
  resAccuSuperClase=[resAccuSuperClase;mean(resAccuSuperClase);std(resAccuSuperClase)]
   
  contador = 1:1:N+2; % vector para las etiquetas
  Concentrado_clase = table([contador',resAccuClase]);
  Concentrado_superClase = table([contador',resAccuSuperClase]);

    finalDir = strcat(pathImg, 'Report');
    if ~exist('',finalDir)
        mkdir(finalDir);
    end   
  
   %filename = strcat(finalDir,'/SVM_',dimensionType,'_concentrado_',distance,'_',ponderar,'.xlsx');
   filename = strcat(finalDir,'/KNN_',dimensionType,'_concentrado_','.xlsx');
   writetable(Concentrado_clase,filename,'Sheet',1);
   writetable(Concentrado_superClase,filename,'Sheet',2);
   output = 1;
end


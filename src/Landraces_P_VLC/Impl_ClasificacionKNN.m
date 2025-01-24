function [output] = Impl_ClasificacionKNN(pathImg, extension, dimensionType)
      directorio = strcat(pathImg,'/');
      dbPopulations = dir(strcat(directorio,extension)); % Cargar todas las muestras de entrenamiento 
      N=length(dbPopulations);
      resAccuClase_lab = [];
      resAccuClase_lch = [];
      train_lab = [];
      test_lab = [];
      train_lch = [];
      test_lch = []; 
      clase = [];
      for i = 1 : N % 1 to total db bean landraces
         dbfile = dbPopulations(i).name;       % Database name
         disp([int2str(i), ' ', dbfile]);       
         db = load(strcat(directorio, dbfile), '-mat'); % load database
         disp(['   Reshape 2D' , db.populationName]);
         %% Training Data Section
         sizelab = size(db.cie_ab_e, 1) * size(db.cie_ab_e, 2);
         sizelch = size(db.cie_ch_e, 1) * size(db.cie_ch_e, 2);
     
         cie_ab_e = reshape(db.cie_ab_e, sizelab, 1)';
         cie_la_e = reshape(db.cie_la_e, sizelab, 1)';
         cie_lb_e = reshape(db.cie_lb_e, sizelab, 1)';
         cie_ab_p = reshape(db.cie_ab_p, sizelab, 1)';
         cie_la_p = reshape(db.cie_la_p, sizelab, 1)';
         cie_lb_p = reshape(db.cie_lb_p, sizelab, 1)';
         % db lab
         res_train_lab = [cie_ab_e, cie_la_e, cie_lb_e];
         res_test_lab =  [cie_ab_p, cie_la_p, cie_lb_p];
         train_lab = [train_lab;res_train_lab];
         test_lab = [test_lab;res_test_lab];

         cie_ch_e = reshape(db.cie_ch_e, sizelch, 1)';
         cie_lc_e = reshape(db.cie_lc_e, sizelch, 1)';
         cie_lh_e = reshape(db.cie_lh_e, sizelch, 1)';
         cie_ch_p = reshape(db.cie_ch_p, sizelch, 1)';
         cie_lc_p = reshape(db.cie_lc_p, sizelch, 1)';
         cie_lh_p = reshape(db.cie_lh_p, sizelch, 1)';
         % db lch 
         res_train_lch = [cie_ch_e, cie_lc_e, cie_lh_e];
         res_test_lch =  [cie_ch_p, cie_lc_p, cie_lh_p];
         train_lch = [train_lch;res_train_lch];
         test_lch = [test_lch;res_test_lch];
     
         clase =[clase; {db.populationName}];
     
     end   
     
     [accuracyClase_lab] = k_NN(train_lab, test_lab, clase, clase);
     [accuracyClase_lch] = k_NN(train_lch, test_lch, clase, clase);
   
     resAccuClase_lab = [resAccuClase_lab;accuracyClase_lab];   
     resAccuClase_lab = [resAccuClase_lab;mean(resAccuClase_lab);std(resAccuClase_lab)];

     resAccuClase_lch = [resAccuClase_lch;accuracyClase_lch];
     resAccuClase_lch = [resAccuClase_lch;mean(resAccuClase_lch);std(resAccuClase_lch)];

     contador = 1:1:N+2; 
     Concentrado_clase_lab = table([contador',resAccuClase_lab]);
     Concentrado_clase_lch = table([contador',resAccuClase_lch]);
     
     finalDir = strcat(pathImg, 'Report');
     if ~exist('',finalDir)
         mkdir(finalDir);
     end   
       
     filename = strcat(finalDir,'/KNN_',dimensionType,'_concentrado_','.xlsx');
     writetable(Concentrado_clase_lab,filename,'Sheet', 1);
     writetable(Concentrado_clase_lch,filename,'Sheet', 2);
     output = 1;
     
     end
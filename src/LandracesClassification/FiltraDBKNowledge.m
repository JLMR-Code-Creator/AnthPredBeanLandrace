function FiltraDBKNowledge(pathDB, nameDataSet, nameMat)

   rootdir = pathDB;
   filename1 = strcat(rootdir,filesep, nameDataSet);
   db = load(filename1,'-mat');
   train_lab = db.train_3Hlab;
   %clase =  db.clase;
   train_median_lab = db.train_median_lab;
   train_ab = db.train_1Hab;

   devstd = std(train_ab);
   idx = devstd > 0;
   datos1h = train_ab(:,idx); 
    
   devstd = std(train_lab);
   idx = devstd > 0;
   datos3h = train_lab(:,idx); 

   clase = string(db.clase);
   outputFile = strcat(pathDB, nameMat);
   save(outputFile, "clase","datos1h", "datos3h");


end


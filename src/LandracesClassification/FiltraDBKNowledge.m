function FiltraDBKNowledge(pathDB, nameDataSet)

   rootdir = pathDB;
   filename1 = strcat(rootdir,filesep, nameDataSet);
   db = load(filename1,'-mat');
   train_lab = db.train_3Hlab;
   %clase =  db.clase;
   train_median_lab = db.train_median_lab;
   train_ab = db.train_1Hab;

   devstd = std(train_ab);
   idx = devstd > 0;
   datos = train_ab(:,idx); 
    
   clase = string(db.clase);

   save('frijoldb.mat', "clase","datos");


end


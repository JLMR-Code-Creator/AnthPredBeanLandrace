function FiltraDBKNowledge(pathDB, nameDataSet)
% FiltraDBKNowledge('../Images/DB/', 'db5knn.mat')
   rootdir = pathDB;
   filename1 = strcat(rootdir,filesep, nameDataSet);
   db = load(filename1,'-mat');
   train_lab = db.train_3Hlab;
   %clase =  db.clase;
   train_median_lab = db.train_median_lab;
   train_ab = db.train_1Hab;

   devstd = std(train_lab);
   idx = find(devstd > 0);
   datos = train_lab(:,idx); 
 %  
 %  maxi= max(train_ab);
 %  idx = find(maxi > min(maxi));
 %  datos = train_ab(:,idx); 
 %

   clase = string(db.clase);
   outputFile = strcat(pathDB, 'frijoldbLAB.mat'); 
   save(outputFile, "clase","datos");


end


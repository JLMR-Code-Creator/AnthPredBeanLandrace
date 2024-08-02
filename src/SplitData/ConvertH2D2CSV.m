function ConverH2D2CSV(pathImg, file, dirOut)
  dbPopulations = dir(strcat(pathImg,file)); % Cargar todas las muestras de entrenamiento
  createDBCSV(pathImg, dirOut, dbPopulations)
    
end

function createDBCSV(pathImg, dirOut,  dbPopulations)

    finalDir = strcat(pathImg, dirOut);
    mkdir(finalDir);
    dirEntrena = strcat(finalDir,'/entrenamiento');
    mkdir(dirEntrena);
    dirPrueba = strcat(finalDir,'/prueba');
    mkdir(dirPrueba);
    dirMat = strcat(finalDir,'/MAT');
    mkdir(dirMat);

    pob = [];
    colores =[];
    antocianin = [];
    for k = 1:length(dbPopulations)            % Recorrer las imagenes
        %Inicializaci?n de variables
        archivo = dbPopulations(k).name;        % Nombre del imagen
        populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
        disp([datestr(datetime), ' Procesando población ',populationName]);
        % L = 
        load(strcat(pathImg,archivo)); % Carga el archivo de la m?scara


        pob = [pob;{populationName}];
        colores = [colores;{color}];
        antocianin = [antocianin; valantocianinas];


        dirDatosE = strcat(dirEntrena,'/carpeta_',num2str(k));
        mkdir(dirDatosE);

        dbFile = strcat(dirDatosE,'/', 'cie_ab.csv');
        writematrix(cie_ab_e, dbFile);

        dbFile = strcat(dirDatosE,'/', 'cie_la.csv');
        writematrix(cie_la_e, dbFile);

        dbFile = strcat(dirDatosE,'/', 'cie_lb.csv');
        writematrix(cie_lb_e, dbFile);
        
        dbFile = strcat(dirDatosE,'/', 'hsi_hs.csv');
        writematrix(hsi_hs_e, dbFile);

        dbFile = strcat(dirDatosE,'/', 'hsi_hi.csv');
        writematrix(hsi_hi_e, dbFile);

        dbFile = strcat(dirDatosE,'/', 'hsi_si.csv');
        writematrix(hsi_si_e, dbFile);


        dirDatosP = strcat(dirPrueba,'/carpeta_',num2str(k));
        mkdir(dirDatosP);

        dbFile = strcat(dirDatosP,'/', 'cie_ab.csv');
        writematrix(cie_ab_p, dbFile);

        dbFile = strcat(dirDatosP,'/', 'cie_la.csv');
        writematrix(cie_la_p, dbFile);

        dbFile = strcat(dirDatosP,'/', 'cie_lb.csv');
        writematrix(cie_lb_p , dbFile); 

        dbFile = strcat(dirDatosE,'/', 'hsi_hs.csv');
        writematrix(hsi_hs_p, dbFile);

        dbFile = strcat(dirDatosE,'/', 'hsi_hi.csv');
        writematrix(hsi_hi_p, dbFile);

        dbFile = strcat(dirDatosE,'/', 'hsi_si.csv');
        writematrix(hsi_si_p, dbFile);        
        
        dirDatosMat = strcat(dirMat,'/carpeta_',num2str(k));
        mkdir(dirDatosMat);
        copyfile(strcat(pathImg,archivo), strcat(dirDatosMat,'/z.mat'));
        
    end
    
    claseDir = strcat(finalDir,'/complements');
    mkdir(claseDir);
           
    fid = fopen( strcat(finalDir,'/complements/', 'color','.csv'), 'wt' );
    fprintf( fid, '%s\n', string(colores));
    fclose(fid);

    fid = fopen( strcat(finalDir,'/complements/', 'poblaciones','.csv'), 'wt' );
    fprintf( fid, '%s\n', string(pob));
    fclose(fid);

    dbFile =  strcat(finalDir,'/complements/', 'clase','.csv');
    writematrix(antocianin, dbFile);

end

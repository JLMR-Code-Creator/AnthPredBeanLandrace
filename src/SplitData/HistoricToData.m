function HistoricToData(pathDB, file, pathImg, pathTarget)
   dbPopulations = dir(strcat(pathDB,file)); % Cargar todas las muestras de historico    
   N = length(dbPopulations);

   [pob, colores, mini] = histogramas(N, dbPopulations, pathDB, pathImg, pathTarget)
 
end

function [populationName, colores, mini] = histogramas(N, sortData, pathDB, pathImg, pathTarget)
   populationName = [];
   colores =[];
   mini = [];
   for i = 1 : N
        dbfile = sortData(i).name;       % Nombre de la db 
        disp(dbfile);
        load(strcat(pathDB,dbfile));
        dat = registro(end);
        populationName = dat.landrace;
        color = dat.color;
        valantocianinas = dat.antocianinas;
        % lectura de las imagenes 
        I_rgb = imread(strcat(pathImg,populationName, '.tif'));    
        [I_Lab] = RGB2PCS(I_rgb, pathImg, strcat(populationName, '.tif'));
        [cie_ab_e, cie_la_e, cie_lb_e] =Img2Hist2DABLALB(I_Lab, dat.mask_e) ;
        [cie_ab_p, cie_la_p, cie_lb_p] =Img2Hist2DABLALB(I_Lab, dat.mask_p) ;
        I = uint8(I_rgb / 256);
        [hsi_hs_e, hsi_hi_e, hsi_si_e] = Img2Hist2DHSHISI(I, dat.mask_e);
        [hsi_hs_p, hsi_hi_p, hsi_si_p] = Img2Hist2DHSHISI(I, dat.mask_p);    

        completo = strcat(populationName,'.mat');
        nombredatos = strcat(pathTarget,'/',completo);
        save(nombredatos,'cie_ab_e', 'cie_la_e', 'cie_lb_e', ...
                         'cie_ab_p', 'cie_la_p', 'cie_lb_p', ...
                         'hsi_hs_e', 'hsi_hi_e', 'hsi_si_e', ...
                         'hsi_hs_p', 'hsi_hi_p', 'hsi_si_p', ....
                        'color', 'populationName', 'valantocianinas');

   end
end


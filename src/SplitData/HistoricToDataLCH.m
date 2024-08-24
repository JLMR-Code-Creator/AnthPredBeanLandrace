function HistoricToDataLCH(pathDB, file, pathImg, pathTarget)
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
    [cie_ab_e, cie_la_e, cie_lb_e] =Img2Hist2DABLALB(I_Lab, dat.mask_e);
    [cie_ab_p, cie_la_p, cie_lb_p] =Img2Hist2DABLALB(I_Lab, dat.mask_p);
    % To generate PMF of follows color parameters
    [cie_ch_e, cie_lc_e, cie_lh_e] =Img2Hist2DCHLCLH(I_Lab, dat.mask_e);
    [cie_ch_p, cie_lc_p, cie_lh_p] =Img2Hist2DCHLCLH(I_Lab, dat.mask_p);
    
    
    completo = strcat(populationName,'.mat');
    nombredatos = strcat(pathTarget,'/',completo);
    save(nombredatos,'cie_ab_e', 'cie_la_e', 'cie_lb_e', ...
        'cie_ab_p', 'cie_la_p', 'cie_lb_p', ...
        'cie_ch_e', 'cie_lc_e', 'cie_lh_e', ...
        'cie_ch_p', 'cie_lc_p', 'cie_lh_p', ....
        'color', 'populationName', 'valantocianinas');
    
end
end


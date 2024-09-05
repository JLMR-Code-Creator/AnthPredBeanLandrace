function Image2GetMediana(pathImg, file, dirOut)
dbPopulations = dir(strcat(pathImg,file));     % Cargar todas las muestras de entrenamiento
matfile = dir(strcat(pathImg,'Masks/*.mat'));  % Cargar mascara de cada poblaci?n
listPopulationfile = dir(strcat(pathImg,'*.tif'));   % Cargar mascara de cada poblaci?n
imgPopulations = struct2cell(listPopulationfile(:,1));
iteraPoblacion(pathImg, dirOut, matfile, imgPopulations)

end

function iteraPoblacion(pathImg, dirOut, matfile, imgPopulations)

finalDir = dirOut;
mkdir(finalDir);
dirEntrena = strcat(finalDir,'/Partitiones');
mkdir(dirEntrena);

 for k = 1:length(matfile)            % Recorrer las imagenes
    %Inicializaci?n de variables
    archivo = matfile(k).name;        % Nombre del imagen
    populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
    disp([datestr(datetime), ' Procesando poblacion ',populationName]);
    nombre=strcat(pathImg,'Masks/');
    L = load(strcat(nombre,populationName)); % Carga el archivo de la m?scara    
    Mask = L.Mask;
    disp([datestr(datetime), ' Procesando población ',populationName]);
    I_rgb = imread(strcat(pathImg,populationName, '.tif'));
    
   [I_Lab] = RGB2PCS(I_rgb, pathImg, strcat(populationName, '.tif'));   
    I = uint8(I_rgb/256);
   [cie_ab_e, cie_la_e, cie_lb_e] =Img2Hist2DABLALB(I_Lab, Mask);
   [cie_ch, cie_lc, cie_lh] = Img2Hist2DCHLCLH(I_Lab, Mask);
   [ RGB_R, RGB_G, RGB_B, HSI_H, HSI_S, HSI_I, LAB_L, LAB_A, LAB_B ] = hist1d(I, I_Lab, Mask);
   
   pks = findpeaks(LAB_L+LAB_B,"Threshold",0.0004);
   if length(pks)>1
    disp(['picos', num2str(length(pks))]); 
   else
    disp(['picos', num2str(length(pks))]); 
   end
    
end

end






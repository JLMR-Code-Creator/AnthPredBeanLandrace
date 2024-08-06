function [output] = Impl_ShowEspecificSegmentationResult(imgPath,extension,nameLandraces)
imgPopulations = dir(strcat(imgPath, extension)); % Cargar todas las muestras de entrenamiento 
 finalDir = strcat(imgPath, 'Masks');
 
 for k = 1:length(imgPopulations)           % Recorrer las imagenes          
    imgfile = imgPopulations(k).name;       % Nombre del imagen       
    if(strcmp(imgfile, nameLandraces)==0)  
        continue  
    end
    populationName = strrep(imgfile,'.tif','') 
    I_rgb = imread(strcat(imgPath,imgfile));    % Lectura de la imagen    
    
    rutat = strcat(imgPath, 'Masks/', strcat(populationName,'.mat'));
    L = load(rutat);
    
    Mask = L.Mask;
    disp([datestr(datetime), ' Fin segmentación ']);
    figure;
    subplot(2,2,1), imagesc(I_rgb), title(populationName);  
    borde = ~Mask;
    segmento=double(I_rgb);  % Obtenci?n de la imagen para dejar la parte segmentada
    segmento(:,:,1)= segmento(:,:,1).*borde; 
    segmento(:,:,2)= segmento(:,:,2).*borde;
    segmento(:,:,3)= segmento(:,:,3).*borde;
    segmento=uint16(segmento);
    subplot(2,2,2), imagesc(segmento), title('Granos de frijol'); 
    
    borde = Mask;
    seg_t=double(I_rgb);  % Obtenci?n de la imagen para dejar la parte segmentada
    seg_t(:,:,1)= seg_t(:,:,1).*borde; 
    seg_t(:,:,2)= seg_t(:,:,2).*borde;
    seg_t(:,:,3)= seg_t(:,:,3).*borde;
    seg_t=uint16(seg_t);      
    subplot(2,2,3), imagesc(seg_t), title('Fondo');     
 end
output = 1;


end


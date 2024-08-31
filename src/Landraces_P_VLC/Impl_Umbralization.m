function  Impl_Umbralization(imgPath, extension)
   
 imgPopulations = dir(strcat(imgPath, extension)); % Cargar todas las muestras de entrenamiento 
 finalDir = strcat(imgPath, 'Masks');
 if ~exist('',finalDir)
     mkdir(finalDir);
 end    
 for k = 1:length(imgPopulations)           % Recorrer las imagenes          
    imgfile = imgPopulations(k).name;       % Nombre del imagen       
    populationName = strrep(imgfile,'.tif','') 
    if exist(strcat(imgPath, 'Masks/', strcat(populationName,'.mat')),'file')         % si el archivo existe continua con el siguiente.        
       continue;
    end   

    I_rgb = imread(strcat(imgPath,imgfile));    % Lectura de la imagen    
    %I_rgb = uint8(I_rgb / 256);    
    Mask = MorphoSegmetation(I_rgb);
    Mask = ~Mask;
    disp([datestr(datetime), ' Fin segmentación ']);
    figure;
    I_rgb = uint8(I_rgb / 256);
    subplot(2,2,1), imagesc(I_rgb), title('Original');  
    borde = ~Mask;
    borde = uint8(borde);
    segmento=(I_rgb);  % Obtenci?n de la imagen para dejar la parte segmentada
    segmento(:,:,1)= segmento(:,:,1).*borde; 
    segmento(:,:,2)= segmento(:,:,2).*borde;
    segmento(:,:,3)= segmento(:,:,3).*borde;
    subplot(2,2,2), imagesc(segmento), title('Granos de frijol'); 
    
    borde = Mask;
    borde = uint8(borde);
    seg_t=(I_rgb);  % Obtenci?n de la imagen para dejar la parte segmentada
    seg_t(:,:,1)= seg_t(:,:,1).*borde; 
    seg_t(:,:,2)= seg_t(:,:,2).*borde;
    seg_t(:,:,3)= seg_t(:,:,3).*borde;     
    subplot(2,2,3), imagesc(seg_t), title('Fondo'); 
        
    beep;
%    choice = questdlg('Continuar con la siguiente población', ...
%        'Continuar', 'Si','No','');
    choice = 'Si';
 
    % Handle response
    switch choice
        case 'Si'
            disp([choice ' Continuando...'])                        
            %% Guardado histograma 2d de entrenamiento en base de datos
            completo = strcat(populationName,'.mat');
            nombredatos = strcat(imgPath,'Masks/',completo);
            save(nombredatos,'Mask');            
            
        case 'No'
            disp([choice 'Saliendo de la aplicaci�n']);
            close all;
            return;
    end
    close all;
 end 
end
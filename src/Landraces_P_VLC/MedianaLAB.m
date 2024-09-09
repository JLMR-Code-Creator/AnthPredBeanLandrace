function [mediana] = MedianaLAB(ILab, Mask) 
%% Obtenci�n de indices
    [global_rows, global_cols, ~] = size(ILab);
    MaskV=reshape(Mask,global_rows * global_cols, 1);
    indices = find(MaskV == 0);       
    data_raw=reshape(ILab, global_rows*global_cols,3);
    datosLAB=data_raw(indices,:);    
    [rows,~] = size(datosLAB);          
    datosLAB(:,1) = datosLAB(:,1) / 100;     % l* normalizaci?n
    datosLAB(:,1) = datosLAB(:,1) * 255;     % l* escalado a 
    datosLAB(:,1) = datosLAB(:,1) + 1;       % desplazamiento en l, rango de 1/256
    datosLAB(:,2:3) = datosLAB(:,2:3) + 129; % Escala el rango de -128/127 a 1/256 a* b*
    datosLAB = round(datosLAB);
    mediana = median(datosLAB);
end


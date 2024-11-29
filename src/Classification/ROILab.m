function [dataLab, pixels] = ROILab(ILab, Mask)
    [global_rows, global_cols, ~] = size(ILab);
    MaskV=reshape(Mask,global_rows * global_cols, 1);
    indices = find(MaskV == 0);
    data_raw=reshape(ILab,global_rows*global_cols,3);
    dataLab=data_raw(indices,:);
    pixels = dataLab;
    [rows,~] = size(pixels);
    pixels(:,1) = pixels(:,1) / 100;     % l* normalizaci?n
    pixels(:,1) = pixels(:,1) * 255;     % l* escalado a 
    pixels(:,1) = pixels(:,1) + 1;       % desplazamiento en l, rango de 1/256
    pixels(:,2:3) = pixels(:,2:3) + 129; % Escala el rango de -128/127 a 1/256 a* b*
    pixels = round(pixels);    
end


function [Mask] = CleanPixels(BinaryMask, PixNum)

    % Limpieza de pixeles  % Clean up small groups pixels
    [ML, ~]=bwlabel(BinaryMask);               % Etiquetar granos de frijol conectados
    propied= regionprops(ML);            % Calcular propiedades de los objetos de la imagen
    s=find([propied.Area] < PixNum);       % grupos menores a 100 px
    for i1=1:size(s,2)                   % eliminaci�n de pixeles
        index = ML == s(i1);
        BinaryMask(index) = 0;
    end
    Mask = BinaryMask;
end
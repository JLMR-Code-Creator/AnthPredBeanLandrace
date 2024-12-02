function [cie_ab, cie_la, cie_lb, pixels] = Pixel2DABLALB(pixels)

    [rows,~] = size(pixels);
    pixels(:,1) = pixels(:,1) / 100;     % l* normalizaci?n
    pixels(:,1) = pixels(:,1) * 255;     % l* escalado a 
    pixels(:,1) = pixels(:,1) + 1;       % desplazamiento en l, rango de 1/256
    pixels(:,2:3) = pixels(:,2:3) + 129; % Escala el rango de -128/127 a 1/256 a* b*
    pixels = round(pixels);
    cie_ab=zeros(256,256);
    tic
    for i=1:rows 
        ind = pixels(i,:);
        cie_ab(ind(2),ind(3)) = cie_ab(ind(2), ind(3)) + 1;
    end       
    toc
    cie_ab=cie_ab/rows;
    disp([datestr(datetime), ' Histograma 2D de A*B* creado']);
    
    cie_la=zeros(256,256);
    tic
    for i=1:rows 
        ind = pixels(i,:)
        cie_la(ind(1),ind(2)) = cie_la(ind(1), ind(2)) + 1;
    end       
    toc
    cie_la=cie_la/rows;
    disp([datestr(datetime), ' Histograma 2D de L*A* creado']);
    
    cie_lb=zeros(256,256);
    tic
    for i=1:rows 
        ind = pixels(i,:);
        cie_lb(ind(1),ind(3)) = cie_lb(ind(1), ind(3)) + 1;
    end       
    toc
    cie_lb=cie_lb/rows;
    disp([datestr(datetime), ' Histograma 2D de L*B* creado']);
end


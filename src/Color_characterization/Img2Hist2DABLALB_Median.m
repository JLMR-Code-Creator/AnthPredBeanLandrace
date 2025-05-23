function [cie_ab, cie_la, cie_lb, mediana] = Img2Hist2DABLALB_Median(ILab, Mask) 
    % Img2Hist2D genera matriz de probabilidad
    % conjunta en los espacios de color HSI y CIE L*A*B* considerando solo
    % los matices en los canales HS y AB.
    % I es una matriz de n x m x z que corresponden a una imagen de color
    % Mask matriz de nxm que corresponde a la mascara de segmentaci�n.
    % Resultado : 
    % hsi_hs: matriz de nxm con las probabilidades conjuntas de cada tono de color en
    % los componentes de H y S.
    % cie_ab: matriz de nxm con las probabilidades conjuntas de cada tono de color en
    % los componentes A* y B*
    
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
    cie_ab=zeros(256,256);
    tic
    for i=1:rows 
        ind = datosLAB(i,:);
        cie_ab(ind(2),ind(3)) = cie_ab(ind(2), ind(3)) + 1;
    end       
    toc
    cie_ab=cie_ab/rows;
    disp([datestr(datetime), ' Histograma 2D de A*B* creado']);
    
    cie_la=zeros(256,256);
    tic
    for i=1:rows 
        ind = datosLAB(i,:);
        cie_la(ind(1),ind(2)) = cie_la(ind(1), ind(2)) + 1;
    end       
    toc
    cie_la=cie_la/rows;
    disp([datestr(datetime), ' Histograma 2D de L*A* creado']);
    
    cie_lb=zeros(256,256);
    tic
    for i=1:rows 
        ind = datosLAB(i,:);
        cie_lb(ind(1),ind(3)) = cie_lb(ind(1), ind(3)) + 1;
    end       
    toc
    cie_lb=cie_lb/rows;
    disp([datestr(datetime), ' Histograma 2D de L*B* creado']);
   % H2ABLALB = cat(3, cie_ab, cie_la, cie_lb);        
    
end


function [ RGB_R, RGB_G, RGB_B, HSI_H, HSI_S, HSI_I, LAB_L, LAB_A, LAB_B ] = hist1d(I, ILab, Mask) 
      % hist1d genera los histogramas en los espacios de color RGB, HSI y CIE
      % L*A*B* con rango din?mico de 1 a 256.
      % HSI con rango din�mico de 1 a 256
      % argumentos:
      % I = imagen en el espacio de color RGB;
      % Mask = mascara de segmentaci�n
      
    [global_rows,global_cols,z] = size(I);
    MaskV=reshape(Mask,global_rows * global_cols, 1);
    indices = find(MaskV == 0);
    %% RGB
    data_raw = reshape(I, global_rows * global_cols, 3);
    datosRGB = data_raw(indices,:);
    [rows,cols] = size(datosRGB);
    datosRGB = datosRGB + 1; % desplaza de 0-255 a 1 a 256
    RGB_R=zeros(1,256); RGB_G=zeros(1,256); RGB_B=zeros(1,256);
    
    for i = 1:rows
        ind = datosRGB(i,1); 
        RGB_R(ind) = RGB_R(ind) + 1;

        ind2 = datosRGB(i,2); 
        RGB_G(ind2) = RGB_G(ind2) + 1;
        
        ind3 = datosRGB(i,3); 
        RGB_B(ind3) = RGB_B(ind3) + 1;
    end
    RGB_R = RGB_R / rows; % normalizaci?n
    RGB_G = RGB_G / rows;
    RGB_B = RGB_B / rows;

    %%  HSI     
    img = rgb2hsi(I);
    data_raw = reshape(img, global_rows * global_cols, 3);
    datosHSI = data_raw(indices,:);
    [rows,cols] = size(datosHSI);
    datosHSI = (datosHSI * 255) + 1; %  Escala el rango de [0-1] a 1/256 
    datosHSI = round(datosHSI);
   
    HSI_H = zeros(1,256); HSI_S = zeros(1,256); HSI_I = zeros(1,256);
    for i = 1:rows
        ind1 = datosHSI(i,1);
        HSI_H(ind1) = HSI_H(ind1) + 1;
        
        ind2 = datosHSI(i,2);
        HSI_S(ind2) = HSI_S(ind2) + 1;

        ind3 = datosHSI(i,3);
        HSI_I(ind3) = HSI_I(ind3) + 1;
    end
    HSI_H = HSI_H / rows;
    HSI_S = HSI_S / rows;
    HSI_I = HSI_I / rows;

    %% cie L*A*B*
    img=ILab;
    data_raw=reshape(img,global_rows*global_cols,3);
    datosLAB=data_raw(indices,:);    
    [rows,cols] = size(datosLAB);
    datosLAB(:,1) = datosLAB(:,1) / 100;     % l* normalizaci?n
    datosLAB(:,1) = datosLAB(:,1) * 255;     % l* escalado a 
    datosLAB(:,1) = datosLAB(:,1) + 1;       % desplazamiento en l
    datosLAB(:,2:3) = datosLAB(:,2:3) + 129; % Escala el rango de -128/127 a 1/256 a* b*
    datosLAB = round(datosLAB); 
    
    LAB_L = zeros(1,256); LAB_A = zeros(1,256); LAB_B = zeros(1,256);
    for i=1:rows
        ind1 = datosLAB(i,1);    
        LAB_L(ind1) = LAB_L(ind1) + 1;
        
        ind2 = datosLAB(i,2);    
        LAB_A(ind2) = LAB_A(ind2) + 1;        
        
        ind3 = datosLAB(i,3);
        LAB_B(ind3) = LAB_B(ind3) + 1;        
    end
    LAB_L=LAB_L/rows;
    LAB_A=LAB_A/rows;
    LAB_B=LAB_B/rows;    

end


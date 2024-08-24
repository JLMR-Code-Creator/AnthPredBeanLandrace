function [cie_ch, cie_lc, cie_lh] = Img2Hist2DCHLCLH(ILab, Mask)
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
% Compute Chrome and Hue values
[L1, c1,h1] = CromaHueChannel(datosLAB);
datosLAB = [L1,c1,h1];
datosLAB = round(datosLAB)+1;
cie_ch=zeros(361,361);
tic
for i=1:rows
    ind = datosLAB(i,:);
    cie_ch(ind(2),ind(3)) = cie_ch(ind(2), ind(3)) + 1;
end
toc
cie_ch=cie_ch/rows;
disp([datestr(datetime), ' Histograma 2D de C*H* creado']);

cie_lc=zeros(361,361);
tic
for i=1:rows
    ind = datosLAB(i,:);
    cie_lc(ind(1),ind(2)) = cie_lc(ind(1), ind(2)) + 1;
end
toc
cie_lc=cie_lc/rows;
disp([datestr(datetime), ' Histograma 2D de L*C* creado']);

cie_lh=zeros(361,361);
tic
for i=1:rows
    ind = datosLAB(i,:);
    cie_lh(ind(1),ind(3)) = cie_lh(ind(1), ind(3)) + 1;
end
toc
cie_lh=cie_lh/rows;
disp([datestr(datetime), ' Histograma 2D de L*H* creado']);

end


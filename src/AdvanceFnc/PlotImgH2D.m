fileList = seleccionarImagenesOpenUI();
data_list = [];
% Process each selected image
for i = 1:size(fileList, 1)
    img = imread( fileList.FullPath(i));
    archivo = fileList.Name(i);             % Nombre del imagen
    maskFile = strrep(archivo,'.tif','.mat');   % Nombre de la poblaci?n
    FullPathMask = strcat(fileList.Folder(i),'/Masks/');
    L = load(strcat(FullPathMask, maskFile));       % Carga el archivo de la m?scara     
    Mask = uint8(L.Mask);
    %Mask = ~Mask; 
    [MaskC] = CleanPixels(Mask, 1000);
    [I_Lab] = RGB2PCS(img, fileList.Folder(i), strcat('/',archivo));
    [Lab_Values, data_raw]= ROILab(I_Lab, MaskC);
    data_list = [data_list;Lab_Values];
    % Further processing can be added here
end
    [cie_ab, cie_la, cie_lb, pixels] = Pixel2DABLALB(data_list);
    [cie_ch, cie_lc, cie_lh, c1] = Pixels2Hist2DCHLCLH(data_list);
    mesh(cie_ch), xlabel("a"), ylabel("b")
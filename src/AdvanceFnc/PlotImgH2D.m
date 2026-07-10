fileList = seleccionarImagenesOpenUI();
data_list = [];
% Process each selected image
for i = 1:size(fileList, 1)
    img = imread( fileList.FullPath(i));
    archivo = fileList(i).Name;             % Nombre del imagen
    mask = strrep(archivo,'.tif','.mat');   % Nombre de la poblaci?n
    nombre=strcat(pathImg,'Masks/');
    L = load(strcat(nombre,archivo));       % Carga el archivo de la m?scara     
    
    %ILab = rgb2lab(img);
    [global_rows, global_cols, ~] = size(ILab);    
    data_raw=reshape(ILab, global_rows*global_cols,3);
    data_list = [data_list;data_raw];
    % Further processing can be added here
end
    [cie_ab, cie_la, cie_lb, pixels] = Pixel2DABLALB(data_list);
    mesh(cie_ab), xlabel("a"), ylabel("b")
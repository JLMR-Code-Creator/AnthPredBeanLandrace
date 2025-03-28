function  GetClases2(pathImg, target)
% Función que permite obtener la información de las semillas destinadas
% para el algoritmo de clasificación.
matfile = dir(strcat(pathImg,'Masks/*.mat'));                       % Cargar mascara de cada poblaci?n
for k = 1:length(matfile)
    archivo = matfile(k).name;        % Nombre del imagen
    populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
    nombre=strcat(pathImg,'Masks/');
    L = load(strcat(nombre,archivo)); % Carga el archivo de la m?scara
    Mask = uint8(L.Mask);
    Mask = ~Mask;
    % Limpieza de pixeles
    % Clean up small groups pixels
    [ML, ~]=bwlabel(Mask);         % Etiquetar granos de frijol conectados
    propied= regionprops(ML);      % Calcular propiedades de los objetos de la imagen
    s=find([propied.Area] < 1000); % grupos menores a 100 px
    for i1=1:size(s,2)              % eliminaci�n de pixeles
        index = ML == s(i1);
        Mask(index) = 0;
    end
    
    [ML, N] = bwlabel(Mask);         % Etiquetar granos de frijol conectados
    propied = regionprops(ML);      % Calcular propiedades de los objetos de la imagen
    I = imread(strcat(pathImg,populationName,'.tif'));
    [I_Lab] = RGB2PCS(I, pathImg, strcat(populationName, '.tif'));
    I = uint8(I/256);
    figure('WindowState', 'maximized');
    imshow(I);
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    hold on;
    ML = uint8(ML);
    for i2=1:size(propied,1)              % eliminaci�n de pixeles
        %drawrectangle('Position',propied(i).BoundingBox, LineWidth=0.5,MarkerSize=0.1,Color='r',Label=num2str(ML(round(propied(i).Centroid(2)),round(propied(i).Centroid(1)))));
        text(round(propied(i2).Centroid(1)),round(propied(i2).Centroid(2)),num2str(ML(round(propied(i2).Centroid(2)),round(propied(i2).Centroid(1)))),'FontSize',10,'color','red');
    end
    
    prompt = {'Introduce los numeros','Enter colormap name:'};
    dlgtitle = 'Input';
    fieldsize = [1 45; 1 45];
    definput = {'',''};
    answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
    if isempty(answer)
        close all;
        continue;
    end
    a = answer{1};% list of numbers
    objects = split(a, ',');
    class = answer{2};
    
    
    for i3=1:length(objects)
        seedValue =  uint8(str2num(objects{i3}));
        seeds = 1:N;
        seeds = uint8(seeds);
        seeds(seeds==seedValue) = [];
        Mask_tmp = Mask;
        for j1=1:length(seeds)
            value = seeds(j1);
            index = ML == value;
            Mask_tmp(index) = 0;
        end
        Mask_tmp = ~Mask_tmp;
        [cie_ab, cie_la, cie_lb, mediana] = Img2Hist2DABLALB_Median(I_Lab, Mask_tmp);
        if strcmp(class,'Black') == 1
            ruta = strcat(target,'/','Black');
            numFile = string(datetime('now'));
            numFile = strrep(numFile,' ','');
            numFile = strrep(numFile,':','_');
            fileName=strcat(ruta,'/','Black_',num2str(numFile));
            save(fileName,"cie_ab","cie_la","cie_lb","mediana","class");
            Mask_tmp = ~Mask_tmp;
            [subimage] = cutImage(I,uint8(Mask_tmp));
            imwrite(subimage,strcat(fileName,".png"));
        elseif strcmp(class,'Red') == 1
            ruta = strcat(target,'/','Red');
            numFile = string(datetime('now'));
            numFile = strrep(numFile,' ','');
            numFile = strrep(numFile,':','_');
            fileName=strcat(ruta,'/','Red_',num2str(numFile));
            save(fileName,"cie_ab","cie_la","cie_lb","mediana","class");
            Mask_tmp = ~Mask_tmp;
            [subimage] = cutImage(I,uint8(Mask_tmp));
            imwrite(subimage,strcat(fileName,".png"));
        elseif strcmp(class,'Brown') == 1
            ruta = strcat(target,'/','Brown');
            numFile = string(datetime('now'));
            numFile = strrep(numFile,' ','');
            numFile = strrep(numFile,':','_');
            fileName=strcat(ruta,'/','Brown_',num2str(numFile));
            save(fileName,"cie_ab","cie_la","cie_lb","mediana","class");
            Mask_tmp = ~Mask_tmp;
            [subimage] = cutImage(I,uint8(Mask_tmp));
            imwrite(subimage,strcat(fileName,".png"));
        elseif strcmp(class,'Yellow') == 1
            ruta = strcat(target,'/','Yellow');
            numFile = string(datetime('now'));
            numFile = strrep(numFile,' ','');
            numFile = strrep(numFile,':','_');
            fileName=strcat(ruta,'/','Yellow_',num2str(numFile));
            save(fileName,"cie_ab","cie_la","cie_lb","mediana","class");
            Mask_tmp = ~Mask_tmp;
            [subimage] = cutImage(I,uint8(Mask_tmp));
            imwrite(subimage,strcat(fileName,".png"));
        elseif strcmp(class,'Pink') == 1
            ruta = strcat(target,'/','Pink');
            numFile = string(datetime('now'));
            numFile = strrep(numFile,' ','');
            numFile = strrep(numFile,':','_');
            fileName=strcat(ruta,'/','Pink_',num2str(numFile));
            save(fileName,"cie_ab","cie_la","cie_lb","mediana","class");
            Mask_tmp = ~Mask_tmp;
            [subimage] = cutImage(I,uint8(Mask_tmp));
            imwrite(subimage,strcat(fileName,".png"));
        elseif strcmp(class,'Purple') == 1
            ruta = strcat(target,'/','Purple');
            numFile = string(datetime('now'));
            numFile = strrep(numFile,' ','');
            numFile = strrep(numFile,':','_');
            fileName=strcat(ruta,'/','Purple_',num2str(numFile));
            save(fileName,"cie_ab","cie_la","cie_lb","mediana","class");
            Mask_tmp = ~Mask_tmp;
            [subimage] = cutImage(I,uint8(Mask_tmp));
            imwrite(subimage,strcat(fileName,".png"));
        elseif strcmp(class,'White') == 1
            ruta = strcat(target,'/','White');
            numFile = string(datetime('now'));
            numFile = strrep(numFile,' ','');
            numFile = strrep(numFile,':','_');
            fileName=strcat(ruta,'/','White_',num2str(numFile));
            save(fileName,"cie_ab","cie_la","cie_lb","mediana","class");
            Mask_tmp = ~Mask_tmp;
            [subimage] = cutImage(I,uint8(Mask_tmp));
            imwrite(subimage,strcat(fileName,".png"));
        elseif strcmp(class,'Variegado') == 1
            ruta = strcat(target,'/','Variegado');
            numFile = string(datetime('now'));
            numFile = strrep(numFile,' ','');
            numFile = strrep(numFile,':','_');
            fileName=strcat(ruta,'/','Variegado_',num2str(numFile));
            save(fileName,"cie_ab","cie_la","cie_lb","mediana","class");
            Mask_tmp = ~Mask_tmp;
            [subimage] = cutImage(I,uint8(Mask_tmp));
            imwrite(subimage,strcat(fileName,".png"));
        end
    end % end for objects
    close all;
end % end for matfiles

end

function [subimage] =cutImage(Irgb,BI)
%LB=bwlabel(BI);
imgResult = Irgb .* cat(3, BI, BI, BI);
BI2 = ~BI;
imgResult = imgResult + uint8(255 * BI2);
bound = regionprops(BI,'BoundingBox');
coord = bound.BoundingBox;
subimage = imcrop(imgResult,[coord(1),coord(2),coord(3),coord(4)]);
end
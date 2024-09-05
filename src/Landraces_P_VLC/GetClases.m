function  GetClases(pathImg)
    matfile = dir(strcat(pathImg,'Masks/*.mat'));                       % Cargar mascara de cada poblaci?n
     for k = 1:length(matfile)   
       archivo = matfile(k).name;        % Nombre del imagen
       populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
       nombre=strcat(pathImg,'Masks/');
       L = load(strcat(nombre,archivo)); % Carga el archivo de la m?scara        
       Mask = L.Mask;
       Mask = ~Mask;   
       % Limpieza de pixeles
       [ML, N] = bwlabel(Mask);         % Etiquetar granos de frijol conectados       
       propied = regionprops(ML);      % Calcular propiedades de los objetos de la imagen
       I = imread(strcat(pathImg,populationName,'.tif'));        
       I = uint8(I/256);
       figure();
       imshow(I);
       hold on;
       ML = uint8(ML);
       for i=1:size(propied,1)              % eliminaci�n de pixeles
           
          drawrectangle('Position',propied(i).BoundingBox, LineWidth=0.5,MarkerSize=0.1,Color='r',Label=num2str(ML(round(propied(i).Centroid(2)),round(propied(i).Centroid(1)))));
          %text(round(propied(i).Centroid(1)),round(propied(i).Centroid(2)),num2str(ML(round(propied(i).Centroid(2)),round(propied(i).Centroid(1)))),'FontSize',10,'color','red');

       end  

       prompt = {'Introduce los numeros','Enter colormap name:'};
       dlgtitle = 'Input';
       fieldsize = [1 45; 1 45];
       definput = {'20','clase'};
       answer = inputdlg(prompt,dlgtitle,fieldsize,definput)
       
       %% Get of the index grains
       for i=1:length(trainingbeans)
         index = ML == trainingbeans(i);
         % desde aquí es el gaurdado de los histogramas
         Mask(index) = 0;

       end
       


     end

end


function PlotLandracesInCIE(pathImg, target)
    matfile = dir(strcat(pathImg,'Masks/*.mat'));                       % Cargar mascara de cada poblaci?n
     for k = 1:3%length(matfile)   
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
       SeedsCIE = [];
       parfor i3=1:size(propied,1)
          seedValue =  i3; 
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
          [Lab_Values,~ ]= ROILab(I_Lab, Mask_tmp);
          SeedsCIE = [SeedsCIE; median(Lab_Values)];
       end % end for objects
       %figure();
       load("valuesLAB.mat");
       MaxL = max(SeedsCIE(:,1));
       L=coordLAB(:,1) < MaxL;
       newdata=coordLAB(L,:);

       MinA = max(SeedsCIE(:,2));
       A=newdata(:,2) > MinA;
       newdata2=newdata(A,:);

       seeds = [newdata2;SeedsCIE];
       plot_Lab(4,seeds',1,'',20,0,populationName);
   
     end % end for matfiles

end


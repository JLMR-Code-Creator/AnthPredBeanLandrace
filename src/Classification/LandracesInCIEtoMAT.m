function LandracesInCIEtoMAT(pathImg, target)
    matfile = dir(strcat(pathImg,'Masks/*.mat')); % Cargar mascara de cada poblaci?n
     for k = 1:length(matfile)   
       archivo = matfile(k).name;                 % Nombre del imagen
       populationName = strrep(archivo,'.mat','') % Nombre de la poblaci?n
       nombre=strcat(pathImg,'Masks/');
       L = load(strcat(nombre,archivo));          % Carga el archivo de la m?scara        
       Mask = uint8(L.Mask);
       Mask = ~Mask;   
       % Limpieza de pixeles  % Clean up small groups pixels
       [ML, ~]=bwlabel(Mask);               % Etiquetar granos de frijol conectados
       propied= regionprops(ML);            % Calcular propiedades de los objetos de la imagen
       s=find([propied.Area] < 1000);       % grupos menores a 100 px
       for i1=1:size(s,2)                   % eliminaci�n de pixeles
           index = ML == s(i1);
           Mask(index) = 0;
       end

       [ML, N] = bwlabel(Mask);             % Etiquetar granos de frijol conectados       
       propied = regionprops(ML);           % Calcular propiedades de los objetos de la imagen
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

          % remove outliers in 3D point data of seed bean
          distance = sqrt(sum(Lab_Values.^2, 2));
          indices = distance < (mean(distance) + std(distance)); %note I use smaller than instead of bigger
          remainingPoints = Lab_Values(indices, :);          

          v_x_axis = 1:25;
          %a = histogram(remainingPoints(:,1),25);
          [counts, edges] = histcounts(remainingPoints(:,1), 25);
          %figure();plot(a.Values);
         
          [pks, locs] = findpeaks(abs(counts), v_x_axis);
          %pks = pks(pks>=100)
        
          K = length(pks)
          pix = remainingPoints;%[remainingPoints(:,1),remainingPoints(:,3)];
          GMModel = fitgmdist(pix, K);

          idx = cluster(GMModel,pix);
       
          unicos = unique(idx)
          for i=1:length(unicos)
            dataPixeles = remainingPoints(idx==i, :);
            SeedsCIE = [SeedsCIE; median(dataPixeles)];                      
          end

       end % end for objects
       %figure();
       %load("valuesLAB.mat");
       %MaxL = max(SeedsCIE(:,1));
       %L=coordLAB(:,1)<MaxL;
       %newdata=coordLAB(L,:);
       %seeds = [newdata;SeedsCIE];
       %plot_Lab(4,seeds',1,'',12,0,populationName);
       %[L1, c1,h1] = CromaHueChannel1(SeedsCIE);
       %disp(['L* ',num2str(median(L1)), ' C* ', num2str(median(c1)), ' H* ', num2str(median(h1)) ]);
       ruta = strcat(target,'/',populationName);
       save(ruta, "SeedsCIE");
     end % end for matfiles

end
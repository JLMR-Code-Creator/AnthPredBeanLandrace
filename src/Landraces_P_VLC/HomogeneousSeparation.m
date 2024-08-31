function HomogeneousSeparation(pathImg, file, dirOut)

dbPopulations = dir(strcat(pathImg,file));     % Cargar todas las muestras de entrenamiento
matfile = dir(strcat(pathImg,'Masks/*.mat'));  % Cargar mascara de cada poblaci?n
listPopulationfile = dir(strcat(pathImg,'*.tif'));   % Cargar mascara de cada poblaci?n
imgPopulations = struct2cell(listPopulationfile(:,1));
% [clase, antocianinas] = Determinaciones(100);
%% Iterar poblaciones para encontrar la mejor
iteraPoblacion(pathImg, dirOut, matfile, imgPopulations)


end


function iteraPoblacion(pathImg, dirOut, matfile, imgPopulations)

finalDir = dirOut;
mkdir(finalDir);
dirEntrena = strcat(finalDir,'/Partitiones');
mkdir(dirEntrena);

%for k = 1:100           % Recorrer las imagenes
 for k = 1:length(matfile)            % Recorrer las imagenes
    %Inicializaci?n de variables
    archivo = matfile(k).name;        % Nombre del imagen
    populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
    if exist(strcat(dirEntrena, '/H_', strcat(populationName,'.mat')),'file')         % si el archivo existe continua con el siguiente.        
       continue;
    end       
    disp([datestr(datetime), ' Procesando población ',populationName]);
    nombre=strcat(pathImg,'Masks/');
    L = load(strcat(nombre,archivo)); % Carga el archivo de la m?scara
    I_rgb = imread(strcat(pathImg,populationName, '.tif'));
    
    dirLAB=strcat(pathImg,'imgLAB/');
    if (~exist(dirLAB, 'dir'))
        perfil = iccread('DSC00005.icc');
        perfil.Header.ColorSpace
        perfil.Header.ConnectionSpace
        C = makecform('clut', perfil, 'AToB1')
        I_Lab = applycform(I_rgb, C);
    else
        I_Lab = imread(strcat(dirLAB,'/',populationName, '.tif'));
    end
    
    buscaHomogeneizar3Hist(I_rgb, I_Lab, L, populationName, dirEntrena)
    %buscaHomogeneizarLAB(I_rgb, I_Lab, L, color, landrace, valantocianinas, dirEntrena)
    
end

end



function dist1 = cmpHistogramas3D(cielab_e, cielab_p)
 dist1 = sum(sum(sum(abs(cielab_e - cielab_p))));
end

function  buscaHomogeneizar3Hist(I_rgb, I_Lab, L, populationName, dirEntrena)

log = [];
registro = [];
progreso = [];
memoria = []; % Con la finalidad de conocer si la secuencia aleatoria ya fue evaluada
aDouble = double(I_Lab); % Converting to double so can have decimals
Lab= [];
% 16 bits
Lab(:,:,1) = aDouble(:,:,1)*100/65280; % L
Lab(:,:,2) = aDouble(:,:,2)/256 - 128; % a
Lab(:,:,3) = aDouble(:,:,3)/256 - 128 ; % b

Mask = uint8(L.Mask);
if(Mask(1,1)==0)
    disp([archivo, populationName])
end

if ~isnumeric(Mask)
    error('MyComponent:incorrectType',...
        'Error. \nEntrada debe ser tipo logical, y no del tipo %s.',class(Mask));
end
Mask = ~Mask;
[ML, GT] = bwlabel(Mask);   % Etiquetar granos de frijol conectados

limite = false;
contador = 1;
while(limite == false)
    exemplar =  1:1:GT;         % de 1 en 1 hasta total de granos
    shufled = exemplar(randperm(length(exemplar))); % permutacion
    %% Verifica en memoria que la secuencia aletoria no fue evaluada
    if ~isempty(memoria)
        inx = ismember(memoria, shufled,'rows');
        S = sum(inx);
        if S > 0
            continue;
        end
    end
    %% Divide en entrenamiento y prueba. Genera los histogramas
    [ Mask_e, Mask_p ] = mask2HO(Mask, shufled, GT, ML);
    [cie_ab_e, cie_la_e, cie_lb_e] =Img2Hist2DABLALB(Lab, Mask_e) ;
    [cie_ab_p, cie_la_p, cie_lb_p] =Img2Hist2DABLALB(Lab, Mask_p) ;
    memoria = [memoria;shufled];
    %% Compara los histogramas
    prom = cmpHistogramas(cie_ab_e, cie_la_e, cie_lb_e, cie_ab_p, cie_la_p, cie_lb_p);
    if exist('minValue', 'var')
        %%  Si es una mejora se registra
        if (prom < minValue) 
            minValue = prom;
            maskMejor = struct('mask_e', Mask_e, 'mask_p', Mask_p, ...
                               'landrace',populationName,  'distance', minValue );
            registro = [registro; maskMejor];
            progreso = [progreso, minValue];
            h = size(progreso, 2);
            plot(progreso,'r-','linewidth',2), text(1:h,progreso,string(progreso)),
            title(strcat(populationName, ''));
            str = strcat('Corrida: ',num2str(contador), ' encontrado: ', num2str(minValue));
            disp(str);
            log = [log; {str}];         
            pause(0.1);      
        end
        contador =  contador + 1;
        if contador > 250
            beep;
%             choice = questdlg('Continuar con las iteraciones', ...
%                 'Continuar', 'Si','No','');
%             
%             switch choice
%                 case 'No'
                    completo = strcat(populationName,'.mat');
                    nombredatos = strcat(dirEntrena,'/H_',completo);
                    save(nombredatos,'registro');
                    dat = registro(end);
                    
                    [imagenE, imagenP, imagenT] = separaImagen(I_rgb, dat.mask_e, dat.mask_p);
                    
                    filename = strcat(dirEntrena, '/',populationName,'_entrenamiento.jpg');
                    imwrite(imagenE,filename,'jpg');
                    filename = strcat(dirEntrena, '/',populationName,'_prueba.jpg');
                    imwrite(imagenP,filename,'jpg');
                    filename = strcat(dirEntrena, '/',populationName,'_completa.jpg');
                    imwrite(imagenT,filename,'jpg'); 
                    
                    fid = fopen( strcat(dirEntrena, '/',populationName,'.txt'), 'wt' );
                    fprintf( fid, '%s\n', string(log));
                    fclose(fid);
                    
                    figure1 = figure;
                    axes1 = axes('Parent',figure1);
                    hold(axes1,'all');
                    plot(progreso,'r-','linewidth',2), text(1:h,progreso,string(progreso)),
                    title(strcat(populationName, ''));
                    strImg = strcat(dirEntrena,'/',populationName,'.eps');
                    saveas(figure1, strImg);
                    close all;
                    limite = true;
%                 case 'Si'
%                     disp([choice ' Continuando...']);
%                     contador = 1;
%             end
        end % if contador > 50
    else
        minValue = prom;
        maskMejor = struct('mask_e', Mask_e, 'mask_p', Mask_p, ...
            'landrace', populationName, ...
            'distance', minValue  );
        registro = [registro; maskMejor];
        progreso = [progreso, minValue];
        h = size(progreso, 2);
        plot(progreso,'r-','linewidth',2), text(1:h,progreso,string(progreso)),
        title(strcat(populationName, ''));
        pause(0.1);
    end
end

end

function [imagenE, imagenP, imagenT] = separaImagen(I, Mask_e, Mask_p)
I = uint8(I / 256);
tam = 50/100;
total =  ~Mask_e + ~Mask_p;
borde1 = ~Mask_e;
imagenE=double(I);  % Obtenci?n de la imagen para dejar la parte segmentada
imagenE(:,:,1)= imagenE(:,:,1).*borde1;
imagenE(:,:,2)= imagenE(:,:,2).*borde1;
imagenE(:,:,3)= imagenE(:,:,3).*borde1;
imagenE=uint8(imagenE);
[r c z] = size(imagenE);
for j=1:r
    for k=1:c
        if (imagenE(j,k,1)==0 && imagenE(j,k,2)==0 && imagenE(j,k,3)==0)
            imagenE(j,k,1)=255;
            imagenE(j,k,2)=255;
            imagenE(j,k,3)=255; % change value out of white
        end
        
    end
end

borde2 = ~Mask_p;
imagenP=double(I);  % Obtenci?n de la imagen para dejar la parte segmentada
imagenP(:,:,1)= imagenP(:,:,1).*borde2;
imagenP(:,:,2)= imagenP(:,:,2).*borde2;
imagenP(:,:,3)= imagenP(:,:,3).*borde2;
imagenP=uint8(imagenP);
[r c z] = size(imagenP);
for j=1:r
    for k=1:c
        if (imagenP(j,k,1)==0 && imagenP(j,k,2)==0 && imagenP(j,k,3)==0)
            imagenP(j,k,1)=255;
            imagenP(j,k,2)=255;
            imagenP(j,k,3)=255; % change value out of white
        end
        
    end
end

borde3 = total;
imagenT=double(I);  % Obtenci?n de la imagen para dejar la parte segmentada
imagenT(:,:,1)= imagenT(:,:,1).*borde3;
imagenT(:,:,2)= imagenT(:,:,2).*borde3;
imagenT(:,:,3)= imagenT(:,:,3).*borde3;
imagenT=uint8(imagenT);
[r c z] = size(imagenT);
for j=1:r
    for k=1:c
        if (imagenT(j,k,1)==0 && imagenT(j,k,2)==0 && imagenT(j,k,3)==0)
            imagenT(j,k,1)=255;
            imagenT(j,k,2)=255;
            imagenT(j,k,3)=255; % change value out of white
        end
        
    end
end

imagenE = imresize(imagenE, tam);
imagenP = imresize(imagenP, tam);
imagenT = imresize(imagenT, tam);

end


function prom = cmpHistogramas(cie_ab_e, cie_la_e, cie_lb_e, cie_ab_p, cie_la_p, cie_lb_p)

%dist1 = sum(sum(pdist2(cie_ab_e, cie_ab_p,'cityblock')));
%dist2 = sum(sum(pdist2(cie_la_e, cie_la_p,'cityblock')));
%dist3 = sum(sum(pdist2(cie_lb_e, cie_lb_p,'cityblock')));
dist1 = sum(sum(abs(cie_ab_e - cie_ab_p)));
dist2 = sum(sum(abs(cie_la_e - cie_la_p)));
dist3 = sum(sum(abs(cie_lb_e - cie_lb_p)));
prom = mean([dist1, dist2, dist3]);

end

function [ Mask_e, Mask_v ] = mask2HO( Mask, shufled, GT, ML)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mask2trainingandtest Binary processing for create two binary images
% Mask: Binary image
% Outcome
% Mask_e : Binary image with ROI for training
% Mask_v : Binary image with ROI for testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mask_e  = uint8(Mask);
Mask_v  = uint8(Mask);
N = round(GT/2); 
trainingbeans = shufled(1:N);
for i=1:length(trainingbeans)
    index = ML == trainingbeans(i);
    Mask_v(index) = 0;
end
testbeans = shufled(N+1:GT);
for i=1:length(testbeans)
    index = ML == testbeans(i);
    Mask_e(index) = 0;
end
Mask_e = ~Mask_e;
Mask_v = ~Mask_v;
end

function  buscaHomogeneizar3DLAB(I_rgb, I_Lab, L, color, populationName, valantocianinas, dirEntrena)

log = [];
registro = [];
progreso = [];
memoria = []; % Con la finalidad de conocer si la secuencia aleatoria ya fue evaluada
aDouble = double(I_Lab); % Converting to double so can have decimals
Lab= [];
% 16 bits
Lab(:,:,1) = aDouble(:,:,1)*100/65280; % L
Lab(:,:,2) = aDouble(:,:,2)/256 - 128; % a
Lab(:,:,3) = aDouble(:,:,3)/256 - 128 ; % b

Mask = uint8(L.Mask);
if(Mask(1,1)==0)
    disp([archivo, populationName])
end

if ~isnumeric(Mask)
    error('MyComponent:incorrectType',...
        'Error. \nEntrada debe ser tipo logical, y no del tipo %s.',class(Mask));
end
Mask = ~Mask;
% Limpieza de pixeles
[ML, ~]=bwlabel(Mask);         % Etiquetar granos de frijol conectados
propied= regionprops(ML);      % Calcular propiedades de los objetos de la imagen
s=find([propied.Area] < 700); % grupos menores a 100 px
for i=1:size(s,2)              % eliminación de pixeles
    index = ML == s(i);
    Mask(index) = 0;
end

[ML, GT] = bwlabel(Mask);   % Etiquetar granos de frijol conectados

limite = false;
contador = 1;
while(limite == false)
    exemplar =  1:1:GT;         % de 1 en 1 hasta total de granos
    shufled = exemplar(randperm(length(exemplar))); % permutacion
    %% Verifica en memoria que la secuencia aletoria no fue evaluada
    if ~isempty(memoria)
        inx = ismember(memoria, shufled,'rows');
        S = sum(inx);
        if S > 0
            continue;
        end
    end
    %% Divide en entrenamiento y prueba. Genera los histogramas
    [ Mask_e, Mask_p ] = mask2HO(Mask, shufled, GT, ML);
    % [cie_ab_e, cie_la_e, cie_lb_e] =Img2Hist2DABLALB(Lab, Mask_e);
    % [cie_ab_p, cie_la_p, cie_lb_p] =Img2Hist2DABLALB(Lab, Mask_p);
    [ cielab_e ] = Img2Hist3DLab( Lab, Mask_e);
    [ cielab_p ] = Img2Hist3DLab( Lab, Mask_p);
    memoria = [memoria;shufled];
    %% Compara los histogramas
    prom = cmpHistogramas3D(cielab_e, cielab_p);
    if exist('minValue', 'var')
        %%  Si es una mejora se registra
        if (prom < minValue) 
            minValue = prom;
            maskMejor = struct('mask_e', Mask_e, 'mask_p', Mask_p, ...
                'color', color, ...
                'landrace', populationName, ...
                'antocianinas', valantocianinas, 'distance', minValue );
            registro = [registro; maskMejor];
            progreso = [progreso, minValue];
            h = size(progreso, 2);
            plot(progreso,'r-','linewidth',2), text(1:h,progreso,string(progreso)),
            title(strcat(populationName, ''));
            str = strcat('Corrida: ',num2str(contador), ' encontrado: ', num2str(minValue));
            disp(str);
            log = [log; {str}];         
            pause(0.1);      
        end
        %% Incremento de contador de iteraciones y verificacion de limite
        contador =  contador + 1;
        if contador > 200
            beep;
%             choice = questdlg('Continuar con las iteraciones', ...
%                 'Continuar', 'Si','No','');
%             
%             switch choice
%                 case 'No'
                    completo = strcat(populationName,'.mat');
                    nombredatos = strcat(dirEntrena,'/H_',completo{1});
                    save(nombredatos,'registro');
                    dat = registro(end);
                    % [cie_ab_e, cie_la_e, cie_lb_e] =Img2Hist2DABLALB(Lab, dat.mask_e) ;
                    % [cie_ab_p, cie_la_p, cie_lb_p] =Img2Hist2DABLALB(Lab, dat.mask_p) ;
                     [ cielab_e ] = Img2Hist3DLab( Lab, dat.mask_e);
                     [ cielab_p ] = Img2Hist3DLab( Lab, dat.mask_p);
                    completo = strcat(populationName,'.mat');
                    nombredatos = strcat(dirEntrena,'/',completo{1});
                    save(nombredatos, ...
                        'cielab_e', 'cielab_p', ...
                        'color', 'populationName', 'valantocianinas');
                    
                    [imagenE, imagenP, imagenT] = separaImagen(I_rgb, dat.mask_e, dat.mask_p);
                    
                    filename = strcat(dirEntrena, '/',populationName{1},'_entrenamiento.jpg');
                    imwrite(imagenE,filename,'jpg');
                    filename = strcat(dirEntrena, '/',populationName{1},'_prueba.jpg');
                    imwrite(imagenP,filename,'jpg');
                    filename = strcat(dirEntrena, '/',populationName{1},'_completa.jpg');
                    imwrite(imagenT,filename,'jpg'); 
                    
                    fid = fopen( strcat(dirEntrena, '/',populationName{1},'.txt'), 'wt' );
                    fprintf( fid, '%s\n', string(log));
                    fclose(fid);
                    
                    figure1 = figure;
                    axes1 = axes('Parent',figure1);
                    hold(axes1,'all');
                    plot(progreso,'r-','linewidth',2), text(1:h,progreso,string(progreso)),
                    title(strcat(populationName, ''));
                    strImg = strcat(dirEntrena,'/',populationName{1},'.eps');
                    saveas(figure1, strImg);
                    close all;
                    limite = true;
%                 case 'Si'
%                     disp([choice ' Continuando...']);
%                     contador = 1;
%             end
        end % if contador > 50
    else
        minValue = prom;
        maskMejor = struct('mask_e', Mask_e, 'mask_p', Mask_p, ...
            'color', color, ...
            'landrace', populationName, ...
            'antocianinas', valantocianinas, 'distance', minValue  );
        registro = [registro; maskMejor];
        progreso = [progreso, minValue];
        h = size(progreso, 2);
        plot(progreso,'r-','linewidth',2), text(1:h,progreso,string(progreso)),
        title(strcat(populationName, ''));
        pause(0.1);
    end
end

end
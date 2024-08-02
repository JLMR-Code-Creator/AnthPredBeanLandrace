function SearchPartitions(pathImg, file, dirOut)

%dbPopulations = dir(strcat(pathImg,file)); % Cargar todas las muestras de entrenamiento
matfile = dir(strcat(pathImg,'Masks/*.mat'));                       % Cargar mascara de cada poblaci?n
listPopulationfile = dir(strcat(pathImg,'*.tif'));   % Cargar mascara de cada poblaci?n
imgPopulations = struct2cell(listPopulationfile(:,1));
clase = {'P-01','N';'P-07','B';'P-08','N';'P-09','R';'P-16','N';'P-18','N';'P-23A','X';'P-23B','N';'P-23C','R';'P-24A','A';'P-24B','B';'P-24C','A';'P-28','R';'P-29','N';'P-34A','X';'P-34B','A';'P-40','R';'P-45','N';'P-48','N';'P-49','N';'P-50','B';'P-55','N';'P-56A','A';'P-56B','N';'P-58','R';'P-59','A';'P-60','C';'P-61','N';'P-62','R';'P-63','R';'P-65','A';'P-66','N';'P-67','B';'P-68','X';'P-71','X';'P-72A','A';'P-72B','MX';'P-72C','R';'P-76','R';'P-93C2','N';'P-98C2','N';'FCA-06','N';'FCA-08','A';'FCA-12','N';'FCA-14','N';'FRIJOLON','X';'POB-02','B';'POB-03','MX';'POB-04','N';'POB-05','B';'POB-06','N';'POB-08','N';'POB-09','R';'POB-11','A';'POB-13','N';'POB-17','MX';'POB-18','N';'POB-19','R';'POB-20','MX';'POB-22','X';'POB-23','X';'POB-26','MX';'POB-28','MX';'POB-29','N';'POB-30','N';'POB-31','MX';'POB-32','X';'POB-33','MX';'POB-34','X';'POB-35','MX';'POB-39','MX';'POB-40','R';'POB-41','N';'POB-43','MX';'POB-44','N';'POB-46','N';'POB-48','N';'POB-49','N';'POB-50','B';'POB-51','MX';'POB-52','N';'POB-54','MX';'POB-55','N';'POB-56','MX';'POB-57','A';'POB-58','R';'POB-59','A';'POB-61','N';'POB-62','R';'POB-63','R';'POB-64','R';'POB-65','A';'POB-66','MX';'POB-67','B';'POB-68','MX';'POB-69','MX';'POB-71','X';'POB-72','MX';'POB-74','MX';'POB-76','R'};
antocianinas = [3.41872459338818,3.57520948935992,3.67834392549964,3.71128075902173;0,0,0,0;4.35675943349099,4.54402801937382,4.49713651801824,4.59947952059964;0.566810497547752,0.591651664842017,0.727034225205825,0.708316432670444;7.53517924365739,8.51923017801079,8.96885963746899,8.50697182066008;5.93638629566411,5.99558535837924,6.11345484127524,6.35355065741438;0,0,0,0;4.12600047338596,4.24287181914800,3.97775357011914,4.23705535367037;0.563137831095809,0.655468810466571,0.633859913582405,0.575203871106175;0,0,0,0;0,0,0,0;0,0,0,0;0.0165122921710519,0.0175443104317427,0.0174951667050431,0.0175443104317427;3.65975569000486,3.68246726464994,3.81662425364755,3.64715080424317;0.947533376015421,0.936017330304282,0.976624997934738,0.953412001927578;0,0,0,0;0.786190970942807,0.891682798376790,0.810616122266675,0.788708861052360;1.53256741094935,1.47610772724728,1.45783718626231,1.55151265434880;2.33897749110180,4.58555457895837,2.13182852354967,2.52156688748955;2.29534496707390,2.44987981732197,2.49070767783337,2.52034989672776;0,0,0,0;2.56475974963716,2.37927860819871,2.64909081481583,2.50706154762357;0,0,0,0;3.30737074886243,3.47323873058142,3.55218618147680,3.48625650856251;0.0226957218262852,0.0225112037626569,0.0229417459111230,0.0228187338687041;0,0,0,0;0,0,0,0;2.54299930519736,2.84397377312175,2.70439178499804,2.78765789469706;0.0167733355952099,0.0172988709141199,0.0165981571555732,0.0170361032546649;0.0115010304769049,0.0132305087441087,0.0132305087441087,0.0131007978740684;0,0,0,0;5.46867359374035,5.77292607077627,5.44379111477312,5.82670555486622;0,0,0,0;0.881129175194900,0.958719952860027,1.00264100403521,0.992738448598077;0.00199037212271413,0.00197350456235215,0.00175422627764635,0.00177109383800834;0,0,0,0;0,0,0,0;0.00894328387058917,0.00909523286839044,0.00926888886587761,0.00952937286210836;0.00255752905415622,0.00393778282941513,0.00495267531122315,0.00487148391267851;3.17655846800229,3.24792749895438,3.37939262604636,3.26021809433356;2.33127345439098,2.34674263048095,2.39147935849522,2.37182994265803;4.94517673074104,2.69651144135839,3.31837496442403,3.97893405888560;0,0,0,0;2.16238977159848,2.28117313185833,2.25127488106902,2.26622400646368;1.90951634519144,2.20437965833181,1.93632613275428,2.58936900021883;0.00339638334068427,0.00339638334068427,0.00279258185789595,0.00313222019196438;0.00000000000000,0.000000000000,0.0000000000000,0.000000000000;0.287600000000000,0.324000000000000,0.271100000000000,0.334100000000000;3.08710000000000,2.92760000000000,2.94420000000000,2.97770000000000;0,0,0,0;0.878300000000000,0.894000000000000,0.894000000000000,0.860200000000000;3.33540000000000,3.33490000000000,3.33050000000000,3.37170000000000;0.467900000000000,0.490800000000000,0.594100000000000,0.556900000000000;0,0,0,0;3.14470000000000,3.10670000000000,3.03320000000000,3.05180000000000;0.100400000000000,0.0766000000000000,0.104400000000000,0.0745000000000000;4.12430000000000,4.18270000000000,4.10410000000000,4.08910000000000;0.265800000000000,0.317100000000000,0.265400000000000,0.282000000000000;0.656700000000000,0.647600000000000,0.580500000000000,0.580400000000000;0.305900000000000,0.336900000000000,0.342200000000000,0.314200000000000;1.69050000000000,1.58450000000000,1.62940000000000,1.54070000000000;0.691700000000000,0.757400000000000,0.622800000000000,0.764000000000000;0.204000000000000,0.175700000000000,0.179900000000000,0.204500000000000;3.42430000000000,3.27780000000000,3.27600000000000,3.31140000000000;2.89260000000000,2.83070000000000,2.93650000000000,2.83030000000000;2.04000000000000,1.92970000000000,1.99520000000000,1.96880000000000;2.17940000000000,2.42160000000000,2.23500000000000,2.20580000000000;1.51580000000000,1.39160000000000,1.46890000000000,1.54620000000000;0.255100000000000,0.275500000000000,0.248600000000000,0.248100000000000;1.19520000000000,1.14700000000000,1.18260000000000,1.18900000000000;0.318500000000000,0.300300000000000,0.336700000000000,0.326600000000000;0.430500000000000,0.384800000000000,0.341500000000000,0.353500000000000;6.15820000000000,5.98580000000000,6.01300000000000,6.02660000000000;0.0230000000000000,0.0220000000000000,0.0270000000000000,0.0219000000000000;2.95880000000000,2.83150000000000,2.84740000000000,2.84740000000000;2.76790000000000,2.73880000000000,2.68210000000000,2.76720000000000;2.73500000000000,2.68040000000000,2.71550000000000,2.61490000000000;2.08420000000000,2.00100000000000,1.93530000000000,1.96770000000000;0,0,0,0;1.33700000000000,1.28440000000000,1.32070000000000,1.29880000000000;2.75450000000000,2.62620000000000,2.70610000000000,2.73580000000000;0.326800000000000,0.362900000000000,0.388900000000000,0.366600000000000;3.09370000000000,2.93010000000000,2.91220000000000,2.89320000000000;1.97700000000000,1.79090000000000,1.87220000000000,1.90280000000000;0,0,0,0;0.139300000000000,0.135200000000000,0.123100000000000,0.126100000000000;0,0,0,0;3.19490000000000,3.24400000000000,3.54880000000000,3.20880000000000;0.185800000000000,0.253600000000000,0.255500000000000,0.185600000000000;0.0648000000000000,0.0682000000000000,0.0782000000000000,0.0764000000000000;0.194700000000000,0.192900000000000,0.221600000000000,0.198800000000000;0,0,0,0;5.51410000000000,5.47930000000000,5.37500000000000,5.44450000000000;0,0,0,0;0.700500000000000,0.684300000000000,0.605100000000000,0.700300000000000;0.862700000000000,0.931600000000000,0.948600000000000,0.882200000000000;0.208500000000000,0.221300000000000,0.205400000000000,0.202400000000000;0.106200000000000,0.103100000000000,0.100800000000000,0.108100000000000;0,0,0,0;0.141100000000000,0.132000000000000,0.149000000000000,0.159300000000000];

%% Iterar poblaciones para encontrar la mejor
iteraPoblacion(pathImg, dirOut, matfile, imgPopulations, antocianinas, clase);


end



function iteraPoblacion(pathImg, dirOut, matfile, imgPopulations, antocianinas, clase)

finalDir = dirOut;
mkdir(finalDir);
dirEntrena = strcat(finalDir,'/Experimento');
mkdir(dirEntrena);

for k = 1:100           % Recorrer las imagenes
    %for k = 1:length(matfile)            % Recorrer las imagenes
    %Inicializaci?n de variables
    archivo = matfile(k).name;        % Nombre del imagen
    populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
    disp([datestr(datetime), ' Procesando población ',populationName]);
    nombre=strcat(pathImg,'Masks/');
    L = load(strcat(nombre,archivo)); % Carga el archivo de la m?scara
    % carga la imagen de la poblaci?n
    pos= ~cellfun(@isempty,strfind(upper(imgPopulations(1,:)),populationName));
    file = imgPopulations(1,pos);
    index = find(strcmpi(strtrim(clase(:,1)), strtrim(populationName)));
    color = clase(index(1),2);
    landrace =  clase(index(1),1);
    valantocianinas = antocianinas(index, :);
    I_rgb = imread(strcat(pathImg,file{1}));    
    I_Lab = ColorCalibration(I_rgb);
    
    buscaHomogeneizar(I_rgb, I_Lab, L, color, landrace, valantocianinas, dirEntrena)
    %buscaHomogeneizarLAB(I_rgb, I_Lab, L, color, landrace, valantocianinas, dirEntrena)
    
end

end

function  buscaHomogeneizarLAB(I_rgb, I_Lab, L, color, populationName, valantocianinas, dirEntrena)

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

function dist1 = cmpHistogramas3D(cielab_e, cielab_p)
 dist1 = sum(sum(sum(abs(cielab_e - cielab_p))));
end

function  buscaHomogeneizar(I_rgb, I_Lab, L, color, populationName, valantocianinas, dirEntrena)

log = [];
registro = [];
progreso = [];
memoria = []; % Con la finalidad de conocer si la secuencia aleatoria ya fue evaluada
Lab = double(I_Lab); % Converting to double so can have decimals
%Lab= [];
% 16 bits
%Lab(:,:,1) = aDouble(:,:,1)*100/65280; % L
%Lab(:,:,2) = aDouble(:,:,2)/256 - 128; % a
%Lab(:,:,3) = aDouble(:,:,3)/256 - 128 ; % b

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
s=find([propied.Area] < 1000); % grupos menores a 100 px
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
        if contador > 50
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
                     [cie_ab_e, cie_la_e, cie_lb_e] =Img2Hist2DABLALB(Lab, dat.mask_e) ;
                     [cie_ab_p, cie_la_p, cie_lb_p] =Img2Hist2DABLALB(Lab, dat.mask_p) ;
                    completo = strcat(populationName,'.mat');
                    nombredatos = strcat(dirEntrena,'/',completo{1});
                    save(nombredatos, ...
                        'cie_ab_e', 'cie_la_e', 'cie_lb_e', ...
                        'cie_ab_p', 'cie_la_p', 'cie_lb_p', ...
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
% mask2trainingandtest Procesamiento binario de la mascara se segmentación
% eliminación de regiones con pocos pixeles y separación de la mascara
% para obtención de granos de muestra de entrenamiento y de prueba
% Mask: imagen binaria.
% Resultado
% Mask_e : matriz de nxm con valores binarios.
% Mask_v : matriz de nxm con valores binarios.
%Mascaras de segmentación para granos de frijol para entrenamiento y prueba
Mask_e  = uint8(Mask);
Mask_v  = uint8(Mask);
N = round(GT/2);  % División para entrenamiento y validación
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
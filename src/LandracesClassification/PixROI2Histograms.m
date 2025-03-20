function PixROI2Histograms(pathDB, file)
    %% Second step
    %% 2. function for create three types of color characterizations
    dbPopulations = dir(strcat(pathDB,file)); % Load data
    folder_3H2D_LAB = strcat(pathDB, '3H2D_LAB_05');
    if ~exist(folder_3H2D_LAB, 'dir')
       mkdir(folder_3H2D_LAB)
    end
    folder_3H2D_LCH = strcat(pathDB, '3H2D_LCH_05');
    if ~exist(folder_3H2D_LCH, 'dir')
       mkdir(folder_3H2D_LCH)
    end
    folder_H3D = strcat(pathDB, '1H3D_05');
    if ~exist(folder_H3D, 'dir')
       mkdir(folder_H3D)
    end

    for j = 1 : length(dbPopulations)
        archivo = dbPopulations(j).name;            % Nombre del imagen
        populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
        disp([datestr(datetime), ' Procesando población ',populationName]);
        load(strcat(dbPopulations(j).folder,'/',archivo)); % Carga el archivo de la m?scara

   
        [Classquatities, ClassCategories] = sortArrayElements(listClasses);
        clase = '';
        if numel(ClassCategories)>1
            tblLbl = {};
            for m = 1:length(ClassCategories)
                val = ClassCategories{m};
                quantitie = Classquatities(m);
                percentage = quantitie/sum(Classquatities);
                if percentage > 0.5
                        if isempty(clase)
                           clase = val;
                        else
                           clase = [clase, ' ', val];
                        end
                        
                   clase = strcat(clase, ' ', val);
                end
                tblLbl = [tblLbl; val ,{m}, {quantitie}, {percentage}];
            end
            tblLbl

            [Quatities, Categories] = sortArrayElements(listClassesByLandraces);
            tblSeeds = {};
            for m = 1:length(Categories)
                val = Categories{m};
                quant = Quatities(m);
                percentage = quant/sum(Quatities);
                tblSeeds = [tblSeeds; val ,{m}, {quant}, {percentage}];
            end
            tblSeeds
            %clase = strip(clase, 'left');
            for i=1:6
                C{i,1}=cat(1, strjoin(v(i,:)));
            end
            idc = strfind(my_cell_array,'Red');   % search for 'bore' in all cells.
            idx = ~cellfun('isempty',idc)
            my_cell_array(idx)


        else
            clase = ClassCategories{1};
        end
        
        %clase = finalClass;
        [H3D] = Pixles2H3DLAB(Final_Lab_Values);           
        dirFile = strcat(folder_H3D,'/', populationName);
        save(dirFile, 'H3D', 'clase', '-v7');
        clase = cellstr(clase);
        [cie_ab, cie_la, cie_lb, ~] = Pixel2DABLALB(Final_Lab_Values);
        dirFile = strcat(folder_3H2D_LAB,'/', populationName);
        save(dirFile, 'cie_ab', 'cie_la', 'cie_lb', 'clase',"populationName", '-v7');
        [cie_ch, cie_lc, cie_lh, ~] = Pixels2Hist2DCHLCLH(Final_Lab_Values); 
        dirFile = strcat(folder_3H2D_LCH,'/', populationName);
        save(dirFile, 'cie_ch', 'cie_lc', 'cie_lh', 'clase', "populationName",'-v7');
    end % for
end
function [Classquatities, ClassCategories] = sortArrayElements(idx)
    categoricItems = categorical(idx);
    ClassCategories = categories(categoricItems);
    Classquatities = countcats(categoricItems);
    [Xsorted,Indx] = sort(Classquatities, "descend");
    Classquatities = Xsorted;
    ClassCategories = ClassCategories(Indx);
end
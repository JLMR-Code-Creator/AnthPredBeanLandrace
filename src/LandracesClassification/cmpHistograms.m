%% Función que permite comparar distribuciones de probabilidad conjunta para asignar etiqueta a cada nueva distribución
function cmpHistograms(pathDB, folderImage1, folderImage2)
    matfile = dir(strcat(pathDB,'/*.mat'));
    listClasses = cell(1, length(matfile));
    listNames = cell(1,length(matfile));
    train_3Hlab = [];
    for i = 1:length(matfile)  % Iteration to each sample landraces
        archivo = matfile(i).name;        % File name
        rutadbFile = strcat(pathDB,filesep, archivo);
        L = load(rutadbFile); % load file mask
        clase = strrep(L.clase,' ', '-');

        listClasses(1, i) = cellstr(clase);
        listNames(1, i) = cellstr(L.populationName);    
        sizelab = size(L.cie_ab, 1) * size(L.cie_ab, 2);
        cie_ab_e = reshape(L.cie_ab, sizelab, 1)';
        cie_la_e = reshape(L.cie_la, sizelab, 1)';
        cie_lb_e = reshape(L.cie_lb, sizelab, 1)';
        train_lab = [cie_ab_e, cie_la_e, cie_lb_e];
        train_3Hlab = [train_3Hlab;train_lab];
    
    end
 [ prediccion ] = comparar(pathDB, train_3Hlab, train_3Hlab, listNames, listClasses,'cityblock' )

end

function [ prediccion ] = comparar(pathDB, training, test, trainingLabel, trainingLabelColor, Distance )
 color = {};
 landraces={};
 %similares = {};
 list_predicted_class = {};
 list_predicted_superClass = {};
   prediccion = [];
   for i_ = 1 : size(test, 1) 
      classify_this_histogram = test(i_,:);  % vector a clasificar
      l = trainingLabel(i_);
      c = trainingLabelColor(i_);
      [predicted_class, predicted_Superclass]= HistogramDistance(training, trainingLabel, trainingLabelColor,classify_this_histogram, Distance);
      color = [color; c];
      landraces = [landraces; l]; 
      list_predicted_class = [list_predicted_class; strrep(strjoin(predicted_class), ' ', ',')];
      list_predicted_superClass = [list_predicted_superClass; strrep(strjoin(predicted_Superclass), ' ', ',')];
      %list_predicted_class=[list_predicted_class;predicted_class];
      % almacena los vecinos más cercanos de cada vector del conjunto de entrenamiento
      %data = struct('trainingLabel', trainingLabel{i_}, ...
      %          'predictedLabel',predicted_class);
      %prediccion = [prediccion;data];
   end % end for
   tbl_simil = table(color,landraces,list_predicted_class, list_predicted_superClass);
   ruta = strcat(pathDB, '/similares.csv');
    writetable(tbl_simil,ruta,'Delimiter',',');
   end
             
   function [predicted_class, predicted_Superclass]= HistogramDistance(train,train_class_labels, train_superClass_labels,unknown_histogram, Distance)
   unknown_histogram = unknown_histogram + 1;
   list_distances=zeros(1,length(train_class_labels));
   for i = 1 : size(train_class_labels, 2)
       compare_to_this_histogram = train(i,:);
       compare_to_this_histogram = compare_to_this_histogram + 1;
       if strcmp(Distance,'Euk') % Euclidean distance
           list_distances(i) = sqrt(sum((compare_to_this_histogram - unknown_histogram).^2));
       elseif strcmp(Distance,'KL') % Kullback?Leibler distance
           list_distances(i) = sum(compare_to_this_histogram .* log(compare_to_this_histogram ./ unknown_histogram)  );
       elseif strcmp(Distance,'Manh') % Manhattan distance
           list_distances(i) = sum(abs(compare_to_this_histogram - unknown_histogram));
       elseif strcmp(Distance,'KS') % Kolmogorov?Smirnov distance
           list_distances(i) = max(abs(compare_to_this_histogram - unknown_histogram));
       elseif strcmp(Distance,'X2') % Chi-square distance
           d_item = ( compare_to_this_histogram - unknown_histogram ).^2 ./  (unknown_histogram );
           d_item(isnan(d_item) | isinf(d_item)) = 0;
           list_distances(i) = sum(d_item)/2;
       elseif strcmp(Distance,'Int') % Histogram intersection
           d_item = sum(min(compare_to_this_histogram - unknown_histogram));
       elseif strcmp(Distance,'Jeff') % Jeffrey-divergence distance
           list_distances(i) = sum(compare_to_this_histogram .* log(compare_to_this_histogram ./ unknown_histogram) + ...
               unknown_histogram .* log(unknown_histogram ./ compare_to_this_histogram));
       elseif strcmp(Distance,'cityblock') % Kolmogorov?Smirnov distance
           list_distances(i) = sum(abs(compare_to_this_histogram - unknown_histogram));
       end

   end % end for
       [list_distances, orden]=sort(list_distances,'ascend');
       valor_similitud = list_distances(1);
       predicted_class=train_class_labels(orden(2:11));
       predicted_Superclass=train_superClass_labels(orden(2:11));
   end
%------------------------
% K_Nearest_Neighbor
%------------------------
function [Accuracy, confusionM, neighbor]=k_nearest(TRAIN,TEST,TRAIN_class_labels,TEST_class_labels,k, alternates)
correct = 0; % Initialize the number we got correct
est_lab = [];
neighbor = [];
if (alternates)
    disp('K-NN: Clasificará de prueba sin su vector de entrenamiento');
else
    disp('K-NN: Clasificación con entrenamiento y prueba');
end
for i = 1 : length(TEST_class_labels) % Loop over every instance in the test set
   classify_this_object = TEST(i,:);  % vector a clasificar
   if (alternates)
       % para clasificar vector de prueba sin considerar su vector de entrenamiento       
       train = TRAIN; 
       train(i,:) = []; % Menos el vector de entrenamiento
       trainLabel = TRAIN_class_labels;
       trainLabel(i,:) = [];% eliminar la clase del vector de entrenamiento
       [predicted_class, clases ]= KNN(train,trainLabel, classify_this_object,k); 
   else
       [predicted_class, clases ]= KNN(TRAIN,TRAIN_class_labels, classify_this_object,k); 
   end
   est_lab=[est_lab;predicted_class];
   % almacena los vecinos más cercanos de cada vector del conjunto de
   % entrenamiento
   data = struct('trainingLabel', TRAIN_class_labels{i}, ...
                'predictedLabel',predicted_class, 'neighbor', clases);
   neighbor = [neighbor;data]; 
   
end;
disp('K-NN:  Calculando precisión y matriz de confusión.');
[Accuracy, confusionM]=accuracy(TEST_class_labels,est_lab);
disp('K-NN: finalización de algoritmo.');
 
function [predicted_class, clases ]= KNN(TRAIN,TRAIN_class_labels,unknown_object,k)
 
 distance=zeros(1,length(TRAIN_class_labels));
for i = 1 : length(TRAIN_class_labels)
     compare_to_this_object = TRAIN(i,:);
     %K vecinos mas cercanos
     %distance(i) = sqrt(sum((compare_to_this_object - unknown_object).^2)); % Euclidean distance                
     %distance(i) = 1-(sum(min(compare_to_this_object,unknown_object))); %
     %intersección
     %d1 = sum(sqrt(compare_to_this_object.*unknown_object));
     %distance(i)   = sqrt (1 - d1); %bhattacharyya
     % distancia camberra
     %c = (compare_to_this_object+unknown_object);
     %c(c==0) = 1; % both are zero
     %distance(i) = sum (abs(compare_to_this_object-unknown_object) ./ c);
     %chi cuadrada
     %disp('chi cuadrada');
     %d_item = ( compare_to_this_object - unknown_object ).^2 ./  (compare_to_this_object + unknown_object );
     %d_item(isnan(d_item) | isinf(d_item)) = 0;
     %distance(i) = sum(d_item)/2;     
     distance(i) = sum(abs(compare_to_this_object - unknown_object));

     
     
     
     
end;
%k Vecinos mas cercanos
[distance, orden]=sort(distance,'ascend');
best_so_far=distance(1:k);
clases=TRAIN_class_labels(orden(1:k));
[u f c]=unique(clases);
for i=1:size(u,1)
    contadores_u(i,1)=size(find(c==i),1);  
    contadores_u(i,2)=min(best_so_far(find(strcmp(clases,u(i)))));   
end
Orden_maximos_contadores=flip(sortrows(contadores_u,1),1);
Maximos_iguales=find(contadores_u(:,1)==Orden_maximos_contadores(1,1));
[V, Orden_minimos]=sortrows(contadores_u(Maximos_iguales,:),2);
predicted_class=u(Maximos_iguales(Orden_minimos(1)));
 
%-----------------
% Accuracy
%-----------------
function [ accuracy, confusionMatrix ] = accuracy( training_c_label, prediction_c_label )
 % confusionMatrix Genera matriz de confusión con datos de entrenamiento y
 % datos de predicción.
 % Entrada: 
 %         training_class_label vector de n x 1 que contiene el listado de
 % las clases de entrenamiento.
 %         prediction_class_label vector de n x 1 que contiene el listado
 % de las clases de predicción.
 % Salida
 %        accuracy: presición
 %        confusionMatrix: Matriz de confución de n x n
 
 if ~iscell(training_c_label) || ~iscell(prediction_c_label)  
    error('MyComponent:incorrectType',...
          'Error. \nEntrada debe ser tipo cell');
 end   
 
 confusionMatrix = zeros(length(unique(training_c_label)), length(unique(training_c_label)));
 positions = unique(training_c_label);
 success = 0;
 for i = 1: length(training_c_label) %recorrer todas las etiquetas de entrenamiento
     % obtención de las correctas
     if(strcmpi(training_c_label(i),prediction_c_label(i)))
        success = success + 1;
     end
     % llenado de la matriz, entrenamiento y predicción.
     col = find(strcmp(positions, training_c_label{i}));
     row = find(strcmp(positions, prediction_c_label{i}));
     confusionMatrix(col,row) = confusionMatrix(col,row) + 1;     
 end 
accuracy = success / length(training_c_label);


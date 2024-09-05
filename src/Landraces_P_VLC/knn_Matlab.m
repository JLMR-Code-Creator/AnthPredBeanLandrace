function [Accuracy] = knn_Matlab( train, test, labeltraining, labelTest, Distance, K, DW )
    %knn_Matlab funci�n clasificaci�n
    disp(['K = ',int2str(K)]);      % log sobre K procesamiento        
    Model = fitcknn(train,labeltraining,'NumNeighbors',K, 'Distance', Distance, 'DistanceWeight', DW);
    
    out = predict(Model,test);
%     confMat = confusionmat(labeltraining,out);
%     confMat = confMat./sum(confMat,2);
%     display('Accuracy: ')
    %Accuracy = mean(diag(confMat))*100;
%     confusionchart(labelTest,out);
    Accuracy = (sum(string(labelTest) == string(out),'all')/numel(out))*100;
    
%     predictedClass = [];
%     for i=1:size(test,1)  
%         test_v = test(i,:);
%         predicted_class = predict(Model,test_v);
%         predictedClass=[predictedClass;predicted_class];
%     end
%     [Accuracy1, confusionMatrix, fails]=accuracy(labelTest, predictedClass);
%     display('Accuracy: ')
%     Accuracy1*100
    
end  
  
%% functions
function [ accuracy, confusionMatrix, fails ] = accuracy( training_c_label, prediction_c_label )
 % confusionMatrix Genera matriz de confusi�n con datos de entrenamiento y
 % datos de predicci�n.
 % Entrada: 
 %         training_class_label vector de n x 1 que contiene el listado de
 %las clases de entrenamiento.
 %         prediction_class_label vector de n x 1 que contiene el listado
 % de las clases de predicci�n.
 % Salida
 %        accuracy: presici�n
 %        confusionMatrix: Matriz de confuci�n de n x n
 
 if ~iscell(training_c_label) || ~iscell(prediction_c_label)  
    error('MyComponent:incorrectType',...
          'Error. \nEntrada debe ser tipo cell');
 end   
 
 confusionMatrix = zeros(length(unique(training_c_label)), length(unique(training_c_label)));
 positions = unique(training_c_label);
 success = 0;
 fails = [];
 for i = 1: length(training_c_label) %recorrer todas las etiquetas de entrenamiento
     % obtenci�n de las correctas
     if(strcmpi(training_c_label(i),prediction_c_label(i)))
        % disp([training_c_label(i),' - ',prediction_c_label(i)]);
        success = success + 1;
     else
         fails = [fails;training_c_label(i),prediction_c_label(i)]; %registro de los fallos de clasificaci�n.
     end
     % llenado de la matriz, entrenamiento y predicci�n.
     col = find(strcmp(positions, training_c_label{i}));
     row = find(strcmp(positions, prediction_c_label{i}));
     confusionMatrix(col,row) = confusionMatrix(col,row) + 1;     
 end 
accuracy = success / length(training_c_label);
end

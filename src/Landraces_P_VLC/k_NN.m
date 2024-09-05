function [accuracyClase] = k_NN(train, test, train_clase, test_clase)
   accuracyClase = [];
   kvector = [1, 3, 5 ,7, 9];
   distance = 'cityblock';
   ponderar = 'squaredinverse';
   for K=1:length(kvector) 
       [Accu1] = knn_Matlab(train, test, train_clase, test_clase, distance, kvector(K), ponderar);
       accuracyClase = [accuracyClase, (Accu1)];       
   end  
 end

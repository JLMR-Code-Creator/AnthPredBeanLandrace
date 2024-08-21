function TrainCNNWith1H2DLABCurve(XTrainLAB, ...
    YTrainLAB, XTrainPop, XTrainColor, XValidationLAB, YValidationLAB, ...
    XValidationPop, XValidationColor, XTestLAB, YTestLAB, XTestPop, XTestColor, epoch, pathDB, dirOut, nameOut)
    rng('default') 
    rng(0, "threefry") 
    %gpurng(0, "threefry") 
  
    XTrain = XTrainLAB;
    YTrain = mean(YTrainLAB');
   
    XValidation = XValidationLAB;
    YValidation = mean(YValidationLAB');
   
    XTest = XTestLAB;
    YTest = mean(YTestLAB');
   
    altura = size(XTestLAB, 1);
    ancho =  size(XTestLAB, 1);

    % The network has 3 convolutional layers with: 
    % (16, 7, max, 2) (32, 2, max, 2) (16, 6, max, 4) 
    % and 2 fully-connected layers with: (4)(64) neurons


    canales = 1;
    imageSize = [altura ancho canales];
    inputLayer = imageInputLayer(imageSize);
    sizeFilter = [7 7];
    filtros  = 16;
    middleLayers = [
    convolution2dLayer([7 7], 16, 'Stride',1, 'Padding', 1);
    batchNormalizationLayer
    reluLayer();
    maxPooling2dLayer(2, 'Stride', 1, Padding=0);
    % Stack 2
    convolution2dLayer([2 2], 32, 'Stride',1, 'Padding', 1); 
    batchNormalizationLayer      
    reluLayer();
    maxPooling2dLayer(1, 'Stride',1, Padding=0);
    % Stack 3
    convolution2dLayer([6 6], 16, 'Stride',1, 'Padding', 1); 
    batchNormalizationLayer
    reluLayer();
    maxPooling2dLayer(4, 'Stride',1, Padding=0);
    
    ] 

    finalLayers = [
      fullyConnectedLayer(4)
      fullyConnectedLayer(64)
      fullyConnectedLayer(1)
      %regressionLayer  
    ]
    layers = [
        inputLayer
        middleLayers
        finalLayers
    ]

    % Valores aleatorios para los pesos de las capas ocultas
    layers(2).Weights = 0.0001 * randn([sizeFilter canales filtros]);

    options = trainingOptions('adam',...
        InitialLearnRate= 0.001, ...
        ValidationData ={XTrain, YTrain'},... 
        Plots ='training-progress',...
        MaxEpochs = epoch,... % 'ExecutionEnvironment','parallel',...
        Verbose = true)

   net = trainnet(XTrain, YTrain', layers, 'mse', options);
   
   YPredTrain = predict(net, XTrain);
     
   YPredValidation = predict(net, XValidation);  
   
   YPredTest = predict(net, XTest);   
   
   poblaciones = XTrainPop; 
   colores =  XTrainColor;
      
   [RMSE, R2, MAPE, ~, ~, precision, STD_precision, ~] = Performance(YTrain', YPredTest) 
   
   filenamemat = strcat(pathDB,dirOut, nameOut);
   save(filenamemat, 'XTrainLAB',   'YTrainLAB', 'YPredTrain',   'YPredValidation', 'YPredTest', 'XTrainPop', 'XTrainColor', 'net');
  
end
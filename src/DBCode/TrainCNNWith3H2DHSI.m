function TrainCNNWith2H2DHSI(XTrainHSI, YTrainHSI, XTrainPop, XTrainColor, ...
         XValidationHSI, YValidationHSI, XValidationPop, XValidationColor, ...
         XTestHSI, YTestHSI, XTestPop, XTestColor, epoch, pathDB, dirOut, nameOut)
   rng('default') 
   rng(0, "threefry") 
   %gpurng(0, "threefry") 
  
   XTrain = XTrainHSI;
   YTrain = mean(YTrainHSI');
   
   XValidation = XValidationHSI;
   YValidation = mean(YValidationHSI');
   
   XTest = XTestHSI;
   YTest = mean(YTestHSI');
   
    altura = size(XTestHSI, 1);
    ancho =  size(XTestHSI, 1);
    canales = 3;
    imageSize = [altura ancho canales];
    inputLayer = imageInputLayer(imageSize);
     sizeFilter = [7 7];
     filtros  = 16;

     

     % The network has 3 convolutional layers with: 
     % (16, 7, max, 2) (32, 2, max, 2) (16, 6, max, 4) and 2 
     % fully-connected layers with: (4)(64) neurons

%     CNN(
%   (extraction): Sequential(
%     (0): Conv2d(3, 16, kernel_size=(7, 7), stride=(1, 1), padding=(1, 1))
%     (1): BatchNorm2d(16, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
%     (2): ReLU(inplace=True)
%     (3): MaxPool2d(kernel_size=2, stride=2, padding=0, dilation=1, ceil_mode=False)

%     (4): Conv2d(16, 32, kernel_size=(2, 2), stride=(1, 1), padding=(1, 1))
%     (5): BatchNorm2d(32, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
%     (6): ReLU(inplace=True)
%     (7): MaxPool2d(kernel_size=2, stride=2, padding=0, dilation=1, ceil_mode=False)

%     (8): Conv2d(32, 16, kernel_size=(6, 6), stride=(1, 1), padding=(1, 1))
%     (9): BatchNorm2d(16, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
%     (10): ReLU(inplace=True)
%     (11): MaxPool2d(kernel_size=4, stride=2, padding=0, dilation=1, ceil_mode=False)
%   )
%   (classifier): Sequential(
%     (0): Linear(in_features=13456, out_features=4, bias=True)
%     (1): ReLU(inplace=True)
%     (2): Linear(in_features=4, out_features=64, bias=True)
%     (3): ReLU(inplace=True)
%     (4): Linear(in_features=64, out_features=1, bias=True)
%   )
% )

    middleLayers = [
    convolution2dLayer([7 7], 16, 'Stride',1, 'Padding', 1);
    batchNormalizationLayer
    reluLayer();
    maxPooling2dLayer(2, 'Stride', 2, Padding=0);
    % Stack 2
    convolution2dLayer([2 2], 32, 'Stride',2, 'Padding', 1); 
    batchNormalizationLayer
    reluLayer();
    maxPooling2dLayer(2, 'Stride',2);
    % Stack 3
    convolution2dLayer([6 6], 16, 'Stride',1, 'Padding', 1); 
    batchNormalizationLayer
    reluLayer();
    maxPooling2dLayer(4, 'Stride',2, Padding=0);
    
    ] 

    finalLayers = [
      fullyConnectedLayer(4)
      fullyConnectedLayer(64)
      fullyConnectedLayer(1)
      regressionLayer  
    ]
    layers = [
        inputLayer
        middleLayers
        finalLayers
    ]

    % Valores aleatorios para los pesos de las capas ocultas
    layers(2).Weights = 0.0001 * randn([sizeFilter canales filtros]);

    options = trainingOptions('adam',...
        'InitialLearnRate', 0.001, ...
        'ValidationData',{XTrain, YTrain'},... 
        'Plots','training-progress',...
        'MaxEpochs', epoch,... % 'ExecutionEnvironment','parallel',...
        'Verbose', true)

   net = trainNetwork(XTrain, YTrain', layers, options);
   
   YPredTrain = predict(net, XTrain);
     
   YPredValidation = predict(net, XValidation);   
   
   YPredTest = predict(net, XTest);   
   
   poblaciones = XTrainPop;
   colores =  XTrainColor;
   
   [RMSE, R2, MAPE, ~, ~, precision, STD_precision, ~] = Performance(YTrain', YPredTest) 
   
   filenamemat = strcat(pathDB,dirOut, nameOut);
   save(filenamemat, 'XTrainHSI',   'YTrainHSI', 'YPredTrain',   'YPredValidation', 'YPredTest', 'XTrainPop', 'XTrainColor', 'net');
  
end

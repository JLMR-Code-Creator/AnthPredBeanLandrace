function TrainCNNWith1H2DHSICurve(XTrainHSI, YTrainHSI, XTrainPop, XTrainColor, ...
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
canales = 1;
imageSize = [altura ancho canales];
inputLayer = imageInputLayer(imageSize);
    sizeFilter = [7 7];
    filtros  = 16;
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
    %reluLayer()
    fullyConnectedLayer(64)
    %reluLayer()
    fullyConnectedLayer(1)
    %reluLayer()
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
    Plots = 'training-progress',...
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
save(filenamemat, 'XTrainHSI',   'YTrainHSI', 'YPredTrain',   'YPredValidation', 'YPredTest', 'XTrainPop', 'XTrainColor', 'net');

end

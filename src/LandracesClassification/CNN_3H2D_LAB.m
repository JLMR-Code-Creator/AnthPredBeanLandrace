function CNN_3H2D_LAB(XTrainLAB, YTrainLAB, XTestLAB, YTestLAB, ...
                      epoch, filenamemat)

    rng('default')
    rng(0, "threefry")
    gpurng(0, "threefry")
    
    XTrain = XTrainLAB;
    YTrain = categorical(YTrainLAB);

    XTest = XTestLAB;
    YTest = categorical(YTestLAB);

    % The next text was obtained from DeepGa Algorithm
    % Firts level
    % The network has 3 convolutional layers with:
    % (8, 2, avg, 2) (16, 3, avg, 2) (8, 2, avg, 2)
    % and 1 fully-connected layers with: (128) neurons
    % Second level : none

    %% Convolutional neural network
    %Firts Level (Convolutional Block)
    altura = size(XTestLAB, 1);
    ancho =  size(XTestLAB, 1);
    canales = 3;
    imageSize = [altura ancho canales];
    inputLayer = imageInputLayer(imageSize);
    sizeFilter = [2 2];
    filtros  = 8;
    middleLayers = [
        convolution2dLayer([2 2], 8, 'Stride', 1, 'Padding', 1, 'Name','conv_1'); % in DeepGA fixed values for 'Stride', 1, 'Padding', 1
        batchNormalizationLayer('Name','BN_1');
        reluLayer('Name','relu_1');
        averagePooling2dLayer(2, 'Stride', 2, 'Name','avgpool_1'); % in DeepGA stride value is 2
        % Stack 2
        convolution2dLayer([3 3], 16, 'Stride', 1, 'Padding', 1, 'Name','conv_2');
        batchNormalizationLayer('Name','BN_2');
        reluLayer('Name','relu_2');
        averagePooling2dLayer(2, 'Stride', 2, 'Name','avgpool_2');
        % Stack 3
        convolution2dLayer([2 2], 8, 'Stride',1, 'Padding', 1, 'Name','conv_3');
        batchNormalizationLayer('Name','BN_3');
        reluLayer('Name','relu_3');
        averagePooling2dLayer(2, 'Stride',2, 'Name','avgpool_3');
        ]
    
    finalLayers = [
        fullyConnectedLayer(128,'Name','fc_128n')
        fullyConnectedLayer(12,'Name','numClasses') %number of classes of the responses (12)
        softmaxLayer('Name','softmax')
        classificationLayer('Name','classOutput')
        ]
    layers = [
        inputLayer
        middleLayers
        finalLayers
        ]
    lgraph = layerGraph(layers);
    figure
    plot(lgraph);
    % Second level (connections) none    

    % Valores aleatorios para los pesos de las capas ocultas
    layers(2).Weights = 0.0001 * randn([sizeFilter canales filtros]);
    
    options = trainingOptions('adam',...
        'InitialLearnRate', 0.001, ...
        'ValidationPatience',10, ... % early stopping
        'ValidationData',{XTrain, YTrain},...
        'Plots','training-progress',...
        'MaxEpochs', epoch,...  
        'ExecutionEnvironment','parallel',...
        'Verbose', true,...
        'Plots','training-progress');
    
    net = trainNetwork(XTrain, YTrain, lgraph, options);
    
    YPredTrain = predict(net, XTrain);
    
    YPredTest = predict(net, XTest);
    accuracy = mean(YPredTest == YTest)
    save(filenamemat, 'XTrain',   'YTrain', 'XTest', 'YTest', 'net', "lgraph","accuracy");

end
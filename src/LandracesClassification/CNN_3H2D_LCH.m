function CNN_3H2D_LCH(XTrainLCH, YTrainLCH, XTestLCH, YTestLCH, ...
                      epoch, filenamemat)

    rng('default')
    rng(0, "threefry")
    gpurng(0, "threefry")
    
    XTrain = XTrainLCH;
    YTrain = YTrainLCH;

    XTest = XTestLCH;
    YTest = YTestLCH;

    % The next text was obtained from DeepGa Algorithm
    % Firts level
    % The network has 3 convolutional layers with:
    % (16, 4, max, 3) (8, 2, avg, 3) (8, 4, off, 2) (128, 3, max, 3) (8, 3, max, 3)
    % and 3 fully-connected layers with: (16)(128)(256) neurons
    % Second level : 1 11 100

    %% Convolutional neural network
    %Firts Level (Convolutional Block)
    altura = size(XTestLCH, 1);
    ancho =  size(XTestLCH, 1);
    canales = 3;
    imageSize = [altura ancho canales];
    inputLayer = imageInputLayer(imageSize);
    sizeFilter = [4 4];
    filtros  = 16;
    middleLayers = [
        convolution2dLayer([4 4], 16, 'Stride', 1, 'Padding', 1, 'Name','conv_1'); % in DeepGA fixed values for 'Stride', 1, 'Padding', 1
        batchNormalizationLayer('Name','BN_1');
        reluLayer('Name','relu_1');
        maxPooling2dLayer(3, 'Stride', 2,'Name','maxpool_1'); % in DeepGA stride value is 2
        % Stack 2
        convolution2dLayer([2 2], 8, 'Stride', 1, 'Padding', 1, 'Name','conv_2');
        batchNormalizationLayer('Name','BN_2');
        reluLayer('Name','relu_2');
        averagePooling2dLayer(3, 'Stride', 2, 'Name','avgpool_2');
        % Stack 3
        convolution2dLayer([4 4], 8, 'Stride',1, 'Padding', 1, 'Name','conv_3');
        batchNormalizationLayer('Name','BN_3');
        reluLayer('Name','relu_3');
        %maxPooling2dLayer(4, 'Stride',2, Padding=0);
        % Stack 4
        convolution2dLayer([3 3], 128, 'Stride',1, 'Padding', 1, 'Name','conv_4');
        batchNormalizationLayer('Name','BN_4');
        reluLayer('Name','relu_4');
        maxPooling2dLayer(3, 'Stride',2, 'Name','maxpool_4');        
        % Stack 5
        convolution2dLayer([3 3], 8, 'Stride',1, 'Padding', 1, 'Name','conv_5');
        batchNormalizationLayer('Name','BN_5');
        reluLayer('Name','relu_5');
        maxPooling2dLayer(3, 'Stride',2, 'Name','maxpool_5');                
        ]
    
    finalLayers = [
        fullyConnectedLayer(16,'Name','fc_16n')
        fullyConnectedLayer(128,'Name','fc_128n')
        fullyConnectedLayer(256,'Name','fc_256n')
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
    % Second level (connections) 1 11 100
    lgraph = connectLayers(lgraph,'maxpool_1','conv_3');
    lgraph = connectLayers(lgraph,'maxpool_1','conv_4');
    lgraph = connectLayers(lgraph,'maxpool_1','conv_5');
    lgraph = connectLayers(lgraph,'avgpool_2','conv_4');
    figure
    plot(lgraph);

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
    save(filenamemat, 'XTrain',   'YTrain', 'XTest', 'YTest', 'net', "lgraph", "accuracy");

end
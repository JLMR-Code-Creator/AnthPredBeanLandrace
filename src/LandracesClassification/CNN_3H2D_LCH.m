function CNN_3H2D_LCH(XTrainLCH, YTrainLCH, XTestLCH, YTestLCH, ...
                      epoch, filenamemat)

    rng('default')
    rng(0, "threefry")
    gpurng(0, "threefry")
    
    XTrain = XTrainLCH;
    YTrain = categorical(YTrainLCH);

    XTest = XTestLCH;
    YTest = categorical(YTestLCH);

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
    %INPUT = imageInputLayer(imageSize, 'Name','input');
    % sizeFilter = [4 4];
    % filtros  = 16;
    CNN = dlnetwork; % empty network
    tempCNN = [
        imageInputLayer([361 361 3],"Name","input")
        convolution2dLayer([4 4],16,"Name","conv_1","Padding",[1 1 1 1])
        batchNormalizationLayer("Name","BN_1")
        reluLayer("Name","relu_1")
        maxPooling2dLayer([3 3],"Name","maxpool_1","Stride",[2 2])];
    CNN = addLayers(CNN,tempCNN);

    tempCNN = [
        convolution2dLayer([2 2],8,"Name","conv_2","Padding",[1 1 1 1])
        batchNormalizationLayer("Name","BN_2")
        reluLayer("Name","relu_2")
        averagePooling2dLayer([3 3],"Name","avgpool_2","Stride",[2 2])];
    CNN = addLayers(CNN,tempCNN);

    tempCNN = resize2dLayer("Name","resize-1a4","GeometricTransformMode","half-pixel","Method","nearest","NearestRoundingMode","round","OutputSize",[88 88]);
    CNN = addLayers(CNN,tempCNN);

    tempCNN = resize2dLayer("Name","resize-1a2","GeometricTransformMode","half-pixel","Method","nearest","NearestRoundingMode","round","OutputSize",[89 89]);
    CNN = addLayers(CNN,tempCNN);

    tempCNN = [
        depthConcatenationLayer(2,"Name","concat_1")
        convolution2dLayer([4 4],8,"Name","conv_3","Padding",[1 1 1 1])
        batchNormalizationLayer("Name","BN_3")
        reluLayer("Name","relu_3")];
    CNN = addLayers(CNN,tempCNN);
    
    tempCNN = resize2dLayer("Name","resize-2a4","GeometricTransformMode","half-pixel","Method","nearest","NearestRoundingMode","round","OutputSize",[88 88]);
    CNN = addLayers(CNN,tempCNN);
    
    tempCNN = [
        depthConcatenationLayer(3,"Name","concat_2")
        convolution2dLayer([3 3],128,"Name","conv_4","Padding",[1 1 1 1])
        batchNormalizationLayer("Name","BN_4")
        reluLayer("Name","relu_4")
        maxPooling2dLayer([2 2],"Name","maxpool_4","Stride",[2 2])];
    CNN = addLayers(CNN,tempCNN);
    
    tempCNN = resize2dLayer("Name","resize-1a5","GeometricTransformMode","half-pixel","Method","nearest","NearestRoundingMode","round","OutputSize",[44 44]);
    CNN = addLayers(CNN,tempCNN);

    tempCNN = [
        depthConcatenationLayer(2,"Name","concat_3")
        convolution2dLayer([3 3],8,"Name","conv_5","Padding",[1 1 1 1])
        batchNormalizationLayer("Name","BN_5")
        reluLayer("Name","relu_5")
        maxPooling2dLayer([3 3],"Name","maxpool_5","Stride",[2 2])
        fullyConnectedLayer(16,"Name","fc_16n")
        fullyConnectedLayer(128,"Name","fc_128n")
        fullyConnectedLayer(256,"Name","fc_256n")
        fullyConnectedLayer(12,"Name","numClasses")
        softmaxLayer("Name","softmax")
        classificationLayer("Name","classoutput")];
        CNN = addLayers(CNN,tempCNN);
        CNN = connectLayers(CNN,"maxpool_1","conv_2");
    CNN = connectLayers(CNN,"maxpool_1","resize-1a4");
    CNN = connectLayers(CNN,"maxpool_1","resize-1a2");
    CNN = connectLayers(CNN,"maxpool_1","resize-1a5");
    CNN = connectLayers(CNN,"avgpool_2","concat_1/in1");
    CNN = connectLayers(CNN,"avgpool_2","resize-2a4");
    CNN = connectLayers(CNN,"resize-1a4","concat_2/in1");
    CNN = connectLayers(CNN,"resize-1a2","concat_1/in2");
    CNN = connectLayers(CNN,"relu_3","concat_2/in2");
    CNN = connectLayers(CNN,"resize-2a4","concat_2/in3");
    CNN = connectLayers(CNN,"maxpool_4","concat_3/in1");
    CNN = connectLayers(CNN,"resize-1a5","concat_3/in2");
     %CNN = initialize(CNN);

      

     %deepNetworkDesigner(CNN)
     %figure
     %plot(cnn);


    % Valores aleatorios para los pesos de las capas ocultas
    %cnn.Layers(2,1).Weights = 0.0001 * randn([sizeFilter canales filtros]);
    
    options = trainingOptions('adam',...
        'InitialLearnRate', 0.001, ...
        'ValidationPatience',10, ... % early stopping
        'ValidationData',{XTrain, YTrain},...
        'Plots','training-progress',...
        'MaxEpochs', epoch,...  
        'ExecutionEnvironment','parallel',...
        'Verbose', true,...
        'Plots','training-progress');
    lgraph = layerGraph(CNN);
    figure
    plot(lgraph)
    ModelNet = trainNetwork(XTrain, YTrain, lgraph, options);
    
    YPredTrain = classify(ModelNet, XTrain);
    
    YPredTest = classify(ModelNet, XTest);
    accuracy = mean(YPredTest == YTest)
    save(filenamemat, 'XTrain',   'YTrain', 'XTest', 'YTest', 'ModelNet', "CNN", "accuracy");

end
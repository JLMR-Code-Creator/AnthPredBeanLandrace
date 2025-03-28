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
    CNNet = dlnetwork; % empty network
    tempNet = [
        imageInputLayer([361 361 3],"Name","input")
        convolution2dLayer([4 4],16,"Name","conv_1","Padding",[1 1 1 1])
        batchNormalizationLayer("Name","BN_1")
        reluLayer("Name","relu_1")
        maxPooling2dLayer([3 3],"Name","maxpool_1","Stride",[2 2])];
    CNNet = addLayers(CNNet,tempNet);

    tempNet = [
        convolution2dLayer([2 2],8,"Name","conv_2","Padding",[1 1 1 1])
        batchNormalizationLayer("Name","BN_2")
        reluLayer("Name","relu_2")
        averagePooling2dLayer([3 3],"Name","avgpool_2","Stride",[2 2])];
    CNNet = addLayers(CNNet,tempNet);

    tempNet = maxPooling2dLayer([3 3],"Name","maxpool_1a3","Stride",[2 2]);
    CNNet = addLayers(CNNet,tempNet);

    tempNet = [
        depthConcatenationLayer(2,"Name","concat_1")
        convolution2dLayer([4 4],8,"Name","conv_3","Padding",[1 1 1 1])
        batchNormalizationLayer("Name","BN_3")
        reluLayer("Name","relu_3")];
    CNNet = addLayers(CNNet,tempNet);

    tempNet = maxPooling2dLayer([4 4],"Name","maxpool_2a4","Padding",[1 1 1 1]);
    CNNet = addLayers(CNNet,tempNet);

    tempNet = maxPooling2dLayer([4 4],"Name","maxpool_1a4","Stride",[2 2]);
    CNNet = addLayers(CNNet,tempNet);

    tempNet = [
        depthConcatenationLayer(3,"Name","concat_2")
        convolution2dLayer([3 3],128,"Name","conv_4","Padding",[1 1 1 1])
        batchNormalizationLayer("Name","BN_4")
        reluLayer("Name","relu_4")
        maxPooling2dLayer([2 2],"Name","maxpool_4","Stride",[2 2])];
    CNNet = addLayers(CNNet,tempNet);

    tempNet = maxPooling2dLayer([4 4],"Name","maxpool_1a5","Stride",[4 4]);
    CNNet = addLayers(CNNet,tempNet);

    tempNet = [
        depthConcatenationLayer(2,"Name","concat_3")
        convolution2dLayer([3 3],8,"Name","conv_5","Padding",[1 1 1 1])
        batchNormalizationLayer("Name","BN_5")
        reluLayer("Name","relu_5")
        maxPooling2dLayer([3 3],"Name","maxpool_5","Stride",[2 2])
        fullyConnectedLayer(16,"Name","fc_16n")
        reluLayer("Name","relu")
        fullyConnectedLayer(128,"Name","fc_128n")
        reluLayer("Name","relu_6")
        fullyConnectedLayer(256,"Name","fc_256n")
        reluLayer("Name","relu_7")
        fullyConnectedLayer(12,"Name","numClasses")
        softmaxLayer("Name","softmax")
        classificationLayer("Name","classoutput")];
    CNNet = addLayers(CNNet,tempNet);
    CNNet = connectLayers(CNNet,"maxpool_1","conv_2");
    CNNet = connectLayers(CNNet,"maxpool_1","maxpool_1a3");
    CNNet = connectLayers(CNNet,"maxpool_1","maxpool_1a4");
    CNNet = connectLayers(CNNet,"maxpool_1","maxpool_1a5");
    CNNet = connectLayers(CNNet,"avgpool_2","concat_1/in1");
    CNNet = connectLayers(CNNet,"avgpool_2","maxpool_2a4");
    CNNet = connectLayers(CNNet,"maxpool_1a3","concat_1/in2");
    CNNet = connectLayers(CNNet,"relu_3","concat_2/in1");
    CNNet = connectLayers(CNNet,"maxpool_2a4","concat_2/in2");
    CNNet = connectLayers(CNNet,"maxpool_1a4","concat_2/in3");
    CNNet = connectLayers(CNNet,"maxpool_4","concat_3/in1");
    CNNet = connectLayers(CNNet,"maxpool_1a5","concat_3/in2");
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
    lgraph = layerGraph(CNNet);
    figure
    plot(lgraph)
    ModelNet = trainNetwork(XTrain, YTrain, lgraph, options);
    
    YPredTrain = classify(ModelNet, XTrain);
    
    YPredTest = classify(ModelNet, XTest);
    accuracy = mean(YPredTest == YTest)
    save(filenamemat, 'XTrain',   'YTrain', 'XTest', 'YTest', 'ModelNet', "CNNet", "accuracy");

end
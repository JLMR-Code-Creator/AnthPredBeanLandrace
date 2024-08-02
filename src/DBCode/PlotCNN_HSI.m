function PlotCNN_HSI(DBSource, dbfile, type)

    load(strcat(DBSource,dbfile),'-mat');
    
    YTrue = mean(YTrainHSI')';
    
    [RMSE_Train, R2_Train, MAPE_Train, stdMape_Train, ~, precision_Train, STD_precision_Train, ~] = Performance(YTrue, YPredTrain);
    disp(['RMSE_Train:',num2str(RMSE_Train), ' R2: ',num2str(R2_Train), ' MAPE: ',num2str(MAPE_Train), ' STD: ',num2str(stdMape_Train), ' Precision: ',num2str(precision_Train), ' STD: ',num2str(STD_precision_Train)]);
    [RMSE_Validation, R2_Validation, MAPE_Validation, stdMape_Validation, ~, precision_Validation, STD_precision_Validation, ~] = Performance(YTrue, YPredValidation);
    disp(['RMSE_Validation:',num2str(RMSE_Validation), ' R2: ',num2str(R2_Validation), ' MAPE: ',num2str(MAPE_Validation), ' STD: ',num2str(stdMape_Validation), ' Precision: ',num2str(precision_Validation), ' STD: ',num2str(STD_precision_Validation)]);
    [RMSE_Test, R2_Test, MAPE_Test, stdMape_Test, ~, precision_Test, STD_precision_Test, ~] = Performance(YTrue, YPredTest);
    disp(['RMSE_Test:',num2str(RMSE_Test), ' R2: ',num2str(R2_Test), ' MAPE: ',num2str(MAPE_Test), ' STD: ',num2str(stdMape_Test), ' Precision: ',num2str(precision_Test), ' STD: ',num2str(STD_precision_Test)]);   
        
    
    [B, sI]=sort(YTrue, 'ascend');
    sortPredTest = YPredTest(sI);
    union = strcat(string(XTrainPop), '-', string(XTrainColor));
    sortLabelPop = union(sI);
    markerType = '';
    if(type == 1)
        markerType = '+k';
        legends = {'pH Differential Method', 'DeepGA CNN with 1H2D'};
    else
        markerType = 'diamondk';
        legends = {'pH Differential Method', 'DeepGA CNN with 3H2D'};
    end

    plotEstimatedvsReal(B, sortPredTest,markerType, 0,sortLabelPop,'Anthocyanin estimation', 'HSI color space', 'Bean landraces', 'Anthocyanins [mg (C3G)/g]', 1, legends);


end

  

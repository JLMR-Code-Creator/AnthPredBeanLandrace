function PlotCNN_1H_3H_HSI(DBSource, dbfile1, dbfile2)

    D_1H = load(strcat(DBSource,dbfile1),'-mat');
    D_3H = load(strcat(DBSource,dbfile2),'-mat');
    
    YTrue = mean(D_1H.YTrainHSI')';
    
    [RMSE_Test_1H, R2_Test_1H, MAPE_Test_1H, stdMape_Test_1H, ~, precision_Test_1H, STD_precision_Test_1H, ~] = Performance(YTrue, D_1H.YPredTest);
    disp(['RMSE_Test:',num2str(RMSE_Test_1H), ' R2: ',num2str(R2_Test_1H), ...
        ' MAPE: ',num2str(MAPE_Test_1H), ' STD: ',num2str(stdMape_Test_1H), ...
        ' Precision: ',num2str(precision_Test_1H), ' STD: ',num2str(STD_precision_Test_1H)]);   
    
    [RMSE_Test_3H, R2_Test_3H, MAPE_Test_3H, stdMape_Test_3H, ~, precision_Test_3H, STD_precision_Test_3H, ~] = Performance(YTrue, D_3H.YPredTest);
    disp(['RMSE_Test:',num2str(RMSE_Test_3H), ' R2: ',num2str(R2_Test_3H), ...
        ' MAPE: ',num2str(MAPE_Test_3H), ' STD: ',num2str(stdMape_Test_3H), ...
        ' Precision: ',num2str(precision_Test_3H), ' STD: ',num2str(STD_precision_Test_3H)]);   

    [B, sI]=sort(YTrue, 'ascend');
    sortPredTest_1H = D_1H.YPredTest(sI);
    sortPredTest_3H = D_3H.YPredTest(sI);

             
    color_ = string(D_1H.XTrainColor);
    colorVal = replace(color_, 'B', '(White)');     % Blanco White
    colorVal = replace(colorVal, 'A', '(Yellow)');  % Amarillo Yellow
    colorVal = replace(colorVal, 'N', '(Black)');   % Negro Black
    colorVal = replace(colorVal, 'C', '(Brown)');   % Negro Black
    colorVal = replace(colorVal, 'R', '(Red)');     % Negro Black
    colorVal = replace(colorVal, 'X', '(Mixture)'); % Negro Black
    %labelPob=strcat(string(clase(:,1)),'-',colorVal,'');   
    %sortLabelPop = labelPob(idx);
    union = strcat(string(D_1H.XTrainPop), '-', string(colorVal), '');
    sortLabelPop = union(sI);

    plotAchievedReal(B, sortPredTest_1H, sortPredTest_3H, sortLabelPop, 'HSI color space', '', 'Bean landraces', 'Anthocyanins [mg (C3G) g^{-1}]', 1)


end

  

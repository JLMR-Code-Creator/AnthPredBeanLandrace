function Plot_CNN_1H_HSI_LAB(DBSource, dbfile1, dbfile2)

    D_1HLAB = load(strcat(DBSource,dbfile1),'-mat');
    D_1HHSI = load(strcat(DBSource,dbfile2),'-mat');
    
    YTrue = mean(D_1HLAB.YTrainLAB')';
    
    [RMSE_Test_1H, R2_Test_1H, MAPE_Test_1H, stdMape_Test_1H, ~, precision_Test_1H, STD_precision_Test_1H, ~] = Performance(YTrue, D_1HLAB.YPredTest);
    disp(['RMSE_Test:',num2str(RMSE_Test_1H), ' R2: ',num2str(R2_Test_1H), ...
        ' MAPE: ',num2str(MAPE_Test_1H), ' STD: ',num2str(stdMape_Test_1H), ...
        ' Precision: ',num2str(precision_Test_1H), ' STD: ',num2str(STD_precision_Test_1H)]);   
    
    [RMSE_Test_3H, R2_Test_3H, MAPE_Test_3H, stdMape_Test_3H, ~, precision_Test_3H, STD_precision_Test_3H, ~] = Performance(YTrue, D_1HHSI.YPredTest);
    disp(['RMSE_Test:',num2str(RMSE_Test_3H), ' R2: ',num2str(R2_Test_3H), ...
        ' MAPE: ',num2str(MAPE_Test_3H), ' STD: ',num2str(stdMape_Test_3H), ...
        ' Precision: ',num2str(precision_Test_3H), ' STD: ',num2str(STD_precision_Test_3H)]);   

    [B, sI]=sort(YTrue, 'ascend');
    sortPredTest_1HLAB = D_1HLAB.YPredTest(sI);
    sortPredTest_1HHSI = D_1HHSI.YPredTest(sI);

             
    color_ = string(D_1HLAB.XTrainColor);
    colorVal = replace(color_, 'B', '(White)');     % Blanco White
    colorVal = replace(colorVal, 'A', '(Yellow)');  % Amarillo Yellow
    colorVal = replace(colorVal, 'N', '(Black)');   % Negro Black
    colorVal = replace(colorVal, 'C', '(Brown)');   % Negro Black
    colorVal = replace(colorVal, 'R', '(Red)');     % Negro Black
    colorVal = replace(colorVal, 'X', '(Mixture)'); % Negro Black
    %labelPob=strcat(string(clase(:,1)),'-',colorVal,'');   
    %sortLabelPop = labelPob(idx);
    union = strcat(string(D_1HLAB.XTrainPop), '-', string(colorVal), '');
    sortLabelPop = union(sI);

    legenda = {'pH Differential Method', ...
        'DeepGA CNN with 1 PMF for CIE L*a*b*', ...
        'DeepGA CNN with 1 PMF for HSI'};

    plotEstimatedvsReal_vs_LAB_HSI(B, sortPredTest_1HLAB, 'squarek', sortPredTest_1HHSI,'diamondk', ...
                     sortLabelPop, '', '', ...
                     'Common Bean landraces', 'Anthocyanins [mg (C3G) g^{-1}]', 1, legenda)

end

  

function Plot_CNN_3H_HSI_LAB(DBSource, dbfile1, dbfile2)

    D_3HLAB = load(strcat(DBSource,dbfile1),'-mat');
    D_3HHSI = load(strcat(DBSource,dbfile2),'-mat');
    
    YTrue = mean(D_3HLAB.YTrainLAB')';
    
    [RMSE_Test_3H, R2_Test_3H, MAPE_Test_3H, stdMape_Test_3H, ~, precision_Test_3H, STD_precision_Test_3H, ~] = Performance(YTrue, D_3HLAB.YPredTest);
    disp(['RMSE_Test:',num2str(RMSE_Test_3H), ' R2: ',num2str(R2_Test_3H), ...
        ' MAPE: ',num2str(MAPE_Test_3H), ' STD: ',num2str(stdMape_Test_3H), ...
        ' Precision: ',num2str(precision_Test_3H), ' STD: ',num2str(STD_precision_Test_3H)]);   
    
    [RMSE_Test_3H, R2_Test_3H, MAPE_Test_3H, stdMape_Test_3H, ~, precision_Test_3H, STD_precision_Test_3H, ~] = Performance(YTrue, D_3HHSI.YPredTest);
    disp(['RMSE_Test:',num2str(RMSE_Test_3H), ' R2: ',num2str(R2_Test_3H), ...
        ' MAPE: ',num2str(MAPE_Test_3H), ' STD: ',num2str(stdMape_Test_3H), ...
        ' Precision: ',num2str(precision_Test_3H), ' STD: ',num2str(STD_precision_Test_3H)]);   

    [B, sI]=sort(YTrue, 'ascend');
    sortPredTest_3HLAB = D_3HLAB.YPredTest(sI);
    sortPredTest_3HHSI = D_3HHSI.YPredTest(sI);

             
    color_ = string(D_3HLAB.XTrainColor);
    colorVal = replace(color_, 'B', '(White)');     % Blanco White
    colorVal = replace(colorVal, 'A', '(Yellow)');  % Amarillo Yellow
    colorVal = replace(colorVal, 'N', '(Black)');   % Negro Black
    colorVal = replace(colorVal, 'C', '(Brown)');   % Negro Black
    colorVal = replace(colorVal, 'R', '(Red)');     % Negro Black
    colorVal = replace(colorVal, 'X', '(Mixture)'); % Negro Black
    %labelPob=strcat(string(clase(:,1)),'-',colorVal,'');   
    %sortLabelPop = labelPob(idx);
    union = strcat(string(D_3HLAB.XTrainPop), '-', string(colorVal), '');
    sortLabelPop = union(sI);

    legenda = {'pH Differential Method', ...
        'DeepGA CNN with 3 PMF for CIE L*a*b*', ...
        'DeepGA CNN with 3 PMF for HSI'};

    plotEstimatedvsReal_vs_LAB_HSI(B, sortPredTest_3HLAB, 'pentagramk', sortPredTest_3HHSI,'vk', ...
                     sortLabelPop, '', '', ...
                     'Common Bean landraces', 'Anthocyanins [mg (C3G) g^{-1}]', 1, legenda)

end

  

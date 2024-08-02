function Plot_CNN_Overall(DBSource, dbfile1, dbfile2, dbfile3, dbfile4)

    D_1HCIE = load(strcat(DBSource,dbfile1),'-mat');
    D_3HCIE = load(strcat(DBSource,dbfile2),'-mat');
    D_1HHSI = load(strcat(DBSource,dbfile3),'-mat');
    D_3HHSI = load(strcat(DBSource,dbfile4),'-mat');
    
 YTrue = mean(D_1HCIE.YTrainLAB')';
    
    [RMSE_Test_1H, R2_Test_1H, MAPE_Test_1H, stdMape_Test_1H, ~, LAB_precision_Test_1H, STD_precision_Test_1H, PrecisionsList_CIE1H] = Performance(YTrue, D_1HCIE.YPredTest);
    disp(['RMSE_Test:',num2str(RMSE_Test_1H), ' R2: ',num2str(R2_Test_1H), ...
        ' MAPE: ',num2str(MAPE_Test_1H), ' STD: ',num2str(stdMape_Test_1H), ...
        ' Precision: ',num2str(LAB_precision_Test_1H), ' STD: ',num2str(STD_precision_Test_1H)]);   
    
    [RMSE_Test_3H, R2_Test_3H, MAPE_Test_3H, stdMape_Test_3H, ~, LAB_precision_Test_3H, STD_precision_Test_3H, PrecisionsList_CIE3H] = Performance(YTrue, D_3HCIE.YPredTest);
    disp(['RMSE_Test:',num2str(RMSE_Test_3H), ' R2: ',num2str(R2_Test_3H), ...
        ' MAPE: ',num2str(MAPE_Test_3H), ' STD: ',num2str(stdMape_Test_3H), ...
        ' Precision: ',num2str(LAB_precision_Test_3H), ' STD: ',num2str(STD_precision_Test_3H)]);   

     YTrue2 = mean(D_1HHSI.YTrainHSI')';

    [RMSE_Test_1H, R2_Test_1H, MAPE_Test_1H, stdMape_Test_1H, ~, HSI_precision_Test_1H, STD_precision_Test_1H, PrecisionsList_HSI1H] = Performance(YTrue, D_1HHSI.YPredTest);
    disp(['RMSE_Test:',num2str(RMSE_Test_1H), ' R2: ',num2str(R2_Test_1H), ...
        ' MAPE: ',num2str(MAPE_Test_1H), ' STD: ',num2str(stdMape_Test_1H), ...
        ' Precision: ',num2str(HSI_precision_Test_1H), ' STD: ',num2str(STD_precision_Test_1H)]);   
    
    [RMSE_Test_3H, R2_Test_3H, MAPE_Test_3H, stdMape_Test_3H, ~, HSI_precision_Test_3H, STD_precision_Test_3H, PrecisionsList_HSI3H] = Performance(YTrue, D_3HHSI.YPredTest);
    disp(['RMSE_Test:',num2str(RMSE_Test_3H), ' R2: ',num2str(R2_Test_3H), ...
        ' MAPE: ',num2str(MAPE_Test_3H), ' STD: ',num2str(stdMape_Test_3H), ...
        ' Precision: ',num2str(HSI_precision_Test_3H), ' STD: ',num2str(STD_precision_Test_3H)]);   


    [B, sI]=sort(YTrue, 'ascend');

    D_1HCIE = load(strcat(DBSource,dbfile1),'-mat');
    D_3HCIE = load(strcat(DBSource,dbfile2),'-mat');
    D_1HHSI = load(strcat(DBSource,dbfile3),'-mat');
    D_3HHSI = load(strcat(DBSource,dbfile4),'-mat');

    sortPredTest_1HCIE = D_1HCIE.YPredTest(sI);
    sortPredTest_3HCIE = D_3HCIE.YPredTest(sI);
    sortPredTest_1HHSI = D_1HHSI.YPredTest(sI);
    sortPredTest_3HHSI = D_3HHSI.YPredTest(sI);

             
    color_ = string(D_1HCIE.XTrainColor);
    colorVal = replace(color_, 'B', '(White)');     % Blanco White
    colorVal = replace(colorVal, 'A', '(Yellow)');  % Amarillo Yellow
    colorVal = replace(colorVal, 'N', '(Black)');   % Negro Black
    colorVal = replace(colorVal, 'C', '(Brown)');   % Negro Black
    colorVal = replace(colorVal, 'R', '(Red)');     % Negro Black
    colorVal = replace(colorVal, 'X', '(Mixture)'); % Negro Black
    %labelPob=strcat(string(clase(:,1)),'-',colorVal,'');   
    %sortLabelPop = labelPob(idx);
    union = strcat(string(D_1HCIE.XTrainPop), '-', string(colorVal), '');
    sortLabelPop = union(sI);

    legenda = {'pH Differential Method', ...
        'DeepGA CNN with 1 PMF for CIE L*a*b*', ...
        'DeepGA CNN with 3 PMF for CIE L*a*b*' ...
        'DeepGA CNN with 1 PMF for HSI', ...
        'DeepGA CNN with 3 PMF for HSI'};

    plotEstimatedvsRealAll(B, sortPredTest_1HCIE, 'squarek', sortPredTest_3HCIE,'pentagramk',  ...
                     sortPredTest_1HHSI, 'diamondk', sortPredTest_3HHSI, 'vk', ...
                     sortLabelPop, '', '', ...
                     'Common Bean landraces', 'Anthocyanins [mg (C3G) g^{-1}]', 1, legenda)
    

end

  

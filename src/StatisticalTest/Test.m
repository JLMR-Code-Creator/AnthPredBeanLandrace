function  Test(DBSource, dbfile1, dbfile2, dbfile3, dbfile4 )

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





    mtx = [PrecisionsList_CIE1H,PrecisionsList_CIE3H,PrecisionsList_HSI1H,PrecisionsList_HSI3H];


%% swTest Shapiro-Wilk Test

K1=[]; K2=[]; 

Reg_Prom_LAB_test = (mtx);% Sin encabezado

%[h,p] = lillietest(Reg_Prom_LAB_test(:,4),'Alpha',0.05)
[H, pValue, W] = swtest(mtx(:,4), 0.05, -1);
K1 = [K1;Reg_Prom_LAB_test(:,1)];
K1 = [K1;H];
K1 = [K1;pValue];
K1 = [K1;W];



% Concentrado_total = [K1,K2];
% 
% filename = strcat('swTestColor.xlsx');
% writetable(table(Concentrado_total),filename,'Sheet',1);


%%  kruskalwallis
     %vecinos = {'DeepGA CNN and 1 PMF CIE L*a*b*','DeepGA CNN and 3 PMF CIE L*a*b*', 'DeepGA CNN and 1 PMF HSI','DeepGA CNN and 3 PMF HSI'};
      vecinos = {'DeepGA CNN with 1 PMF for CIE L*a*b*','DeepGA CNN with 3 PMF for CIE L*a*b*', 'DeepGA CNN with 1 PMF for HSI','DeepGA CNN with 3 PMF for HSI'};

     [p,tbl,stats]= kruskalwallis(mtx,[],'off');
     figure;
     c = multcompare(stats);
     %[vecinos(c(:,1))',vecinos(c(:,2))', num2cell(c(:,6:6))]
disp('dd')
end


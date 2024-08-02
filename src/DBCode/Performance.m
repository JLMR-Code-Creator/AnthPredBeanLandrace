function [RMSE, R2, MAPE, stdMape, MAPE_Vector, precision, STD_precision, PRE_Vector] = Performance(YTrue, yPred)
    RMSE = rmse(YTrue, yPred);
    RSS = sum((YTrue - yPred).^2);
    TSS = sum((YTrue - mean(YTrue)).^2);
    R2 =  1 - (RSS/TSS); %R2 = (TSS-RSS)/TSS; % Es lo mismo que lo anterior.
    antoInc = YTrue + 1;
    antoInc2 = yPred + 1;
    MAPE_Vector = double((abs(antoInc - antoInc2)./abs(antoInc))*100);
    stdMape = std(MAPE_Vector);
    MAPE = mean(MAPE_Vector);
    PRE_Vector = abs(100 - MAPE_Vector);
    precision = mean(PRE_Vector);
    STD_precision = std(PRE_Vector);
end


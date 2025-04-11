function  ConcentraResultados(pathDBRead1,pathDBRead2)
% Read two paths for get the accuracy of each color characterization. 
 [listAccuracyLAB] = getInfo(pathDBRead1);
 [listAccuracyLCH] = getInfo(pathDBRead2);
 
% Prueba estadistica 
% Prueba de normalidad
[H_lab, pValue_lab, SWstatistic_lab] = swtest(listAccuracyLAB, 0.05, -1);
if(H_lab==0)
    disp('Distribución normal'); 
end

[H_lch, pValue_lch, SWstatistic_lch] = swtest(listAccuracyLCH, 0.05, -1);
if(H_lch==0)
    disp('Distribución normal'); 
end


[h, p] = ttest2(listAccuracyLAB, listAccuracyLCH);

% Mostrar resultados
if h == 0
    disp(['No hay diferencia significativa entre los modelos (p = ' num2str(p) ')']);
else
    disp(['Sí hay diferencia significativa entre los modelos (p = ' num2str(p) ')']);
end

figure();
labels = {'DeepGA CNN con \newline 3 PMF en CIE L*a*b*', ...
          'DeepGA CNN con \newline 3 PMF en CIE L*C*h*'};
boxplot([listAccuracyLAB(:); listAccuracyLCH(:)], ...
        [repmat({'LAB'}, 30, 1); repmat({'LCH'}, 30, 1)]);
ylabel('Accuracy');



meanLAB = mean(listAccuracyLAB);
stdLAB = std(listAccuracyLAB);
maxLAB = max(listAccuracyLAB);
minLAB = min(listAccuracyLAB);

meanLCH = mean(listAccuracyLCH);
stdLCH = std(listAccuracyLCH);
maxLCH = max(listAccuracyLCH);
minLCH = min(listAccuracyLCH);



YPredTest = classify(net, XTest);
cm = confusionchart(YTest, YPredTest)


YPredTest = classify(ModelNet, XTest);
cm2 = confusionchart(YTest, YPredTest)


% labels = {'DeepGA CNN with \newline 3 PMF for CIE L*a*b* ', ...
%     'DeepGA CNN with \newline 3 PMF for CIE L*C*H* '};
% [p1,tbl,stats] =  anova1([listAccuracyLAB,listAccuracyLCH], labels);
% [c,m,h,nms]=multcompare(stats,'CType','hsd');
% [ncomp,nccol] = size(c);
% disp(' Comparación de grupos  - Mostrandos las diferencias significativas')
% for j=1:ncomp
%     if c(j,nccol) <= 0.05
%         disp(['  Grupo ' labels{c(j,1)} ' de ' labels{c(j,2)} ' - p = ' num2str(c(j, nccol))]);
%     end
% end



end

function [listAccuracy] = getInfo(pathDBRead)
    matfile = dir(strcat(pathDBRead,'/*.mat'));
    %% 1. Get list of classes of color and landraces name
    listAccuracy = zeros(length(matfile), 1);
    for i = 1:length(matfile)  % Iteration to each sample landraces
        disp([num2str(i), ' ', matfile(i).name]);
        archivo = matfile(i).name;        % File name
        rutadbFile = strcat(pathDBRead,filesep, archivo);
        L = load(rutadbFile); % load file mask
        listAccuracy(i,1) = L.accuracy;
    end

end
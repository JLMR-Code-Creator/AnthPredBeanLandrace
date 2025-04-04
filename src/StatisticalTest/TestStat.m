load("datos.mat");
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


figure();
labels = {'DeepGA CNN with \newline 3 PMF for CIE L*a*b* ', ...
     'DeepGA CNN with \newline 3 PMF for CIE L*C*H* '};
 [p1,tbl,stats] =  anova1([listAccuracyLAB,listAccuracyLCH], labels);
 [c,m,h,nms]=multcompare(stats,'CType','hsd'); 
 [ncomp,nccol] = size(c);
disp(' Comparación de grupos  - Mostrandos las diferencias significativas')
for j=1:ncomp
  if c(j,nccol) <= 0.05 
     disp(['  Grupo ' labels{c(j,1)} ' de ' labels{c(j,2)} ' - p = ' num2str(c(j, nccol))]); 
  end
end
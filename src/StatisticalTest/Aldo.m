load("aldo.mat"); 


histogram((mtx));

%[h,p] = lillietest(Reg_Prom_LAB_test(:,4),'Alpha',0.05)
[H, pValue, W] = swtest(mtx(:,1), 0.05, -1) % -1 (1-sided test), alternative: X is lower the normal.
if(H==0) disp('Distribución normal'); end
[H, pValue, W] = swtest(mtx(:,2), 0.05, -1)  %-1 (1-sided test), alternative: X is lower the normal.
if(H==0) disp('Distribución normal'); end
[H, pValue, W] = swtest(mtx(:,3), 0.05, -1)
if(H==0) disp('Distribución normal'); end
[H, pValue, W] = swtest(mtx(:,4), 0.05, -1)
if(H==0) disp('Distribución normal'); end



%%  kruskalwallis
vecinos = {'DeepGA CNN with 1 PMF for CIE L*a*b*','DeepGA CNN with 3 PMF for CIE L*a*b*', 'DeepGA CNN with 1 PMF for HSI','DeepGA CNN with 3 PMF for HSI'};
    
[p,tbl,stats]= kruskalwallis(mtx,vecinos);
disp(tbl); 
c=multcompare(stats,'display','on');
[ncomp,nccol] = size(c);
disp(' ');
disp(' Comparación de grupos  - Mostrandos las diferencias significativas')
for j=1:ncomp
  if c(j,nccol) <= 0.05 
     disp(['  Grupo ' vecinos{c(j,1)} ' de ' vecinos{c(j,2)} ' - p = ' num2str(c(j, nccol))]); 
  end
end

figure();
labels = {'DeepGA CNN with \newline 1 PMF for CIE L*a*b* ', ...
     'DeepGA CNN with \newline 3 PMF for CIE L*a*b* ','DeepGA with \newline 1 PMF for HSI ', ...
     'DeepGA CNN with \newline 3 PMF for HSI'};
 [p1,tbl,stats] =  anova1(mtx, labels);
 [c,m,h,nms]=multcompare(stats,'CType','hsd'); 
 [ncomp,nccol] = size(c);
disp(' Comparación de grupos  - Mostrandos las diferencias significativas')
for j=1:ncomp
  if c(j,nccol) <= 0.05 
     disp(['  Grupo ' labels{c(j,1)} ' de ' labels{c(j,2)} ' - p = ' num2str(c(j, nccol))]); 
  end
end
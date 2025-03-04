function Plot_Points(SeedsCIE,populationName)
    load("valuesLAB.mat");      %Load reference points
    MaxL = max(SeedsCIE(:,1));
    L=coordLAB(:,1)<MaxL;
    newdata=coordLAB(L,:);
    seeds = [newdata;SeedsCIE];
    plot_Lab(4,seeds',1,'',12,0,populationName);
    [L1, c1,h1] = CromaHueChannel1(SeedsCIE);
    disp(['L* ',num2str(median(L1)), ' C* ', num2str(median(c1)), ' H* ', num2str(median(h1)) ]);
end


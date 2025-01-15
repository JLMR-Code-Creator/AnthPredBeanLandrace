function PlotMedianColorLandraces(pathMAT, target)
matfile = dir(strcat(pathMAT,'*.mat'));                       % Cargar mascara de cada poblaci?n
SeedsMedians = [];
for k = 1:length(matfile)
    archivo = matfile(k).name;        % Nombre del imagen
    L = load(strcat(pathMAT,archivo)); % Carga el archivo de la m?scara
    SeedsMedians = [SeedsMedians;L.SeedsCIE];
end % end for matfiles
%load("valuesLAB.mat");
%MaxL = max(SeedsMedians(:,1));
%L=coordLAB(:,1)<MaxL;
%newdata=coordLAB(L,:);
%Seeds = [newdata;SeedsMedians];
%plot_Lab(4,Seeds',1,'',20,0,'100 Landraces');
plot_Lab(4,SeedsMedians',1,'',20,0,'100 Landraces');
%[L1, c1,h1] = CromaHueChannel1(SeedsMedians);
%disp(['L* ',num2str(median(L1)), ' C* ', num2str(median(c1)), ' H* ', num2str(median(h1)) ]);
end


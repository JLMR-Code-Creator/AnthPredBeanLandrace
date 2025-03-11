function [ XTrainLCH, YTrainLCH, XTrainPop, XTrainColor, ...
    XValidationLCH, YValidationLCH, XValidationPop, XValidationColor, ...
    XTestLCH, YTestLCH, XTestPop, XTestColor]...
    = Load_3H2DLCH(dbPopulations, pathDB)

XTrainLCH = [];
YTrainLCH = [];
XTrainPop = [];
XTrainColor = [];
XValidationLCH = [];
YValidationLCH = [];
XValidationPop = [];
XValidationColor = [];
XTestLCH = [];
YTestLCH = [];
XTestPop = [];
XTestColor = [];
for j = 1 : length(dbPopulations)
    archivo = dbPopulations(j).name;        % Nombre del imagen
    populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
    disp([datestr(datetime), ' Procesando población ',populationName]);
    % L =
    load(strcat(pathDB,archivo)); % Carga el archivo de la m?scara
    tv = cat(3, cie_ch_e, cie_lc_e, cie_lh_e);
    
    XTrainLCH = cat(4, XTrainLCH, tv);
    YTrainLCH = [YTrainLCH; valantocianinas];
    XTrainPop = [XTrainPop;{populationName}];
    XTrainColor = [XTrainColor;{color}];
    
    XValidationLCH = cat(4, XValidationLCH, tv);
    YValidationLCH = [YValidationLCH;valantocianinas];
    XValidationPop = [XValidationPop;{populationName}];
    XValidationColor = [XValidationColor;{color}];
    
    tt = cat(3, cie_ch_p, cie_lc_p, cie_lh_p);
    
    XTestLCH =cat(4, XTestLCH, tt);
    YTestLCH = [YTestLCH; valantocianinas];
    XTestPop = [XTestPop;{populationName}];
    XTestColor = [XTestColor;{color}];
    
    
end % for

end
function [ XTrainHSI, YTrainHSI, XTrainPop, XTrainColor, ...
           XValidationHSI, YValidationHSI, XValidationPop, XValidationColor, ...
           XTestHSI, YTestHSI, XTestPop, XTestColor]...
           = Load3H2DHSI(dbPopulations, pathDB, option)

    XTrainHSI = []; 
    YTrainHSI = []; 
    XTrainPop = []; 
    XTrainColor = [];
    XValidationHSI = []; 
    YValidationHSI = []; 
    XValidationPop = []; 
    XValidationColor = [];    
    XTestHSI = [];
    YTestHSI = [];
    XTestPop = [];
    XTestColor = [];
    for j = 1 : length(dbPopulations)
        archivo = dbPopulations(j).name;        % Nombre del imagen
        populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
        disp([datestr(datetime), ' Procesando población ',populationName]);
        % L = 
        load(strcat(pathDB,archivo)); % Carga el archivo de la m?scara
        if option == 1
            tv = hsi_hs_e;
        else % '3H'
            tv = cat(3, hsi_hs_e, hsi_hi_e, hsi_si_e);
        end
        XTrainHSI = cat(4, XTrainHSI, tv);
        YTrainHSI = [YTrainHSI; valantocianinas];
        XTrainPop = [XTrainPop;{populationName}];
        XTrainColor = [XTrainColor;{color}];
        
        XValidationHSI = cat(4, XValidationHSI, tv);
        YValidationHSI = [YValidationHSI;valantocianinas];
        XValidationPop = [XValidationPop;{populationName}];
        XValidationColor = [XValidationColor;{color}];
        
        if option == 1
            tt = hsi_hs_p;
        else % '3H'
            tt = cat(3, hsi_hs_p, hsi_hi_p, hsi_si_p);
        end

        XTestHSI =cat(4, XTestHSI, tt);
        YTestHSI = [YTestHSI; valantocianinas];
        XTestPop = [XTestPop;{populationName}];
        XTestColor = [XTestColor;{color}];       
        
                          
    end % for

end
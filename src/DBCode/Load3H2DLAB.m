function [ XTrainLAB, YTrainLAB, XTrainPop, XTrainColor, ...
           XValidationLAB, YValidationLAB, XValidationPop, XValidationColor, ...
           XTestLAB, YTestLAB, XTestPop, XTestColor]...
           = Load3H2DLAB(dbPopulations, pathDB, option)

    XTrainLAB = []; 
    YTrainLAB = []; 
    XTrainPop = []; 
    XTrainColor = [];
    XValidationLAB = []; 
    YValidationLAB = []; 
    XValidationPop = []; 
    XValidationColor = [];    
    XTestLAB = [];
    YTestLAB = [];
    XTestPop = [];
    XTestColor = [];
    for j = 1 : length(dbPopulations)
        archivo = dbPopulations(j).name;        % Nombre del imagen
        populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
        disp([datestr(datetime), ' Procesando población ',populationName]);
        % L = 
        load(strcat(pathDB,archivo)); % Carga el archivo de la m?scara
        if option == 1
            tv = cie_ab_e;
        else % '3H'
            tv = cat(3, cie_ab_e, cie_la_e, cie_lb_e);
        end
        XTrainLAB = cat(4, XTrainLAB, tv);
        YTrainLAB = [YTrainLAB; valantocianinas];
        XTrainPop = [XTrainPop;{populationName}];
        XTrainColor = [XTrainColor;{color}];
        
        XValidationLAB = cat(4, XValidationLAB, tv);
        YValidationLAB = [YValidationLAB;valantocianinas];
        XValidationPop = [XValidationPop;{populationName}];
        XValidationColor = [XValidationColor;{color}];
        
        if option == 1
            tt = cie_ab_p;
        else % '3H'
            tt = cat(3, cie_ab_p, cie_la_p, cie_lb_p);
        end

        XTestLAB =cat(4, XTestLAB, tt);
        YTestLAB = [YTestLAB; valantocianinas];
        XTestPop = [XTestPop;{populationName}];
        XTestColor = [XTestColor;{color}];       
        
                          
    end % for

end
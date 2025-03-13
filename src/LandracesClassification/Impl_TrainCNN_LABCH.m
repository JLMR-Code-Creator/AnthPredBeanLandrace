function  Impl_TrainCNN_LABCH(pathDB, file, epoch, dirOut, nameOut, colorSpace)
dbPopulations = dir(strcat(pathDB,file)); % Load data
N = length(dbPopulations);
finalDir = strcat(pathDB, dirOut); % Create directory
if ~exist('',finalDir)
    mkdir(finalDir);
end

if strcmp(colorSpace, 'LCH')==1
    [ XTrainLCH, YTrainLCH, XTrainPop, XTrainColor, ...
        XValidationLCH, YValidationLCH, XValidationPop, XValidationColor, ...
        XTestLCH, YTestLCH, XTestPop, XTestColor]...
        = Load3H2DLCH(dbPopulations, pathDB);
    TrainCNNWith3H2DLABCH(XTrainLCH, YTrainLCH, XTrainPop, XTrainColor, ...
        XValidationLCH, YValidationLCH, XValidationPop, XValidationColor, ...
        XTestLCH, YTestLCH, XTestPop, XTestColor, epoch, pathDB, dirOut, nameOut);
end
if strcmp(colorSpace, 'LAB')==1 %Cie lab
    [ XTrainLAB, YTrainLAB, XTrainPop, XTrainColor, ...
        XValidationLAB, YValidationLAB, XValidationPop, XValidationColor, ...
        XTestLAB, YTestLAB, XTestPop, XTestColor]...
        = Load3H2DLAB(dbPopulations, pathDB, 3);
    TrainCNNWith3H2DLAB(XTrainLAB, ...
        YTrainLAB, XTrainPop, XTrainColor, XValidationLAB, YValidationLAB, ...
        XValidationPop, XValidationColor, XTestLAB, YTestLAB, XTestPop, XTestColor, epoch, pathDB, dirOut, nameOut)
end

end

function [ XTrain, YTrainLabel, XValidation, YValidationLabel, ...
           XTest, YTestLabel] = Load3H2D(dbPopulations, pathDB, option)

    XTrain = []; YTrainLabel = []; 
    XValidation = []; YValidationLabel = [];   
    XTest = []; YTestLabel = [];

    for j = 1 : length(dbPopulations)
        archivo = dbPopulations(j).name;        % Nombre del imagen
        populationName = strrep(archivo,'.mat',''); % Nombre de la poblaci?n
        disp([datestr(datetime), ' Procesando población ',populationName]);
        load(strcat(pathDB,archivo)); % Carga el archivo de la m?scara


        if strcmp(option, '--H3D') == 1
            tv = cie_ab_e;
        elseif strcmp(option, '--3H2D--LAB') == 1
            tv = cat(3, cie_ab_e, cie_la_e, cie_lb_e);
        elseif strcmp(option, '--3H2D--LCH') == 1
            
        end
        XTrain = cat(4, XTrain, tv);
        YTrainLabel = [YTrainLabel; valantocianinas];
        XTrainPop = [XTrainPop;{populationName}];
        XTrainColor = [XTrainColor;{color}];
        
        XValidation = cat(4, XValidation, tv);
        YValidationLabel = [YValidationLabel;valantocianinas];
        XValidationPop = [XValidationPop;{populationName}];
        XValidationColor = [XValidationColor;{color}];
        
        if option == 1
            tt = cie_ab_p;
        else % '3H'
            tt = cat(3, cie_ab_p, cie_la_p, cie_lb_p);
        end

        XTest =cat(4, XTest, tt);
        YTestLabel = [YTestLabel; valantocianinas];
        XTestPop = [XTestPop;{populationName}];
        XTestColor = [XTestColor;{color}];       
        
                          
    end % for

end

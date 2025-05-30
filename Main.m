Head.Library;
% Function for image segmentation
Impl_Segmentation('../Images/Pob_frijol_27mm','*.tif');
% Function for show images and segmetations
val = Impl_ShowAllSegmentation('../Images/Pob_frijol_27mm/','*.tif');

% Split data process 50 and 50
SearchPartitions('../Images/Pob_frijol_27mm/', '*.mat', '../Images/Pob_frijol_27mm/NeuroEvolution/Particion/Historico');

HistoricToData('../Images/Pob_frijol_27mm/NeuroEvolution/Experimento/Historico/', '*.mat', '../Images/Pob_frijol_27mm/', '../Images/Pob_frijol_27mm/NeuroEvolution/Final');
% Was generated data for create the database for DeepGA Algorithm and
% the same db for train CNN using Matlab
ConvertH2D2CSV('../Images/Pob_frijol_27mm/NeuroEvolution/Final/', '*.mat', 'csv')


% Network training process
Impl_TrainCNN('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 250, 'CNNNeuroExp1/', 'OutcomeHSI1H2D_300','HSI', 1);
Impl_TrainCNN('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 250, 'CNNNeuroExp1/', 'OutcomeHSI3H2D_250','HSI', 3);
Impl_TrainCNN('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 250, 'CNNNeuroExp1/', 'OutcomeLAB1H2D_250','LAB', 1);
Impl_TrainCNN('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 250, 'CNNNeuroExp1/', 'OutcomeLAB3H2D_250','LAB', 3);

% Plot model performance

PlotCNN_LAB('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/CNNNeuroExp1/', 'OutcomeLAB1H2D.mat',1)
PlotCNN_LAB('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/CNNNeuroExp1/', 'OutcomeLAB3H2D.mat',3)
PlotCNN_HSI('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/CNNNeuroExp1/', 'OutcomeHSI1H2D.mat',1)
PlotCNN_HSI('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/CNNNeuroExp1/', 'OutcomeHSI3H2D.mat',3)

Plot_CNN_1H_3H_LAB('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/CNNNeuroExp1/', 'OutcomeLAB1H2D.mat', 'OutcomeLAB3H2D.mat');
Plot_CNN_1H_3H_HSI('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/CNNNeuroExp1/', 'OutcomeHSI1H2D.mat', 'OutcomeHSI3H2D.mat');

Test('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/CNNNeuroExp1/', 'OutcomeLAB1H2D.mat', 'OutcomeLAB3H2D.mat', 'OutcomeHSI1H2D.mat', 'OutcomeHSI3H2D.mat');


Plot_CNN_Overall('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/CNNNeuroExp1/', 'OutcomeLAB1H2D.mat', 'OutcomeLAB3H2D.mat', 'OutcomeHSI1H2D.mat', 'OutcomeHSI3H2D.mat');

Plot_CNN_1H_HSI_LAB('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/CNNNeuroExp1/', 'OutcomeLAB1H2D.mat',  'OutcomeHSI1H2D.mat');

Plot_CNN_3H_HSI_LAB('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/CNNNeuroExp1/', 'OutcomeLAB3H2D.mat',  'OutcomeHSI3H2D.mat');

% Show a especific result of segmentation

val = Impl_ShowEspecificSegmentationResult('../Images/Pob_frijol_27mm/','*.tif', 'P-34B');

% Network training process
Impl_TrainCNNCurve('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 200, 'CNNNeuroExp2/', 'OutcomeHSI1H2D_200','HSI', 1);
Impl_TrainCNNCurve('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 200, 'CNNNeuroExp2/', 'OutcomeHSI3H2D_200','HSI', 3);
Impl_TrainCNNCurve('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 200, 'CNNNeuroExp2/', 'OutcomeLAB1H2D_200','LAB', 1);
Impl_TrainCNNCurve('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 200, 'CNNNeuroExp2/', 'OutcomeLAB3H2D_200','LAB', 3);

% Network training process
Impl_TrainCNN('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 200, 'CNNNeuroExp3/', 'OutcomeHSI1H2D_200','HSI', 1);
Impl_TrainCNN('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 200, 'CNNNeuroExp3/', 'OutcomeHSI3H2D_200','HSI', 3);
Impl_TrainCNN('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 200, 'CNNNeuroExp3/', 'OutcomeLAB1H2D_200','LAB', 1);
Impl_TrainCNN('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 200, 'CNNNeuroExp3/', 'OutcomeLAB3H2D_200','LAB', 3);


%New challengeHe
% The modules and functions are derivate of the principal functions
HistoricToDataLCH('../Images/Pob_frijol_27mm/NeuroEvolution/Experimento/Historico/', '*.mat', '../Images/Pob_frijol_27mm/', '../Images/Pob_frijol_27mm/NeuroEvolution/FinalLCH');

Impl_TrainCNN_LCH('../Images/Pob_frijol_27mm/NeuroEvolution/FinalLCH/', '*.mat', 250, 'CNNNeuroExpLCH/', 'OutcomeLCH_32D_250','LCH');
Impl_TrainCNN_LCH('../Images/Pob_frijol_27mm/NeuroEvolution/FinalLCH/', '*.mat', 250, 'CNNNeuroExpLAB/', 'OutcomeLAB_32D_250','LAB');

% Classification of common bean landraces

% Impl_Umbralization('../Images/LANDRACES1/','*.tif');
% HomogeneousSeparation('../Images/LANDRACES/', '*.mat', '../Images/LANDRACES');
% val = Impl_ShowAllSegmentation('../Images/LANDRACES/','*.tif');
% Historico para la generación de datos.

% HistoricToData_LAB_LCH('../Images/LANDRACES/partitions/', '*.mat', '../Images/LANDRACES/', '../Images/LANDRACES/DB_LAB_&_LCH');
% moveFiles('../Images/LANDRACES/DB_LAB_&_LCH')

[output] = Impl_ClasificacionKNN('../Images/LANDRACES/DB_LAB_&_LCH/DB', '*.mat', 0);

%% section created for color quantification
%Image2GetMediana('../Images/Pob_frijol_27mm/', '*.tif', '');
%GetClases('../Images/LANDRACES/', '../Images/DB');% for DB creation
% Now read a db a classify eachs landraces
ReadDB2AssignLabel('../Images/DB','../Images/LANDRACES/', '');
%val = Impl_ShowAllSegmentation('../Images/LANDRACES/','PC-001-TOO-001-R1-C1.tif');
[correctas, incorrectas] = ShowColorQuantification('../Images/LANDRACES/', '../Images/DB/Clases');

%% Section for classification of bean landraces.
% Firts adjust the nethod for assing label automatic
GetSeedAnalysis('../Images/LANDRACES/', '../Images/DB');% for DB creation

PlotLandracesInCIE('../Images/LANDRACES/', '../Images/DB');
%********* El siguiente codigo es para generar el valor de la mediana LAB de cada semilla
% el resultado es un conjunto de valores de pixeles de las regiones de
% interés.
LandracesInCIEtoMAT('../Images/Pob_frijol_27mm/', '../Images/MedianLandraces');

PlotMedianColorLandraces( 'Z:/MedianLandraces/Black/','')

% Color pallete creation

% para unificar los histogramas generados de cada semilla de cada categoria
% de color, es la bd de conocimiento para el algortimo K-NN
Create_DBKnowledge4KNN('../Images/DB');

% Para la clasificación de cada semilla y generar la etiqueta de clase de
% la semilla de cada población de frijol.
ReadDB2AssignLabel('../Images/DB/', '../Images/LANDRACES/', 'db4knn.mat')

Dataset_Split('../Images/LANDRACES/Clases/', '*.mat', '', 30)


% Using the algoritmh for training and classify test samples
Classification_Laboratory('../Images/LANDRACES/Clases/3H2D_LAB_E210/corridas','../Images/LANDRACES/Clases/3H2D_LAB_E210/Epoch_100/','LAB', 100)
Classification_Laboratory('../Images/LANDRACES/Clases/3H2D_LCH_E210/corridas','../Images/LANDRACES/Clases/3H2D_LCH_E210/Epoch_500/','LCH', 500)


ConcentraResultados('../Images/LANDRACES/Clases/3H2D_LAB_E210/Epoch_500', '../Images/LANDRACES/Clases/3H2D_LCH_E210/Epoch_500')
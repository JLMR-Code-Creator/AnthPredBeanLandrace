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

% fue de prueba para verificar funcionamiento PlotCNN_LAB('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/CNNNeuroExp1/', 'HomoCNNADAM250_a.mat', 3)

% Creation of structures as of mask
%DivMorphoMask('src/Images/', 'src/Images/DB_StructMask/', 40);
%Binary images or masks to data set
%MorphoMask2DB('src/Images/', 'src/Images/DB_StructMask/', '*.mat', 'DataCenter');
%Dataset to leaning aprouches

% Average and Regression
%  val = Morpho_Regression('src/Images/DB_StructMask/DataCenter/', '*.mat', 1, 1, 0,'Report40AVG_Reg', '','','','');

% PCA and Regression
%   vec = 3:30;
%   val = Morpho_MultiRegression('src/Images/DB_StructMask/DataCenter/', '*.mat', vec, 1, 2, 'Report402D_Regress', '', '', '', '');


% Average  and ANN
%    val = Morpho_ANN('src/Images/DB_StructMask/DataCenter/', '*.mat', 1, 1, 0, 0, 'Report40AVG_ANN', '', '', '', '');


% PCA and ANN
%    vec = 3:30;
%    val = Morpho_MultiANN('src/Images/DB_StructMask/DataCenter/', '*.mat', vec, 1, 2, 'Report402D_ANN', '', '', '', '');

%PMF and AntEstNet 
%   Morpho_ProcessCNN('src/Images/DB_StructMask/DataCenter/', '*.mat', 500, 'Report_40P_CNN_500')



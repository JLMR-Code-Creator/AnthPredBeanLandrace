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



%
% Network training process
Impl_TrainCNN('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 200, 'CNNNeuroExp3/', 'OutcomeHSI1H2D_200','HSI', 1);
Impl_TrainCNN('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 200, 'CNNNeuroExp3/', 'OutcomeHSI3H2D_200','HSI', 3);
Impl_TrainCNN('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 200, 'CNNNeuroExp3/', 'OutcomeLAB1H2D_200','LAB', 1);
Impl_TrainCNN('../Images/Pob_frijol_27mm/NeuroEvolution/Final46/', '*.mat', 200, 'CNNNeuroExp3/', 'OutcomeLAB3H2D_200','LAB', 3);

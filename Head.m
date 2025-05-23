classdef Head
    methods(Static)
         function  Library()
            addpath src
            addpath src/ICC % Load code files
            addpath src/RGB2PCS
            addpath src/Segmentation
            addpath src/Images       %For the set of images
            addpath src/anthocyanin
            addpath src/DBCode
            addpath src/Color_characterization
            addpath src/SplitData
            addpath src/MATFiles
            addpath src/StatisticalTest
            addpath src/Landraces_P_VLC
            addpath src/LandracesClassification
            addpath src/ColorPalette
            close all;
            clear;
            clc;
         end 
    end
end


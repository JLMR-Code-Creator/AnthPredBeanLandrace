function Mask = MorphoSegmetation(I_rgb)
     
%     cs =  rgb2ycbcr(I_rgb);
%     channelY = cs(:,:,1);
%     channelY(channelY<32000)=0;
%     channelY(channelY>=32000)=1;
%     channelCb = cs(:,:,2);
%     channelCb(channelCb<32000)=0;
%     channelCb(channelCb>=32000)=1;
%     Mask = ~channelY + ~channelCb;
%     Mask(Mask>1)=1;
%     
    

% ========================    
    %Lab = ColorCalibration(I_rgb);      
%      Lab = rgb2lab(I_rgb);
%      umbral1 = Lab(:,:,2);
%      umbral1(umbral1 <- 6) = -128;
%      umbral1(umbral1 >= -6) = 0;
%      umbral1(umbral1 == -128) = 1;
%      
%      umbral2 = Lab(:,:,1);
%      umbral2(umbral2 <= 50) = 0; 
%      umbral2(umbral2 > 50) = 1;
%         
%      
%       Mask = umbral1 + umbral2;
%       Mask(Mask==1)=0;
%       Mask(Mask==2)=1;
%       Mask = ~Mask;
     
     
% ========================         
    
% % ========================    
%     umbral = I_rgb(:,:,3);
%     umbral(umbral<35000)=0;
%     %umbral(umbral>=35000)=1;
%     %Mask = umbral;
%     Mask = imbinarize(umbral);
%     Mask = ~Mask;
% % ========================    
    
            I = rgb2lab(I_rgb);
            
            % Define thresholds for channel 1 based on histogram settings
            channel1Min = 0;
            channel1Max = 89.648;
            
            % Define thresholds for channel 2 based on histogram settings
            channel2Min = -6.330;
            channel2Max = 129.020;
            
            % Define thresholds for channel 3 based on histogram settings
            channel3Min = -128.935;
            channel3Max = 129.074;
            % Create mask based on chosen histogram thresholds
            Mask = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
                (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
                (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
            



    Mask = CleanImpurities(Mask);
    Mask =  imfill(Mask, "holes");   
    se = offsetstrel('ball', 3, 1);
    Mask = imerode(uint8(Mask), se);
    Mask = bwperim(Mask);
    Mask =  imfill(Mask, "holes");
    Mask = uint8(Mask);
end

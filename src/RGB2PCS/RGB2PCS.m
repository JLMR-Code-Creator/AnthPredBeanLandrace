function [Lab] = RGB2PCS(I_rgb, ImagesSource, file)
% RGB2PCS function created for transform rgb to CIE L*a*b*
% 
% 
    dirLAB=strcat(ImagesSource,'imgLAB/');
    if (~exist(dirLAB, 'dir'))
        perfil = iccread('DSC00005.icc');
        perfil.Header.ColorSpace
        perfil.Header.ConnectionSpace
        C = makecform('clut', perfil, 'AToB1');
        I_Lab = applycform(I_rgb, C);
    else
        I_Lab = imread(strcat(dirLAB,'/',file));
    end
    aDouble = double(I_Lab); % Converting to double so can have decimals
    Lab= []; % 16 bits
    Lab(:,:,1) = aDouble(:,:,1)*100/65280; % L
    Lab(:,:,2) = aDouble(:,:,2)/256 - 128; % a
    Lab(:,:,3) = aDouble(:,:,3)/256 - 128 ;% b
end

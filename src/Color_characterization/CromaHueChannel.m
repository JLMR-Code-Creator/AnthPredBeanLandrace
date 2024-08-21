function [L1, c1,h1] = CromaHueChannel(lab1)
   [h1,c1] = cart2pol(lab1(:,:,2), lab1(:,:,3));
   h1 = h1*180/pi;
   L1 = lab1(:,:,1);
end


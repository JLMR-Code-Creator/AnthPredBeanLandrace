function [L1, c1,h1] = CromaHueChannel(lab1)
 %This module containe code that compute de Chroma and Hue values
 % of the parameters a* and b*

tam = size(lab1, 1);% size of matrix
h1 = zeros(tam, 1); % To create hue matrix
c1 = zeros(tam, 1); % To create Chroma matrix
for i=1:tam
    if(lab1(i,2) > 0 && lab1(i,3) > 0)             % + +
        h1(i) = atand(lab1(i,3)/lab1(i,2));
    elseif(lab1(i,2) < 0 && lab1(i,3) > 0)         %- +
        h1(i) = atand(lab1(i,3)/lab1(i,2)) + 180;
    elseif(lab1(i,2) < 0 && lab1(i,3) < 0 )        % - -
        h1(i) = atand(lab1(i,3)/lab1(i,2)) + 180;
    elseif(lab1(i,2) > 0 && lab1(i,3) < 0)         % + -
        h1(i) = atand(lab1(i,3)/lab1(i,2)) + 360;
    end
    c1(i) = sqrt(lab1(i,2).^2 + lab1(i,3).^2);
end %for loop

L1 = lab1(:,1);
end



function [cielab] = Pixles2H3DLAB(pixels)
    [rows,~] = size(pixels);
    pixels(:,1) = pixels(:,1) / 100;     % normalizaci�n [0-1]
    pixels(:,1) = pixels(:,1) * 255;     % escalado [0-127] 
    pixels(:,1) = pixels(:,1) + 1;       % desplazamiento [1-128]
    pixels(:,2:3) = pixels(:,2:3) + 129; % desplaza de [-128 - 127] a [0-255] a* b*
    pixels = round(pixels); 
    cielab=zeros(256,256,256); % matriz 3d de 128
        
    tic
    for i=1:rows 
        ind = pixels(i,:);
        cielab(ind(1), ind(2), ind(3)) = cielab(ind(1), ind(2), ind(3)) + 1;
    end           
    toc
        
    cielab=cielab/rows;    
    % elements = 256^3;
    % H3DMxN = zeros(elements, 4);
    % position = 1;
    % for i = 1:256
    %     for j=1:256
    %         for k=1:256
    %            H3DMxN(position,:) = [i,j,k,cielab(i, j, k)];
    %            position = position + 1;
    %         end
    %     end
    % end
    
end


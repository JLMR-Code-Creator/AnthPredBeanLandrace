function ConvertFormat(pathImg, outputDirectory)
mkdir(outputDirectory);
tiffile = dir(strcat(pathImg,'*.tif')); % Cargar mascara de cada poblaci?n
for i = 1:length(tiffile) 
    

    
    imageData = imread(tiffFilePath, i);
    
  
    % Specify the full path for the output JPEG image
    jpegFilePath = fullfile(outputDirectory, jpegFileName);
    
    % Write the current frame to a JPEG file
    imwrite(imageData, jpegFilePath);
end


end


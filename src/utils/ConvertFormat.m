function ConvertFormat(pathImg, outputDirectory)
mkdir(outputDirectory);
tiffile = dir(strcat(pathImg,'*.tif')); % Cargar mascara de cada poblaci?n
for i = 1:length(tiffile) 
    fileIMG = strcat(pathImg, tiffile(i).name);
    imageData = imread(fileIMG);
      
    % Specify the full path for the output JPEG image
    [filepath, name, ext] =  fileparts(fileIMG);
    jpegFilePath = strcat(outputDirectory, name, ".jpg");
    
    % Write the current frame to a JPEG file
    imwrite(imageData, jpegFilePath, "jpg");
end


end


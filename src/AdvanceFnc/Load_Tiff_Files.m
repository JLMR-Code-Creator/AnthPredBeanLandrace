function [tifImages, listMask, fileInfo] = Load_Tiff_Files()
% Prompt user to choose one or more .tif/.tiff files using uigetfile
% Allows multi-selection and returns images in tifImages and file info in fileInfo.

% Ask user to choose files (multi-select enabled)
[filenames, folder] = uigetfile({'*.tif;*.tiff','TIFF Files (*.tif, *.tiff)'; '*.*','All Files'}, ...
    'Select one or more TIFF files', 'MultiSelect', 'on');

% Handle cancel
if isequal(filenames,0)
    tifImages = {};
    listMask = {};
    fileInfo = struct('folder', {}, 'name', {}, 'fullpath', {});
    totalFiles = 0;
else
    % Normalize filenames to cell array
    if ischar(filenames)
        filenames = {filenames};
    end
    n = numel(filenames);
    tifImages = cell(1,n);
    listMask = cell(1,n);
    fileInfo = struct('folder', cell(1,n), 'name', cell(1,n), 'fullpath', cell(1,n));
    totalFiles = 0;
    for k = 1:n
        fn = filenames{k};
        [~, name, ~] = fileparts(fn);
        fp = fullfile(folder, fn);
        fm = fullfile(folder, 'Masks',strcat(name,'.mat'));
        try
            img = imread(fp);
            [I_Lab] = RGB2PCS(img, folder, strcat(name, '.tif'));
            totalFiles = totalFiles + 1;
            tifImages{totalFiles} = I_Lab;
            L = load(fm); % Carga el archivo de la m?scara
            Mask = uint8(L.Mask);
            Mask = ~Mask;
            % Limpieza de pixeles
            % Clean up small groups pixels
            [ML, ~] = bwlabel(Mask);          % Etiquetar granos de frijol conectados
            propied = regionprops(ML);       % Calcular propiedades de los objetos de la imagen
            s = find([propied.Area] < 1000);  % grupos menores a 100 px
            for i1 = 1 : size(s, 2)              % eliminaci�n de pixeles
                index = ML == s(i1);
                Mask(index) = 0;
            end
            listMask {totalFiles} =  Mask;
            fileInfo(totalFiles) = struct('folder', folder, 'name', fn, 'fullpath', fp);
        catch ME
            warning('Failed to read "%s": %s', fp, ME.message);
        end
    end
    % Trim preallocated cells/structs if some reads failed
    if totalFiles < n
        tifImages = tifImages(1:totalFiles);
        fileInfo = fileInfo(1:totalFiles);
        listMask = listMask(1:totalFiles);
    end
end

end
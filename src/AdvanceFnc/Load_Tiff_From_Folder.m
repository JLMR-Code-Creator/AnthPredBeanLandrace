function [tifImages,fileInfo] = Load_Tiff_From_Folder()

% Prompt user to select one or more folders, find .tif files, and load them.
% Uses uigetdir in a loop to allow multiple folder selection (since uigetfile
% doesn't select folders). Collects all .tif/.tiff files (case-insensitive)
% and reads them using imread into a cell array `tifImages`. Also returns a
% struct array `fileInfo` with filename and folder.
%
% Result variables:
%   tifImages - cell array of images
%   fileInfo  - struct array with fields: folder, name, fullpath
%   totalFiles - number of files loaded
%
% If the user cancels immediately, variables are empty and a message is shown.

tifImages = {};
fileInfo = struct('folder', {}, 'name', {}, 'fullpath', {});
totalFiles = 0;

% Let user pick folders repeatedly until they cancel or press OK with empty input.
uiPrompt = 'Select a folder containing .tif files. Cancel to finish selection.';
while true
    folder = uigetdir(pwd, uiPrompt);
    if isequal(folder, 0)
        break; % user cancelled — finish selection
    end
    % Find tif/tiff files in the chosen folder (non-recursive)
    d = dir(fullfile(folder, '*.tif'));
    d2 = dir(fullfile(folder, '*.tiff'));
    d = [d; d2];
    if isempty(d)
        uiwait(warndlg(sprintf('No .tif files found in:\n%s', folder), 'No Files', 'modal'));
    else
        for k = 1:numel(d)
            fp = fullfile(folder, d(k).name);
            try
                img = imread(fp);
            catch ME
                warning('Failed to read image "%s": %s', fp, ME.message);
                continue;
            end
            totalFiles = totalFiles + 1;
            tifImages{end+1} = img; %#ok<SAGROW>
            fileInfo(end+1) = struct('folder', folder, 'name', d(k).name, 'fullpath', fp); %#ok<SAGROW>
        end
    end
    % Ask whether to select another folder
    choice = questdlg('Select another folder?', 'Continue', 'Yes', 'No', 'No');
    if strcmp(choice, 'Yes')
        continue;
    else
        break;
    end
end

if totalFiles == 0
    disp('No TIFF files were loaded.');
else
    fprintf('Loaded %d TIFF file(s) from %d folder(s).\n', totalFiles, numel(unique({fileInfo.folder})));
end

end
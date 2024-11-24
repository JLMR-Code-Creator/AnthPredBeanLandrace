function [correctas, incorrectas] = ShowColorQuantification(pathImg, pathDB)
correctas = {};
incorrectas = {};
matfile = dir(strcat(pathDB,'/*.mat'));
for k = 1:length(matfile)
    registerFile = matfile(k);
    archivo = registerFile.name;    % Name of the bean landraces
    pahtFile = registerFile.folder;
    db = load(strcat(pahtFile,filesep,archivo));
    archivoTiff =  strrep(archivo,'.mat','.tif');
    tbl = cell2mat(db.tblPercantage);
    Irgb =  imread(strcat(pathImg,archivoTiff));
    figure('units','normalized','outerposition',[0 0 1 1]);
    imagesc(Irgb), title(archivoTiff), subtitle([num2str(tbl(:,3)'),num2str(tbl(:,2)'),db.finalClass']);
    
    answer = questdlg('Verificar la cuantificación', ...
    	'Cuantificación del color', ...
    	'Correcta','Incorrecta','Salir','Salir');
    % Handle response
    switch answer
        case 'Correcta'
            disp([answer ' coming right up.'])
            correctas = [correctas;{archivoTiff}];
            close all;
        case 'Incorrecta'
            disp([answer ' coming right up.'])
            incorrectas = [incorrectas, {archivoTiff}];
            close all;
        case 'Salir'
            disp('I''ll bring you your check.')
            k = length(matfile);
            close all;
            break;
    end % switch

end % for
end % function
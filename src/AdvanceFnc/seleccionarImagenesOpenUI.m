function fileList = seleccionarImagenesOpenUI()
% seleccionarImagenesOpenUI Abrir diálogo para seleccionar varias imágenes y devolver listado
%   fileList = seleccionarImagenesOpenUI() abre un UI panel para seleccionar
%   archivos de imagen de distintos formatos (jpg, png, tif, bmp, gif, jpeg).
%   Devuelve fileList como una tabla con columnas: Folder, Name, FullPath.
%
%   El usuario puede seleccionar múltiples archivos. Si cancela, fileList
%   será una tabla vacía.

% Extensiones soportadas
ext = {'*.jpg;*.jpeg;*.png;*.tif;*.tiff;*.bmp;*.gif','Imágenes (*.jpg,*.jpeg,*.png,*.tif,*.tiff,*.bmp,*.gif)'};

% Crear figura modal con uicontrols simples para selección y listado
hFig = figure('Name','Seleccionar imágenes','NumberTitle','off',...
    'MenuBar','none','ToolBar','none','Resize','off','Position',[300 300 600 400],...
    'WindowStyle','modal');

% Panel para botones
uipanel('Parent',hFig,'Units','normalized','Position',[0 0 0.3 1]);

% Lista de archivos seleccionados
hList = uicontrol('Parent',hFig,'Style','listbox','Units','normalized',...
    'Position',[0.31 0.05 0.68 0.9],'FontSize',10,'String',{});

% Botón para agregar archivos (usa uigetfile)
uicontrol('Parent',hFig,'Style','pushbutton','Units','normalized',...
    'Position',[0.02 0.8 0.26 0.12],'String','Agregar imágenes...','FontSize',10,...
    'Callback',@agregarCallback);

% Botón para limpiar lista
uicontrol('Parent',hFig,'Style','pushbutton','Units','normalized',...
    'Position',[0.02 0.65 0.26 0.12],'String','Limpiar lista','FontSize',10,...
    'Callback',@limpiarCallback);

% Botón para eliminar seleccionado
uicontrol('Parent',hFig,'Style','pushbutton','Units','normalized',...
    'Position',[0.02 0.5 0.26 0.12],'String','Eliminar seleccionado','FontSize',10,...
    'Callback',@eliminarCallback);

% Botón para aceptar y devolver resultado
uicontrol('Parent',hFig,'Style','pushbutton','Units','normalized',...
    'Position',[0.02 0.2 0.26 0.12],'String','Aceptar','FontSize',12,...
    'BackgroundColor',[0.2 0.6 0.2],'ForegroundColor','w','Callback',@aceptarCallback);

% Botón para cancelar
uicontrol('Parent',hFig,'Style','pushbutton','Units','normalized',...
    'Position',[0.02 0.05 0.26 0.12],'String','Cancelar','FontSize',12,...
    'BackgroundColor',[0.6 0.2 0.2],'ForegroundColor','w','Callback',@cancelarCallback);

% Datos internos: cell array de rutas completas
files = {};

% Wait until figure is closed
uiwait(hFig);

% Si figura fue cerrada por cancelar, devolver tabla vacía
if ~ishandle(hFig)
    fileList = table('Size',[0 3],'VariableTypes',{'string','string','string'},...
        'VariableNames',{'Folder','Name','FullPath'});
    return;
end

% Construir tabla con resultados
if isempty(files)
    fileList = table('Size',[0 3],'VariableTypes',{'string','string','string'},...
        'VariableNames',{'Folder','Name','FullPath'});
else
    fullpaths = files(:);
    [folders, names, extnames] = cellfun(@fileparts, fullpaths, 'UniformOutput', false);
    names = strcat(names, extnames);
    fileList = table(string(folders(:)), string(names(:)), string(fullpaths(:)),...
        'VariableNames',{'Folder','Name','FullPath'});
end

% Cerrar figura si aún existe
if ishandle(hFig)
    close(hFig);
end

% --- Callbacks ---
    function agregarCallback(~,~)
        % Permitir múltiples selecciones
        [fn, p] = uigetfile(ext, 'Seleccionar imágenes', 'MultiSelect', 'on');
        if isequal(fn,0)
            return; % canceló
        end
        if ischar(fn)
            fn = {fn};
        end
        % Construir rutas completas y añadir evitando duplicados
        nuevos = fullfile(p, fn);
        % Normalizar para evitar diferencias de mayúsculas/minúsculas en Windows
        if ispc
            normNew = lower(nuevos);
            normExist = lower(files);
        else
            normNew = nuevos;
            normExist = files;
        end
        toAdd = ~ismember(normNew, normExist);
        files = [files; nuevos(toAdd)']; %#ok<AGROW>
        actualizarLista();
    end

    function limpiarCallback(~,~)
        files = {};
        actualizarLista();
    end

    function eliminarCallback(~,~)
        idx = get(hList,'Value');
        if isempty(files)
            return;
        end
        if numel(idx)>1
            files(idx) = [];
        else
            files(idx) = [];
        end
        % Asegurar índice válido
        if isempty(files)
            set(hList,'Value',1);
        else
            set(hList,'Value',min(get(hList,'Value'),numel(files)));
        end
        actualizarLista();
    end

    function aceptarCallback(~,~)
        uiresume(hFig);
    end

    function cancelarCallback(~,~)
        files = {};
        if ishandle(hFig)
            close(hFig);
        end
    end

    function actualizarLista()
        if isempty(files)
            set(hList,'String',{'(ningún archivo seleccionado)'},'Value',1);
        else
            [~, names, extn] = cellfun(@fileparts, files, 'UniformOutput', false);
            names = strcat(names, extn);
            set(hList,'String',files,'Value',1,'TooltipString','Rutas completas');
        end
    end
end
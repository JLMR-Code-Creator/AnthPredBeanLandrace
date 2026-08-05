function InterfazValidacionPoblaciones(carpetaInicial)
%INTERFAZVALIDACIONPOBLACIONES Interfaz para segmentar y validar poblaciones.
%
%   InterfazValidacionPoblaciones
%   InterfazValidacionPoblaciones(carpetaInicial)
%
% Flujo de trabajo
%   1. Seleccionar la carpeta que contiene las imagenes de las poblaciones.
%   2. La tabla indica si cada imagen ya tiene un archivo MAT asociado.
%   3. Seleccionar una poblacion para visualizar su imagen y, cuando exista,
%      cargar automaticamente la mascara almacenada en el archivo MAT.
%   4. Si la mascara no es correcta, cambiar el umbral y pulsar
%      "Segmentar / repetir".
%   5. Pulsar "Aceptar, guardar y siguiente" para guardar la mascara y
%      avanzar automaticamente a la siguiente poblacion pendiente.
%
% Convencion de archivos MAT
%   - Todos los MAT se almacenan en la subcarpeta Masks.
%   - Si Masks no existe, la interfaz la crea automaticamente.
%   - Archivo principal: Masks/<nombreImagen>.mat
%   - Tambien se reconoce: Masks/<nombreImagen>_mascara.mat
%   - Los MAT antiguos ubicados junto a las imagenes se trasladan a Masks.
%   - La mascara se guarda en la variable logica BW.
%   - Adicionalmente se guardan infoSegmentacion, umbral, validada,
%     origenImagen y fechaValidacion.
%
% Variables de mascara reconocidas al cargar archivos existentes
%   BW, REGION, mascara, mask, Mask y segmentationMask. Si no existe una de
%   estas variables, se busca la primera matriz numerica o logica 2-D cuyo
%   tamano coincida con la imagen.
%
% Formatos de imagen reconocidos
%   TIF, TIFF, PNG, JPG, JPEG y BMP.
%
% Requiere Image Processing Toolbox. El uso de GPU requiere Parallel
% Computing Toolbox y una GPU compatible.
%
% Revision: corrige el alcance de los componentes UI, la carga de rutas,
% el reconocimiento de extensiones y el cierre seguro de la ventana.
% Los archivos MAT se administran exclusivamente en la subcarpeta Masks.

    if nargin < 1
        carpetaInicial = '';
    end

    state = struct();
    state.Folder = '';
    state.MasksFolder = '';
    state.Items = struct([]);
    state.CurrentIndex = 0;
    state.CurrentImage = [];
    state.CurrentPreview = [];
    state.CurrentLab = [];
    state.CurrentMask = [];
    state.CurrentMaskPreview = [];
    state.CurrentInfo = struct();
    state.CurrentMatMetadata = struct();
    state.LabDevice = 'No calculado';
    state.IsBusy = false;

    % IMPORTANTE: todos los componentes utilizados por callbacks se declaran
    % en el ambito de la funcion principal. De esta forma, las funciones
    % anidadas comparten los mismos manejadores y no intentan acceder a
    % variables locales exclusivas de crearInterfaz().
    fig = [];
    campoRuta = [];
    botonBuscar = [];
    botonActualizar = [];
    tabla = [];
    botonAnterior = [];
    botonPendiente = [];
    botonSiguiente = [];
    etiquetaResumen = [];
    ejeOriginal = [];
    ejeResultado = [];
    spinnerUmbral = [];
    spinnerArea = [];
    checkGPU = [];
    checkLimpiar = [];
    sliderTransparencia = [];
    etiquetaGPU = [];
    botonSegmentar = [];
    botonRecargarMAT = [];
    botonAceptar = [];
    etiquetaDatos = [];
    etiquetaActual = [];
    botonAbrirCarpeta = [];
    botonFinalizar = [];
    botonCerrar = [];
    etiquetaEstado = [];

    crearInterfaz();

    if ~isempty(carpetaInicial) && isfolder(carpetaInicial)
        cargarCarpeta(carpetaInicial);
    end

    function crearInterfaz()
        fig = uifigure( ...
            'Name', 'Segmentacion y validacion de poblaciones', ...
            'Position', [60 50 1500 900], ...
            'Color', [0.97 0.97 0.97], ...
            'CloseRequestFcn', @cerrarInterfaz);

        principal = uigridlayout(fig, [3 1]);
        principal.RowHeight = {52, '1x', 34};
        principal.Padding = [10 10 10 10];
        principal.RowSpacing = 8;

        barraRuta = uigridlayout(principal, [1 4]);
        barraRuta.Layout.Row = 1;
        barraRuta.ColumnWidth = {95, '1x', 125, 100};
        barraRuta.ColumnSpacing = 8;
        barraRuta.Padding = [0 0 0 0];

        uilabel(barraRuta, ...
            'Text', 'Carpeta:', ...
            'FontWeight', 'bold', ...
            'HorizontalAlignment', 'right');

        campoRuta = uieditfield(barraRuta, 'text', ...
            'Editable', 'off', ...
            'Placeholder', 'Seleccione la carpeta de las poblaciones');

        botonBuscar = uibutton(barraRuta, 'push', ...
            'Text', 'Buscar ruta...', ...
            'ButtonPushedFcn', @buscarRuta);

        botonActualizar = uibutton(barraRuta, 'push', ...
            'Text', 'Actualizar', ...
            'Enable', 'off', ...
            'ButtonPushedFcn', @actualizarCarpeta);

        contenido = uigridlayout(principal, [1 2]);
        contenido.Layout.Row = 2;
        contenido.ColumnWidth = {465, '1x'};
        contenido.ColumnSpacing = 10;
        contenido.Padding = [0 0 0 0];

        panelListado = uipanel(contenido, ...
            'Title', 'Poblaciones encontradas', ...
            'FontWeight', 'bold');
        panelListado.Layout.Column = 1;

        gridListado = uigridlayout(panelListado, [3 1]);
        gridListado.RowHeight = {'1x', 38, 58};
        gridListado.Padding = [8 8 8 8];
        gridListado.RowSpacing = 7;

        tabla = uitable(gridListado, ...
            'Data', cell(0,5), ...
            'ColumnName', {'N.', 'Poblacion', 'Estado', 'Umbral', 'Archivo MAT'}, ...
            'ColumnEditable', false(1,5), ...
            'ColumnWidth', {42, 180, 132, 65, 215}, ...
            'RowName', {}, ...
            'CellSelectionCallback', @seleccionarFila);
        tabla.Layout.Row = 1;

        navegacion = uigridlayout(gridListado, [1 3]);
        navegacion.Layout.Row = 2;
        navegacion.ColumnWidth = {'1x', '1x', '1x'};
        navegacion.Padding = [0 0 0 0];
        navegacion.ColumnSpacing = 6;

        botonAnterior = uibutton(navegacion, 'push', ...
            'Text', '< Anterior', ...
            'Enable', 'off', ...
            'ButtonPushedFcn', @irAnterior);

        botonPendiente = uibutton(navegacion, 'push', ...
            'Text', 'Siguiente pendiente', ...
            'Enable', 'off', ...
            'ButtonPushedFcn', @irSiguientePendiente);

        botonSiguiente = uibutton(navegacion, 'push', ...
            'Text', 'Siguiente >', ...
            'Enable', 'off', ...
            'ButtonPushedFcn', @irSiguiente);

        etiquetaResumen = uilabel(gridListado, ...
            'Text', 'Seleccione una carpeta.', ...
            'WordWrap', 'on', ...
            'VerticalAlignment', 'top');
        etiquetaResumen.Layout.Row = 3;

        panelTrabajo = uipanel(contenido, ...
            'Title', 'Validacion visual de la segmentacion', ...
            'FontWeight', 'bold');
        panelTrabajo.Layout.Column = 2;

        gridTrabajo = uigridlayout(panelTrabajo, [3 2]);
        gridTrabajo.RowHeight = {'1x', 205, 42};
        gridTrabajo.ColumnWidth = {'1x', '1x'};
        gridTrabajo.Padding = [8 8 8 8];
        gridTrabajo.RowSpacing = 8;
        gridTrabajo.ColumnSpacing = 8;

        ejeOriginal = uiaxes(gridTrabajo);
        ejeOriginal.Layout.Row = 1;
        ejeOriginal.Layout.Column = 1;
        ejeOriginal.Toolbar.Visible = 'on';
        title(ejeOriginal, 'Imagen original');
        axis(ejeOriginal, 'image');
        ejeOriginal.XTick = [];
        ejeOriginal.YTick = [];

        ejeResultado = uiaxes(gridTrabajo);
        ejeResultado.Layout.Row = 1;
        ejeResultado.Layout.Column = 2;
        ejeResultado.Toolbar.Visible = 'on';
        title(ejeResultado, 'Mascara superpuesta');
        axis(ejeResultado, 'image');
        ejeResultado.XTick = [];
        ejeResultado.YTick = [];

        panelParametros = uipanel(gridTrabajo, ...
            'Title', 'Parametros y procesamiento');
        panelParametros.Layout.Row = 2;
        panelParametros.Layout.Column = [1 2];

        parametros = uigridlayout(panelParametros, [4 6]);
        parametros.RowHeight = {36, 36, 36, 54};
        parametros.ColumnWidth = {105, 105, 105, 125, 120, '1x'};
        parametros.Padding = [8 8 8 8];
        parametros.RowSpacing = 6;
        parametros.ColumnSpacing = 7;

        uilabel(parametros, ...
            'Text', 'Umbral a*b*:', ...
            'HorizontalAlignment', 'right');
        spinnerUmbral = uispinner(parametros, ...
            'Limits', [0.5 100], ...
            'Step', 0.5, ...
            'Value', 17, ...
            'ValueDisplayFormat', '%.1f');

        uilabel(parametros, ...
            'Text', 'Area minima:', ...
            'HorizontalAlignment', 'right');
        spinnerArea = uispinner(parametros, ...
            'Limits', [0 1e8], ...
            'Step', 100, ...
            'Value', 0, ...
            'ValueDisplayFormat', '%.0f', ...
            'Tooltip', 'Cero utiliza el calculo automatico.');

        checkGPU = uicheckbox(parametros, ...
            'Text', 'Usar GPU', ...
            'Value', true, ...
            'ValueChangedFcn', @cambiarPreferenciaGPU);

        checkLimpiar = uicheckbox(parametros, ...
            'Text', 'Limpiar mascara', ...
            'Value', true);

        uilabel(parametros, ...
            'Text', 'Transparencia:', ...
            'HorizontalAlignment', 'right');
        sliderTransparencia = uislider(parametros, ...
            'Limits', [0.15 0.90], ...
            'Value', 0.55, ...
            'MajorTicks', [0.15 0.35 0.55 0.75 0.90], ...
            'ValueChangedFcn', @cambiarTransparencia);
        sliderTransparencia.Layout.Column = [2 3];

        etiquetaGPU = uilabel(parametros, ...
            'Text', ['GPU disponible: ' localSiNo(localCanUseGPU())], ...
            'FontWeight', 'bold');
        etiquetaGPU.Layout.Column = [4 6];

        botonSegmentar = uibutton(parametros, 'push', ...
            'Text', 'Segmentar / repetir', ...
            'Enable', 'off', ...
            'FontWeight', 'bold', ...
            'ButtonPushedFcn', @segmentarActual);
        botonSegmentar.Layout.Row = 3;
        botonSegmentar.Layout.Column = [1 2];

        botonRecargarMAT = uibutton(parametros, 'push', ...
            'Text', 'Recargar mascara MAT', ...
            'Enable', 'off', ...
            'ButtonPushedFcn', @recargarMascaraMat);
        botonRecargarMAT.Layout.Row = 3;
        botonRecargarMAT.Layout.Column = [3 4];

        botonAceptar = uibutton(parametros, 'push', ...
            'Text', 'Aceptar, guardar y siguiente', ...
            'Enable', 'off', ...
            'FontWeight', 'bold', ...
            'ButtonPushedFcn', @aceptarGuardarSiguiente);
        botonAceptar.Layout.Row = 3;
        botonAceptar.Layout.Column = [5 6];

        etiquetaDatos = uilabel(parametros, ...
            'Text', 'Sin poblacion seleccionada.', ...
            'WordWrap', 'on', ...
            'VerticalAlignment', 'top');
        etiquetaDatos.Layout.Row = 4;
        etiquetaDatos.Layout.Column = [1 6];

        acciones = uigridlayout(gridTrabajo, [1 4]);
        acciones.Layout.Row = 3;
        acciones.Layout.Column = [1 2];
        acciones.ColumnWidth = {'1x', 180, 180, 105};
        acciones.Padding = [0 0 0 0];
        acciones.ColumnSpacing = 7;

        etiquetaActual = uilabel(acciones, ...
            'Text', 'Ninguna poblacion seleccionada.', ...
            'FontWeight', 'bold');

        botonAbrirCarpeta = uibutton(acciones, 'push', ...
            'Text', 'Abrir carpeta Masks', ...
            'Enable', 'off', ...
            'ButtonPushedFcn', @abrirCarpetaSistema);

        botonFinalizar = uibutton(acciones, 'push', ...
            'Text', 'Comprobar finalizacion', ...
            'Enable', 'off', ...
            'ButtonPushedFcn', @comprobarFinalizacion);

        botonCerrar = uibutton(acciones, 'push', ...
            'Text', 'Cerrar', ...
            'FontWeight', 'bold', ...
            'ButtonPushedFcn', @cerrarInterfaz);

        etiquetaEstado = uilabel(principal, ...
            'Text', 'Listo.', ...
            'FontColor', [0.15 0.15 0.15]);
        etiquetaEstado.Layout.Row = 3;

        limpiarEjes();
    end

    function buscarRuta(~, ~)
        if state.IsBusy
            return;
        end

        if isempty(state.Folder) || ~isfolder(state.Folder)
            inicio = pwd;
        else
            inicio = state.Folder;
        end

        % uigetdir devuelve 0 cuando el usuario cancela.
        carpeta = uigetdir(inicio, 'Seleccione la carpeta de las poblaciones');
        if isequal(carpeta, 0)
            etiquetaEstado.Text = 'Seleccion de carpeta cancelada.';
            return;
        end

        % Mostrar inmediatamente la ruta elegida y permitir que drawnow
        % actualice la interfaz antes de iniciar la lectura de archivos.
        carpeta = char(carpeta);
        campoRuta.Value = carpeta;
        etiquetaEstado.Text = 'Ruta seleccionada. Buscando imagenes...';
        drawnow;

        try
            cargarCarpeta(carpeta);
        catch ME
            state.IsBusy = false;
            if ~isempty(fig) && isvalid(fig)
                setBusy(false, 'Error al cargar la carpeta.');
                uialert(fig, ME.message, 'No se pudo cargar la carpeta', ...
                    'Icon', 'error');
            end
        end
    end

    function actualizarCarpeta(~, ~)
        if ~isempty(state.Folder) && isfolder(state.Folder)
            cargarCarpeta(state.Folder);
        end
    end

    function cargarCarpeta(carpeta)
        if state.IsBusy
            return;
        end

        setBusy(true, 'Validando carpeta Masks y buscando imagenes...');
        cleanup = onCleanup(@() setBusy(false, 'Listo.'));

        % La carpeta seleccionada contiene exclusivamente las imagenes. Los
        % archivos MAT se leen y guardan en la subcarpeta Masks.
        carpetaMasks = localAsegurarCarpetaMasks(carpeta);
        state.MasksFolder = carpetaMasks;

        % Leer una sola vez el contenido de la carpeta y filtrar las
        % extensiones sin distinguir mayusculas/minusculas. Esto permite
        % reconocer, por ejemplo, .TIF y .TIFF en cualquier sistema operativo.
        contenidoCarpeta = dir(carpeta);
        contenidoCarpeta = contenidoCarpeta(~[contenidoCarpeta.isdir]);
        extensionesValidas = {'.tif','.tiff','.png','.jpg','.jpeg','.bmp'};
        esImagen = false(numel(contenidoCarpeta), 1);

        for k = 1:numel(contenidoCarpeta)
            [~, ~, extension] = fileparts(contenidoCarpeta(k).name);
            esImagen(k) = any(strcmpi(extension, extensionesValidas));
        end

        archivos = contenidoCarpeta(esImagen);

        if isempty(archivos)
            state.Folder = carpeta;
            state.MasksFolder = carpetaMasks;
            state.Items = struct([]);
            state.CurrentIndex = 0;
            campoRuta.Value = carpeta;
            campoRuta.Tooltip = sprintf('Imagenes: %s\nMascaras MAT: %s', carpeta, carpetaMasks);
            tabla.Data = cell(0,5);
            etiquetaResumen.Text = 'No se encontraron imagenes compatibles.';
            limpiarActual();
            actualizarControles();
            uialert(fig, ...
                'La carpeta no contiene archivos TIF, TIFF, PNG, JPG, JPEG o BMP.', ...
                'Sin imagenes', 'Icon', 'warning');
            return;
        end

        % Excluir imagenes auxiliares generadas por procesos anteriores.
        conservar = true(numel(archivos),1);
        for i = 1:numel(archivos)
            [~, baseAuxiliar, ~] = fileparts(archivos(i).name);
            baseAuxiliar = lower(baseAuxiliar);
            sufijosAuxiliares = {'_mascara','_mask','_segmentacion','_overlay'};
            for s = 1:numel(sufijosAuxiliares)
                sufijo = sufijosAuxiliares{s};
                if numel(baseAuxiliar) >= numel(sufijo) && ...
                        strcmp(baseAuxiliar(end-numel(sufijo)+1:end), sufijo)
                    conservar(i) = false;
                    break;
                end
            end
        end
        archivos = archivos(conservar);

        if isempty(archivos)
            state.Folder = carpeta;
            state.MasksFolder = carpetaMasks;
            state.Items = struct([]);
            state.CurrentIndex = 0;
            campoRuta.Value = carpeta;
            campoRuta.Tooltip = sprintf('Imagenes: %s\nMascaras MAT: %s', carpeta, carpetaMasks);
            tabla.Data = cell(0,5);
            etiquetaResumen.Text = 'Solo se encontraron imagenes auxiliares o mascaras.';
            limpiarActual();
            actualizarControles();
            uialert(fig, ...
                'No se encontraron imagenes de poblaciones para procesar.', ...
                'Sin poblaciones', 'Icon', 'warning');
            return;
        end

        nombresMinuscula = cellfun(@lower, {archivos.name}, ...
            'UniformOutput', false);
        [~, orden] = sort(nombresMinuscula);
        archivos = archivos(orden);

        items = repmat(struct( ...
            'Name', '', ...
            'BaseName', '', ...
            'ImagePath', '', ...
            'MatPath', '', ...
            'MatExists', false, ...
            'Validated', false, ...
            'Status', '', ...
            'Threshold', 17), numel(archivos), 1);

        for i = 1:numel(archivos)
            nombre = archivos(i).name;
            [~, base, ~] = fileparts(nombre);
            rutaImagen = fullfile(carpeta, nombre);
            [rutaMat, existeMat] = localResolverRutaMat(carpeta, carpetaMasks, base);

            validada = false;
            umbralGuardado = 17;
            estado = 'Sin MAT';

            if existeMat
                estado = 'MAT existente';
                try
                    resumen = localLeerResumenMat(rutaMat);
                    if isfield(resumen, 'Validada') && resumen.Validada
                        validada = true;
                        estado = 'Validada';
                    end
                    if isfield(resumen, 'Threshold') && ...
                            isfinite(resumen.Threshold) && resumen.Threshold > 0
                        umbralGuardado = resumen.Threshold;
                    end
                catch
                    estado = 'MAT no legible';
                end
            end

            items(i).Name = nombre;
            items(i).BaseName = base;
            items(i).ImagePath = rutaImagen;
            items(i).MatPath = rutaMat;
            items(i).MatExists = existeMat;
            items(i).Validated = validada;
            items(i).Status = estado;
            items(i).Threshold = umbralGuardado;
        end

        state.Folder = carpeta;
        state.MasksFolder = carpetaMasks;
        state.Items = items;
        state.CurrentIndex = 0;
        campoRuta.Value = carpeta;
        campoRuta.Tooltip = sprintf('Imagenes: %s\nMascaras MAT: %s', carpeta, carpetaMasks);
        limpiarActual();
        actualizarTabla();
        actualizarControles();

        botonActualizar.Enable = 'on';
        botonAbrirCarpeta.Enable = 'on';
        botonFinalizar.Enable = 'on';
        botonAnterior.Enable = 'on';
        botonSiguiente.Enable = 'on';
        botonPendiente.Enable = 'on';

        indiceInicial = encontrarSiguientePendiente(0);
        if isempty(indiceInicial)
            indiceInicial = 1;
        end
        clear cleanup
        cargarPoblacion(indiceInicial);
    end

    function seleccionarFila(~, evento)
        if state.IsBusy || isempty(evento.Indices)
            return;
        end
        fila = evento.Indices(1,1);
        cargarPoblacion(fila);
    end

    function cargarPoblacion(indice)
        if state.IsBusy || isempty(state.Items)
            return;
        end
        if indice < 1 || indice > numel(state.Items)
            return;
        end

        setBusy(true, sprintf('Cargando %s...', state.Items(indice).Name));
        cleanup = onCleanup(@() setBusy(false, 'Listo.'));

        limpiarActual();
        state.CurrentIndex = indice;
        item = state.Items(indice);

        try
            I = localLeerImagenRGB(item.ImagePath);
        catch ME
            state.Items(indice).Status = 'Error de imagen';
            state.Items(indice).Validated = false;
            actualizarTabla();
            actualizarControles();
            uialert(fig, ME.message, 'No se pudo leer la imagen', 'Icon', 'error');
            return;
        end

        state.CurrentImage = I;
        state.CurrentPreview = localCrearVistaPrevia(I, 1700);
        state.CurrentLab = [];
        state.CurrentMask = [];
        state.CurrentMaskPreview = [];
        state.CurrentInfo = struct();
        state.CurrentMatMetadata = struct();
        state.LabDevice = 'No calculado';

        spinnerUmbral.Value = min(max(item.Threshold, ...
            spinnerUmbral.Limits(1)), spinnerUmbral.Limits(2));

        imshow(state.CurrentPreview, 'Parent', ejeOriginal);
        title(ejeOriginal, sprintf('Original: %s', item.Name), ...
            'Interpreter', 'none');

        if item.MatExists && exist(item.MatPath, 'file') == 2
            try
                [BW, metadata] = localCargarMascaraMat( ...
                    item.MatPath, size(I,1), size(I,2));
                state.CurrentMask = BW;
                state.CurrentMaskPreview = [];
                state.CurrentMatMetadata = metadata;
                state.CurrentInfo = localExtraerInfoSegmentacion(metadata);

                umbralMat = localExtraerUmbral(metadata);
                if ~isempty(umbralMat)
                    spinnerUmbral.Value = min(max(umbralMat, ...
                        spinnerUmbral.Limits(1)), spinnerUmbral.Limits(2));
                    state.Items(indice).Threshold = spinnerUmbral.Value;
                end

                if state.Items(indice).Validated
                    state.Items(indice).Status = 'Validada';
                else
                    state.Items(indice).Status = 'MAT cargado';
                end
                botonRecargarMAT.Enable = 'on';
            catch ME
                state.Items(indice).Status = 'MAT invalido';
                state.Items(indice).Validated = false;
                state.CurrentMask = [];
                state.CurrentMaskPreview = [];
                state.CurrentMatMetadata = struct();
                botonRecargarMAT.Enable = 'off';
                etiquetaEstado.Text = ['El MAT existente no contiene una mascara valida: ' ME.message];
            end
        else
            botonRecargarMAT.Enable = 'off';
        end

        actualizarTabla();
        mostrarResultado();
        actualizarControles();
        actualizarDatosActuales();
        seleccionarFilaTabla(indice);

        clear cleanup
    end

    function segmentarActual(~, ~)
        if state.IsBusy || state.CurrentIndex == 0 || isempty(state.CurrentImage)
            return;
        end

        umbral = spinnerUmbral.Value;
        if spinnerArea.Value <= 0
            areaMinima = [];
        else
            areaMinima = round(spinnerArea.Value);
        end

        setBusy(true, sprintf('Segmentando con umbral %.1f...', umbral));
        cleanup = onCleanup(@() setBusy(false, 'Segmentacion terminada.'));

        try
            if isempty(state.CurrentLab)
                [state.CurrentLab, state.LabDevice] = localPrepararLab( ...
                    state.CurrentImage, checkGPU.Value);
            end

            timer = tic;
            [BW, info] = SegmentarFrijolesLabRapido( ...
                state.CurrentLab, umbral, checkGPU.Value, ...
                areaMinima, checkLimpiar.Value);
            tiempoInterfaz = toc(timer);

            info.InterfaceSegmentationSeconds = tiempoInterfaz;
            info.LabStorageDevice = state.LabDevice;

            state.CurrentMask = BW;
            state.CurrentMaskPreview = [];
            state.CurrentInfo = info;
            state.Items(state.CurrentIndex).Threshold = umbral;
            state.Items(state.CurrentIndex).Validated = false;
            state.Items(state.CurrentIndex).Status = 'Resultado pendiente';

            actualizarTabla();
            mostrarResultado();
            actualizarControles();
            actualizarDatosActuales();
        catch ME
            uialert(fig, ME.message, 'Error durante la segmentacion', 'Icon', 'error');
        end

        clear cleanup
    end

    function recargarMascaraMat(~, ~)
        if state.IsBusy || state.CurrentIndex == 0
            return;
        end

        item = state.Items(state.CurrentIndex);
        if ~item.MatExists || exist(item.MatPath, 'file') ~= 2
            uialert(fig, 'No existe un archivo MAT para esta poblacion.', ...
                'Archivo no encontrado', 'Icon', 'warning');
            return;
        end

        setBusy(true, 'Recargando la mascara almacenada...');
        cleanup = onCleanup(@() setBusy(false, 'Mascara MAT recargada.'));

        try
            [BW, metadata] = localCargarMascaraMat( ...
                item.MatPath, size(state.CurrentImage,1), size(state.CurrentImage,2));
            state.CurrentMask = BW;
            state.CurrentMaskPreview = [];
            state.CurrentMatMetadata = metadata;
            state.CurrentInfo = localExtraerInfoSegmentacion(metadata);

            umbralMat = localExtraerUmbral(metadata);
            if ~isempty(umbralMat)
                spinnerUmbral.Value = min(max(umbralMat, ...
                    spinnerUmbral.Limits(1)), spinnerUmbral.Limits(2));
            end

            if state.Items(state.CurrentIndex).Validated
                state.Items(state.CurrentIndex).Status = 'Validada';
            else
                state.Items(state.CurrentIndex).Status = 'MAT cargado';
            end
            mostrarResultado();
            actualizarTabla();
            actualizarControles();
            actualizarDatosActuales();
        catch ME
            uialert(fig, ME.message, 'Mascara MAT invalida', 'Icon', 'error');
        end

        clear cleanup
    end

    function aceptarGuardarSiguiente(~, ~)
        if state.IsBusy || state.CurrentIndex == 0 || isempty(state.CurrentMask)
            return;
        end

        indiceGuardado = state.CurrentIndex;
        item = state.Items(indiceGuardado);
        umbral = spinnerUmbral.Value;
        BW = logical(state.CurrentMask); %#ok<NASGU>
        validada = true; %#ok<NASGU>
        origenImagen = item.Name; %#ok<NASGU>
        fechaValidacion = datestr(now, 'yyyy-mm-dd HH:MM:SS'); %#ok<NASGU>

        infoSegmentacion = state.CurrentInfo; %#ok<NASGU>
        if isempty(fieldnames(infoSegmentacion))
            infoSegmentacion = struct(); %#ok<NASGU>
        end
        infoSegmentacion.Threshold = umbral;
        infoSegmentacion.ValidationAccepted = true;
        infoSegmentacion.ValidationDate = fechaValidacion;
        infoSegmentacion.SourceImage = origenImagen;

        setBusy(true, sprintf('Guardando %s...', item.MatPath));
        cleanup = onCleanup(@() setBusy(false, 'Mascara guardada y validada.'));

        % El temporal se crea dentro de Masks para que el reemplazo final
        % ocurra en el mismo volumen y sea lo mas seguro posible.
        archivoTemporal = [tempname(state.MasksFolder) '.mat'];
        guardadoCorrecto = false;
        siguiente = [];
        try
            save(archivoTemporal, 'BW', 'infoSegmentacion', 'umbral', ...
                'validada', 'origenImagen', 'fechaValidacion', '-v7');

            [movido, mensaje] = movefile(archivoTemporal, item.MatPath, 'f');
            if ~movido
                error('No se pudo reemplazar el archivo MAT: %s', mensaje);
            end

            state.Items(indiceGuardado).MatExists = true;
            state.Items(indiceGuardado).Validated = true;
            state.Items(indiceGuardado).Status = 'Validada';
            state.Items(indiceGuardado).Threshold = umbral;
            state.CurrentMatMetadata = struct( ...
                'umbral', umbral, ...
                'validada', true, ...
                'infoSegmentacion', infoSegmentacion);

            actualizarTabla();
            actualizarResumen();
            siguiente = encontrarSiguientePendiente(indiceGuardado);
            guardadoCorrecto = true;
        catch ME
            if exist(archivoTemporal, 'file') == 2
                delete(archivoTemporal);
            end
            uialert(fig, ME.message, 'No se pudo guardar la mascara', 'Icon', 'error');
        end

        clear cleanup

        if guardadoCorrecto
            if isempty(siguiente)
                mostrarResultado();
                actualizarControles();
                actualizarDatosActuales();
                uialert(fig, ...
                    sprintf(['Se finalizaron las %d poblaciones.\n' ...
                             'Todas cuentan con una mascara validada.'], ...
                             numel(state.Items)), ...
                    'Proceso finalizado', 'Icon', 'info');
            else
                cargarPoblacion(siguiente);
            end
        end
    end

    function irAnterior(~, ~)
        if isempty(state.Items)
            return;
        end
        if state.CurrentIndex <= 1
            indice = numel(state.Items);
        else
            indice = state.CurrentIndex - 1;
        end
        cargarPoblacion(indice);
    end

    function irSiguiente(~, ~)
        if isempty(state.Items)
            return;
        end
        if state.CurrentIndex >= numel(state.Items)
            indice = 1;
        else
            indice = state.CurrentIndex + 1;
        end
        cargarPoblacion(indice);
    end

    function irSiguientePendiente(~, ~)
        if isempty(state.Items)
            return;
        end
        indice = encontrarSiguientePendiente(state.CurrentIndex);
        if isempty(indice)
            uialert(fig, 'No quedan poblaciones pendientes de validacion.', ...
                'Proceso completo', 'Icon', 'info');
        else
            cargarPoblacion(indice);
        end
    end

    function indice = encontrarSiguientePendiente(desde)
        indice = [];
        n = numel(state.Items);
        if n == 0
            return;
        end

        if desde < 0 || desde > n
            desde = 0;
        end

        orden = [desde+1:n, 1:desde];
        for k = 1:numel(orden)
            candidato = orden(k);
            if ~state.Items(candidato).Validated
                indice = candidato;
                return;
            end
        end
    end

    function cambiarTransparencia(~, ~)
        if ~isempty(state.CurrentImage)
            mostrarResultado();
        end
    end

    function cambiarPreferenciaGPU(~, ~)
        % Fuerza una nueva preparacion Lab para respetar la preferencia.
        state.CurrentLab = [];
        state.LabDevice = 'No calculado';
        actualizarDatosActuales();
    end

    function mostrarResultado()
        cla(ejeResultado);

        if isempty(state.CurrentPreview)
            title(ejeResultado, 'Mascara superpuesta');
            ejeResultado.XTick = [];
            ejeResultado.YTick = [];
            return;
        end

        if isempty(state.CurrentMask)
            imshow(state.CurrentPreview, 'Parent', ejeResultado);
            title(ejeResultado, 'Sin mascara disponible');
            text(ejeResultado, 0.5, 0.06, ...
                'Pulse "Segmentar / repetir" para generarla.', ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'Color', 'yellow', ...
                'FontWeight', 'bold', ...
                'BackgroundColor', 'black', ...
                'Margin', 4);
            return;
        end

        if isempty(state.CurrentMaskPreview)
            state.CurrentMaskPreview = imresize(state.CurrentMask, ...
                [size(state.CurrentPreview,1), size(state.CurrentPreview,2)], ...
                'nearest');
        end
        RGBvista = localImagenVisual(state.CurrentPreview);
        overlay = labeloverlay(RGBvista, state.CurrentMaskPreview, ...
            'Colormap', [0 1 0], ...
            'Transparency', sliderTransparencia.Value);
        imshow(overlay, 'Parent', ejeResultado);

        [conteo, ~] = obtenerEstadisticasActuales();
        title(ejeResultado, sprintf('Resultado: %d objetos, umbral %.1f', ...
            conteo, spinnerUmbral.Value));
    end

    function actualizarTabla()
        n = numel(state.Items);
        datos = cell(n,5);
        for i = 1:n
            datos{i,1} = i;
            datos{i,2} = state.Items(i).Name;
            datos{i,3} = state.Items(i).Status;
            datos{i,4} = state.Items(i).Threshold;
            if state.Items(i).MatExists
                [~, nombreMat, extensionMat] = fileparts(state.Items(i).MatPath);
                datos{i,5} = [nombreMat extensionMat];
            else
                datos{i,5} = '(se creara al aceptar)';
            end
        end
        tabla.Data = datos;
        actualizarResumen();
    end

    function actualizarResumen()
        total = numel(state.Items);
        if total == 0
            etiquetaResumen.Text = 'No hay poblaciones cargadas.';
            return;
        end
        validadas = nnz([state.Items.Validated]);
        conMat = nnz([state.Items.MatExists]);
        pendientes = total - validadas;
        etiquetaResumen.Text = sprintf([ ...
            'Total: %d   |   Con MAT: %d   |   Validadas: %d   |   Pendientes: %d\n' ...
            'MAT: %s'], ...
            total, conMat, validadas, pendientes, state.MasksFolder);
    end

    function actualizarControles()
        hayImagen = state.CurrentIndex > 0 && ~isempty(state.CurrentImage);
        hayMascara = hayImagen && ~isempty(state.CurrentMask);

        botonSegmentar.Enable = localOnOff(hayImagen && ~state.IsBusy);
        botonAceptar.Enable = localOnOff(hayMascara && ~state.IsBusy);

        if hayImagen && state.Items(state.CurrentIndex).MatExists && ...
                exist(state.Items(state.CurrentIndex).MatPath, 'file') == 2
            botonRecargarMAT.Enable = localOnOff(~state.IsBusy);
        else
            botonRecargarMAT.Enable = 'off';
        end

        spinnerUmbral.Enable = localOnOff(hayImagen && ~state.IsBusy);
        spinnerArea.Enable = localOnOff(hayImagen && ~state.IsBusy);
        checkGPU.Enable = localOnOff(hayImagen && ~state.IsBusy);
        checkLimpiar.Enable = localOnOff(hayImagen && ~state.IsBusy);
        sliderTransparencia.Enable = localOnOff(hayImagen && ~state.IsBusy);
    end

    function actualizarDatosActuales()
        if state.CurrentIndex == 0 || isempty(state.CurrentImage)
            etiquetaDatos.Text = 'Sin poblacion seleccionada.';
            etiquetaActual.Text = 'Ninguna poblacion seleccionada.';
            return;
        end

        item = state.Items(state.CurrentIndex);
        [alto, ancho, canales] = size(state.CurrentImage);
        etiquetaActual.Text = sprintf('Poblacion %d de %d: %s', ...
            state.CurrentIndex, numel(state.Items), item.Name);

        if isempty(state.CurrentMask)
            detalleMascara = 'Mascara: no disponible';
        else
            [objetos, pixeles] = obtenerEstadisticasActuales();
            porcentaje = 100 * pixeles / numel(state.CurrentMask);
            detalleMascara = sprintf('Mascara: %d objetos, %.2f %% de primer plano', ...
                objetos, porcentaje);
        end

        dispositivo = state.LabDevice;
        tiempo = [];
        if isfield(state.CurrentInfo, 'ExecutionDevice')
            dispositivo = state.CurrentInfo.ExecutionDevice;
        end
        if isfield(state.CurrentInfo, 'TotalSeconds')
            tiempo = state.CurrentInfo.TotalSeconds;
        end

        if isempty(tiempo)
            tiempoTexto = 'sin tiempo registrado';
        else
            tiempoTexto = sprintf('%.3f s', tiempo);
        end

        etiquetaDatos.Text = sprintf([ ...
            'Imagen: %d x %d x %d   |   Estado: %s   |   %s\n' ...
            'Umbral: %.1f   |   Dispositivo: %s   |   Tiempo: %s\n' ...
            'MAT: %s'], ...
            alto, ancho, canales, item.Status, detalleMascara, ...
            spinnerUmbral.Value, dispositivo, tiempoTexto, item.MatPath);
    end

    function [objetos, pixeles] = obtenerEstadisticasActuales()
        if isempty(state.CurrentMask)
            objetos = 0;
            pixeles = 0;
            return;
        end

        if isfield(state.CurrentInfo, 'ObjectCount') && ...
                isnumeric(state.CurrentInfo.ObjectCount) && ...
                isscalar(state.CurrentInfo.ObjectCount)
            objetos = double(state.CurrentInfo.ObjectCount);
        else
            objetos = localContarObjetos(state.CurrentMask);
            state.CurrentInfo.ObjectCount = objetos;
        end

        if isfield(state.CurrentInfo, 'ForegroundPixels') && ...
                isnumeric(state.CurrentInfo.ForegroundPixels) && ...
                isscalar(state.CurrentInfo.ForegroundPixels)
            pixeles = double(state.CurrentInfo.ForegroundPixels);
        else
            pixeles = nnz(state.CurrentMask);
            state.CurrentInfo.ForegroundPixels = pixeles;
        end
    end

    function seleccionarFilaTabla(indice)
        try
            tabla.Selection = [indice 1];
        catch
            % Algunas versiones anteriores de MATLAB no exponen Selection.
        end
    end

    function limpiarActual()
        state.CurrentIndex = 0;
        state.CurrentImage = [];
        state.CurrentPreview = [];
        state.CurrentLab = [];
        state.CurrentMask = [];
        state.CurrentMaskPreview = [];
        state.CurrentInfo = struct();
        state.CurrentMatMetadata = struct();
        state.LabDevice = 'No calculado';
        limpiarEjes();
        actualizarDatosActuales();
    end

    function limpiarEjes()
        % Protege contra ejes inexistentes o borrados
        if exist('ejeOriginal','var') && ~isempty(ejeOriginal) && isgraphics(ejeOriginal)
            try
                cla(ejeOriginal);
                title(ejeOriginal, 'Imagen original');
                ejeOriginal.XTick = [];
                ejeOriginal.YTick = [];
            catch
                % ignorar
            end
        end

        if exist('ejeResultado','var') && ~isempty(ejeResultado) && isgraphics(ejeResultado)
            try
                cla(ejeResultado);
                title(ejeResultado, 'Mascara superpuesta');
                ejeResultado.XTick = [];
                ejeResultado.YTick = [];
            catch
                % ignorar
            end
        end
    end


    function setBusy(valor, mensaje)
        state.IsBusy = logical(valor);

        % Un onCleanup puede ejecutarse despues de cerrar la ventana. En ese
        % caso no se debe intentar modificar componentes graficos eliminados.
        if isempty(fig) || ~isvalid(fig)
            return;
        end

        if nargin >= 2 && ~isempty(mensaje) && ...
                ~isempty(etiquetaEstado) && isvalid(etiquetaEstado)
            etiquetaEstado.Text = mensaje;
        end

        if state.IsBusy
            fig.Pointer = 'watch';
            botonBuscar.Enable = 'off';
            botonActualizar.Enable = 'off';
            botonAnterior.Enable = 'off';
            botonSiguiente.Enable = 'off';
            botonPendiente.Enable = 'off';
            botonFinalizar.Enable = 'off';
        else
            fig.Pointer = 'arrow';
            botonBuscar.Enable = 'on';
            botonActualizar.Enable = localOnOff(~isempty(state.Folder));
            hayItems = ~isempty(state.Items);
            botonAnterior.Enable = localOnOff(hayItems);
            botonSiguiente.Enable = localOnOff(hayItems);
            botonPendiente.Enable = localOnOff(hayItems);
            botonFinalizar.Enable = localOnOff(hayItems);
        end
        actualizarControles();
        drawnow;
    end

    function comprobarFinalizacion(~, ~)
        if isempty(state.Items)
            return;
        end
        pendientes = find(~[state.Items.Validated]);
        if isempty(pendientes)
            uialert(fig, ...
                sprintf('Las %d poblaciones estan validadas.', numel(state.Items)), ...
                'Proceso finalizado', 'Icon', 'info');
        else
            uialert(fig, ...
                sprintf('Quedan %d poblaciones pendientes de validacion.', ...
                numel(pendientes)), ...
                'Proceso pendiente', 'Icon', 'warning');
        end
    end

    function abrirCarpetaSistema(~, ~)
        if isempty(state.MasksFolder) || ~isfolder(state.MasksFolder)
            return;
        end
        try
            if ispc
                winopen(state.MasksFolder);
            elseif ismac
                system(sprintf('open "%s" &', state.MasksFolder));
            else
                system(sprintf('xdg-open "%s" >/dev/null 2>&1 &', state.MasksFolder));
            end
        catch ME
            uialert(fig, ME.message, 'No se pudo abrir la carpeta Masks', ...
                'Icon', 'warning');
        end
    end

    function cerrarInterfaz(~, ~)
        % Liberar las matrices grandes antes de destruir la ventana.
        state.IsBusy = false;
        state.CurrentLab = [];
        state.CurrentImage = [];
        state.CurrentPreview = [];
        state.CurrentMask = [];
        state.CurrentMaskPreview = [];
        state.CurrentInfo = struct();
        state.CurrentMatMetadata = struct();
        state.MasksFolder = '';

        if ~isempty(fig) && isvalid(fig)
            % Desactivar primero el callback evita una segunda llamada durante
            % la destruccion explicita de la uifigure.
            fig.CloseRequestFcn = [];
            delete(fig);
        end
    end
end

function carpetaMasks = localAsegurarCarpetaMasks(carpetaImagenes)
% Crea o valida la subcarpeta Masks dentro de la carpeta de imagenes.
    if ~isfolder(carpetaImagenes)
        error('La carpeta de imagenes no existe: %s', carpetaImagenes);
    end

    carpetaMasks = fullfile(carpetaImagenes, 'Masks');

    % Evitar que un archivo ordinario llamado Masks bloquee la carpeta.
    if exist(carpetaMasks, 'file') == 2 && ~isfolder(carpetaMasks)
        error(['Existe un archivo llamado Masks en la ruta seleccionada. ' ...
               'Renombre o elimine ese archivo para poder crear la carpeta.']);
    end

    if ~isfolder(carpetaMasks)
        [creada, mensaje, idMensaje] = mkdir(carpetaMasks);
        if ~creada
            if isempty(idMensaje)
                error('No se pudo crear la carpeta Masks: %s', mensaje);
            else
                error(idMensaje, 'No se pudo crear la carpeta Masks: %s', mensaje);
            end
        end
    end

    % Validar que MATLAB pueda escribir en la carpeta. El archivo de prueba
    % se elimina inmediatamente y no forma parte de los resultados.
    archivoPrueba = [tempname(carpetaMasks) '.tmp'];
    fid = fopen(archivoPrueba, 'w');
    if fid < 0
        error('La carpeta Masks existe, pero MATLAB no tiene permiso de escritura: %s', ...
            carpetaMasks);
    end
    fclose(fid);
    delete(archivoPrueba);
end

function [rutaMat, existe] = localResolverRutaMat(carpetaImagenes, carpetaMasks, base)
% Resuelve los MAT dentro de Masks y migra archivos heredados del directorio
% de imagenes cuando todavia no existe una copia en Masks.
    rutaPrincipal = fullfile(carpetaMasks, [base '.mat']);
    rutaAlterna = fullfile(carpetaMasks, [base '_mascara.mat']);

    if exist(rutaPrincipal, 'file') == 2
        rutaMat = rutaPrincipal;
        existe = true;
        return;
    elseif exist(rutaAlterna, 'file') == 2
        rutaMat = rutaAlterna;
        existe = true;
        return;
    end

    % Compatibilidad con versiones anteriores: mover solo el MAT asociado a
    % esta imagen. No se modifican otros archivos MAT de la carpeta principal.
    legadoPrincipal = fullfile(carpetaImagenes, [base '.mat']);
    legadoAlterno = fullfile(carpetaImagenes, [base '_mascara.mat']);

    if exist(legadoPrincipal, 'file') == 2
        [movido, mensaje] = movefile(legadoPrincipal, rutaPrincipal, 'f');
        if ~movido
            error('No se pudo trasladar %s a Masks: %s', legadoPrincipal, mensaje);
        end
        rutaMat = rutaPrincipal;
        existe = true;
    elseif exist(legadoAlterno, 'file') == 2
        [movido, mensaje] = movefile(legadoAlterno, rutaAlterna, 'f');
        if ~movido
            error('No se pudo trasladar %s a Masks: %s', legadoAlterno, mensaje);
        end
        rutaMat = rutaAlterna;
        existe = true;
    else
        rutaMat = rutaPrincipal;
        existe = false;
    end
end

function resumen = localLeerResumenMat(rutaMat)
% Lee solo variables pequenas para no cargar la mascara durante el listado.
    resumen = struct('Validada', false, 'Threshold', 17);
    variables = whos('-file', rutaMat);
    nombres = {variables.name};

    if any(strcmp(nombres, 'validada'))
        S = load(rutaMat, 'validada');
        if isfield(S, 'validada') && isscalar(S.validada)
            resumen.Validada = logical(S.validada);
        end
    end

    if any(strcmp(nombres, 'umbral'))
        S = load(rutaMat, 'umbral');
        if isfield(S, 'umbral') && isnumeric(S.umbral) && isscalar(S.umbral)
            resumen.Threshold = double(S.umbral);
            return;
        end
    end

    if any(strcmp(nombres, 'infoSegmentacion'))
        S = load(rutaMat, 'infoSegmentacion');
        if isfield(S, 'infoSegmentacion') && isstruct(S.infoSegmentacion) && ...
                isfield(S.infoSegmentacion, 'Threshold')
            valor = S.infoSegmentacion.Threshold;
            if isnumeric(valor) && isscalar(valor)
                resumen.Threshold = double(valor);
            end
        end
    end
end

function [BW, metadata] = localCargarMascaraMat(rutaMat, alto, ancho)
% Carga la mascara sin traer innecesariamente todas las variables del MAT.
    variables = whos('-file', rutaMat);
    nombres = {variables.name};
    prioridad = {'BW','REGION','mascara','mask','Mask','segmentationMask'};
    nombreMascara = '';

    for k = 1:numel(prioridad)
        if any(strcmp(nombres, prioridad{k}))
            nombreMascara = prioridad{k};
            break;
        end
    end

    if isempty(nombreMascara)
        for k = 1:numel(variables)
            tam = variables(k).size;
            clase = variables(k).class;
            esNumerica = any(strcmp(clase, ...
                {'logical','uint8','uint16','uint32','int8','int16','int32', ...
                 'single','double'}));
            if esNumerica && numel(tam) == 2 && ...
                    tam(1) == alto && tam(2) == ancho
                nombreMascara = variables(k).name;
                break;
            end
        end
    end

    if isempty(nombreMascara)
        error(['No se encontro una mascara 2-D compatible. Se esperaban ' ...
               'las variables BW, REGION, mascara, mask, Mask o ' ...
               'segmentationMask, o una matriz del mismo tamano que la imagen.']);
    end

    S = load(rutaMat, nombreMascara);
    candidato = S.(nombreMascara);

    if ~isnumeric(candidato) && ~islogical(candidato)
        error('La variable %s no es numerica ni logica.', nombreMascara);
    end
    if ndims(candidato) ~= 2 || size(candidato,1) ~= alto || size(candidato,2) ~= ancho
        error('La mascara %s no coincide con el tamano %d x %d.', ...
            nombreMascara, alto, ancho);
    end

    BW = logical(candidato ~= 0);

    metadata = struct();
    metadata.MaskVariable = nombreMascara;
    nombresMetadata = {'infoSegmentacion','info','umbral','validada', ...
        'origenImagen','fechaValidacion'};
    cargar = nombresMetadata(ismember(nombresMetadata, nombres));
    if ~isempty(cargar)
        M = load(rutaMat, cargar{:});
        campos = fieldnames(M);
        for k = 1:numel(campos)
            metadata.(campos{k}) = M.(campos{k});
        end
    end
end

function info = localExtraerInfoSegmentacion(metadata)
    info = struct();
    if isfield(metadata, 'infoSegmentacion') && isstruct(metadata.infoSegmentacion)
        info = metadata.infoSegmentacion;
    elseif isfield(metadata, 'info') && isstruct(metadata.info)
        info = metadata.info;
    end
end

function umbral = localExtraerUmbral(metadata)
    umbral = [];
    if isfield(metadata, 'umbral') && isnumeric(metadata.umbral) && ...
            isscalar(metadata.umbral) && isfinite(metadata.umbral) && metadata.umbral > 0
        umbral = double(metadata.umbral);
        return;
    end

    info = localExtraerInfoSegmentacion(metadata);
    if isfield(info, 'Threshold') && isnumeric(info.Threshold) && ...
            isscalar(info.Threshold) && isfinite(info.Threshold) && info.Threshold > 0
        umbral = double(info.Threshold);
    end
end

function I = localLeerImagenRGB(ruta)
    [I, mapa] = imread(ruta);

    if ~isempty(mapa)
        I = ind2rgb(I, mapa);
    end

    if ndims(I) == 2
        I = repmat(I, 1, 1, 3);
    elseif ndims(I) == 3 && size(I,3) > 3
        I = I(:,:,1:3);
    end

    if ndims(I) ~= 3 || size(I,3) ~= 3
        error('La imagen %s no puede convertirse a RGB.', ruta);
    end
end

function vista = localCrearVistaPrevia(I, maxDimension)
    escala = min(1, double(maxDimension) / double(max(size(I,1), size(I,2))));
    if escala < 1
        vista = imresize(I, escala);
    else
        vista = I;
    end
end

function RGB = localImagenVisual(I)
% Convierte a uint8 exclusivamente para una visualizacion consistente.
    if isa(I, 'uint8')
        RGB = I;
    elseif isa(I, 'uint16')
        RGB = im2uint8(I);
    elseif isfloat(I)
        minimo = min(I(:));
        maximo = max(I(:));
        if minimo >= 0 && maximo <= 1
            RGB = im2uint8(I);
        else
            RGB = im2uint8(mat2gray(I));
        end
    else
        RGB = im2uint8(mat2gray(I));
    end
end

function [Lab, dispositivo] = localPrepararLab(I, usarGPU)
% Convierte una sola vez la imagen actual y mantiene Lab para resegmentar.
    if usarGPU && localCanUseGPU()
        try
            Lab = rgb2lab(gpuArray(im2single(I)));
            dispositivo = 'GPU';
            return;
        catch
            % Recuperacion automatica a CPU.
        end
    end

    Lab = rgb2lab(im2single(I));
    dispositivo = 'CPU';
end

function cantidad = localContarObjetos(BW)
    if isempty(BW)
        cantidad = 0;
    else
        CC = bwconncomp(BW, 8);
        cantidad = CC.NumObjects;
    end
end

function tf = localCanUseGPU()
    tf = false;
    if exist('canUseGPU', 'file') == 2
        try
            tf = canUseGPU;
            return;
        catch
            tf = false;
        end
    end

    if exist('gpuDeviceCount', 'file') == 2
        try
            tf = gpuDeviceCount > 0;
        catch
            tf = false;
        end
    end
end

function texto = localSiNo(valor)
    if valor
        texto = 'Si';
    else
        texto = 'No';
    end
end

function valor = localOnOff(condicion)
    if condicion
        valor = 'on';
    else
        valor = 'off';
    end
end

INTERFAZ DE SEGMENTACION Y VALIDACION DE POBLACIONES
===================================================

ARCHIVOS PRINCIPALES
- InterfazValidacionPoblaciones.m
- iniciar_interfaz_segmentacion.m
- SegmentarFrijolesRapido.m
- SegmentarFrijolesLabRapido.m
- EstimarFondoAB.m

INICIO
1. Agregue esta carpeta al path de MATLAB o establezcala como carpeta actual.
2. Ejecute:

   iniciar_interfaz_segmentacion

   o directamente:

   InterfazValidacionPoblaciones

3. Pulse "Buscar ruta..." y seleccione la carpeta que contiene las imagenes.

FLUJO
- Seleccione una poblacion en la tabla.
- Si existe un MAT compatible, la mascara se carga automaticamente.
- Revise la superposicion verde.
- Si la segmentacion no es correcta, ajuste el umbral y pulse
  "Segmentar / repetir".
- Cuando sea correcta, pulse "Aceptar, guardar y siguiente".
- La aplicacion guarda la mascara y abre la siguiente poblacion pendiente.

ARCHIVO MAT
- Se utiliza <nombreImagen>.mat.
- Tambien se reconoce <nombreImagen>_mascara.mat si ya existe.
- La variable principal guardada es BW.
- El archivo tambien contiene:
  infoSegmentacion, umbral, validada, origenImagen y fechaValidacion.

REANUDACION
Los MAT guardados incluyen validada=true. Al volver a abrir la carpeta, la
interfaz identifica las poblaciones ya validadas y comienza por la primera
pendiente.

PARAMETROS
- Umbral a*b*: 17 es el punto inicial recomendado.
- Area minima: cero significa calculo automatico.
- Usar GPU: intenta GPU y recupera automaticamente a CPU si falla.
- Limpiar mascara: apertura, cierre, relleno de huecos y area minima.
- Transparencia: solo cambia la visualizacion, no la segmentacion.

REQUISITOS
- MATLAB con Image Processing Toolbox.
- Parallel Computing Toolbox y GPU compatible son opcionales.

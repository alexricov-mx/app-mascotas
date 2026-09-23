# Proyecto: amiva.pet / Huella — Diseño (Cowork Design Artifact)

## Qué es esto
Este repositorio contiene los archivos fuente de un prototipo de diseño construido en **Cowork** (Claude en modo Design/canvas artifact), para un ecosistema de negocio veterinario/pet-care:

- **amiva.pet** — marca pública de la plataforma (landing + registro de negocios).
- **Huella** — panel administrativo interno (expediente clínico, agenda, comercio/inventario/POS) que usan las veterinarias/sucursales registradas en amiva.pet.

El artifact vivo (editable/visualizable en el navegador) está en:
`https://claude.ai/artifact/DbdovQqRu4aZnhobJ84Sfo`

## Formato de los archivos — IMPORTANTE
Los `.dc.html` en `project/` **no son HTML autocontenido ejecutable en un navegador local**. Son "Design Components" del tipo de artifact de Cowork:

- Usan placeholders de templating `{{token}}` (ej. `{{bg}}`, `{{text}}`, `{{accent}}`) que se resuelven en tiempo de publicación/render dentro de Cowork, vía un bloque `<script type="text/x-dc" data-dc-script>` que define `class Component extends DCLogic { renderVals() {...} }`.
- Referencian `<script src="./support.js">`, un runtime que **solo existe dentro de Cowork** (no viene incluido en este export) — abrir estos archivos directo en Chrome no va a renderizar bien.
- `project/canvas.json` es el índice del "lienzo": posiciones (x,y), tamaños (w,h) y orden de cada artboard, más las notas de título de cada fila.

**Para seguir iterando el diseño de verdad, el flujo correcto sigue siendo Cowork/el Artifact tool** (editar el `.dc.html`, publicar con `root` = carpeta padre de `project/` y `file_path` = ruta absoluta a `project/canvas.json`, más un mapa `files` con los demás `.dc.html` tocados). Si algún archivo fue editado en el navegador (toggle de tema, etc.) desde la última vez que Claude lo leyó, el publish se rechaza por concurrencia optimista — hay que releer ese archivo del artifact antes de reintentar.

**Si lo que quieres en VSCode es reimplementar esto como código real** (React/HTML/CSS funcional, no mockup), estos archivos sirven como referencia visual y de contenido (copy, estructura de datos de ejemplo, jerarquía de pantallas), pero habría que reescribirlos sin el sistema de templating `{{}}` de Cowork.

## Sistema de diseño (tokens compartidos)
Todas las pantallas comparten el mismo bloque `renderVals()` con un prop `dark` (boolean, editable en el panel "Tema") que calcula ~24 tokens de color:

- Fondo/superficie: `bg`, `surface`, `surfaceAlt`, `border`, `divider`
- Texto: `text`, `muted`
- Acento: `accent`, `accentButton`, `accentContrast`, `accentSoft`
- Sidebar: `sidebarBg`, `sidebarBorder`, `sidebarStrongText`, `sidebarActiveBg`, `sidebarActiveText`, `sidebarText`, `sidebarMuted`
- Avatar: `avatarBg`, `avatarText`
- Estados: `successBg/Text`, `warnBg/Text`, `dangerBg/Text`
- Gráficas: `chartBar`, `chartBarStrong`

Paleta clara = azul acero; paleta oscura = casi negro/azul eléctrico. Tipografías: Bricolage Grotesque (encabezados) + Public Sans (texto), vía Google Fonts.

## Estructura de pantallas (canvas.json → boards, por fila)

**Fila 1 — Expediente clínico (panel veterinaria, web/tablet)**
- `Main.dc.html` — Ficha integral del paciente (Rocky, Golden Retriever)
- `Prevencion.dc.html` — Vacunas y desparasitación
- `Timeline.dc.html` — Línea de tiempo de eventos clínicos
- `Documentos.dc.html` — Recetas, PDFs, resultados de laboratorio
- `SignosVitales.dc.html` — Peso, temperatura, frecuencia cardiaca/respiratoria (con gráfica de barras)

**Fila 2 — Exploración de color (sin conexión funcional)**
- `OpcionA/B/C/D.dc.html` — 4 swatches de paleta (gris claro, pizarra oscuro, claro con barra oscura, carbón azul alto contraste)

**Fila 3 — Agenda y citas**
- `Agenda.dc.html` — Calendario/lista de citas
- `NuevaCita1/2/3.dc.html` — Flujo de reservación en 3 pasos (breadcrumb + step indicator, sin sidebar completa)

**Fila 4 — Registro de negocio (portal público amiva.pet)**
- `Landing.dc.html` — Landing page pública
- `Registro1/2.dc.html` — Flujo de alta de negocio en 2 pasos

**Fila 5 — Comercio, inventario y punto de venta** *(agregada en esta sesión)*
- `Inventario.dc.html` — Catálogo de productos: imagen, precio, existencia, descripción breve, toggle ocultar/activar, badges de "Stock bajo"/"Agotado", tabs Catálogo/Promociones
- `NuevoProducto.dc.html` — Alta de producto (imagen, cantidad inicial, precio, categoría, descripción, visibilidad en POS)
- `Promociones.dc.html` — Paquetes compuestos por productos del inventario (ej. "Kit Cachorro" = vacuna + desparasitante), con precio especial vs. precio regular
- `NuevaPromocion.dc.html` — Formulario de creación de promoción con selector de productos y cálculo de ahorro
- `POS.dc.html` — Pantalla de venta: grid de productos con imágenes grandes (incluye promociones destacadas), señales de stock bajo/agotado, carrito con suma/resta de cantidades y total
- `POSCobro.dc.html` — Cobro: método de pago, monto recibido, accesos rápidos de montos, cálculo automático de cambio, resumen de qué se descuenta del inventario
- `VentasAuditoria.dc.html` — Auditoría de ventas: métricas del día + tabla de tickets (fecha/hora, productos afectados en inventario, método de pago, monto, cajero)

## Requisito original que dio pie a la Fila 5 (verbatim del usuario)
> "vamos a seguir, agrga el inventario y el POS. Para el inventario, debera ser una opcion que deba administrar el administrador de la sucursal, podra ver el catalogo de productos, existencia, darlos de alta, con cantidad, imagen, precio y breve descripcion. podra ocultar o activar productos. tambien promociones que se componen de items del inventario, por lo que en el POS se afectaran los items al venderse restando al inventario ya sea por ventas normales o por promociones de productos. necesitamos que el evento de la venta sea amigable con imagenes grandes, que permita sumar, restar, ver total, seccion de cobrar indicando con cuanto le pagan y cuanto hay que dar de cambio, auditoria de ventas, fechas, montos, productos afectados en inventario. productos sin stock deberan de indicarse con una señal adecuada."

Todos los sub-requisitos de ese mensaje están cubiertos por la Fila 5 descrita arriba.

## Navegación entre pantallas
Los enlaces `<a href="...">` entre archivos son reales (no `href="#"` placeholder) para que el modo "Play" del artifact funcione como prototipo clicable. El sidebar de las 6 pantallas con sidebar completo (Main, Prevencion, Timeline, Documentos, SignosVitales, Agenda) tiene "Comercio" → `POS.dc.html` e "Inventario" → `Inventario.dc.html`.

## Convenciones de layout del canvas (para si se agregan más filas)
- 80px de espacio horizontal entre artboards de una misma fila (`x` siguiente = `x` anterior + `w` anterior + 80).
- 120px+ de espacio vertical entre filas.
- Cada fila lleva una nota de título (`kind: "title1"`) que debe quedar ≥223px arriba de la fila que etiqueta, sin traslaparse verticalmente con el bottom de la fila anterior (patrón usado: ~240px de nota a fila, ~40px de buffer sobre el bottom de la fila previa).

## Pendiente / no construido aún
El resto del ecosistema original (servicios y precios, descubrimiento y reseñas, planes para negocios, app móvil de usuario final) no se ha construido — solo estaba en el alcance conceptual inicial, no ha sido pedido explícitamente todavía.

## Gotcha técnico a recordar
Al publicar cambios con el Artifact tool: si algún archivo fue tocado en el navegador desde la última lectura de Claude (p.ej. el usuario cambia el toggle de tema en el panel "Tweaks"), el publish se rechaza entero por concurrencia optimista. Hay que releer ese archivo específico del artifact (`action: "read"`), reaplicar el cambio sobre ese contenido actual, y volver a publicar — nunca reenviar la copia vieja.

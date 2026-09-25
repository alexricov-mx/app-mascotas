# Plataforma para el Cuidado de Mascotas — Requerimientos

**Nombre del producto:** amiva.pet  
**Versión:** 3.9  
**Fecha:** 2026-09-24  
**Estado:** fuente de verdad vigente del producto.

Este documento reemplaza como referencia de trabajo a `analisis/01-requerimiento.md`, `analisis/02-respuesta-21092026.md` y `analisis/03-requerimiento-2.md`. Los documentos anteriores se conservan como historial. `App-Ventas` no se modifica; se usa como referencia funcional para el punto de venta, inventario y promociones.

## 1. Producto

amiva.pet es una plataforma SaaS para veterinarias y estéticas de mascotas. La mascota es la entidad central. El sistema conecta la administración del negocio, la relación con dueños y mascotas, la agenda, los servicios y el comercio.

El núcleo debe poder reutilizarse posteriormente en otros tipos de negocio. El primer vertical es mascotas y el primer alcance comercial son veterinarias y estéticas en México, comenzando por Guerrero, Puebla, Estado de México y Ciudad de México.

### 1.1 Superficies del ecosistema

| Superficie | Dirección | Usuario | Tecnología |
|---|---|---|---|
| Portal de administración | `admin.amiva.pet` | Administradores de la plataforma | Vue 3, TypeScript y Vite |
| Portal operativo del negocio | `app.amiva.pet` | Personal y administradores del negocio | Flutter Web; mismo proyecto que la app para tablet |
| App del dueño | App móvil iOS y Android | Dueños, familiares y cuidadores | Flutter |
| API común | Servicio interno de todos los clientes | Sistema | ASP.NET Core .NET 10 |
| Página pública | `amiva.pet` | Visitantes y negocios invitados | Por definir |

Los negocios acceden a `app.amiva.pet` mediante usuario y contraseña entregados o habilitados por la administración de la plataforma. El administrador de negocio opera sus sucursales desde esa misma solución Flutter, en navegador o tablet.

El API es el único componente autorizado para conectarse a PostgreSQL/PostGIS y a OVH Object Storage. Ninguna app o portal contiene credenciales ni se conecta directamente a esos servicios.

### 1.2 Marca y nombres

- **amiva.pet:** marca pública y dominio principal de la plataforma.
- **admin.amiva.pet:** portal privado de administración de la plataforma.
- **app.amiva.pet:** portal operativo para negocios y sucursales.
- **AppMascotas:** nombre provisional del proyecto técnico durante la definición.
- **Huella:** nombre visual del prototipo de diseño; no es una decisión funcional ni sustituye los nombres anteriores.

## 2. Núcleo y vertical

### Núcleo genérico

Organizaciones, sucursales, usuarios, roles, permisos, identidad, tenants, suscripciones, planes, entitlements, auditoría, notificaciones, clientes, servicios, variantes, precios, agenda, citas, comercio, inventario, proveedores, compras, promociones, métricas y parámetros.

### Vertical de mascotas

Mascotas, propietarios, usuarios autorizados, especies, razas, expediente clínico, prevención, vacunas, carnet, ficha integral, documentos y línea de tiempo.

## 3. Actores y permisos

- **Dueño principal:** único propietario principal de una mascota.
- **Usuario autorizado:** familiar o cuidador con cuenta propia; puede ver la ficha, el carnet y la línea de tiempo, llevar y recoger a la mascota y solicitar, cancelar o reprogramar citas. No edita datos de la mascota, no vincula negocios, no autoriza a otros, no transfiere y no exporta.
- **Profesional:** veterinario, estilista u otro prestador.
- **Recepción:** acepta y registra citas y realiza ventas autorizadas.
- **Administrador de negocio:** configura usuarios, sucursales, catálogo, precios, inventario, operación y reseñas desde `app.amiva.pet`.
- **Administrador de plataforma:** da de alta negocios, administra planes, suscripciones, parámetros, usuarios, reseñas y estados de cuentas desde `admin.amiva.pet`.
- **Sistema:** ejecuta procesos automáticos y notificaciones.
- **Proveedor externo:** identidad, correo, push, mapas, almacenamiento y pagos futuros.

La autorización es granular y aplica mínimo privilegio. Un administrador no obtiene automáticamente acceso a funciones que no correspondan a su rol.

## 4. Alta de negocios y usuarios

### 4.1 Alta de negocios

El alta de negocios la realizan exclusivamente los administradores de la plataforma desde `admin.amiva.pet`. El negocio no se autorregistra en el MVP.

El administrador registra la empresa, RFC único, plan, prueba, sucursales, ubicación y usuarios iniciales. La prueba dura 10 días naturales, se activa una sola vez por empresa, sin tarjeta. La suscripción y sus fechas se administran desde el portal de plataforma; el cobro es manual en el MVP.

Una empresa puede tener varias sucursales y un solo registro empresarial por RFC.

### 4.2 Alta del usuario final

El usuario final descarga la app móvil, se registra mediante un proveedor de identidad y proporciona correo electrónico. Se envía un enlace de verificación; la cuenta se activa al verificarlo.

En el MVP el usuario final se registra con Google, Facebook o Apple. Microsoft y X quedan para una versión posterior. El servicio de identidad es Keycloak (sección 15), que integra estos proveedores y también el acceso con usuario y contraseña de `app.amiva.pet` y `admin.amiva.pet`.

El usuario agrega sus mascotas, busca sucursales en el mapa y solicita vincularse con ellas. Si un negocio ya lo había registrado como cliente provisional, activa su mascota con la invitación que recibió (sección 6.1).

## 5. Mascotas, propiedad y límites

Una mascota tiene un propietario principal y cero o más usuarios autorizados. No existen propietarios secundarios. La excepción es la mascota provisional, que registra un negocio para un cliente que todavía no usa la app y no tiene propietario hasta que el dueño la activa (sección 6.1). La transferencia requiere que el propietario actual la inicie y que el nuevo propietario la acepte; se conserva la historia. Al transferirse, se retiran las autorizaciones anteriores.

El propietario autoriza a otra persona compartiendo una invitación (enlace o QR) o con el correo de una cuenta existente; la otra persona acepta desde su app. El propietario puede retirar la autorización y el autorizado puede renunciar en cualquier momento. Una mascota autorizada no ocupa espacio del autorizado.

Las solicitudes de transferencia y de autorización vencen si no se responden en 7 días (parámetro); quien las envió puede cancelarlas antes.

La app del dueño tiene un **buzón** con dos apartados:

- **Solicitudes:** lo que espera una respuesta del usuario (transferencias y autorizaciones recibidas) y el estado de las que él envió, con opción de cancelarlas.
- **Avisos:** notificaciones internas informativas (citas, recordatorios, beneficios de referidos).

Datos: nombre, fotografía, especie, raza, sexo, estado reproductivo, fecha de nacimiento, edad calculada, peso, color, características físicas, señas particulares, microchip, alergias, condiciones especiales, medicamentos activos, dieta y veterinario habitual.

- La raza siempre admite "Otra" o "Mestizo" con texto libre.
- El microchip, si se captura, no puede repetirse en otra mascota activa.
- La ficha muestra el último peso registrado, por el dueño o en una consulta; el historial de peso vive en el expediente.
- El veterinario habitual se elige entre los negocios vinculados o se captura como texto libre si no está en la plataforma.
- El fallecimiento lo puede registrar el propietario desde la app o el personal autorizado de un negocio vinculado.

Especies iniciales: perro, gato, ave, roedor, reptil y otro.

Cada usuario final tiene espacios para mascotas de tres tipos. Cada mascota activa ocupa un espacio de un solo tipo:

| Tipo | Límite inicial | Cómo se obtiene |
|---|---|---|
| Base | 2 | Al registrarse. |
| Por beneficio | Hasta 5 por cuenta | Por referidos de usuarios finales (sección 11). |
| Pagado | Sin límite | Cargo registrado en sucursal. |

Los tres límites son parámetros configurables desde `admin.amiva.pet`; el límite de espacios pagados puede dejarse sin tope o fijarse.

Al registrar una mascota se ocupa primero un espacio base, después uno por beneficio y al final uno pagado. El usuario consulta en la app cuántos espacios de cada tipo tiene, cuántos ocupa y cuántos le quedan.

Los espacios pagados tienen un cargo configurable, pero en el MVP no se cobra dentro de la app: la sucursal registra el evento y cobra en efectivo por sus propios medios; el cargo se incorpora al periodo de facturación del negocio con la plataforma.

Un espacio se libera de inmediato cuando su mascota se marca como fallecida o se transfiere a otro propietario. El espacio liberado conserva su tipo y puede ocuparlo una nueva mascota sin volver a pagarlo ni volver a ganarlo.

Para aceptar una transferencia, el nuevo propietario necesita un espacio libre de cualquier tipo. Si no lo tiene, la app se lo indica y le ofrece invitar usuarios o adquirir un espacio pagado en una sucursal; la solicitud de transferencia sigue vigente mientras tanto.


## 6. Vinculación y privacidad

El usuario selecciona una sucursal desde la app y ve una pantalla de consentimiento y vinculación con acciones de aceptar o cancelar. El negocio obtiene acceso únicamente después de la aceptación.

- La vinculación es con el negocio: se inicia desde una sucursal, pero todas sus sucursales atienden al dueño.
- El dueño elige qué mascotas comparte con cada negocio; por defecto, la mascota con la que llega. Puede agregar o quitar mascotas después.
- Alergias, condiciones especiales y medicamentos activos se comparten siempre en el nivel 1, por seguridad de la mascota.
- Al transferirse una mascota, deja de estar compartida con los negocios del propietario anterior; esos negocios solo recuperan el acceso si el nuevo propietario se vincula con ellos.

Se registra el texto mostrado, su versión, usuario, negocio, sucursal, fecha, resultado y bitácora del evento. El texto se administra desde `admin.amiva.pet`.

Un negocio vinculado puede consultar:

- **Nivel 1:** perfil básico y datos que el dueño decida compartir.
- **Nivel 2:** vacunas, desparasitación, tratamientos preventivos y certificados.
- **Información generada por el propio negocio.**

Nunca puede consultar el nivel 3 generado por otro negocio. Al desvincularse, el negocio pierde el acceso a la información del usuario y deja de navegar los registros de esa relación, incluidos los que él mismo generó; los conserva y los recupera si el dueño se vuelve a vincular.

El dueño consulta vacunas, alergias, padecimientos, recetas, consultas, servicios, citas, documentos y la línea de tiempo con el nombre del negocio que generó cada evento. Las notas internas, costos, márgenes y observaciones comerciales son privadas del negocio.

Cuando la plataforma publica una nueva versión de un texto legal, las aceptaciones anteriores siguen siendo válidas; si la marca como obligatoria, la app pide aceptarla la siguiente vez que el usuario entra.

### 6.1 Clientes sin app

Un negocio puede atender a un cliente que todavía no usa la app:

1. El personal registra un **cliente provisional** (nombre, teléfono y correo) y sus **mascotas provisionales** (datos básicos).
2. Ese cliente y esas mascotas existen solo dentro del negocio: ningún otro negocio los ve, ni siquiera el nivel 2.
3. El negocio opera con ellos normalmente: citas, expediente, vacunas, documentos y ventas.
4. El sistema envía al cliente una **invitación de activación** por correo. También se puede mostrar como QR en la sucursal.
5. Cuando el dueño instala la app, se registra o inicia sesión y acepta la invitación, acepta el consentimiento de vinculación y confirma los datos. La mascota pasa a ser suya, ocupa uno de sus espacios y queda vinculada con ese negocio. Todo el historial se conserva.
6. Si el dueño ya tenía esa mascota registrada en la app, elige fusionarlas: el historial del negocio pasa a la mascota que ya tenía.

Reglas:

- Sin correo no se puede enviar la invitación por correo, pero sí mostrar el QR en la sucursal.
- Para activar se necesita un espacio libre, igual que al recibir una transferencia.
- La invitación vence a los 30 días (parámetro) y el negocio puede reenviarla. La mascota provisional se conserva aunque nunca se active, sujeta a las reglas de conservación.
- Un cliente provisional recibe recordatorios solo por correo y no recibe campañas.
- Los servicios anteriores a la activación no cuentan para referidos.
- Cada negocio que atiende a la misma persona sin app tiene su propio cliente provisional; al activar cada invitación, todo termina en la misma cuenta y, si el dueño lo elige, en la misma mascota.

## 7. Expediente y documentos

Las veterinarias registran consultas, motivo, diagnóstico, tratamiento, medicamentos, recetas, estudios, procedimientos, cirugías, observaciones y signos vitales. Las estéticas registran servicios no clínicos, como baño y estética.

Los documentos pueden agregarse, actualizarse y eliminarse. La eliminación es lógica, se audita y solo puede ejecutarla el negocio que subió el documento.

Tipos y tamaños aceptados en el MVP (parámetros configurables desde `admin.amiva.pet`):

| Tipo de archivo | Tamaño máximo |
|---|---:|
| Fotografías de mascotas | 10 MB |
| Recetas, tickets y notas | 15 MB |
| Estudios clínicos | 25 MB |
| Documentos firmados | 25 MB |
| Exportaciones generadas por el sistema | 50 MB |

Se aceptan `JPEG`, `PNG`, `WEBP` y `PDF`. Se rechazan ejecutables, archivos comprimidos y formatos editables.

Transferencia de archivos:

- La carga y la descarga pasan siempre por el API, por *streaming*, sin cargar el archivo completo en memoria.
- El API valida el tipo por el contenido real del archivo, no solo por la extensión.
- Si el tamaño declarado supera el límite, el archivo se rechaza antes de leerlo completo.
- Cada fotografía genera una miniatura para listas y línea de tiempo.
- Antes de entregar un archivo, el API valida los permisos de quien lo pide.

Al fallecer una mascota, cambia a estado fallecida. Después de un mes se ocultan datos, fotos, expediente e historial para el usuario, pero la información se conserva. El usuario puede registrar una nueva mascota.

Si una mascota no tiene actividad ni consumo durante cinco años, se eliminan sus datos, historial, expediente y fotografías conforme a los parámetros de la plataforma.

Cuando un negocio deja de pagar, después del periodo de resguardo se eliminan físicamente inventario, citas históricas, usuarios operadores, ventas y compras. Los registros necesarios para reportes e historial clínico se conservan mediante borrado lógico.

La eliminación solicitada por un usuario es lógica e inmediata para impedirle el acceso, sujeta a obligaciones legales y conservación aplicable.

### 7.1 Productos proporcionados por el dueño

Al registrar una vacuna, desparasitante o medicamento aplicado, el veterinario indica el origen del producto:

| | Del inventario de la sucursal | Proporcionado por el dueño |
|---|---|---|
| Qué se captura | Producto del catálogo y cantidad | Nombre comercial, laboratorio, lote y fecha de caducidad |
| Inventario | Genera la salida automáticamente | No genera ningún movimiento |
| Qué se cobra | Producto y servicio de aplicación | Solo el servicio de aplicación |
| Carnet y línea de tiempo | Registro normal | Registro con la etiqueta "Proporcionado por el dueño", lote y caducidad |

Reglas para el producto del dueño:

- Aceptarlo es una **política del negocio**: aplica igual a todas sus sucursales. La configura el administrador de negocio y está activada por defecto.
- En vacunas, el lote y la caducidad son obligatorios. En desparasitantes y medicamentos se capturan si el empaque los trae.
- No se permite registrar la aplicación si la fecha de caducidad ya pasó.
- El veterinario confirma la revisión del producto: empaque sellado, caducidad vigente y conservación declarada por el dueño.
- El dueño firma en papel una responsiva. El formato lo administra la plataforma y el negocio lo imprime; la responsiva firmada se sube como documento (foto o PDF) y queda ligada al registro. Es obligatoria para guardar la aplicación.
- El recordatorio de siguiente dosis se programa igual que con producto propio.
- Si el veterinario no acepta el producto, simplemente no registra la aplicación.

## 8. Agenda y citas

Toda cita corresponde a una mascota. La que solicita el dueño requiere aprobación del negocio. El negocio también puede registrar citas en nombre de un cliente, vinculado o provisional (por ejemplo, por teléfono o en mostrador); esas nacen confirmadas. Flujo: mascota, servicio, fecha y horario. El negocio acepta o rechaza con mensaje, inicia el servicio y puede marcarla como no atendida.

Estados: solicitada, confirmada, en proceso, completada, rechazada, cancelada y no atendida.

La capacidad se configura por cantidad de mascotas simultáneas, horario y día. La duración depende del servicio, variantes y tiempos adicionales configurados.

El dueño puede cancelar o reprogramar hasta el límite configurable, inicialmente 30 minutos antes. La tolerancia para no atención también es configurable. No existe penalización por inasistencia.

Vacunas: recordatorio una semana antes. Citas: recordatorio dos horas antes; si se crean con menos de dos horas de anticipación, no se envía recordatorio.

La lista de espera queda para una versión posterior. Cada turno dispone de 10 minutos; si no confirma o rechaza, se elimina y se avisa al siguiente. El orden es el momento de entrada a la cola.

## 9. Servicios, variantes y precios

El catálogo contiene nombre, descripción, duración, disponibilidad, sucursal, estado publicado y reglas de cancelación. Las variantes permiten matrices de precio y duración por especie, tamaño, raza, peso, duración o condición clínica.

El precio y la duración se definen por defecto a nivel de negocio y cada sucursal puede ajustarlos. Los servicios pueden tener precio publicado o no listado.

Los servicios de aplicación (vacunas, desparasitantes, medicamentos) pueden tener la variante "Aplicación con producto del dueño", con su propio precio, para cobrar solo la aplicación.

No habrá flujo de cotización en la app. Cuando se acuerde un precio especial, el usuario y el profesional lo acuerdan fuera de ese flujo y el profesional registra el servicio y su costo. El precio queda en el evento y, cuando corresponda, en la venta.

## 10. Inventario, promociones y punto de venta

El MVP incorpora inventario, promociones y ventas en sitio. La experiencia funcional del POS se basa en `App-Ventas`; el prototipo `amiva-huella` se usa únicamente como referencia para adaptar la presentación a web y tablet.

El inventario se administra por sucursal. Las existencias solo cambian mediante movimientos: entradas, salidas, ajustes por conteo físico, aplicación clínica, consumo interno, merma, caducidad, ventas y cancelaciones. No se permite existencia negativa. El stock mínimo y sus alertas se definen por sucursal.

Reglas de inventario:

- Cada producto tiene su unidad de medida (pieza, mililitro, gramo, dosis, etc.); las cantidades son enteras, sin fracciones.
- El precio de venta incluye IVA.
- El dinero se maneja en pesos MXN con decimales: precios, totales, pagos y cambio con dos decimales; el costo unitario con cuatro, para productos que se manejan en unidades pequeñas (por ejemplo, mililitros).
- El costo se calcula con costo promedio ponderado.
- Las vacunas, desparasitantes y medicamentos aplicados en consulta descuentan inventario automáticamente al registrarse. Si el producto lo proporciona el dueño, no se mueve inventario (sección 7.1).
- El consumo interno puede ligarse opcionalmente a una cita o servicio.
- Los traspasos entre sucursales llegan en R3, con el ecommerce.
- Las órdenes de compra (R4) tienen los estados `borrador`, `en proceso` y `concluida`, con autorización del administrador y recepción parcial. Un borrador que no se usa se elimina; no hay estado `cancelada`.

El detalle de la operación está en `docs/05-inventario.md`.

Los productos tienen cantidad, imagen, precio, descripción breve y estado visible u oculto. Las promociones se componen de productos del inventario y descuentan sus componentes al venderse. La venta debe conservar el detalle y precio acordados; una cancelación devuelve los componentes mediante movimientos.

El POS debe permitir productos y promociones con imágenes grandes, sumar y restar cantidades, mostrar total, registrar cuánto se recibe, calcular cambio, indicar agotados y consultar auditoría de ventas. Las operaciones críticas son transaccionales y conservan trazabilidad.

Se incluyen ventas en efectivo. La sucursal puede aceptar tarjeta por sus propios medios, pero el procesamiento de tarjetas no se integra en el MVP. Ecommerce, carrito multi-negocio, pagos integrados y comisión de venta quedan para una evolución posterior. La Tienda Digital no se muestra hasta que exista el módulo.

## 11. Suscripciones, planes y referidos

Planes: Básico, Extendido y Tienda Digital. Los administradores de plataforma configuran precios, sucursales adicionales y límites operativos desde `admin.amiva.pet`.

| Plan | Sucursales | Campañas activas | Nota |
|---|---|---|---|
| Básico | 1 (configurable) | 1 (configurable) | Para un negocio con una sola sucursal. |
| Extendido | Las incluidas en el plan (configurable) más sucursales adicionales con precio | Configurable | Para negocios con varias sucursales. |
| Tienda Digital | — | — | Oculto hasta que exista el módulo. |

Los planes se distinguen únicamente por lo que habilitan y sus límites, que se configuran por plan.

Cobro de la suscripción:

- Los periodos son mensuales en el MVP.
- Los precios de plan incluyen IVA y se manejan con dos decimales.
- Cada periodo cobra el plan, las sucursales adicionales y los espacios pagados de mascotas vendidos por sus sucursales.
- Las sucursales adicionales se cobran por el mayor número de sucursales activas durante el periodo, sin prorrateo.
- Un mes gratuito por referido bonifica solo el cargo del plan; las sucursales adicionales y los espacios pagados se cobran igual.
- El cobro es manual: la plataforma genera los cargos y el administrador de plataforma registra el pago.

No hay límite de usuarios por plan. No se lleva contador de almacenamiento, pero se limitan tamaños y tipos de recursos. Add-ons quedan en backlog. Enterprise es futuro.

Impago: dos días de gracia, cinco días en solo lectura, después sin acceso y seis meses de resguardo antes de la eliminación definida en este documento. Una prueba que vence sin pago sigue el mismo camino. Durante el periodo sin acceso, los dueños conservan su propia información.

Todos los parámetros los fija la plataforma; los negocios no los sobrescriben. Lo que decide cada negocio son sus políticas (por ejemplo, aceptar productos proporcionados por el dueño).

Los referidos de usuarios finales y de negocios forman parte del MVP.

### Invitación mediante QR y enlace

Cada usuario final y cada negocio tiene un enlace de invitación personal, que también se muestra como código QR. Se puede enviar por correo, copiar como imagen o copiar como enlace.

- **App del dueño:** sección "Invitar y obtener beneficios".
- **`app.amiva.pet`:** sección "Invitar otras veterinarias y estéticas".

La pantalla de registro de la app siempre incluye el campo "Código de quien te invitó". Si la persona abre la app desde el enlace, el campo llega lleno; si instaló la app desde la tienda, puede escribirlo o pegarlo. A quien se registra solo se le muestra el nombre visible de quien lo invitó, sin correo ni otros datos.

Una cuenta solo puede tener un referidor, se asigna al registrarse y no cambia después. No se permiten auto-referidos ni duplicados.

### Referidos de usuarios finales

El enlace abre la app en la pantalla de registro con el código de quien invita; si la app no está instalada, abre App Store o Google Play.

El seguimiento empieza cuando el usuario referido activa su cuenta. Cuando acumula diez servicios pagados, el usuario que refiere obtiene un espacio por beneficio (sección 5), hasta el límite configurado, inicialmente cinco.

Cuentan como servicio pagado, en cualquier negocio:

- Una cita completada.
- Un evento de venta en POS asociado al usuario, no cancelado. Una venta cuenta como uno sin importar cuántos productos incluya.

Una venta ligada a una cita cuenta junto con esa cita como un solo servicio.

### Referidos de negocios

Los negocios no se autorregistran. El enlace abre en `amiva.pet` una página de "Quiero afiliarme" con un formulario de contacto que conserva quién invitó. El administrador de plataforma da de alta el negocio desde `admin.amiva.pet` con el referido ya ligado.

El negocio referido se afilia como mínimo al plan Básico y lo mantiene pagado dos meses consecutivos. El negocio que refiere obtiene un mes gratuito de su plan actual por cada referido elegible, sin límite. Los meses se acumulan, no caducan y se consumen antes de generar nuevos cargos.

### Evaluación de beneficios

Un proceso automático nocturno revisa las condiciones de los referidos pendientes y otorga los beneficios. Cada otorgamiento se audita y se notifica al beneficiario.

## 12. Notificaciones, reseñas y campañas

El MVP usa correo, push y notificaciones internas; estas últimas se ven en el buzón de la app (sección 5). Los clientes provisionales solo reciben correo. WhatsApp queda fuera. No hay chat directo negocio-dueño en el MVP.

El dueño puede apagar todas las notificaciones o configurar cada tipo. Se registran errores de envío, sin mensajes atrasados ni registro de apertura o entrega.

Las reseñas se solicitan por correo. El operador de sucursal y la administración de plataforma pueden revisarlas; la publicación requiere acción del administrador de plataforma. La retención es configurable.

El negocio puede publicar una sola respuesta pública por reseña, vinculada a ella y sin editar la reseña original. La respuesta pasa por la misma moderación y el administrador de plataforma puede ocultarla o retirarla por incumplimiento.

Los negocios pueden crear campañas para correo, banners y push. La vigencia, frecuencia y prioridad son configurables. La plataforma puede ocultar campañas inadecuadas.

Alcance de una campaña:

- **De negocio:** aplica a todas las sucursales del negocio.
- **De sucursal:** aplica solo a una sucursal.

Una campaña se puede copiar manualmente a otra sucursal. La copia es independiente: se crea como borrador y se edita y publica por separado.

El negocio puede tener en su pantalla de campañas todas las que quiera configuradas (borradores o inactivas), pero solo puede tener activas al mismo tiempo las que permita su plan.

Segmentación de la audiencia:

- Se permite por especie, raza, sexo, edad, sucursal y servicios previos.
- Solo se dirigen a dueños vinculados; los clientes provisionales no reciben campañas.
- No se permite segmentar directamente por diagnóstico, alergias, padecimientos, medicamentos, estado reproductivo ni notas clínicas.
- Los atributos clínicos solo se usan para recordatorios asistenciales autorizados previamente por el dueño, nunca para promociones comerciales.
- Se registra quién creó, aprobó, publicó, modificó, copió u ocultó cada campaña.
- El sistema advierte al administrador cuando la audiencia puede inferirse a partir de datos sensibles.

## 13. Auditoría y legal

Se auditan vinculaciones, consentimientos, transferencias, autorizaciones, accesos clínicos, registros, documentos, datos sensibles, precios, servicios, variantes, suscripciones, inventario, suspensiones, contactos verificados, cancelaciones y citas no atendidas.

Desde `admin.amiva.pet` se administran versiones de aviso de privacidad, consentimiento, términos, conservación, eliminación, tratamiento de datos, responsabilidades, pagos, responsiva por producto proporcionado por el dueño y documentos legales. Cada aceptación conserva la versión mostrada y su bitácora.

`admin.amiva.pet` tiene una sección para configurar cada uno de estos documentos, de modo que el desarrollo no depende del texto final. Antes de iniciar la operación se requiere la revisión de un abogado sobre propiedad de la información, aviso de privacidad, derechos ARCO, conservación, eliminación, responsabilidades, tratamiento de datos y pagos. Esa revisión no bloquea el desarrollo, pero sí la salida a producción.

## 14. Requisitos no funcionales

- Seguridad, autenticación fuerte, autorización granular, mínimo privilegio, cifrado y secretos seguros.
- Multi-tenant desde el inicio con `tenant_id` y RLS.
- Relación explícita entre tenants, dueños y mascotas.
- Trazabilidad de operaciones críticas.
- Escalabilidad de usuarios, mascotas, negocios, sucursales, citas y documentos.
- Integraciones desacopladas mediante límites de integración.
- Experiencia rápida y búsqueda contextual.
- Parámetros configurables desde `admin.amiva.pet`.
- Respaldos incrementales diarios con retención de una semana, gestionados por mantenimiento.

## 15. Arquitectura

PostgreSQL con PostGIS se instala dentro del VPS en un contenedor. El backend es ASP.NET Core .NET 10 en un monolito modular. El portal operativo del negocio es Flutter Web y Flutter para tablet. La app del dueño es Flutter para iOS y Android. El portal administrativo es Vue 3 + TypeScript + Vite. Los archivos se almacenan en OVH Object Storage detrás de una interfaz.

El API es el único componente autorizado para conectarse a PostgreSQL y Object Storage. Todos los clientes se comunican exclusivamente con el API mediante HTTPS. Los identificadores internos tienen prefijo y UUID.

El API se organiza con **arquitectura de cortes verticales (VSA, *Vertical Slice Architecture*) por feature**. Cada feature o caso de uso contiene todo lo que necesita: endpoint, validación, reglas y acceso a datos. Las features se agrupan en módulos por dominio dentro del monolito.

La identidad la resuelve **Keycloak** en un contenedor. Integra Google, Facebook y Apple para el usuario final, y usuario y contraseña para el negocio y la plataforma. El API valida los tokens que emite Keycloak.

### 15.1 Ambientes

| Ambiente | Base de datos | Estado |
|---|---|---|
| Desarrollo | PostgreSQL 18 + PostGIS y Keycloak en Podman, en el equipo del desarrollador. Base `amiva-dev`, definida en `infra/dev/compose.yaml`. | Disponible |
| Staging | Por configurar. Dominio, base y apps de prueba propios. | Pendiente |
| Producción | PostgreSQL + PostGIS y Keycloak en contenedores dentro del VPS de OVH, en Canadá. | Pendiente |

La topología de despliegue sigue la recomendada por OVH para el VPS. Los datos de la cuenta, el VPS, Object Storage, dominio y staging se reúnen en `infra/ovh/ficha-configuracion.md`.

### 15.2 Enlaces de invitación

Las invitaciones usan enlaces universales (iOS) y App Links (Android) sobre el dominio `amiva.pet`. La ruta de invitación de usuario abre la app; la de negocio siempre abre la página web. El detalle está en `docs/estudio/01-enlaces-universales.md`.

## 16. Repositorios

- `app-mascotas-usuario`: app móvil del dueño.
- `app-mascotas-negocio`: app para tablet y portal web Flutter del negocio.
- `app-mascotas-admin`: portal Vue de `admin.amiva.pet`.
- `app-mascotas-api`: API común, reglas de negocio, persistencia e integraciones.

## 17. Releases

- **R0:** fundaciones, identidad, negocios, sucursales, usuarios, roles, multi-tenant, auditoría, planes, `admin.amiva.pet` y `app.amiva.pet`.
- **R1 MVP:** clientes (incluidos clientes y mascotas provisionales con invitación de activación), mascotas, ficha, expediente básico, vacunas, documentos, signos vitales, agenda, citas, servicios, variantes, capacidad, inventario, promociones, ventas en sitio, POS, línea de tiempo, mapa, notificaciones, administración de plataforma, espacios de mascotas por tipo, referidos de usuarios finales y de negocios, y página pública de afiliación.
- **R2:** lista de espera, reseñas, favoritos, filtros avanzados, ranking, SMS y búsqueda rápida.
- **R3:** ecommerce, carrito, pedidos, pagos integrados, comisión, traspasos entre sucursales y evolución del inventario.
- **R4:** lotes, caducidades, proveedores y órdenes de compra.
- **R5:** campañas avanzadas, automatizaciones, métricas y recompensas.
- **R6:** marketplace B2B, laboratorios, facturación electrónica y hospitalización.

## 18. Entidades conceptuales iniciales

Esta lista fue el punto de partida. El modelo vigente, con los cambios que surgieron al modelar, está en `docs/06-modelo-conceptual.md`.

Usuario, IdentidadExterna, Tenant, Negocio, Sucursal, UsuarioTenant, Rol, Permiso, Mascota, UsuarioMascota, Vinculacion, Consentimiento, Cliente, Profesional, Servicio, Variante, PrecioSucursal, Cita, EventoMascota, RegistroClinico, Vacuna, Documento, Notificacion, Auditoria, Plan, Entitlement, Suscripcion, Parametro, Producto, MovimientoInventario, Promocion, Venta, VentaDetalle, Pago, EspacioMascota, Referido, BeneficioReferido, SolicitudAfiliacion y OrdenCompra.

## 19. Pendientes vigentes

- Revisión legal de los documentos; no bloquea el desarrollo, sí el inicio de la operación.
- Datos de infraestructura de OVH (VPS, Object Storage, dominio y staging), por llenar en `infra/ovh/ficha-configuracion.md`.

Estos pendientes no deben resolverse por suposición durante el diseño del modelo de datos. Cuando afecten una regla o entidad, se registran como decisión pendiente antes de construir.

## 20. Historial

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-09-21 | Consolidación inicial. |
| 1.1 | 2026-09-21 | Incorporación de respuestas iniciales. |
| 2.0 | 2026-09-22 | Integración de respuestas ampliadas. |
| 2.1 | 2026-09-22 | Separación de clientes y portales. |
| 2.2 | 2026-09-22 | PostgreSQL/PostGIS en VPS, Vue 3 + Vite, API como único acceso a datos y UUID con prefijos. |
| 3.0 | 2026-09-22 | Cierre del requerimiento: dominios `admin.amiva.pet` y `app.amiva.pet`, alta de negocios por administración, POS basado en App-Ventas y prototipos como referencia visual. |
| 3.1 | 2026-09-24 | Referidos en el MVP con QR y enlace, página pública de afiliación, evaluación nocturna de beneficios, conteo de servicios pagados y espacios de mascotas por tipo que se liberan por fallecimiento o transferencia, y espacio libre requerido para aceptar una transferencia. |
| 3.2 | 2026-09-24 | Respuesta pública del negocio a reseñas, tipos y tamaños de archivos, campañas de negocio o sucursal con reglas de segmentación, documentos legales configurables sin bloquear el desarrollo, proveedores de identidad Google, Facebook y Apple, enlaces universales y ambientes de desarrollo, staging y producción. |
| 3.3 | 2026-09-24 | Transferencia de archivos por streaming a través del API, API con arquitectura de cortes verticales por feature, Keycloak como servicio de identidad y ficha de configuración de OVH. |
| 3.4 | 2026-09-24 | Reglas de inventario aprobadas: unidades de medida sin fracciones, precio con IVA, costo promedio ponderado, descuento automático en aplicaciones clínicas, stock mínimo por sucursal, traspasos en R3 y órdenes de compra sin estado cancelada. |
| 3.5 | 2026-09-24 | Dinero con decimales: dos para precios y totales, cuatro para el costo unitario. |
| 3.6 | 2026-09-24 | Vacunas, desparasitantes y medicamentos proporcionados por el dueño: política por negocio, lote y caducidad, responsiva firmada que se sube como documento, sin movimiento de inventario y variante de servicio para cobrar solo la aplicación. |
| 3.7 | 2026-09-24 | Planes Básico y Extendido con sucursales y campañas configurables, periodos mensuales, IVA incluido, mes a favor solo sobre el plan, sucursales sin prorrateo, prueba vencida como impago, parámetros solo de plataforma, límite de campañas activas (no de configuradas) y retiro del límite de mascotas por negocio. |
| 3.8 | 2026-09-24 | Usuarios autorizados (permisos, invitación y retiro), buzón de solicitudes y avisos en la app, vencimiento de solicitudes, microchip único, fallecimiento registrado también por el dueño, último peso en la ficha y veterinario habitual. |
| 3.9 | 2026-09-24 | Reglas de vinculación (por negocio, mascotas elegidas, datos de seguridad, retiro y transferencia), nuevas versiones de textos legales, clientes y mascotas provisionales con invitación de activación y fusión, y citas registradas por el negocio. |

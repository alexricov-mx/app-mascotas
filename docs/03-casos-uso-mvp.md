# Casos de uso del MVP — amiva.pet

**Versión:** 1.9  
**Fecha:** 2026-09-24  
**Fuente:** `docs/02-requerimiento.md` versión 3.10  
**Estado:** aprobado el 2026-09-24. Base para el modelo conceptual.

## 1. Propósito

Este documento traduce el requerimiento vigente a comportamientos observables del MVP. Todavía no define tablas, endpoints ni componentes internos. Esas decisiones se tomarán después del modelo conceptual.

## 2. Actores

| Código | Actor | Superficie |
|---|---|---|
| ACT-01 | Dueño principal | App móvil |
| ACT-02 | Usuario autorizado | App móvil |
| ACT-03 | Recepción | `app.amiva.pet` / tablet |
| ACT-04 | Veterinario | `app.amiva.pet` / tablet |
| ACT-05 | Estilista | `app.amiva.pet` / tablet |
| ACT-06 | Administrador de negocio | `app.amiva.pet` / tablet |
| ACT-07 | Administrador de plataforma | `admin.amiva.pet` |
| ACT-08 | Sistema | Procesos automáticos |
| ACT-09 | Proveedor de identidad | Servicio externo |
| ACT-10 | Proveedor de correo, push o mapas | Servicio externo |
| ACT-11 | Negocio invitado (prospecto) | Página pública `amiva.pet` |

## 3. Reglas transversales

- El API valida autenticación, autorización y aislamiento por tenant.
- Ningún cliente accede directamente a PostgreSQL/PostGIS ni a Object Storage.
- Las operaciones críticas se auditan.
- El dueño solo ve la información que le corresponde y la línea de tiempo de sus mascotas.
- Un negocio solo accede a un dueño y sus mascotas después de una vinculación aceptada, salvo a sus propios clientes y mascotas provisionales (UC-47).
- Todo lo que el negocio registra (citas, expediente, vacunas, documentos, ventas) puede hacerse sobre una mascota provisional.
- Los identificadores internos usan prefijo y UUID.
- Las operaciones multi-entidad que deban ser atómicas se ejecutan en una transacción.
- Los registros clínicos pasados no se modifican; una corrección genera un nuevo registro.
- Los documentos se referencian desde el dominio y se almacenan mediante el API.

## 4. Identidad y acceso

### UC-01 — Registrar usuario final

**Actor principal:** ACT-01.  
**Precondiciones:** la app está instalada y el proveedor de identidad está disponible.  
**Flujo:**

1. El usuario elige un proveedor de identidad: Google, Facebook o Apple.
2. Proporciona o confirma su correo.
3. Opcionalmente captura el código de quien lo invitó. Si llegó por una invitación de activación de un negocio, al terminar el registro continúa en UC-48. Si abrió la app desde un enlace de invitación (UC-38), el campo llega lleno y se muestra el nombre visible de quien invita.
4. El sistema crea la identidad interna asociada al proveedor.
5. El sistema envía el enlace de verificación.
6. El usuario verifica el correo.
7. El sistema activa la cuenta con sus espacios base y, si hubo código válido, registra el referido e inicia el seguimiento de servicios pagados.

**Resultado:** usuario final activo, sin negocio vinculado todavía.  
**Errores:** correo ya registrado, proveedor no disponible, verificación expirada, cuenta bloqueada o código de invitación inválido. Un código inválido no impide el registro; solo no se registra el referido.

### UC-02 — Iniciar y cerrar sesión

**Actores:** ACT-01 a ACT-07.  
**Resultado:** sesión autenticada con permisos del actor; cerrar sesión revoca o invalida la sesión local según la política definida. La autenticación la resuelve Keycloak: Google, Facebook o Apple para el usuario final; usuario y contraseña para el negocio y la plataforma.

### UC-03 — Dar de alta un negocio

**Actor principal:** ACT-07.  
**Superficie:** `admin.amiva.pet`.  
**Flujo:**

1. El administrador captura empresa, RFC y datos generales.
2. Selecciona plan y activa la prueba de 10 días.
3. Registra una o más sucursales con ubicación.
4. Configura el usuario inicial del negocio.
5. Si el alta viene de una solicitud de afiliación (UC-41), la selecciona y el sistema liga al negocio que invitó.
6. El sistema valida RFC único y límites.
7. El sistema crea el negocio, tenant, sucursales, suscripción y accesos.

**Resultado:** negocio habilitado para acceder a `app.amiva.pet`.  
**Errores:** RFC duplicado, datos incompletos, plan no disponible, más sucursales de las que permite el plan o alta no autorizada.

### UC-04 — Administrar usuarios y roles del negocio

**Actor principal:** ACT-06.  
**Actores secundarios:** ACT-03, ACT-04 y ACT-05.  
**Resultado:** usuarios del negocio creados, activados, desactivados o asignados a sucursales y roles conforme a permisos.

### UC-05 — Administrar planes y estado de negocio

**Actor principal:** ACT-07.  
**Resultado:** plan, prueba, fechas, límites y estados de suscripción actualizados. El sistema aplica gracia, solo lectura, sin acceso y resguardo según parámetros.

## 5. Mascotas y privacidad

### UC-06 — Registrar mascota propia

**Actor principal:** ACT-01.  
**Flujo:**

1. El usuario captura datos generales y características de la mascota.
2. El sistema busca un espacio libre en este orden: base, por beneficio y pagado.
3. El sistema guarda la mascota y la asigna al espacio encontrado.

**Resultado:** mascota asociada al propietario principal y ocupando un espacio de un tipo.  
**Errores:** sin espacios disponibles, datos inválidos, microchip ya registrado en otra mascota activa o usuario bloqueado. Si no hay espacios, la app indica cómo obtener más: invitar usuarios (UC-38) o adquirir un espacio pagado en una sucursal (UC-37).

### UC-07 — Registrar mascota durante una vinculación

**Actor principal:** ACT-01.  
**Actor secundario:** ACT-06 o personal autorizado del negocio.  
**Flujo:** el usuario ya tiene cuenta y está en la sucursal; selecciona la sucursal en la app, acepta la vinculación (UC-08), elige o registra la mascota y completa o confirma los datos necesarios. Si el dueño no usa la app, aplica UC-47.

**Resultado:** relación usuario-mascota-negocio vigente y auditable.

### UC-08 — Aceptar o cancelar vinculación

**Actor principal:** ACT-01.  
**Flujo:** el usuario revisa el texto y versión del consentimiento, elige qué mascotas comparte (por defecto, la mascota con la que llega), acepta o cancela, y el sistema registra la aceptación con su versión.

**Resultado:** si acepta, la vinculación es con todo el negocio y este obtiene, de las mascotas compartidas, nivel 1 (incluye siempre alergias, condiciones especiales y medicamentos activos), nivel 2 y sus propios registros; si cancela, no obtiene acceso. El dueño puede agregar o quitar mascotas compartidas después.

### UC-09 — Retirar vinculación

**Actor principal:** ACT-01.  
**Resultado:** el negocio deja de navegar los datos de la relación, incluidos los registros que él mismo generó, que conserva por obligación. Si el dueño se vuelve a vincular, recupera el acceso. El evento de retiro queda auditado.

### UC-10 — Consultar ficha y línea de tiempo

**Actores:** ACT-01, ACT-02, ACT-03, ACT-04, ACT-05 y ACT-06 según permisos.  
**Resultado:** cada actor recibe únicamente los datos permitidos por rol, tenant, vinculación y nivel de visibilidad.

### UC-11 — Transferir propiedad de mascota

**Actor principal:** ACT-01 propietario actual.  
**Actor secundario:** nuevo propietario.  
**Flujo:**

1. El propietario inicia la transferencia.
2. La solicitud llega al buzón del nuevo propietario (UC-46), que la revisa. El sistema valida que tenga un espacio libre de cualquier tipo.
3. Si no lo tiene, la app se lo indica y le ofrece invitar usuarios (UC-38) o adquirir un espacio pagado en una sucursal (UC-37). La solicitud sigue vigente.
4. El nuevo propietario acepta y el sistema asigna la mascota a su espacio libre, con el mismo orden de UC-06.
5. El sistema registra solicitud, aceptación y fechas, retira las autorizaciones anteriores y deja de compartir la mascota con los negocios del propietario anterior. El nuevo propietario ve toda la historia de la mascota, pero no los datos del propietario anterior.

Si no se responde en 7 días (parámetro), la solicitud vence. El propietario puede cancelarla antes.

**Resultado:** nuevo propietario principal, mascota en uno de sus espacios y conservación de la historia. El espacio que ocupaba la mascota se libera de inmediato para el propietario anterior y conserva su tipo.

### UC-12 — Marcar mascota como fallecida

**Actores:** ACT-01 propietario desde la app, o personal con permiso de un negocio vinculado.  
**Resultado:** estado fallecida; el espacio que ocupaba se libera de inmediato y conserva su tipo. Después de un mes la mascota se oculta para el usuario conforme al proceso automático.

### UC-45 — Autorizar usuario sobre una mascota

**Actor principal:** ACT-01 propietario.  
**Actor secundario:** ACT-02 persona autorizada.

**Flujo:**

1. El propietario elige la mascota y la opción "Autorizar a alguien".
2. Comparte una invitación por enlace o QR, o captura el correo de una cuenta existente.
3. Si la persona no tiene cuenta, se registra primero (UC-01).
4. La invitación aparece en el buzón de la persona (UC-46) y la acepta o rechaza.
5. El sistema crea la autorización y la audita.

El propietario puede retirar la autorización y el autorizado puede renunciar en cualquier momento. La invitación vence a los 7 días (parámetro).

**Resultado:** la persona puede ver la ficha, el carnet y la línea de tiempo, llevar y recoger a la mascota y gestionar sus citas. La mascota no ocupa espacio del autorizado.  
**Errores:** invitación vencida o cancelada, o la persona ya está autorizada.

### UC-46 — Consultar buzón

**Actores:** ACT-01 y ACT-02.  
**Superficie:** app móvil.

**Flujo:** el usuario abre el buzón, que tiene dos apartados:

- **Solicitudes:** transferencias y autorizaciones recibidas, con botones para aceptar o rechazar; y las que él envió, con su estado y opción de cancelar.
- **Avisos:** notificaciones internas informativas, como cambios de cita, recordatorios y beneficios de referidos.

**Resultado:** solicitudes respondidas o canceladas y avisos marcados como leídos. Cada solicitud nueva también llega por push si el usuario lo tiene activado.

### UC-47 — Registrar cliente y mascota provisionales

**Actor principal:** ACT-03 o ACT-06.  
**Superficie:** `app.amiva.pet` / tablet.

**Flujo:**

1. El personal busca si la persona ya es cliente del negocio.
2. Si no, registra un cliente provisional: nombre, teléfono y correo.
3. Registra una o más mascotas provisionales con sus datos básicos.
4. El sistema envía la invitación de activación al correo del cliente, si lo tiene, y permite mostrarla como QR en la sucursal.
5. Desde ese momento el negocio puede agendar, registrar expediente y vender sobre esas mascotas.

El negocio puede reenviar la invitación; vence a los 30 días (parámetro).

**Resultado:** cliente y mascotas provisionales visibles solo para este negocio.  
**Errores:** datos incompletos o permiso insuficiente.

### UC-48 — Activar mascota provisional

**Actor principal:** ACT-01.  
**Precondiciones:** el dueño recibió una invitación de activación (correo o QR).

**Flujo:**

1. El dueño abre la invitación; si no tiene la app, la instala.
2. Se registra (UC-01) o inicia sesión.
3. Ve el negocio que lo invita y las mascotas provisionales.
4. Acepta el consentimiento de vinculación (UC-08).
5. Por cada mascota, elige: activarla como nueva o fusionarla con una mascota que ya tiene registrada.
6. Confirma o corrige los datos.
7. El sistema asigna la mascota a un espacio libre (orden de UC-06), crea la vinculación con el negocio y conserva todo el historial. En una fusión, el historial del negocio pasa a la mascota existente.

**Resultado:** mascotas del dueño, vinculadas con el negocio, con su historial completo; el cliente provisional queda ligado a la cuenta del dueño.  
**Errores:** invitación vencida o cancelada, sin espacios disponibles (la app ofrece las mismas opciones que en UC-06), o microchip que ya tiene otra mascota activa (se sugiere la fusión).

### UC-13 — Agregar, consultar y eliminar documento

**Actores:** ACT-03, ACT-04, ACT-05, ACT-06 y ACT-01 según permisos.  
**Reglas:** solo se aceptan `JPEG`, `PNG`, `WEBP` y `PDF`, con el tamaño máximo configurado para cada tipo de documento. El archivo viaja por streaming a través del API, que valida el tipo por su contenido y los permisos en cada descarga; las fotografías generan miniatura (sección 7 del requerimiento).  
**Resultado:** documento referenciado en el dominio, protegido por el API y con eliminación lógica auditada. Incluye la responsiva firmada por producto proporcionado por el dueño (UC-15). Los documentos que sube el dueño los ven los negocios con los que comparte la mascota.  
**Errores:** tipo no permitido, tamaño excedido o permiso insuficiente.

## 6. Expediente y prevención

### UC-14 — Registrar consulta clínica

**Actor principal:** ACT-04.  
**Flujo:** selecciona mascota, captura motivo, diagnóstico, tratamiento, receta, estudios, procedimientos, cirugías, observaciones y signos vitales; si aplica medicamentos, indica el origen de cada uno igual que en UC-15; guarda el registro.

**Resultado:** nuevo registro clínico fechado, asociado a mascota, negocio, sucursal y profesional. Los medicamentos del inventario generan su salida automáticamente en la misma transacción; los proporcionados por el dueño no mueven inventario. La receta queda disponible para el dueño en PDF y el negocio puede imprimirla.

**Corrección:** si el registro tiene un error, el veterinario crea un registro de corrección que apunta al original con el motivo; el original no se edita ni se borra.

### UC-15 — Registrar vacuna o prevención

**Actor principal:** ACT-04.  
**Flujo:**

1. Selecciona la mascota y el tipo de aplicación: vacuna, desparasitación o tratamiento preventivo.
2. Indica el origen del producto: inventario de la sucursal o proporcionado por el dueño. La segunda opción solo aparece si el negocio la acepta (UC-44).
3. **Del inventario:** elige producto y cantidad.
4. **Del dueño:**
   1. Captura nombre comercial, laboratorio, lote y caducidad. En vacunas, lote y caducidad son obligatorios.
   2. Confirma la revisión del producto: empaque sellado, caducidad vigente y conservación declarada por el dueño.
   3. Sube la responsiva firmada por el dueño (UC-13).
5. Captura fecha y datos de aplicación y la fecha de la próxima dosis, y guarda.

**Resultado:** aplicación registrada; se programa recordatorio si corresponde. Del inventario: se descuenta automáticamente en la misma transacción. Del dueño: no se mueve inventario y el carnet y la línea de tiempo muestran "Proporcionado por el dueño", con lote y caducidad.  
**Errores:** existencia insuficiente del producto elegido; producto del dueño caducado; falta lote o caducidad en vacuna; falta la responsiva; el negocio no acepta productos del dueño.

### UC-16 — Registrar servicio no clínico

**Actor principal:** ACT-05.  
**Resultado:** evento de baño, estética u otro servicio, con inicio y conclusión cuando aplique. Lo ven el dueño y el negocio que lo hizo; otros negocios no.

### UC-17 — Consultar y exportar historia

**Actores:** ACT-01; ACT-02 solo consulta.  
**Resultado:** el usuario consulta la línea de tiempo, carnet y documentos permitidos; el propietario puede exportar la línea de tiempo en PDF, que se genera al pedirlo y no se guarda.

## 7. Servicios y agenda

### UC-18 — Administrar catálogo de servicios

**Actor principal:** ACT-06.  
**Resultado:** servicio, variante, duración, disponibilidad, precio y reglas de sucursal configurados. Los servicios de aplicación pueden tener la variante "Aplicación con producto del dueño", con su propio precio.

### UC-19 — Buscar sucursales y servicios

**Actor principal:** ACT-01.  
**Resultado:** sucursales afiliadas visibles en mapa con perfil, horarios, servicios, precios y ubicación.

### UC-20 — Solicitar cita

**Actor principal:** ACT-01 o ACT-02.  
**Flujo:** selecciona mascota, sucursal, servicio, fecha y horario; envía solicitud.

**Resultado:** cita en estado solicitada; negocio notificado.

### UC-49 — Agendar cita desde el negocio

**Actor principal:** ACT-03 o ACT-06.  
**Flujo:** el personal elige cliente (vinculado o provisional), mascota, servicio, fecha y horario, dentro de la capacidad configurada.

**Resultado:** cita confirmada. Si el cliente está vinculado, la ve en su app y recibe aviso; si es provisional, recibe aviso por correo.

### UC-21 — Aceptar o rechazar cita

**Actor principal:** ACT-03 o ACT-05 autorizado.  
**Resultado:** cita confirmada o rechazada con mensaje; dueño notificado.

### UC-22 — Iniciar, completar o marcar no atendida una cita

**Actor principal:** personal autorizado del negocio.  
**Resultado:** transición de estado auditada y disponibilidad actualizada. Una cita completada cuenta como servicio pagado para referidos (UC-42).

### UC-23 — Cancelar o reprogramar cita

**Actor principal:** ACT-01, ACT-02 o negocio según el caso.  
**Regla:** se aplica la ventana configurable, inicialmente 30 minutos antes.

## 8. Inventario y ventas

### UC-24 — Administrar productos e inventario

**Actor principal:** ACT-06.  
**Flujo:** el administrador crea productos con unidad de medida y precio con IVA; por sucursal define existencia inicial, stock mínimo y costo; registra entradas manuales, consumo interno (con liga opcional a una cita o servicio), mermas y caducidades.
**Resultado:** productos con imagen, precio, descripción, existencia y visibilidad por sucursal; las existencias se modifican mediante movimientos y el costo promedio ponderado se recalcula con cada entrada. Consulta de existencias, kardex y valuación.
**Errores:** existencia negativa, cantidad no entera o permiso insuficiente.

### UC-43 — Realizar conteo físico

**Actor principal:** ACT-06.
**Flujo:**

1. Inicia un conteo de toda la sucursal o de una categoría.
2. El sistema guarda la existencia teórica de cada producto.
3. El personal captura las cantidades contadas.
4. El sistema muestra las diferencias.
5. El administrador autoriza y el sistema genera los ajustes.

**Resultado:** existencias conciliadas con ajustes auditados.

### UC-25 — Administrar promociones compuestas

**Actor principal:** ACT-06.  
**Resultado:** promoción compuesta por productos y cantidades; disponibilidad calculada por componentes; cambios posteriores no alteran ventas históricas.

### UC-26 — Registrar venta en POS

**Actor principal:** ACT-03 o ACT-05 autorizado.  
**Flujo:**

1. Opcionalmente identifica al cliente (vinculado o provisional) y, si aplica, la cita relacionada.
2. Selecciona productos y promociones con imágenes grandes.
3. Ajusta cantidades dentro de existencias disponibles.
4. Consulta total.
5. Captura monto recibido.
6. El sistema calcula cambio.
7. Confirma la venta.
8. El API valida nuevamente productos, precios, existencias y permisos dentro de una transacción.
9. Guarda venta, detalles, pagos y movimientos de inventario.

**Resultado:** venta registrada y existencias actualizadas. Una venta asociada a un usuario cuenta como un servicio pagado para referidos, sin importar cuántos productos incluya; si está ligada a una cita, cuenta junto con ella como uno solo (UC-42).  
**Errores:** existencia insuficiente, precio cambiado, producto desactivado, monto insuficiente, doble envío o sucursal no autorizada.

### UC-27 — Cancelar venta

**Actor autorizado:** ACT-06 o rol configurado.  
**Resultado:** venta cancelada una sola vez, movimientos de devolución registrados y reportes actualizados. Una venta cancelada deja de contar como servicio pagado para referidos.

### UC-28 — Consultar auditoría de ventas

**Actores:** ACT-06 y ACT-07 según permisos.  
**Resultado:** consulta de ventas, fechas, montos, productos o promociones afectados, usuario, sucursal y estado.

### UC-44 — Configurar políticas del negocio

**Actor principal:** ACT-06.  
**Superficie:** `app.amiva.pet`.  
**Resultado:** políticas que aplican por igual a todas las sucursales del negocio, auditadas. En el MVP: aceptar o no vacunas, desparasitantes y medicamentos proporcionados por el dueño (activada por defecto).

## 9. Administración de plataforma

### UC-29 — Configurar parámetros

**Actor principal:** ACT-07.  
**Resultado:** límites, plazos, precios de planes, tamaños de archivos, textos legales y otros parámetros quedan versionados y auditados. Incluye los límites de espacios de mascotas por tipo (base, por beneficio y pagado, este último con o sin tope), el cargo del espacio pagado y los servicios requeridos para el beneficio de referido.

### UC-30 — Administrar textos y consentimientos

**Actor principal:** ACT-07.  
**Resultado:** texto activo y versiones históricas disponibles para nuevas aceptaciones y auditoría. Al publicar una versión, el administrador indica si es obligatoria; si lo es, la app pide aceptarla la siguiente vez que el usuario entra, y las aceptaciones anteriores siguen siendo válidas. Hay una sección por documento legal: aviso de privacidad, consentimiento, términos, conservación, eliminación, tratamiento de datos, responsabilidades, pagos y responsiva por producto proporcionado por el dueño. El formato de la responsiva se puede descargar e imprimir desde `app.amiva.pet`. El desarrollo usa textos provisionales; los definitivos, revisados por un abogado, se cargan antes de iniciar la operación.

### UC-31 — Administrar reseñas

**Actor principal:** ACT-07.  
**Actor secundario:** ACT-06, que puede publicar una sola respuesta por reseña.  
**Resultado:** revisión, publicación, ocultamiento o suspensión de reseñas y respuestas conforme a las reglas vigentes. La respuesta del negocio no modifica la reseña y pasa por la misma moderación.

### UC-32 — Administrar campañas

**Actores:** ACT-06 crea; ACT-07 puede ocultar o supervisar.  
**Flujo:**

1. El administrador elige el alcance: todo el negocio o una sucursal.
2. Define canal, contenido, vigencia, frecuencia y prioridad.
3. Define la audiencia con los atributos permitidos: especie, raza, sexo, edad, sucursal y servicios previos. Solo se incluyen dueños vinculados; los clientes provisionales quedan fuera.
4. El sistema advierte si la audiencia puede inferirse a partir de datos sensibles.
5. Publica la campaña.

**Copiar a otra sucursal:** el administrador copia una campaña a otra sucursal; la copia se crea como borrador independiente.  
**Reglas:** no se segmenta por diagnóstico, alergias, padecimientos, medicamentos, estado reproductivo ni notas clínicas. El negocio puede tener varias campañas configuradas, pero el número de campañas activas al mismo tiempo no puede superar el límite del plan; para activar otra, primero desactiva una. Se audita quién crea, aprueba, publica, modifica, copia u oculta.  
**Resultado:** campaña dirigida a una audiencia, con alcance, canal, vigencia, frecuencia y prioridad configurados.

## 10. Procesos automáticos

### UC-33 — Enviar recordatorios

**Actor:** ACT-08.  
**Resultado:** recordatorios de vacunas una semana antes y citas dos horas antes cuando corresponda; a los clientes provisionales, solo por correo. Los errores se registran y no se envían mensajes atrasados.

### UC-34 — Aplicar ciclo de suscripción

**Actor:** ACT-08.  
**Flujo:**

1. Al vencer un periodo, el sistema revisa si el negocio tiene meses gratuitos a favor por referidos (UC-42).
2. Genera los cargos del periodo: plan, sucursales adicionales (el mayor número de sucursales activas en el periodo) y espacios pagados de mascotas vendidos por sus sucursales (UC-37).
3. Si el negocio tiene meses gratuitos a favor, consume uno y bonifica solo el cargo del plan. Si no queda nada por cobrar, el periodo queda bonificado; si queda, queda por pagar.
4. Cambia el estado de la suscripción conforme a fechas, pagos y parámetros: gracia, solo lectura, sin acceso y resguardo. Una prueba vencida sin pago sigue el mismo camino.

**Resultado:** suscripción en el estado que corresponde, con permisos de operación, lectura o bloqueo aplicados; meses a favor y cargos auditados.

### UC-35 — Ocultar mascota fallecida

**Actor:** ACT-08.  
**Resultado:** después del plazo configurado, la mascota deja de mostrarse al usuario, conservando la información conforme a las reglas de conservación.

### UC-36 — Aplicar conservación y eliminación

**Actor:** ACT-08 bajo configuración y autorización de plataforma.  
**Resultado:** se aplican borrados físicos o lógicos según tipo de información, estado del negocio, actividad de mascota y obligaciones de conservación.

## 11. Espacios de mascotas y referidos

### UC-37 — Registrar espacio pagado de mascota en sucursal

**Actor principal:** ACT-03 o ACT-06.  
**Precondiciones:** el usuario final está vinculado con la sucursal.  
**Flujo:**

1. El personal identifica al usuario final.
2. El sistema muestra sus espacios por tipo y valida el límite de espacios pagados, si está configurado.
3. El personal registra el cargo configurado, cobrado en efectivo por la sucursal.
4. El sistema agrega un espacio pagado al usuario y registra el cargo para la facturación del negocio con la plataforma.

**Resultado:** el usuario tiene un espacio pagado más para registrar una mascota (UC-06 o UC-07).  
**Errores:** usuario no vinculado, límite de espacios pagados alcanzado o permiso insuficiente.

### UC-38 — Invitar usuarios finales

**Actor principal:** ACT-01.  
**Superficie:** app móvil, sección "Invitar y obtener beneficios".  
**Flujo:**

1. El usuario abre la sección.
2. El sistema muestra su código QR y su enlace de invitación personal, con el avance de sus referidos y los beneficios obtenidos.
3. El usuario envía la invitación por correo, copia la imagen del QR o copia el enlace.

Al abrir el enlace o escanear el QR: si la app está instalada, se abre en la pantalla de registro con el código lleno (UC-01); si no, se abre App Store o Google Play.

**Resultado:** invitación compartida.

### UC-39 — Consultar espacios de mascotas

**Actor principal:** ACT-01.  
**Resultado:** el usuario ve cuántos espacios tiene por tipo (base, por beneficio y pagado), cuántos ocupa, cuántos le quedan y qué mascota ocupa cada uno.

### UC-40 — Invitar negocios

**Actor principal:** ACT-06.  
**Superficie:** `app.amiva.pet`, sección "Invitar otras veterinarias y estéticas".  
**Flujo:** igual que UC-38. El enlace abre la página "Quiero afiliarme" en `amiva.pet` (UC-41). La sección muestra los negocios invitados, su estado y los meses gratuitos obtenidos, consumidos y disponibles.

**Resultado:** invitación compartida.

### UC-41 — Solicitar afiliación desde una invitación

**Actor principal:** ACT-11.  
**Superficie:** página pública `amiva.pet`.  
**Flujo:**

1. El prospecto abre el enlace de invitación.
2. La página muestra el nombre visible del negocio que invita y el formulario de contacto.
3. El prospecto captura sus datos y envía la solicitud.
4. El sistema guarda la solicitud con el negocio que invitó y avisa a la administración de plataforma.

**Resultado:** solicitud de afiliación pendiente en `admin.amiva.pet`, lista para el alta (UC-03).  
**Errores:** enlace inválido o datos incompletos. Un enlace inválido no impide enviar la solicitud; solo no se registra el referido.

### UC-42 — Evaluar referidos y otorgar beneficios

**Actor:** ACT-08, proceso nocturno.  
**Flujo:**

1. Para cada usuario final referido, cuenta los servicios pagados desde la activación de su cuenta: citas completadas y eventos de venta asociados no cancelados, en cualquier negocio. Una venta cuenta como uno sin importar sus productos; una venta ligada a una cita cuenta junto con ella como uno.
2. Si alcanza el número configurado, inicialmente diez, otorga un espacio por beneficio al usuario que refirió, salvo que ya tenga el máximo configurado, inicialmente cinco.
3. Para cada negocio referido, revisa si está en plan Básico o superior y tiene dos meses consecutivos pagados.
4. Si cumple, otorga un mes gratuito al negocio que refirió.
5. Cada referido otorga su beneficio una sola vez. El sistema audita y notifica cada otorgamiento.

**Resultado:** beneficios otorgados y referidos marcados como cumplidos.

## 12. Casos fuera del MVP

- Ecommerce y carrito multi-negocio.
- Pagos integrados.
- Lista de espera operativa.
- SMS.
- Reseñas completas si el alcance definitivo cambia.
- Marketplace B2B.
- Lotes y caducidades avanzados.
- Facturación electrónica.
- Hospitalización y laboratorios.
- Chatbot de síntomas.

## 13. Decisiones pendientes que afectan casos de uso


## 14. Siguiente documento

Catálogo aprobado. El siguiente documento es el modelo conceptual (`docs/06-modelo-conceptual.md`), que se construye por bloques separando núcleo genérico y vertical de mascotas. Si al modelar aparece un cambio de comportamiento, se actualiza primero este catálogo.

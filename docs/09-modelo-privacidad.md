# Modelo de privacidad — amiva.pet

**Versión:** 1.0  
**Fecha:** 2026-09-24  
**Fuente:** bloques 1, 3, 4, 5 y 9 de `docs/06-modelo-conceptual.md`, `docs/07-modelo-datos.md` y `docs/08-matriz-roles-permisos.md`  
**Estado:** aprobado el 2026-09-24.

## 1. Propósito

Convierte en **reglas sobre las tablas** lo que ya se decidió sobre quién ve qué:

- Ningún negocio ve datos de otro negocio.
- La mascota es del dueño; un negocio solo la ve si el dueño la comparte con él (o si es su mascota provisional).
- De lo que registra un negocio, los demás solo ven los niveles 1 y 2.
- Dentro de un negocio, cada rol ve lo que le permite la matriz.
- Todo acceso a lo clínico queda registrado.

No agrega reglas de negocio nuevas; si alguna regla de aquí contradice el requerimiento, manda el requerimiento.

## 2. Capas de protección

| Capa | Qué protege | Dónde vive |
|---|---|---|
| 1. Autenticación | Quién es la persona | Keycloak |
| 2. Permisos por rol | Qué acción puede hacer (matriz) | API |
| 3. Aislamiento por negocio | Que un negocio no vea filas de otro | PostgreSQL, con RLS |
| 4. Acceso a mascotas | Que un negocio solo vea mascotas compartidas con él | PostgreSQL, con RLS |
| 5. Niveles de visibilidad | Qué eventos del expediente ve cada quien | PostgreSQL (RLS) y API |
| 6. Archivos | Que nadie descargue un archivo que no puede ver | API (Object Storage nunca se expone) |
| 7. Auditoría | Registro de accesos y cambios sensibles | `registro_auditoria` |

Si una capa falla, la siguiente sigue protegiendo: por eso el aislamiento y el acceso a mascotas se aplican en la base de datos y no solo en el código del API.

## 3. Contexto de la sesión

En cada transacción, el API le dice a PostgreSQL quién está operando:

| Variable | Valor |
|---|---|
| `app.tipo_sesion` | `personal`, `dueno`, `plataforma` o `proceso` |
| `app.usuario_id` | El usuario autenticado |
| `app.negocio_id` | El negocio activo (solo personal) |
| `app.sucursal_id` | La sucursal activa (solo personal) |

- Se fijan con `SET LOCAL`, así que valen solo para esa transacción y no se filtran a otra petición.
- El API se conecta con un usuario de base de datos **sin** permiso para saltarse RLS (`BYPASSRLS`) y que no es dueño de las tablas.
- Los procesos automáticos (cierre de periodo, referidos, recordatorios) usan un usuario de base de datos propio, con permisos solo sobre lo que necesitan.

## 4. Clasificación de las tablas

| Grupo | Tablas | Regla |
|---|---|---|
| **A. Del negocio** | Todas las que llevan `negocio_id` y son operación del negocio: `sucursal`, `miembro_negocio`, `asignacion_rol`, `profesional`, `cliente`, `invitacion_activacion`, `servicio*`, `horario_sucursal`, `dia_especial`, `regla_capacidad`, `cita*`, `producto*`, `movimiento_inventario`, `conteo_*`, `promocion`, `componente_promocion`, `venta*`, `pago_venta`, `cancelacion_venta`, `impresion_ticket`, `campana`, `criterio_audiencia`, `cargo*`, `periodo_facturacion`, `movimiento_mes_a_favor` | Personal: solo filas de su `negocio_id`. Dueño: solo lo suyo que el negocio le muestra (por ejemplo, sus citas y ventas). |
| **B. Del dueño y su mascota** | `mascota`, `propiedad`, `autorizacion`, `transferencia_propiedad`, `fallecimiento`, `vinculacion`, `mascota_vinculada`, `evento_mascota` y sus detalles, `documento` | Reglas de las secciones 5 y 6. |
| **C. Personales del usuario** | `usuario`, `perfil_usuario_final`, `preferencia_notificacion`, `dispositivo_push`, `aceptacion`, `notificacion`, `codigo_invitacion`, `referido_usuario` | Solo el propio usuario. El negocio ve de un dueño únicamente lo que está en su `cliente`. |
| **D. Catálogos de plataforma** | `especie`, `raza`, `plan`, `precio_plan`, `entitlement`, `parametro`, `version_parametro`, `tasa_iva`, `tipo_notificacion`, `documento_legal`, `version_documento_legal`, `rol`, `permiso`, `rol_permiso` | Todos leen; solo la plataforma escribe. |
| **E. Plataforma** | `usuario_plataforma`, `suscripcion`, `cambio_suscripcion`, `pago_suscripcion`, `solicitud_afiliacion`, `referido_negocio`, `beneficio_referido` | La plataforma lee y escribe; el negocio solo lee lo suyo (su suscripción, sus cargos, sus referidos). |
| **F. Auditoría** | `registro_auditoria` | Solo inserción. El negocio lee lo suyo; la plataforma, todo, y esa lectura también se audita. |

## 5. Quién ve una mascota

Una sesión puede ver una mascota si se cumple **alguna** de estas condiciones:

| Quién | Condición |
|---|---|
| Propietario | Tiene la `propiedad` vigente (`hasta` nulo). |
| Autorizado | Tiene una `autorizacion` vigente sobre ella. |
| Personal del negocio N | La mascota está en `mascota_vinculada` abierta, dentro de una `vinculacion` **vigente** con N. |
| Personal del negocio N | La mascota es **provisional** y `negocio_custodio_id` = N. |

Además, si la mascota está **oculta** (fallecida hace más de 30 días), el dueño ya no la ve, pero los negocios que tenían acceso la siguen viendo en solo lectura como historial.

Consecuencias que ya estaban decididas y que esta regla cumple sola:

- Con la vinculación **retirada**, el negocio no ve la mascota ni lo que él mismo registró; si el dueño se vuelve a vincular, lo recupera.
- Al **transferirse**, deja de estar compartida con los negocios del propietario anterior, y el propietario anterior pierde el acceso.
- Una mascota **provisional** solo la ve su negocio custodio.

## 6. Qué eventos del expediente ve cada quien

Aplica a `evento_mascota`, sus tablas de detalle y los `documento` ligados. Primero se exige poder ver la mascota (sección 5).

| Evento | Dueño y autorizados | Negocio que lo generó | Otro negocio con acceso |
|---|---|---|---|
| Nivel 1 (perfil, peso, datos de seguridad, eventos y documentos del dueño) | Sí | Sí | Sí |
| Nivel 2 (vacunas, desparasitaciones, preventivos, certificados) | Sí | Sí | Sí |
| Nivel 3 (consultas, signos vitales, recetas, estudios, procedimientos) | Sí | Solo con `expediente.consultar_clinico` | No |
| Servicios de estética | Sí | Solo con `expediente.consultar_estetica` | No |
| Interno (notas) | No | Solo con `nota_mascota.registrar` | No |
| Evento `corregido` | No (ve el vigente) | Sí, con el permiso de su nivel | No |

- La **base de datos** aplica las tres columnas por quién generó el evento (dueño, mismo negocio, otro negocio).
- El **API** aplica el permiso del rol dentro del negocio (por ejemplo, que una recepcionista no vea el nivel 3).
- Después de una fusión, los eventos de la mascota provisional ya apuntan a la mascota del dueño y siguen estas mismas reglas.

## 7. Qué se audita por privacidad

Además de la lista de la sección 13 del requerimiento, cada uno de estos accesos crea un `registro_auditoria`:

| Acceso | Se registra |
|---|---|
| Abrir el expediente clínico (nivel 3) de una mascota | Quién, qué mascota, qué negocio y sucursal, cuándo. Uno por consulta de pantalla, no por campo. |
| Descargar un documento clínico | Quién, qué documento, cuándo. |
| Exportar la línea de tiempo en PDF | Quién y cuándo. |
| Consulta de la plataforma a la auditoría de un negocio | Quién, qué negocio y qué filtros. |
| Activación o fusión de una mascota provisional | Quién, qué mascotas y con qué resultado. |

## 8. Ejemplo de política RLS

Ilustrativo; las políticas definitivas se escriben con las migraciones.

```sql
-- Aislamiento por negocio (grupo A)
alter table venta enable row level security;
create policy venta_por_negocio on venta
  using (negocio_id = current_setting('app.negocio_id')::uuid);

-- Acceso a mascotas (grupo B): una función reúne las condiciones de la sección 5
create policy mascota_visible on mascota
  using (puede_ver_mascota(mascota_id));
```

`puede_ver_mascota` y `puede_ver_evento` se implementan como funciones de la base de datos, con índices sobre `propiedad`, `autorizacion` y `mascota_vinculada` para que no afecten el rendimiento.

## 9. Decisiones confirmadas

| # | Decisión |
|---|---|
| 1 | Contexto de sesión por transacción (`SET LOCAL`) y usuario de base de datos del API sin `BYPASSRLS`. |
| 2 | La base de datos aplica aislamiento por negocio, acceso a mascotas y origen de cada evento; el API aplica los permisos por rol. |
| 3 | Otro negocio ve qué negocio generó un evento de nivel 2. |
| 4 | Un negocio no ve con qué otros negocios está vinculado el dueño, más allá de los eventos de nivel 2. |
| 5 | La mascota oculta la siguen viendo en solo lectura los negocios que tenían acceso. |
| 6 | El propietario anterior pierde todo acceso después de una transferencia, incluido el historial. |
| 7 | Los accesos clínicos se auditan por pantalla, no por campo. |
| 8 | En el MVP la plataforma no ve datos operativos ni clínicos de ningún negocio, ni para soporte; si se necesita después, será con autorización del negocio y por tiempo limitado. |

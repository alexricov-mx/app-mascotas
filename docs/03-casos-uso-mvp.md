# Casos de uso del MVP — amiva.pet

**Versión:** 1.0  
**Fecha:** 2026-09-22  
**Fuente:** `requerimiento.md` versión 3.0  
**Estado:** borrador de trabajo para revisión antes del modelo conceptual y físico.

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

## 3. Reglas transversales

- El API valida autenticación, autorización y aislamiento por tenant.
- Ningún cliente accede directamente a PostgreSQL/PostGIS ni a Object Storage.
- Las operaciones críticas se auditan.
- El dueño solo ve la información que le corresponde y la línea de tiempo de sus mascotas.
- Un negocio solo accede después de una vinculación aceptada.
- Los identificadores internos usan prefijo y UUID.
- Las operaciones multi-entidad que deban ser atómicas se ejecutan en una transacción.
- Los registros clínicos pasados no se modifican; una corrección genera un nuevo registro.
- Los documentos se referencian desde el dominio y se almacenan mediante el API.

## 4. Identidad y acceso

### UC-01 — Registrar usuario final

**Actor principal:** ACT-01.  
**Precondiciones:** la app está instalada y el proveedor de identidad está disponible.  
**Flujo:**

1. El usuario elige un proveedor de identidad.
2. Proporciona o confirma su correo.
3. El sistema crea la identidad interna asociada al proveedor.
4. El sistema envía el enlace de verificación.
5. El usuario verifica el correo.
6. El sistema activa la cuenta.

**Resultado:** usuario final activo, sin negocio vinculado todavía.  
**Errores:** correo ya registrado, proveedor no disponible, verificación expirada o cuenta bloqueada.

### UC-02 — Iniciar y cerrar sesión

**Actores:** ACT-01 a ACT-07.  
**Resultado:** sesión autenticada con permisos del actor; cerrar sesión revoca o invalida la sesión local según la política definida.

### UC-03 — Dar de alta un negocio

**Actor principal:** ACT-07.  
**Superficie:** `admin.amiva.pet`.  
**Flujo:**

1. El administrador captura empresa, RFC y datos generales.
2. Selecciona plan y activa la prueba de 10 días.
3. Registra una o más sucursales con ubicación.
4. Configura el usuario inicial del negocio.
5. El sistema valida RFC único y límites.
6. El sistema crea el negocio, tenant, sucursales, suscripción y accesos.

**Resultado:** negocio habilitado para acceder a `app.amiva.pet`.  
**Errores:** RFC duplicado, datos incompletos, plan no disponible o alta no autorizada.

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
**Flujo:** el usuario captura datos generales y características de la mascota; el sistema valida el límite base y guarda la mascota.

**Resultado:** mascota asociada al propietario principal.  
**Errores:** límite alcanzado, datos inválidos o usuario bloqueado.

### UC-07 — Registrar mascota durante una vinculación

**Actor principal:** ACT-01.  
**Actor secundario:** ACT-06 o personal autorizado del negocio.  
**Flujo:** el usuario tiene cuenta, selecciona la sucursal, acepta la vinculación y completa o confirma los datos necesarios.

**Resultado:** relación usuario-mascota-negocio vigente y auditable.

### UC-08 — Aceptar o cancelar vinculación

**Actor principal:** ACT-01.  
**Flujo:** el usuario revisa el texto y versión del consentimiento, elige aceptar o cancelar y el sistema registra el resultado.

**Resultado:** si acepta, el negocio obtiene nivel 1, nivel 2 y sus propios registros; si cancela, no obtiene acceso.

### UC-09 — Retirar vinculación

**Actor principal:** ACT-01.  
**Resultado:** el negocio deja de navegar los datos de la relación. El evento de retiro queda auditado.

### UC-10 — Consultar ficha y línea de tiempo

**Actores:** ACT-01, ACT-03, ACT-04, ACT-05 y ACT-06 según permisos.  
**Resultado:** cada actor recibe únicamente los datos permitidos por rol, tenant, vinculación y nivel de visibilidad.

### UC-11 — Transferir propiedad de mascota

**Actor principal:** ACT-01 propietario actual.  
**Actor secundario:** nuevo propietario.  
**Flujo:** el propietario inicia la transferencia; el nuevo propietario acepta; el sistema registra solicitud, aceptación y fechas.

**Resultado:** nuevo propietario principal y conservación de la historia.

### UC-12 — Marcar mascota como fallecida

**Actor autorizado:** personal con permiso definido por el negocio.  
**Resultado:** estado fallecida; después de un mes se oculta para el usuario conforme al proceso automático.

### UC-13 — Agregar, consultar y eliminar documento

**Actores:** ACT-03, ACT-04, ACT-05, ACT-06 y ACT-01 según permisos.  
**Resultado:** documento referenciado en el dominio, protegido por el API y con eliminación lógica auditada.

## 6. Expediente y prevención

### UC-14 — Registrar consulta clínica

**Actor principal:** ACT-04.  
**Flujo:** selecciona mascota, captura motivo, diagnóstico, tratamiento, receta, estudios, procedimientos, cirugías, observaciones y signos vitales; guarda el registro.

**Resultado:** nuevo registro clínico fechado, asociado a mascota, negocio, sucursal y profesional.

### UC-15 — Registrar vacuna o prevención

**Actor principal:** ACT-04.  
**Resultado:** vacuna, desparasitación o tratamiento preventivo registrados con fechas y datos de aplicación; se programa recordatorio si corresponde.

### UC-16 — Registrar servicio no clínico

**Actor principal:** ACT-05.  
**Resultado:** evento de baño, estética u otro servicio, con inicio y conclusión cuando aplique.

### UC-17 — Consultar y exportar historia

**Actor principal:** ACT-01.  
**Resultado:** el usuario consulta la línea de tiempo, carnet y documentos permitidos; puede exportar su línea de tiempo como imagen.

## 7. Servicios y agenda

### UC-18 — Administrar catálogo de servicios

**Actor principal:** ACT-06.  
**Resultado:** servicio, variante, duración, disponibilidad, precio y reglas de sucursal configurados.

### UC-19 — Buscar sucursales y servicios

**Actor principal:** ACT-01.  
**Resultado:** sucursales afiliadas visibles en mapa con perfil, horarios, servicios, precios y ubicación.

### UC-20 — Solicitar cita

**Actor principal:** ACT-01.  
**Flujo:** selecciona mascota, sucursal, servicio, fecha y horario; envía solicitud.

**Resultado:** cita en estado solicitada; negocio notificado.

### UC-21 — Aceptar o rechazar cita

**Actor principal:** ACT-03 o ACT-05 autorizado.  
**Resultado:** cita confirmada o rechazada con mensaje; dueño notificado.

### UC-22 — Iniciar, completar o marcar no atendida una cita

**Actor principal:** personal autorizado del negocio.  
**Resultado:** transición de estado auditada y disponibilidad actualizada.

### UC-23 — Cancelar o reprogramar cita

**Actor principal:** ACT-01 o negocio según el caso.  
**Regla:** se aplica la ventana configurable, inicialmente 30 minutos antes.

## 8. Inventario y ventas

### UC-24 — Administrar productos e inventario

**Actor principal:** ACT-06.  
**Resultado:** productos con imagen, precio, descripción, existencia y visibilidad por sucursal; las existencias se modifican mediante movimientos.

### UC-25 — Administrar promociones compuestas

**Actor principal:** ACT-06.  
**Resultado:** promoción compuesta por productos y cantidades; disponibilidad calculada por componentes; cambios posteriores no alteran ventas históricas.

### UC-26 — Registrar venta en POS

**Actor principal:** ACT-03 o ACT-05 autorizado.  
**Flujo:**

1. Selecciona productos y promociones con imágenes grandes.
2. Ajusta cantidades dentro de existencias disponibles.
3. Consulta total.
4. Captura monto recibido.
5. El sistema calcula cambio.
6. Confirma la venta.
7. El API valida nuevamente productos, precios, existencias y permisos dentro de una transacción.
8. Guarda venta, detalles, pagos y movimientos de inventario.

**Resultado:** venta registrada y existencias actualizadas.  
**Errores:** existencia insuficiente, precio cambiado, producto desactivado, monto insuficiente, doble envío o sucursal no autorizada.

### UC-27 — Cancelar venta

**Actor autorizado:** ACT-06 o rol configurado.  
**Resultado:** venta cancelada una sola vez, movimientos de devolución registrados y reportes actualizados.

### UC-28 — Consultar auditoría de ventas

**Actores:** ACT-06 y ACT-07 según permisos.  
**Resultado:** consulta de ventas, fechas, montos, productos o promociones afectados, usuario, sucursal y estado.

## 9. Administración de plataforma

### UC-29 — Configurar parámetros

**Actor principal:** ACT-07.  
**Resultado:** límites, plazos, precios de planes, tamaños de archivos, textos legales y otros parámetros quedan versionados y auditados.

### UC-30 — Administrar textos y consentimientos

**Actor principal:** ACT-07.  
**Resultado:** texto activo y versiones históricas disponibles para nuevas aceptaciones y auditoría.

### UC-31 — Administrar reseñas

**Actor principal:** ACT-07.  
**Resultado:** revisión, publicación, ocultamiento o suspensión conforme a las reglas vigentes.

### UC-32 — Administrar campañas

**Actores:** ACT-06 crea; ACT-07 puede ocultar o supervisar.  
**Resultado:** campaña dirigida a una audiencia, con canal, vigencia, frecuencia y prioridad configurados.

## 10. Procesos automáticos

### UC-33 — Enviar recordatorios

**Actor:** ACT-08.  
**Resultado:** recordatorios de vacunas una semana antes y citas dos horas antes cuando corresponda. Los errores se registran y no se envían mensajes atrasados.

### UC-34 — Aplicar ciclo de suscripción

**Actor:** ACT-08.  
**Resultado:** el sistema cambia el estado de la suscripción conforme a fechas y parámetros, aplicando permisos de operación, lectura o bloqueo.

### UC-35 — Ocultar mascota fallecida

**Actor:** ACT-08.  
**Resultado:** después del plazo configurado, la mascota deja de mostrarse al usuario, conservando la información conforme a las reglas de conservación.

### UC-36 — Aplicar conservación y eliminación

**Actor:** ACT-08 bajo configuración y autorización de plataforma.  
**Resultado:** se aplican borrados físicos o lógicos según tipo de información, estado del negocio, actividad de mascota y obligaciones de conservación.

## 11. Casos fuera del MVP

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

## 12. Decisiones pendientes que afectan casos de uso

- Derecho de respuesta en reseñas.
- Reglas para campañas con atributos sensibles.
- Límites finales y tipos de archivos.
- Detalle legal de eliminación, conservación y derechos ARCO.
- Configuración final del proveedor de identidad.
- Estados y flujo detallado de proveedores y órdenes de compra.

## 13. Siguiente documento

El siguiente paso es revisar y aprobar este catálogo de casos de uso. Después se elaborará el modelo conceptual separando núcleo genérico y vertical de mascotas. No se diseñarán tablas hasta cerrar esa revisión.

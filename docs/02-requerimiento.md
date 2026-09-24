# Plataforma para el Cuidado de Mascotas — Requerimientos

**Nombre del producto:** amiva.pet  
**Versión:** 3.0  
**Fecha:** 2026-09-22  
**Estado:** fuente de verdad vigente del producto.

Este documento reemplaza como referencia de trabajo a `01-requerimiento.md`, `02-respuesta-21092026.md` y `03-requerimiento-2.md`. Los documentos anteriores se conservan como historial. `App-Ventas` no se modifica; se usa como referencia funcional para el punto de venta, inventario y promociones.

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
- **Usuario autorizado:** familiar o cuidador con cuenta propia; puede llevar y recoger mascotas según la autorización.
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

Se contemplan Google, Microsoft, Facebook, X y Apple en iOS, sujetos a la configuración y validación técnica final del proveedor de identidad.

El usuario agrega sus mascotas, busca sucursales en el mapa y solicita vincularse con ellas.

## 5. Mascotas, propiedad y límites

Una mascota tiene un propietario principal y cero o más usuarios autorizados. No existen propietarios secundarios. La transferencia requiere que el propietario actual la inicie y que el nuevo propietario la acepte; se conserva la historia.

Datos: nombre, fotografía, especie, raza, sexo, estado reproductivo, fecha de nacimiento, edad calculada, peso, color, características físicas, señas particulares, microchip, alergias, condiciones especiales, medicamentos activos, dieta y veterinario habitual.

Especies iniciales: perro, gato, ave, roedor, reptil y otro.

Cada usuario final tiene dos mascotas base. Las adicionales tienen un cargo configurable, pero en el MVP no se cobra dentro de la app: la sucursal registra el evento y cobra en efectivo por sus propios medios; el cargo se incorpora al periodo de facturación del negocio con la plataforma. Las mascotas obtenidas por referidos son adicionales al límite base y pueden ganarse hasta cinco por cuenta. Las mascotas adicionales pagadas no tienen ese límite.

El límite de mascotas por negocio es configurable desde `admin.amiva.pet`.

## 6. Vinculación y privacidad

El usuario selecciona una sucursal desde la app y ve una pantalla de consentimiento y vinculación con acciones de aceptar o cancelar. El negocio obtiene acceso únicamente después de la aceptación.

Se registra el texto mostrado, su versión, usuario, negocio, sucursal, fecha, resultado y bitácora del evento. El texto se administra desde `admin.amiva.pet`.

Un negocio vinculado puede consultar:

- **Nivel 1:** perfil básico y datos que el dueño decida compartir.
- **Nivel 2:** vacunas, desparasitación, tratamientos preventivos y certificados.
- **Información generada por el propio negocio.**

Nunca puede consultar el nivel 3 generado por otro negocio. Al desvincularse, el negocio pierde el acceso a la información del usuario y deja de navegar los registros de esa relación.

El dueño consulta vacunas, alergias, padecimientos, recetas, consultas, servicios, citas, documentos y la línea de tiempo con el nombre del negocio que generó cada evento. Las notas internas, costos, márgenes y observaciones comerciales son privadas del negocio.

## 7. Expediente y documentos

Las veterinarias registran consultas, motivo, diagnóstico, tratamiento, medicamentos, recetas, estudios, procedimientos, cirugías, observaciones y signos vitales. Las estéticas registran servicios no clínicos, como baño y estética.

Los documentos pueden agregarse, actualizarse y eliminarse. La eliminación es lógica, se audita y solo puede ejecutarla el negocio que subió el documento.

Al fallecer una mascota, cambia a estado fallecida. Después de un mes se ocultan datos, fotos, expediente e historial para el usuario, pero la información se conserva. El usuario puede registrar una nueva mascota.

Si una mascota no tiene actividad ni consumo durante cinco años, se eliminan sus datos, historial, expediente y fotografías conforme a los parámetros de la plataforma.

Cuando un negocio deja de pagar, después del periodo de resguardo se eliminan físicamente inventario, citas históricas, usuarios operadores, ventas y compras. Los registros necesarios para reportes e historial clínico se conservan mediante borrado lógico.

La eliminación solicitada por un usuario es lógica e inmediata para impedirle el acceso, sujeta a obligaciones legales y conservación aplicable.

## 8. Agenda y citas

Toda cita corresponde a una mascota y requiere aprobación del negocio. Flujo: mascota, servicio, fecha y horario. El negocio acepta o rechaza con mensaje, inicia el servicio y puede marcarla como no atendida.

Estados: solicitada, confirmada, en proceso, completada, rechazada, cancelada y no atendida.

La capacidad se configura por cantidad de mascotas simultáneas, horario y día. La duración depende del servicio, variantes y tiempos adicionales configurados.

El dueño puede cancelar o reprogramar hasta el límite configurable, inicialmente 30 minutos antes. La tolerancia para no atención también es configurable. No existe penalización por inasistencia.

Vacunas: recordatorio una semana antes. Citas: recordatorio dos horas antes; si se crean con menos de dos horas de anticipación, no se envía recordatorio.

La lista de espera queda para una versión posterior. Cada turno dispone de 10 minutos; si no confirma o rechaza, se elimina y se avisa al siguiente. El orden es el momento de entrada a la cola.

## 9. Servicios, variantes y precios

El catálogo contiene nombre, descripción, duración, disponibilidad, sucursal, estado publicado y reglas de cancelación. Las variantes permiten matrices de precio y duración por especie, tamaño, raza, peso, duración o condición clínica.

El precio y la duración se definen por defecto a nivel de negocio y cada sucursal puede ajustarlos. Los servicios pueden tener precio publicado o no listado.

No habrá flujo de cotización en la app. Cuando se acuerde un precio especial, el usuario y el profesional lo acuerdan fuera de ese flujo y el profesional registra el servicio y su costo. El precio queda en el evento y, cuando corresponda, en la venta.

## 10. Inventario, promociones y punto de venta

El MVP incorpora inventario, promociones y ventas en sitio. La experiencia funcional del POS se basa en `App-Ventas`; el prototipo `amiva-huella` se usa únicamente como referencia para adaptar la presentación a web y tablet.

El inventario se administra por sucursal. Las existencias solo cambian mediante movimientos: entradas, salidas, ajustes, consumo interno, merma, caducidad, ventas y cancelaciones. Se manejan stock mínimo y alertas.

Los productos tienen cantidad, imagen, precio, descripción breve y estado visible u oculto. Las promociones se componen de productos del inventario y descuentan sus componentes al venderse. La venta debe conservar el detalle y precio acordados; una cancelación devuelve los componentes mediante movimientos.

El POS debe permitir productos y promociones con imágenes grandes, sumar y restar cantidades, mostrar total, registrar cuánto se recibe, calcular cambio, indicar agotados y consultar auditoría de ventas. Las operaciones críticas son transaccionales y conservan trazabilidad.

Se incluyen ventas en efectivo. La sucursal puede aceptar tarjeta por sus propios medios, pero el procesamiento de tarjetas no se integra en el MVP. Ecommerce, carrito multi-negocio, pagos integrados y comisión de venta quedan para una evolución posterior. La Tienda Digital no se muestra hasta que exista el módulo.

## 11. Suscripciones, planes y referidos

Planes: Básico, Extendido y Tienda Digital. Los administradores de plataforma configuran precios, sucursales adicionales y límites operativos desde `admin.amiva.pet`.

No hay límite de usuarios por plan. No se lleva contador de almacenamiento, pero se limitan tamaños y tipos de recursos. Add-ons quedan en backlog. Enterprise es futuro.

Impago: dos días de gracia, cinco días en solo lectura, después sin acceso y seis meses de resguardo antes de la eliminación definida en este documento.

### Referidos de negocios

El negocio referido se afilia como mínimo al plan Básico y lo mantiene pagado dos meses consecutivos. El negocio que refiere obtiene un mes gratuito de su plan actual por cada referido elegible, sin límite. Los meses se acumulan, no caducan y se consumen antes de generar nuevos cargos.

### Referidos de usuarios finales

El usuario referido completa su afiliación y concluye diez servicios pagados. El usuario que refiere obtiene una mascota adicional gratuita, hasta cinco recompensas por cuenta. Se usan enlaces de referido; no se permiten auto-referidos ni duplicados.

## 12. Notificaciones, reseñas y campañas

El MVP usa correo, push y notificaciones internas. WhatsApp queda fuera. No hay chat directo negocio-dueño en el MVP.

El dueño puede apagar todas las notificaciones o configurar cada tipo. Se registran errores de envío, sin mensajes atrasados ni registro de apertura o entrega.

Las reseñas se solicitan por correo. El operador de sucursal y la administración de plataforma pueden revisarlas; la publicación requiere acción del administrador de plataforma. La retención es configurable. El derecho de respuesta del negocio queda pendiente.

Las sucursales pueden crear campañas para correo, banners y push. La audiencia puede seleccionarse por sucursal y atributos de mascota. La vigencia, frecuencia y prioridad son configurables. La plataforma puede ocultar campañas inadecuadas.

## 13. Auditoría y legal

Se auditan vinculaciones, consentimientos, transferencias, autorizaciones, accesos clínicos, registros, documentos, datos sensibles, precios, servicios, variantes, suscripciones, inventario, suspensiones, contactos verificados, cancelaciones y citas no atendidas.

Desde `admin.amiva.pet` se administran versiones de aviso de privacidad, consentimiento, términos, conservación, eliminación, tratamiento de datos, responsabilidades, pagos y documentos legales. Cada aceptación conserva la versión mostrada y su bitácora.

Antes del lanzamiento se requiere validación legal especializada sobre propiedad de la información, aviso de privacidad, derechos ARCO, conservación, eliminación, responsabilidades, tratamiento de datos y pagos.

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

## 16. Repositorios

- `app-mascotas-usuario`: app móvil del dueño.
- `app-mascotas-negocio`: app para tablet y portal web Flutter del negocio.
- `app-mascotas-admin`: portal Vue de `admin.amiva.pet`.
- `app-mascotas-api`: API común, reglas de negocio, persistencia e integraciones.

## 17. Releases

- **R0:** fundaciones, identidad, negocios, sucursales, usuarios, roles, multi-tenant, auditoría, planes, `admin.amiva.pet` y `app.amiva.pet`.
- **R1 MVP:** clientes, mascotas, ficha, expediente básico, vacunas, documentos, signos vitales, agenda, citas, servicios, variantes, capacidad, inventario, promociones, ventas en sitio, POS, línea de tiempo, mapa, notificaciones y administración de plataforma.
- **R2:** lista de espera, reseñas, favoritos, filtros avanzados, ranking, SMS y búsqueda rápida.
- **R3:** ecommerce, carrito, pedidos, pagos integrados, comisión y evolución del inventario.
- **R4:** lotes, caducidades, proveedores y órdenes de compra.
- **R5:** campañas avanzadas, automatizaciones, métricas y recompensas.
- **R6:** marketplace B2B, laboratorios, facturación electrónica y hospitalización.

## 18. Entidades conceptuales iniciales

Usuario, IdentidadExterna, Tenant, Negocio, Sucursal, UsuarioTenant, Rol, Permiso, Mascota, UsuarioMascota, Vinculacion, Consentimiento, Cliente, Profesional, Servicio, Variante, PrecioSucursal, Cita, EventoMascota, RegistroClinico, Vacuna, Documento, Notificacion, Auditoria, Plan, Entitlement, Suscripcion, Parametro, Producto, MovimientoInventario, Promocion, Venta, VentaDetalle, Pago, Referido y OrdenCompra.

## 19. Pendientes vigentes

- Derecho de respuesta en reseñas.
- Límites finales de archivos y tipos aceptados.
- Reglas para campañas dirigidas a atributos sensibles.
- Modelo detallado de proveedores y órdenes de compra.
- Validación legal especializada.
- Configuración concreta del VPS, contenedores, Nginx, Cloudflare y certificados.
- Límites y estrategia de transferencia de archivos a través del API.
- Proveedor y configuración final de identidad externa.

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

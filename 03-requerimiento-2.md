# Plataforma para el Cuidado de Mascotas — Requerimientos consolidados

**Nombre del producto:** provisional (AppMascotas)  
**Versión:** 2.2  
**Fecha:** 2026-09-22  
**Estado:** documento consolidado con las respuestas recibidas. Los asuntos todavía abiertos se encuentran en `04-pendientes-22092026.md`.

## 0. Criterios del documento

Este documento sustituye como referencia de trabajo a las versiones anteriores. Las respuestas del responsable del producto prevalecen sobre propuestas anteriores. `App-Ventas` es únicamente referencia funcional y no se modifica.

Las etiquetas usadas son: **CONFIRMADO**, **PROVISIONAL**, **PROPUESTA**, **LEGAL** y **FUTURO**.

## 1. Producto y alcance

AppMascotas es una plataforma SaaS para veterinarias y estéticas de mascotas, con una aplicación para los usuarios finales, una solución Flutter para la operación del negocio y un portal Vue independiente para la administración de la plataforma. La mascota es la entidad central.

El núcleo debe poder reutilizarse posteriormente en otros tipos de negocio. Los módulos genéricos son organizaciones, sucursales, usuarios, roles, identidad, suscripciones, parámetros, auditoría, clientes, servicios, agenda, comercio, inventario, compras, promociones, notificaciones y métricas. El vertical de mascotas contiene mascotas, propietarios, expediente, prevención, carnet, ficha integral y línea de tiempo.

El mercado inicial es México, comenzando en Guerrero, Puebla, Estado de México y Ciudad de México.

### Decisiones principales

- Proyecto nuevo e independiente de `App-Ventas`.
- Monolito modular; no se inicia con microservicios.
- PostgreSQL y multi-tenant desde el inicio.
- El dueño usa una app móvil para iOS y Android.
- El negocio usa una solución Flutter que se publica como portal web y como app para tablet; ambas superficies comparten el mismo proyecto y la misma lógica de operación.
- Los administradores de la plataforma usan un portal web independiente construido con Vue.
- La plataforma conserva la trazabilidad de la información.
- Los valores de negocio se configuran desde la administración de la plataforma, no se fijan en código.
- Los registros clínicos son históricos: una corrección se registra como un nuevo registro.
- La plataforma queda en línea; no existe requisito de operación offline.

## 2. Actores

- **Dueño principal:** único propietario principal de una mascota.
- **Usuario autorizado:** familiar o cuidador con cuenta propia; puede llevar y recoger mascotas.
- **Profesional:** veterinario, estilista u otro prestador.
- **Recepción:** gestiona agenda y ventas autorizadas.
- **Administrador de negocio:** usa la solución Flutter del negocio para configurar usuarios, catálogo, sucursales y operación.
- **Administrador de plataforma:** usa el portal Vue de administración para administrar negocios, planes, usuarios, reseñas, parámetros y estados de las cuentas.
- **Sistema:** ejecuta procesos automáticos y notificaciones.
- **Proveedores externos:** identidad, pagos futuros, correo, push, mapas y almacenamiento.

## 3. Usuarios, mascotas y vinculación

### 3.1 Alta del usuario final

El usuario final descarga la app, se registra mediante un proveedor de identidad y proporciona un correo electrónico. La plataforma envía un correo de verificación; la cuenta se activa cuando el usuario selecciona el enlace de verificación.

Se admitirán Google, Microsoft, Facebook, X y Apple para iOS, además del proveedor de identidad que se configure. La selección técnica definitiva y sus condiciones de operación quedan sujetas a validación de la implementación.

El usuario puede agregar mascotas, buscar sucursales en el mapa y solicitar vincularse con una sucursal.

### 3.2 Mascotas

Una mascota tiene un propietario principal y cero o más usuarios autorizados. No se contemplan propietarios secundarios. Se conserva la historia de transferencias de propiedad; el propietario actual inicia la transferencia y el nuevo propietario la acepta.

Datos: nombre, fotografía, especie, raza, sexo, estado reproductivo, fecha de nacimiento, edad calculada, peso, color, características físicas, señas particulares, microchip, alergias, condiciones especiales, medicamentos activos, dieta y veterinario habitual.

Especies iniciales: perro, gato, ave, roedor, reptil y otro. La estructura inicial es especie y raza.

### 3.3 Límite y beneficios

- Cada usuario final tiene dos mascotas base.
- Puede agregar mascotas adicionales mediante un cargo configurable en la administración de la plataforma.
- En el MVP no habrá cobro dentro de la app del usuario. La sucursal registra el evento y cobra en efectivo por sus propios medios; el cargo se integra a su periodo de facturación con la plataforma.
- Las mascotas ganadas por referidos son adicionales al límite base.
- Un usuario puede ganar hasta cinco mascotas adicionales por el programa de referidos. Las mascotas adicionales pagadas no tienen ese límite.
- El límite de mascotas por negocio es configurable desde el portal Vue de administración de la plataforma.

### 3.4 Vinculación con negocios

El usuario selecciona una sucursal desde la app y accede a una pantalla de consentimiento y vinculación con botones para aceptar o cancelar. El negocio obtiene acceso únicamente después de la aceptación.

El consentimiento, texto mostrado, versión, usuario, negocio, sucursal, fecha y resultado quedan registrados en la bitácora. El texto se administra desde la plataforma.

Al vincularse, el negocio puede ver:

- Nivel 1: perfil básico y datos que el dueño decida compartir.
- Nivel 2: vacunas, desparasitación, tratamientos preventivos y certificados.
- Información generada por el propio negocio.

El negocio nunca ve el nivel 3 de otro negocio. Al desvincularse, deja de tener acceso a los datos del usuario y tampoco puede navegar los registros que él mismo creó desde esa relación.

## 4. Privacidad, expediente y documentos

El dueño puede consultar vacunas, alergias, padecimientos, recetas, consultas, servicios, citas, documentos e información de sus mascotas. Ve la línea de tiempo con el nombre del negocio que generó cada evento.

El negocio que generó un registro puede verlo completo, incluyendo sus notas internas y observaciones comerciales. Las notas administrativas, costos, márgenes y observaciones comerciales son privadas del negocio.

Las veterinarias registran consultas, diagnósticos, tratamientos, recetas, estudios, procedimientos, cirugías y signos vitales. Las estéticas registran servicios no clínicos, como baño y estética.

Los documentos pueden agregarse, actualizarse y eliminarse. La eliminación es lógica, queda auditada y solo puede hacerla el negocio que subió el documento.

### Fallecimiento y conservación

Al fallecer una mascota, se cambia su estado a fallecida. Después de un mes se ocultan sus datos, fotografías, expediente e historial de eventos para el usuario, pero la información se conserva. El usuario puede registrar una nueva mascota en su lugar.

Si una mascota no tiene actividad ni consumo durante cinco años, se eliminan sus datos, historial, expediente y fotografías, de acuerdo con los parámetros de la plataforma.

Cuando un negocio deja de pagar, se eliminan físicamente sus datos de inventario, citas históricas, usuarios operadores, ventas y compras después del periodo de resguardo. Los registros que permitan asociar información con un usuario final o un médico se conservan mediante borrado lógico para no afectar reportes ni el historial clínico.

La eliminación solicitada por un usuario es lógica e inmediata para impedirle el acceso, conservando la información necesaria para las veterinarias y obligaciones aplicables.

## 5. Agenda y citas

Toda cita corresponde a una mascota y requiere aprobación del negocio. El flujo es mascota, servicio, fecha y horario. El negocio acepta o rechaza con mensaje, inicia el servicio y puede marcarla como no atendida.

Estados: solicitada, confirmada, en proceso, completada, rechazada, cancelada y no atendida.

La capacidad se configura por cantidad de mascotas simultáneas, horario y día. La duración se calcula a partir del servicio, variantes y tiempos adicionales configurados.

El usuario puede cancelar o reprogramar hasta el límite configurable, inicialmente 30 minutos antes. La tolerancia para no atención también es configurable. No se cobra penalización por inasistencia.

Las vacunas tienen recordatorio una semana antes. Las citas tienen recordatorio dos horas antes; si se crean con menos de dos horas de anticipación, no se envía recordatorio.

La lista de espera queda para una versión posterior: cada turno dispone de 10 minutos para confirmar; si rechaza o no responde se elimina y se notifica al siguiente. El orden es el momento de entrada a la cola. Para volver a participar debe formarse nuevamente.

## 6. Servicios, precios y cotizaciones

El catálogo incluye servicios, descripción, duración, disponibilidad, sucursal, estado publicado y reglas de cancelación. Las variantes permiten matrices de precio y duración por especie, tamaño, raza, peso, duración o condición clínica.

El precio y la duración se definen por defecto a nivel de negocio y cada sucursal puede ajustarlos. Los servicios pueden tener precio publicado o marcarse como no listados.

No habrá un flujo de cotización dentro de la app. Cuando el servicio requiere un precio especial, el usuario final y el veterinario lo acuerdan fuera del flujo de cotización y el profesional registra el servicio y su costo en la plataforma. El precio acordado queda en el evento y, posteriormente, en la venta cuando corresponda.

## 7. Roles y permisos mínimos

- **Usuario autorizado:** llevar y recoger mascotas de servicios según la autorización recibida.
- **Recepción:** aceptar citas, registrar citas en agenda y realizar ventas desde el punto de venta.
- **Veterinario:** consultar información de la mascota, registrar vacunas y emitir recetas.
- **Estilista:** iniciar y concluir el evento de servicio asignado.
- **Administrador de negocio:** desde la solución Flutter del negocio, dar de alta personal de recepción, gestionar inventario, productos y servicios, configurar sucursales, precios y logotipos, y revisar reseñas.
- **Administrador de plataforma:** desde el portal Vue de administración, dar de alta negocios, cambiar planes, activar, suspender o bloquear cuentas y usuarios, revisar y suspender reseñas.

La autorización granular y el mínimo privilegio aplican a todos los roles.

## 8. Comercio, inventario y ventas

El MVP incorpora inventario y ventas en sitio como módulo de punto de venta, tomando como referencia funcional general `App-Ventas` sin modificar ese proyecto.

Se incluyen ventas en efectivo. La sucursal puede aceptar tarjetas por sus propios medios, pero el procesamiento de tarjetas no estará integrado en el MVP. El cobro en línea de la plataforma se implementará junto con el ecommerce.

El inventario se maneja por sucursal y cambia únicamente mediante movimientos. Se consideran entradas, salidas, ajustes, consumo interno, merma, caducidad, stock mínimo y alertas. Promociones y descuentos se tomarán del módulo configurable de `App-Ventas`.

La Tienda Digital no estará disponible inicialmente y no se mostrará hasta que el módulo ecommerce exista. Comercio electrónico, carrito, órdenes multi-negocio, pagos integrados y comisión de venta permanecen en la evolución posterior.

## 9. Suscripciones y administración

Planes: Básico, Extendido y Tienda Digital. Los administradores de plataforma configuran precios, precio de sucursal adicional y límites operativos desde el portal Vue de administración.

No hay límite de usuarios por plan. No se llevará un contador de almacenamiento, pero se limitarán el tamaño y los tipos de recursos. Los add-ons quedan en backlog. Enterprise queda como evolución futura.

La prueba dura 10 días naturales, se activa una sola vez por empresa, sin tarjeta, y la administra la plataforma. El RFC es único por empresa.

Ciclo de impago: dos días de gracia, cinco días en solo lectura, después sin acceso y seis meses de resguardo antes de la eliminación definida en la sección 4.

## 10. Notificaciones y comunicación

El MVP utiliza correo, push y notificaciones internas. WhatsApp queda fuera de esta versión. El negocio no tendrá chat directo con el dueño en el MVP; el contacto se hará mediante los datos del negocio y notificaciones.

El dueño puede apagar todas las notificaciones o configurar cada tipo de evento. Se registran errores de envío, sin mensajes atrasados ni registro de apertura o entrega.

## 11. Referidos

### Negocio a negocio

El negocio referido debe afiliarse como mínimo al plan Básico y mantenerlo pagado durante dos meses consecutivos. El negocio que refiere obtiene un mes gratuito de su plan actual por cada referido elegible, sin límite. Los meses se acumulan, no caducan y se consumen antes de generar nuevos cargos.

### Usuario final a usuario final

El usuario referido debe completar su afiliación y concluir diez servicios pagados. El usuario que refiere obtiene una mascota adicional gratuita. El límite es de cinco recompensas por cuenta; las mascotas adicionales pagadas no tienen límite de este programa.

El referido se identifica mediante un enlace generado desde la app o el portal. No se permiten auto-referidos ni cuentas duplicadas por RFC cuando aplique. No hay reembolsos asociados al beneficio.

## 12. Reseñas, campañas y compras futuras

Las reseñas se solicitan por correo. El operador de sucursal y la administración de plataforma pueden revisarlas; la publicación requiere una acción adicional del administrador de plataforma. La retención será configurable. La regla de derecho de respuesta del negocio queda pendiente.

Las sucursales pueden crear campañas. Pueden enviarse por correo, banner dentro de la app y push. La audiencia puede seleccionarse por sucursal y atributos de mascota. La vigencia, frecuencia y prioridad son configurables. El módulo se contempla desde el plan Básico. La plataforma puede ocultar una campaña que considere inadecuada.

Las órdenes de compra quedan como evolución futura sin integración externa. Pueden iniciarlas veterinarios o recepción, requieren autorización del administrador y admiten recepción parcial. Estados: borrador, en proceso y concluida. Deben respetar el modelo futuro de inventarios y proveedores.

## 13. Auditoría y legal

Se auditan vinculaciones, consentimientos, transferencias, autorizaciones, accesos clínicos, registros y documentos, datos sensibles, precios, servicios, variantes, suscripciones, inventario, suspensiones, contactos verificados, cancelaciones y citas no atendidas.

La plataforma administrará versiones de aviso de privacidad, consentimiento, términos, conservación, eliminación, tratamiento de datos, responsabilidades, pagos y documentos legales desde un módulo de configuración. Cada aceptación conserva la versión mostrada y su bitácora.

La interpretación legal de propiedad de la información, obligaciones de la plataforma, derechos ARCO, conservación y comisión de pasarela requiere validación especializada antes del lanzamiento.

## 14. Requisitos no funcionales

- Seguridad: autenticación fuerte, autorización granular, mínimo privilegio, cifrado y secretos seguros.
- Multi-tenant: aislamiento por negocio mediante `tenant_id` y RLS.
- Relación global: deberá existir una relación explícita entre tenants, dueños y mascotas.
- Trazabilidad: operaciones críticas auditables.
- Escalabilidad: usuarios, mascotas, negocios, sucursales, citas y documentos.
- Integraciones desacopladas mediante límites de integración.
- Experiencia rápida y búsqueda contextual.
- Parámetros configurables desde administración.
- Respaldos incrementales diarios con retención de una semana, gestionados por el equipo de mantenimiento y no como función de usuario.

## 15. Arquitectura

La base de datos será PostgreSQL con PostGIS, instalada dentro del VPS en un contenedor. El backend será ASP.NET Core .NET 10 en un monolito modular. La solución Flutter cubrirá la operación del negocio en web y tablet; la app Flutter del usuario final funcionará en iOS y Android; y el portal de administración de la plataforma será Vue 3 + TypeScript + Vite. Los archivos se almacenarán en OVH Object Storage detrás de una interfaz.

El API será el único componente autorizado para conectarse a PostgreSQL y a Object Storage. La solución Flutter del negocio, el portal Vue de administración y la app móvil del usuario final se comunicarán exclusivamente con el API mediante HTTPS; ningún cliente tendrá credenciales ni conexión directa con la base de datos o el filestorage. Los identificadores internos tendrán prefijo y UUID.

## 16. Releases

- **R0:** fundaciones, identidad, negocios, sucursales, usuarios, roles, multi-tenant, auditoría, planes, solución Flutter del negocio y portal Vue de administración de la plataforma.
- **R1 MVP:** clientes, mascotas, ficha, expediente básico, vacunas, documentos, signos vitales, agenda, citas, servicios, variantes, capacidad, inventario, ventas en sitio, punto de venta, línea de tiempo, mapa, notificaciones y administración de plataforma.
- **R2:** lista de espera, reseñas, favoritos, filtros avanzados, ranking, SMS y búsqueda rápida.
- **R3:** ecommerce, carrito, pedidos, pagos integrados, comisión y evolución del inventario.
- **R4:** lotes, caducidades, proveedores y órdenes de compra.
- **R5:** campañas avanzadas, promociones, automatizaciones, métricas y recompensas.
- **R6:** marketplace B2B, laboratorios, facturación electrónica y hospitalización.

Fuera de alcance: chatbot diagnóstico, hospitalización inicial, laboratorios, facturación electrónica inicial, white label, Enterprise inicial y operación offline.

## 17. Entidades conceptuales

Usuario, Mascota, UsuarioMascota, Tenant, Negocio, Sucursal, Cliente, Profesional, Servicio, Variante, Cita, EventoMascota, RegistroClinico, Vacuna, Documento, Vinculacion, Consentimiento, Notificacion, Auditoria, Suscripcion, Plan, Entitlement, Parametro, Inventario, MovimientoInventario, Venta, Promocion, Referido y OrdenCompra.

## Historial

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-09-21 | Consolidación inicial. |
| 1.1 | 2026-09-21 | Incorporación de respuestas iniciales. |
| 2.0 | 2026-09-22 | Integración de las respuestas ampliadas: MVP con inventario y ventas en sitio, identidad móvil, consentimiento en pantalla, conservación, roles, referidos y almacenamiento. |
| 2.1 | 2026-09-22 | Separación de clientes: solución Flutter del negocio para web y tablet, app móvil del dueño y portal Vue para la administración de la plataforma. |
| 2.2 | 2026-09-22 | Definición de PostgreSQL/PostGIS en contenedor dentro del VPS, portal Vue 3 con Vite, API como único componente conectado a datos y UUID con prefijos. |

# Plan de construcción — amiva.pet

**Versión:** 1.1  
**Fecha:** 2026-09-25  
**Fuente:** `docs/02-requerimiento.md` versión 3.19 y `docs/03-casos-uso-mvp.md` versión 1.17  
**Estado:** aprobado para arrancar. La versión 1.1 reordena R0 y R1a por dependencias reales, confirma DbUp y deja preparados los repositorios del API, del negocio y del admin. La forma de trabajar está en `docs/01-estrategia-trabajo-paralelo.md`.

## 1. Propósito

Fija el orden en que se construye el MVP: etapas, features numeradas, repositorios que toca cada una y de qué dependen. El detalle de cada feature vive en la carpeta `docs/features/F-XXX-nombre/` **de cada repositorio** que la construye, con su `01-requerimiento.md` ya escrito.

## 2. Principios

1. **Primero el negocio, después el dueño.** Gracias a los clientes y mascotas provisionales (UC-47), una veterinaria puede operar completa sin que sus clientes tengan la app. Así se pone a trabajar una veterinaria piloto antes de construir la app del dueño.
2. **El API va adelante.** Cada feature se construye primero en el API con su contrato publicado; los clientes se construyen contra ese contrato y arrancan cuando la parte del API está cerrada.
3. **Una feature a la vez por repositorio**, y como máximo una feature que cruce varios repositorios en integración (sección 20 de la estrategia).
4. **Cada feature cierra con commit y push**, solo cuando el responsable lo indica (sección 6 de la estrategia).
5. **El esquema crece con las features.** Cada feature agrega en su migración las tablas del modelo de datos que necesita, con sus políticas RLS. No se crea la base completa de una vez.
6. **Cada repositorio es autosuficiente para construir** (sección 6 de este plan).

## 3. Equipo

| Repositorio | Responsable | Construye |
|---|---|---|
| `app-mascotas-api` | Alex | Claude (sesión de Alex) |
| `app-mascotas-admin` | Juan | Claude (sesión de Juan, en su laptop) |
| `app-mascotas-negocio` | Por asignar (Alex o Juan); mientras tanto aprueba Alex | Claude |
| `app-mascotas-usuario` | Por asignar; mientras tanto aprueba Alex | Claude (arranca en R1b) |

## 4. Decisiones técnicas

| Tema | Decisión | Estado |
|---|---|---|
| Plataforma del API | ASP.NET Core .NET 10, monolito modular con cortes verticales por feature (VSA) | Decidido (sección 15 del requerimiento) |
| Acceso a datos | Dapper sobre Npgsql, SQL escrito a mano dentro de cada feature | Decidido (requerimiento 3.18) |
| Esquema | Migraciones en SQL puro con **DbUp**, solo hacia adelante | Decidido (2026-09-25). Guía de estudio en `app-mascotas-api/docs/estudio/01-dbup.md` |
| Identidad | Keycloak; el API valida los tokens | Decidido |
| Aislamiento | RLS con contexto de sesión por transacción (`SET LOCAL`) y usuario de base de datos sin `BYPASSRLS` | Decidido (`docs/09-modelo-privacidad.md`) |
| Contrato | Problem Details con `codigo`, dinero como texto decimal, identificadores con prefijo, ramas `/negocio`, `/plataforma`, `/dueno` | Propuesto en `app-mascotas-api/docs/contratos/contrato-base.md`; se confirma en F-002 |
| App del negocio | Flutter (web y tablet) con `provider`, `go_router`, `dio` y `decimal` | Decidido (2026-09-25): se toma lo que funcionó en App-Ventas |
| Admin | Vue 3 + TypeScript + Vite, Pinia, tipos generados desde el OpenAPI | Propuesto; Juan lo confirma en F-003 |

## 5. Etapas y features

La numeración es global: F-016 es el punto de venta en el API y en el negocio. Cada repositorio solo tiene carpetas de las features que le tocan.

### Etapa 0 — Cimientos del API

| Feature | Qué incluye | Repos |
|---|---|---|
| F-001 Cimientos del API | Solución .NET, entorno local en el repo, DbUp, dominios, contexto de sesión, errores, identificadores, pruebas con PostgreSQL en contenedor, CI | api |
| F-002 Identidad y contexto de sesión | Keycloak de desarrollo, bloque 1 del modelo, roles y permisos sembrados, auditoría, resolución de sesión y permisos | api |

### R0 — Fundaciones

Resultado: la plataforma da de alta un negocio y ese negocio entra y administra a su equipo.

| Feature | Casos de uso | Repos |
|---|---|---|
| F-003 Planes, parámetros y tasas de IVA (y portal base del admin) | UC-05 (planes), UC-29 | api, admin |
| F-004 Alta de negocio y suscripción | UC-03, UC-05 | api, admin |
| F-005 Entrada del personal (y proyecto Flutter) | UC-02 | api, negocio |
| F-006 Personal y roles | UC-04 | api, negocio |

### R1a — Operación del negocio (piloto)

Resultado: una veterinaria real opera con clientes provisionales.

| Feature | Casos de uso | Repos |
|---|---|---|
| F-007 Catálogo de servicios | UC-18 | api, negocio |
| F-008 Horario, capacidad y políticas | UC-50, UC-44 | api, negocio |
| F-009 Clientes y mascotas provisionales | UC-47 | api, negocio |
| F-010 Agenda desde el negocio | UC-49, UC-21, UC-22, UC-23 | api, negocio |
| F-011 Documentos y archivos | UC-13 | api, negocio |
| F-012 Productos e inventario | UC-24, UC-43 | api, negocio |
| F-013 Expediente clínico y de estética | UC-14, UC-16, UC-10 y UC-17 (negocio) | api, negocio |
| F-014 Vacunas, prevención y certificados | UC-15 | api, negocio |
| F-015 Promociones | UC-25 | api, negocio |
| F-016 Punto de venta | UC-26, UC-27, UC-28 | api, negocio |
| F-017 Corte de caja | UC-51 | api, negocio |
| F-018 Consulta de la auditoría | UC-53 | api, negocio, admin |

Documentos (F-011) e inventario (F-012) van antes del expediente porque la consulta adjunta estudios, la vacuna del dueño exige la responsiva firmada y los medicamentos del inventario se descuentan al registrarse.

### R1b — App del dueño

| Feature | Casos de uso | Repos |
|---|---|---|
| F-019 Registro del dueño y textos legales | UC-01, UC-30 | api, admin, usuario |
| F-020 Mascotas del dueño y espacios | UC-06, UC-37, UC-39 | api, negocio, usuario |
| F-021 Vinculación y activación de provisionales | UC-07, UC-08, UC-09, UC-48 | api, negocio, usuario |
| F-022 Ficha, línea de tiempo y exportación | UC-10, UC-13, UC-17 (dueño) | api, usuario |
| F-023 Búsqueda de sucursales y solicitud de citas | UC-19, UC-20, UC-21, UC-23 | api, negocio, usuario |
| F-024 Usuarios autorizados y buzón | UC-45, UC-46 | api, usuario |
| F-025 Transferencia y fallecimiento | UC-11, UC-12, UC-35 | api, negocio, usuario |

### R1c — Cierre del MVP

| Feature | Casos de uso | Repos |
|---|---|---|
| F-026 Notificaciones y recordatorios | UC-33, UC-52 | api, negocio, usuario |
| F-027 Campañas | UC-32 | api, negocio, admin, usuario |
| F-029 Cobro de la suscripción (va antes que F-028) | UC-05, UC-34 | api, admin, negocio |
| F-028 Referidos y afiliación | UC-38, UC-40, UC-41, UC-42 | api, negocio, admin, usuario, página pública |
| F-030 Conservación y eliminación | UC-36 | api (bloqueada por PEN-32) |

El orden exacto por repositorio, con dependencias, está en el `docs/features/README.md` de cada uno.

## 6. Repositorios preparados

Los cuatro repositorios (`app-mascotas-api`, `app-mascotas-negocio`, `app-mascotas-admin` y `app-mascotas-usuario`) tienen desde el 2026-09-25:

| Archivo | Contenido |
|---|---|
| `CLAUDE.md` | Instrucciones completas para construir en ese repositorio: equipo, ciclo de la feature, definición de terminado, convenciones, reglas de seguridad y de commit |
| `README.md` | Propósito, arquitectura en una página, estructura prevista, cómo ejecutar |
| `docs/arquitectura.md` | Cómo se construye y qué queda por decidir en cada feature |
| `docs/decisiones.md` | Registro de decisiones técnicas |
| `docs/referencia/` | Copias de lo que ese repositorio necesita (modelo de datos, permisos, privacidad, inventario, contrato base o reglas de la plataforma), con la versión de la fuente |
| `docs/features/README.md` | Índice con orden, dependencias y estado |
| `docs/features/_plantillas/` | Plantillas de `02-analisis-situacion`, `03-plan-ejecucion`, `04-construido` y `05-verificacion` |
| `docs/features/F-XXX-.../01-requerimiento.md` | Requerimiento autosuficiente de cada feature: objetivo, alcance, permisos, reglas, datos, errores, criterios de aceptación, pruebas y decisiones pendientes |

Además, el API tiene `docs/contratos/contrato-base.md` y `docs/estudio/01-dbup.md`; el negocio y el usuario, `docs/diseno.md` con los tokens de la marca (el usuario no tiene prototipo propio); el usuario, las reglas del dueño y el estudio de enlaces universales en `docs/referencia/`.

**Regla de sincronización:** este repositorio sigue siendo la fuente de verdad. Si cambia un documento de aquí, se actualizan las copias de `docs/referencia/` y los `01-requerimiento.md` de las features no construidas en los repositorios afectados. Una feature ya construida que quede afectada se trata como solicitud de cambio.

## 7. Decisiones pendientes por feature

Cada `01-requerimiento.md` termina con las preguntas que su responsable debe contestar. Las que conviene resolver pronto:

| Feature | Pregunta |
|---|---|
| F-001 | Validación de forma (.NET 10 integrada o FluentValidation); explorador de OpenAPI; puerto del API |
| F-002 | Un realm de Keycloak o varios; nombres de los encabezados de contexto |
| F-003 | Precios de los planes; sucursales y campañas del Extendido; cargo del espacio pagado; tolerancia de no atención |
| F-004 | Cómo recibe su acceso el administrador inicial; quién agrega sucursales después del alta |
| F-006 | ¿Siempre al menos un administrador activo?; ¿cédula obligatoria? |
| F-010 | Capacidad con servicios de distintas categorías; ventana de cancelación para el negocio; intervalo de horarios |
| F-013 | **Medicamentos aplicados en consulta** (el modelo de datos no tiene dónde guardarlos); quién corrige; librería de PDF |
| F-016 | Varios medios de pago en una venta; cobrar citas no completadas; redondeo del IVA |
| F-019 | Identificador de la app; ¿prototipo visual de la app del dueño antes de construir? (iOS se prueba en la Mac de Juan; las cuentas de las tiendas se tramitan antes de staging: por ahora todo es desarrollo local) |
| F-028 | Qué repositorio construye la página pública `amiva.pet` (también sirve las páginas de `/i/` y `/a/` que redirigen a las tiendas) |

## 8. Dependencias externas

| Pendiente | Bloquea |
|---|---|
| PEN-32 Revisión legal | La salida a producción y F-030. No bloquea el desarrollo. |
| PEN-33 Datos de OVH | Staging y el Object Storage real (F-011 avanza con almacenamiento local). |

## 9. Siguiente paso

Arrancar **F-001** en `app-mascotas-api`: análisis de situación y plan, para aprobación de Alex, y después la construcción.

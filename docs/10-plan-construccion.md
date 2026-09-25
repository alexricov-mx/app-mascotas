# Plan de construcción — amiva.pet

**Versión:** 1.0  
**Fecha:** 2026-09-25  
**Fuente:** `docs/02-requerimiento.md` versión 3.18 y `docs/03-casos-uso-mvp.md` versión 1.16  
**Estado:** propuesta para aprobar. La forma de trabajar está en `docs/01-estrategia-trabajo-paralelo.md`.

## 1. Propósito

Fija el orden en que se construye el MVP: etapas, features numeradas, repositorios que toca cada una y de qué dependen. El detalle de cada feature (requerimiento, análisis, plan y resumen de lo construido) vive en la carpeta `docs/features/F-00X-nombre/` del repositorio donde se construye.

## 2. Principios

1. **Primero el negocio, después el dueño.** Gracias a los clientes y mascotas provisionales (UC-47), una veterinaria puede operar completa sin que sus clientes tengan la app. Así se pone a trabajar una veterinaria piloto antes de construir la app del dueño.
2. **El API va adelante.** Cada feature se construye primero en el API con su contrato publicado; los clientes se construyen contra ese contrato.
3. **Una feature a la vez por repositorio**, y como máximo una feature que cruce varios repositorios en integración (sección 20 de la estrategia).
4. **Cada feature cierra con push**, solo cuando el responsable lo indica (sección 6 de la estrategia).
5. **El esquema crece con las features.** Cada feature agrega en su migración las tablas del modelo de datos (`docs/07-modelo-datos.md`) que necesita, con sus políticas RLS. No se crea la base completa de una vez.

## 3. Equipo

| Repositorio | Responsable | Construye |
|---|---|---|
| `app-mascotas-api` | Alex | Claude (sesión de Alex) |
| `app-mascotas-admin` | Juan | Claude (sesión de Juan) |
| `app-mascotas-negocio` | Por asignar | Por asignar |
| `app-mascotas-usuario` | Por asignar | Por asignar |

## 4. Decisiones técnicas del API

| Tema | Decisión | Estado |
|---|---|---|
| Plataforma | ASP.NET Core .NET 10, monolito modular con cortes verticales por feature (VSA) | Decidido (sección 15 del requerimiento) |
| Acceso a datos | Dapper sobre Npgsql, SQL escrito a mano dentro de cada feature | Decidido (versión 3.18) |
| Esquema | Migraciones en SQL puro, versionadas en el repositorio del API | Decidido (versión 3.18) |
| Herramienta de migraciones | DbUp (recomendada) o Evolve | **Por confirmar** (sección 7) |
| Identidad | Keycloak; el API valida los tokens | Decidido |
| Aislamiento | RLS con contexto de sesión por transacción (`SET LOCAL`) y usuario de base de datos sin `BYPASSRLS` | Decidido (`docs/09-modelo-privacidad.md`) |
| Pruebas | xUnit y PostgreSQL real en contenedor (Testcontainers) para las pruebas de integración | Propuesto en F-001 |
| Integración continua | GitHub Actions: compilar, migrar una base vacía y correr las pruebas | Propuesto en F-001 |

## 5. Etapas y features

La numeración es global y se usa igual en todos los repositorios. Las features de R1b y R1c se pueden dividir o reordenar al llegar a ellas; las de la etapa 0 y R0 son el compromiso inmediato.

### Etapa 0 — Cimientos del API

Resultado: una base técnica probada sobre la que se apoya todo lo demás. Solo toca `app-mascotas-api`.

| Feature | Qué incluye | Casos de uso |
|---|---|---|
| **F-001 Cimientos del API** | Solución .NET 10 con estructura VSA; endpoint de salud; formato común de errores (Problem Details); configuración por ambiente sin secretos; herramienta de migraciones y primera migración (extensiones `postgis` y `citext`, dominios `importe`, `costo`, `porcentaje` y `peso_kg`, roles de base de datos); pruebas con PostgreSQL en contenedor; CI en GitHub Actions; `README.md`, `CLAUDE.md` y estructura `docs/` del repositorio; documento de estudio de Dapper, migraciones y RLS | — |
| **F-002 Identidad y contexto de sesión** | Realm de Keycloak para desarrollo (exportado al repositorio); validación de tokens; resolución del usuario; contexto de sesión (`app.tipo_sesion`, `app.usuario_id`, `app.negocio_id`, `app.sucursal_id`) fijado por transacción; tablas del bloque 1 (identidad y acceso), permisos y catálogos; prueba de aislamiento entre dos negocios; auditoría base | UC-02 (parte del API) |

### R0 — Fundaciones

Resultado: la plataforma da de alta un negocio y ese negocio entra y administra a su equipo.

| Feature | Qué incluye | Repositorios | Casos de uso |
|---|---|---|---|
| **F-003 Alta de negocio** | Login del administrador de plataforma; alta de negocio, sucursales y administrador del negocio; admin mínimo en Vue | API, admin | UC-03 |
| **F-004 Planes y suscripción** | Tablas del bloque 2; planes Básico y Extendido; parámetros de plataforma; prueba gratuita, vencimiento y bloqueo por impago (sin cobro todavía) | API, admin | UC-05, UC-29, UC-34 (parte) |
| **F-005 Entrada del personal** | Login del personal con elección de negocio y sucursal; esqueleto de `app.amiva.pet` (web y tablet) | API, negocio | UC-02 |
| **F-006 Personal y roles** | Invitación y alta del personal, asignación de roles por sucursal, matriz de permisos aplicada en el API | API, negocio | UC-04 |

### R1a — Operación del negocio (piloto)

Resultado: una veterinaria real opera con clientes provisionales. Aquí se reutiliza lo aprendido en App-Ventas (inventario, promociones, POS).

| Feature | Qué incluye | Casos de uso |
|---|---|---|
| F-007 Catálogo de servicios | Servicios, variantes, precios por sucursal e IVA | UC-18 |
| F-008 Horario, capacidad y políticas | Horario y capacidad por categoría; políticas del negocio | UC-50, UC-44 |
| F-009 Clientes y mascotas provisionales | Alta, búsqueda e invitación de activación (el envío real llega en R1c) | UC-47 |
| F-010 Agenda desde el negocio | Agendar, aceptar, iniciar, completar, no atendida, cancelar y reprogramar | UC-49, UC-21, UC-22, UC-23 |
| F-011 Expediente | Consulta clínica, signos vitales, servicio no clínico, consulta de la historia | UC-14, UC-16, UC-17 |
| F-012 Vacunas y prevención | Registro, próxima dosis y productos del dueño | UC-15 |
| F-013 Documentos | Archivos por streaming a través del API hacia Object Storage | UC-13 |
| F-014 Productos e inventario | Productos, movimientos, conteo físico y stock mínimo | UC-24, UC-43 |
| F-015 Promociones | Promociones compuestas con vigencia | UC-25 |
| F-016 Punto de venta | Venta, pagos, ticket en PDF, cancelación y auditoría de ventas; venta de espacios pagados | UC-26, UC-27, UC-28, UC-37 |
| F-017 Corte de caja | Corte diario e impresión | UC-51 |
| F-018 Auditoría del negocio | Consulta de la auditoría por el administrador | UC-53 |

Todas tocan API y negocio.

### R1b — App del dueño

Resultado: los clientes se suman a la plataforma.

| Feature | Casos de uso |
|---|---|
| F-019 Registro del dueño y textos legales | UC-01, UC-30 |
| F-020 Mascotas propias y activación de provisionales | UC-06, UC-48, UC-39 |
| F-021 Vinculación con negocios | UC-07, UC-08, UC-09 |
| F-022 Ficha y línea de tiempo | UC-10, UC-17 (dueño) |
| F-023 Búsqueda de sucursales y solicitud de citas | UC-19, UC-20 |
| F-024 Usuarios autorizados y buzón | UC-45, UC-46 |
| F-025 Transferencia y fallecimiento | UC-11, UC-12, UC-35 |

Tocan API, usuario y, cuando aplica, negocio y admin.

### R1c — Cierre del MVP

| Feature | Casos de uso |
|---|---|
| F-026 Notificaciones y recordatorios | UC-33, UC-52 |
| F-027 Campañas | UC-32 |
| F-028 Referidos y afiliación | UC-38, UC-40, UC-41, UC-42 |
| F-029 Cobro de la suscripción | UC-34 (resto) |
| F-030 Conservación y eliminación | UC-36 (depende de la revisión legal, PEN-32) |

## 6. Dependencias externas

| Pendiente | Bloquea |
|---|---|
| PEN-32 Revisión legal | La salida a producción y F-030. No bloquea el desarrollo. |
| PEN-33 Datos de OVH | Staging y el Object Storage real. F-013 puede avanzar en local si se decide un almacenamiento compatible para desarrollo; se decide en el análisis de F-013. |

## 7. Decisiones por confirmar

1. **Herramienta de migraciones.** Ambas ejecutan scripts SQL numerados y registran cuáles ya se aplicaron. Recomiendo **DbUp** porque se mantiene activa (versión 7.0.1 de `dbup-postgresql`, febrero de 2026); Evolve no publica una versión desde junio de 2023. Se confirma al aprobar F-001.
2. **Responsables de `app-mascotas-negocio` y `app-mascotas-usuario`.** El primero se necesita antes de F-005.

## 8. Siguiente paso

Arrancar F-001 en `app-mascotas-api`: escribir `docs/features/F-001-cimientos-api/01-requerimiento.md` y `02-analisis-situacion.md` para aprobación de Alex, y después el plan y la construcción.

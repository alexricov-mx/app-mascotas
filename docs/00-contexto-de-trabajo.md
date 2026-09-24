# Contexto de trabajo — amiva.pet

**Fecha:** 2026-09-24
**Propósito:** que una sesión nueva (o una persona) retome el trabajo sin depender de la conversación anterior. Léelo primero y después sigue el orden de la carpeta `docs/`.

---

## 1. Qué es este proyecto y de dónde viene

- **Producto:** amiva.pet, plataforma SaaS para veterinarias y estéticas de mascotas con app gratuita para el dueño. Nombre técnico provisional: AppMascotas.
- **Origen:** evoluciona de **App-Ventas** (`c:\Apps\App-Ventas`), una app Flutter offline para tablet Android, con SQLite, hecha para que niños vendan en eventos. App-Ventas **no se toca**: está en su versión 1.1.0 (Fase 10, promociones), ya usada en un evento real.
- **Intención del usuario:** construir un **proyecto nuevo**, online y multisesión, primero para mascotas y con diseño general para aplicarse después a otros tipos de negocio.

## 2. Documentos

**Vigentes (`docs/`), en orden de lectura:**

| Archivo | Contenido |
|---|---|
| `00-contexto-de-trabajo.md` | Este documento. |
| `01-estrategia-trabajo-paralelo.md` | Organización del trabajo: repositorios, ramas y documentos por feature. |
| `02-requerimiento.md` | **Única fuente de verdad** del producto (versión 3.6, 2026-09-24). |
| `03-casos-uso-mvp.md` | Casos de uso del MVP (versión 1.5, aprobados). |
| `04-pendientes.md` | Pendientes vigentes PEN-32 y PEN-33. |
| `05-inventario.md` | Operación de inventario aprobada; detalla la sección 10 del requerimiento. |
| `06-modelo-conceptual.md` | Modelo conceptual del dominio por bloques; bloque 1 (identidad y acceso) aprobado. |
| `estudio/` | Material de estudio: `01-enlaces-universales.md`. |

**Historial (`analisis/`), solo consulta:**

| Archivo | Contenido |
|---|---|
| `01-requerimiento.md` | Versión 1.1: primera consolidación con PEN-01 a PEN-31. |
| `02-respuesta-21092026.md` | Respuestas del usuario a esos pendientes. |
| `03-pendientes-22092026.md` | Revisión de la versión 1.1 contra las respuestas. |
| `03-requerimiento-2.md` | Versión 2.2 consolidada. |

El entorno local de desarrollo está en `infra/dev/` (PostgreSQL 18 + PostGIS y Keycloak en Podman, base `amiva-dev`). Los datos de OVH por llenar están en `infra/ovh/ficha-configuracion.md`.

Si algo no está en `docs/02-requerimiento.md`, se pregunta al usuario. Los documentos de `analisis/` no se citan como fuente ni se actualizan.

## 3. Reglas de trabajo acordadas

- **Solo revisión y análisis. No escribir código** hasta que el usuario lo pida.
- Ir **por partes**, un tema a la vez.
- Todo en español.
- Cambios grandes o que sobrescriban archivos: confirmar antes. La carpeta está bajo git.

## 4. Lo que aporta App-Ventas al proyecto nuevo

Reutilizar como conocimiento de dominio, no como código:

- **Comercio y cobro:** venta, cobro, cambio, cancelación de ventas.
- **Inventario:** las existencias solo cambian mediante movimientos de inventario.
- **Promociones** (Fase 10), respaldo y restauración, consulta de ventas.
- **Convenciones que valen la pena conservar:** todo en español; campos con nombre completo (`ventaId`, no `id`); toda operación multi-tabla en una transacción. A diferencia de App-Ventas, aquí el dinero lleva decimales.

Desde la versión 3.0 del requerimiento, inventario, promociones y punto de venta en sitio entran al MVP (R1). La experiencia funcional del POS se basa en App-Ventas; el prototipo `amiva-huella` solo sirve de referencia visual para web y tablet (sección 10 de `docs/02-requerimiento.md`).

**Lo que se pierde al pasar a online:** App-Ventas funciona sin internet. La plataforma nueva es solo online; no hay requisito de operar sin conexión. Si más adelante un tipo de negocio lo necesita (por ejemplo, vender en una feria), sería un requisito nuevo.

## 5. Arquitectura

Decidida en la sección 15 de `docs/02-requerimiento.md`:

- PostgreSQL con PostGIS en contenedor dentro del VPS.
- API ASP.NET Core .NET 10, monolito modular organizado en cortes verticales por feature (VSA); es el único componente que se conecta a PostgreSQL y a OVH Object Storage, y los archivos pasan por él en streaming.
- Identidad con Keycloak en contenedor.
- `app.amiva.pet` (negocio): Flutter Web y Flutter para tablet, mismo proyecto.
- App del dueño: Flutter para iOS y Android.
- `admin.amiva.pet` (plataforma): Vue 3 + TypeScript + Vite.
- Multi-tenant con `tenant_id` y RLS; identificadores internos con prefijo y UUID.
- Ambientes: desarrollo en Podman local (disponible), staging por configurar y producción en el VPS con la topología recomendada por OVH (sección 15.1).
- Identidad del usuario final: Google, Facebook y Apple, a través de Keycloak.
- Invitaciones con enlaces universales y App Links (sección 15.2).

Solo faltan los datos de infraestructura de OVH (PEN-33 de `docs/04-pendientes.md`).

La propuesta inicial (Neon, Vue 3 + Nuxt UI y un BFF en .NET) se sustituyó en la versión 2.2; ese análisis queda en el historial de git y en `analisis/01-requerimiento.md`.

## 6. Decisiones de fondo que conviene recordar

Están completas en `docs/02-requerimiento.md`. Las que más condicionan todo lo demás:

1. La mascota es la entidad central y pertenece al dueño (global), pero el expediente clínico pertenece a la empresa. Esta tensión define el modelo de datos.
2. Aislamiento por empresa: un negocio solo accede a una mascota tras la vinculación aceptada por el dueño, y nunca ve el nivel 3 generado por otro negocio (sección 6).
3. Historial completo gratis para el dueño; se cobra al negocio por capacidad operativa.
4. Núcleo genérico (tenancy, usuarios, suscripciones, agenda, servicios, comercio, inventario) separado del vertical de mascotas (expediente, carnet, ficha, línea de tiempo).
5. Monolito modular, PostgreSQL, multi-tenant desde el inicio.

## 7. Dónde nos quedamos

**Hecho:**
- Requerimiento cerrado en su versión 3.6 (`docs/02-requerimiento.md`); la 3.1 agrega referidos en el MVP y espacios de mascotas por tipo; la 3.2 resuelve reseñas, archivos, campañas, documentos legales, identidad y ambientes; la 3.3, transferencia de archivos, VSA y Keycloak; la 3.4, reglas de inventario; la 3.5, dinero con decimales; la 3.6, productos proporcionados por el dueño.
- Estrategia de trabajo en paralelo (`docs/01-estrategia-trabajo-paralelo.md`).
- Casos de uso del MVP aprobados (`docs/03-casos-uso-mvp.md`, UC-01 a UC-44).
- Pendientes restantes aislados en `docs/04-pendientes.md`; ninguno cambia la arquitectura base.
- Operación de inventario aprobada (`docs/05-inventario.md`).
- Entorno local funcionando en Podman: base `amiva-dev` (puerto 5433) y Keycloak (puerto 8080).
- No se ha escrito código ni se ha tocado App-Ventas.

**Siguiente paso:** continuar el modelo conceptual con el bloque 2 (suscripciones, planes y parámetros); el bloque 1 (identidad y acceso) ya está aprobado. Después: matriz de roles y permisos → modelo de privacidad → modelo de datos físico en PostgreSQL. No se empieza por tablas.

## 8. Cómo retomar en una sesión nueva

Abre el workspace que incluya esta carpeta y pide, por ejemplo:

> Lee `docs/00-contexto-de-trabajo.md` y los documentos de `docs/` en App-Mascotas. Vamos a continuar el modelo conceptual. No escribas código.

Si el workspace también incluye `c:\Apps\App-Ventas`, aclara que ese proyecto no se modifica.

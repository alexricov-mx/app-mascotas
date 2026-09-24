# Contexto de trabajo — Plataforma para el Cuidado de Mascotas

**Fecha:** 2026-09-21
**Propósito:** que una sesión nueva (o una persona) retome el trabajo sin depender de la conversación anterior. Léelo primero, luego `01-requerimiento.md`.

---

## 1. Qué es este proyecto y de dónde viene

- **Producto:** plataforma SaaS para negocios de servicios para mascotas (veterinarias primero) con app gratuita para el dueño. Nombre provisional: AppMascotas.
- **Origen:** evoluciona de **App-Ventas** (`c:\Apps\App-Ventas`), una app Flutter offline para tablet Android, con SQLite, hecha para que niños vendan en eventos. App-Ventas **no se toca**: está en su versión 1.1.0 (Fase 10, promociones), ya usada en un evento real.
- **Intención del usuario:** construir un **proyecto nuevo**, online y multisesión, primero para mascotas y con diseño general para aplicarse después a otros tipos de negocio.

## 2. Documento fuente de verdad

`01-requerimiento.md` (versión 1.1, 2026-09-21) consolida todas las decisiones, reglas de negocio, alcance por release y 31 pendientes (PEN-01 a PEN-31), e incorpora las respuestas de Alex a los pendientes. Sustituye a los documentos anteriores (mapa del producto, blueprints v1 y v2, requerimientos funcionales v0.3 y puntos pendientes), que el usuario retira manualmente de la carpeta. **No reintroducir ni citar los documentos viejos**: si algo no está en `01-requerimiento.md`, se pregunta al usuario.

El usuario dijo que la intención es "empezar desde cero" con un solo documento para no perder tiempo en qué se dijo antes y qué se dice ahora.

## 3. Reglas de trabajo acordadas

- **Solo revisión y análisis. No escribir código** hasta que el usuario lo pida.
- Ir **por partes**, un tema a la vez.
- Todo en español.
- La sección 15 de `01-requerimiento.md` (contradicciones resueltas) es solo para que el usuario verifique; puede borrarse tras revisarla.
- Cambios grandes o que sobrescriban archivos: confirmar antes. Esta carpeta **no es un repositorio git**, así que no hay historial que recupere un archivo sobrescrito. Conviene que el usuario decida si hace `git init` aquí.

## 4. Lo que aporta App-Ventas al proyecto nuevo

Reutilizar como conocimiento de dominio, no como código:

- **Comercio y cobro:** venta, cobro, cambio, cancelación de ventas.
- **Inventario:** las existencias solo cambian mediante movimientos de inventario.
- **Promociones** (Fase 10), respaldo y restauración, consulta de ventas.
- **Convenciones que valen la pena conservar:** todo en español; campos con nombre completo (`ventaId`, no `id`); dinero en enteros de pesos MXN sin decimales; toda operación multi-tabla en una transacción; el SQL solo en la capa de repositorios.

En el nuevo proyecto estos módulos corresponden a Comercio (R3), Inventario (R3 y R4) y Marketing (R5). El MVP (R1) no los incluye.

**Lo que se pierde al pasar a online:** App-Ventas funciona sin internet. La plataforma nueva es solo online; en las respuestas de Alex no apareció ningún requisito de operar sin conexión. Si más adelante un tipo de negocio lo necesita (por ejemplo, vender en una feria), sería un requisito nuevo.

## 5. Arquitectura en análisis (NO decidida)

Propuesta del usuario: PostgreSQL en **Neon**, frontend **Vue 3 + Nuxt UI**, y un **backend-for-frontend en .NET 10 (C#)** que publica el sitio, actúa como reverse proxy y aporta la seguridad. Detalle y estado en la sección 17.2 de `01-requerimiento.md`.

Conclusiones del análisis hecho hasta ahora:

- **Neon y archivos:** Neon sí ofrece almacenamiento de objetos compatible con S3, pero está en **beta** y solo en `aws-us-east-2` y `aws-eu-central-1` (sin región en México). Gratis durante la beta (5 GB por proyecto en el plan Free); después unos $0.023 USD por GB al mes. Los documentos clínicos deben conservarse mucho tiempo, así que el almacenamiento va detrás de una interfaz para poder cambiar de proveedor. Fuentes: https://neon.com/docs/storage/overview y https://neon.com/docs/guides/file-storage
- **Flutter y Neon:** no chocan si hay un API en medio. El móvil nunca debe conectarse directo a la base. Alex decidió que el dueño usa **app móvil** en el MVP (el negocio usa web), así que la app móvil es necesaria; Flutter sigue como tecnología propuesta y las plataformas (Android/iOS) están en PEN-07.
- **Nuxt:** trae su propio servidor (Nitro). Con el BFF en .NET habría dos servidores. Opciones: Nuxt como SPA servido estático detrás del BFF; SSR solo para perfiles públicos de negocios (R2, por SEO); o Vue con Vite sin Nuxt (Nuxt UI también funciona así).
- **BFF con cookie HttpOnly** sirve a la web, no a una app móvil, que necesita tokens. El API se diseña una vez y el BFF es la puerta de la web.
- **Identificadores:** los IDs tipo `VE-00001` desde una tabla de secuencia (App-Ventas) generan contención con muchos usuarios simultáneos. Para el sistema nuevo se sugiere UUID o `bigint`, con el prefijo solo como formato visible.
- **Aislamiento multi-tenant:** sugerencia `tenant_id` con seguridad a nivel de fila (RLS) en PostgreSQL, y no un esquema por cliente, que complica las migraciones (PEN-10, sin decidir).
- **Neon escala a cero:** la primera consulta tras inactividad puede tardar más.

## 6. Decisiones de fondo que conviene recordar

Están completas en `01-requerimiento.md`. Las que más condicionan todo lo demás:

1. La mascota es la entidad central y pertenece al dueño (global), pero el expediente clínico pertenece a la empresa. Esta tensión define el modelo de datos.
2. Aislamiento por empresa: otra empresa solo accede a una mascota tras una vinculación iniciada o consentida por el dueño.
3. Historial completo gratis para el dueño; se cobra al negocio por capacidad operativa.
4. Núcleo genérico (tenancy, usuarios, suscripciones, agenda, servicios, comercio, inventario) separado del vertical de mascotas (expediente, carnet, ficha, línea de tiempo).
5. Monolito modular, PostgreSQL, multi-tenant desde el inicio.

## 7. Dónde nos quedamos

**Hecho:**
- Se leyeron todos los documentos de definición y se consolidaron en `01-requerimiento.md`.
- Se verificó lo de Neon (almacenamiento y conexión desde móvil).
- Alex respondió los pendientes (archivo `Preguntas-Pendientes-concluido.md`) y esas respuestas ya están incorporadas en la versión 1.1. Quedaron resueltos, entre otros: primer alcance (veterinarias y estéticas), México como mercado (Guerrero, Puebla, Estado de México y CDMX), canal del dueño (app móvil; el negocio usa web), planes (Básico, Extendido, Tienda Digital), prueba de 10 días, ciclo de impago, una cita por mascota con aprobación obligatoria y variantes de precio en el MVP.
- No se ha escrito código ni se ha tocado App-Ventas.

**Siguiente paso:** resolver los 13 pendientes bloqueantes de la sección 16.1. Los que más condicionan el diseño:

| Pendiente | Tema |
|---|---|
| PEN-01 | Qué ve un negocio de lo que generó otro. Las respuestas de Alex chocan entre sí. |
| PEN-02 | Conservación y borrado: 5 años, 6 meses tras el impago, sin eliminación automática y 1 mes en fallecimiento no encajan. |
| PEN-03 | Límite de 2 mascotas y pago de 1 dólar (a quién aplica y cómo se cobra en la app). |
| PEN-07 | Plataformas de la app móvil y proveedores de login. |
| PEN-10 | Aislamiento técnico (`tenant_id` con RLS o esquemas). |

**Después de resolver los bloqueantes**, el orden recomendado es: modelo conceptual del dominio (separando núcleo y vertical) → matriz de roles y permisos → modelo de privacidad → casos de uso del MVP → modelo de datos físico en PostgreSQL. No se empieza por tablas.

## 8. Notas de estado de los archivos

- `01-requerimiento.md` sobrescribió una versión anterior del mismo nombre. Existe una copia del original en la carpeta temporal de la sesión anterior (`C:\Users\alex-rico\AppData\Local\Temp\claude\c--Apps-App-Ventas\e75cec5d-4951-416c-9078-8a7a5bd748f5\scratchpad\01-requerimiento.ORIGINAL.md`). Es temporal y puede desaparecer; el contenido vigente es el nuevo.
- Del blueprint v1 no se leyó nada, porque el v2 lo sustituía. Al retirar los documentos viejos deja de ser relevante.

## 9. Cómo retomar en una sesión nueva

Abre el workspace que incluya esta carpeta y pide, por ejemplo:

> Lee `00-contexto-de-trabajo.md` y `01-requerimiento.md` en App-Mascotas. Vamos a resolver los pendientes bloqueantes uno por uno. No escribas código.

Si el workspace también incluye `c:\Apps\App-Ventas`, aclara que ese proyecto no se modifica.

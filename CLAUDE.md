# Plataforma para el Cuidado de Mascotas (AppMascotas, nombre provisional) — guía para Claude

Proyecto nuevo: SaaS multi-tenant, online, para negocios de servicios para mascotas (veterinarias primero), con app gratuita para el dueño. Diseño con núcleo genérico para poder aplicarse después a otros tipos de negocio.

Nació de la app **App-Ventas** (`c:\Apps\App-Ventas`, Flutter, offline). App-Ventas **no se modifica** desde este proyecto.

## Lee primero

1. `00-contexto-de-trabajo.md`: de dónde viene el proyecto, análisis de arquitectura hecho, dónde nos quedamos y cómo retomar.
2. `01-requerimiento.md`: **única fuente de verdad**. Decisiones (D-), reglas de negocio (RN-), alcance por release, pendientes (PEN-).

Si algo no está en `01-requerimiento.md`, no se asume: se pregunta al usuario. No se citan ni se reconstruyen documentos anteriores.

## Estado actual

Fase de **definición**. Todavía no hay código, ni modelo de datos, ni stack decidido. La arquitectura de la sección 17.2 de `01-requerimiento.md` (Neon, Vue 3 + Nuxt UI, BFF en .NET 10) es una propuesta en análisis.

## Reglas de trabajo

- **No escribir código** hasta que el usuario lo pida. Por ahora solo revisión y análisis.
- Ir **por partes**, un tema a la vez.
- Todo en español (documentos y nombres de dominio).
- Cuando el usuario resuelva un pendiente o tome una decisión, actualizar `01-requerimiento.md` (mover el PEN- a decisión D- o regla RN- y ajustar las secciones afectadas) para que siga siendo la única fuente de verdad.
- Antes de sobrescribir o eliminar un archivo, confirmar. Esta carpeta puede no tener control de versiones.
- Cambios globales al equipo (instalaciones, actualizaciones) y `git push`: solo si el usuario lo pide.

## Orden de trabajo previsto

1. Resolver los pendientes bloqueantes (sección 16.1 de `01-requerimiento.md`).
2. Modelo conceptual del dominio, separando núcleo genérico y vertical de mascotas.
3. Matriz de roles y permisos.
4. Modelo de privacidad.
5. Casos de uso del MVP.
6. Modelo de datos físico en PostgreSQL.

No se empieza por las tablas.

## Convenciones heredadas de App-Ventas (por confirmar cuando empiece el código)

Son las que se usaron allí y valdría la pena conservar, pero no son decisión de este proyecto hasta que el usuario las confirme:

- Campos y modelos con nombre completo (`ventaId`, no `id`).
- Dinero en enteros de pesos MXN, sin decimales.
- Toda operación multi-tabla en una transacción.
- Las existencias solo cambian mediante movimientos de inventario.
- El SQL solo en la capa de repositorios.
- Identificadores: en App-Ventas eran secuenciales con prefijo (`VE-00001`); en un sistema multiusuario se sugiere UUID o `bigint`, dejando el prefijo solo como formato visible.

# amiva.pet (AppMascotas, nombre técnico provisional) — guía para Claude

Proyecto nuevo: SaaS multi-tenant, online, para veterinarias y estéticas de mascotas, con app gratuita para el dueño. Diseño con núcleo genérico para poder aplicarse después a otros tipos de negocio.

Nació de la app **App-Ventas** (`c:\Apps\App-Ventas`, Flutter, offline). App-Ventas **no se modifica** desde este proyecto; se usa como referencia funcional del punto de venta, inventario y promociones.

## Lee primero

1. `docs/00-contexto-de-trabajo.md`: de dónde viene el proyecto, dónde nos quedamos y cómo retomar.
2. `docs/01-estrategia-trabajo-paralelo.md`: cómo se organiza el trabajo (repositorios, ramas, documentos por feature).
3. `docs/02-requerimiento.md`: **única fuente de verdad** del producto (versión 3.15).
4. `docs/03-casos-uso-mvp.md`: casos de uso del MVP (aprobados).
5. `docs/04-pendientes.md`: pendientes vigentes (PEN-32 y PEN-33).
6. `docs/05-inventario.md`: operación de inventario aprobada; detalla la sección 10 del requerimiento.
7. `docs/06-modelo-conceptual.md`: modelo conceptual del dominio, aprobado completo (bloques 1 a 9).
8. `docs/07-modelo-datos.md`: modelo de datos físico en PostgreSQL (tablas, campos, tipos y relaciones), aprobado.

Si algo no está en `docs/02-requerimiento.md`, no se asume: se pregunta al usuario. No se citan ni se reconstruyen documentos anteriores.

Organización de carpetas:

- `docs/`: documentos vigentes, numerados en orden de lectura.
- `docs/estudio/`: material de estudio sobre técnicas que usa el proyecto (por ejemplo, enlaces universales).
- `infra/dev/`: entorno local de desarrollo (PostgreSQL + PostGIS y Keycloak en Podman).
- `infra/ovh/`: ficha con los datos de infraestructura de OVH por llenar.
- `analisis/`: historial de versiones anteriores del requerimiento y respuestas; solo consulta, no se actualizan.

## Estado actual

Fase de **definición**. El requerimiento está cerrado en su versión 3.15 y la arquitectura base está decidida (sección 15 de `docs/02-requerimiento.md`): PostgreSQL/PostGIS en contenedor dentro del VPS, API ASP.NET Core .NET 10 como monolito modular con cortes verticales por feature (VSA) y único acceso a datos, Keycloak para identidad, Flutter para el negocio (web y tablet) y para el dueño (iOS y Android), Vue 3 + TypeScript + Vite para `admin.amiva.pet` y OVH Object Storage. Hay modelo conceptual y modelo de datos aprobados, pero todavía no hay código de aplicación ni migraciones; solo existe el entorno local en Podman (`infra/dev/compose.yaml`): PostgreSQL con la base `amiva-dev` en el puerto 5433 y Keycloak en el 8080.

## Reglas de trabajo

- **No escribir código** hasta que el usuario lo pida. Por ahora solo revisión y análisis.
- Ir **por partes**, un tema a la vez.
- Todo en español (documentos y nombres de dominio).
- Cuando el usuario resuelva un pendiente o tome una decisión: actualizar la sección afectada de `docs/02-requerimiento.md`, quitar el pendiente de su sección 19 y de `docs/04-pendientes.md`, y registrar el cambio en el historial (sección 20).
- Antes de sobrescribir o eliminar un archivo, confirmar.
- Cambios globales al equipo (instalaciones, actualizaciones) y `git push`: solo si el usuario lo pide.

## Orden de trabajo previsto

1. ~~Aprobar los casos de uso del MVP~~ (hecho, 2026-09-24).
2. Modelo conceptual del dominio (`docs/06-modelo-conceptual.md`), por bloques, separando núcleo genérico y vertical de mascotas. Aprobado completo (bloques 1 a 9).
3. Modelo de datos físico en PostgreSQL (`docs/07-modelo-datos.md`), aprobado. Se adelantó a petición del usuario.
4. Matriz de roles y permisos.
5. Modelo de privacidad (políticas RLS y niveles de visibilidad sobre las tablas).

No se empieza por las tablas. Los pendientes de `docs/04-pendientes.md` no se resuelven por suposición: si alguno afecta una regla o entidad, se pregunta antes de seguir.

## Convenciones

Confirmadas (detalle en la sección 2 de `docs/07-modelo-datos.md`):

- Tablas y columnas en español, en `snake_case` y con nombre completo (`venta_id`, nunca `id`). En C# se usan los nombres de .NET y el API traduce.
- Llave primaria UUID versión 7 generada por el API; el prefijo visible (`ven_`, `mas_`) solo al exponerla.
- `negocio_id` en toda tabla con datos de un negocio, con RLS.
- Dinero con dominios: `importe` (2 decimales) y `costo` (4 decimales).
- Estados como `text` con `CHECK`.
- Toda operación multi-tabla en una transacción.

De App-Ventas ya no aplican:

- "El SQL solo en la capa de repositorios": con cortes verticales, el acceso a datos vive dentro de cada feature.
- "Dinero en enteros sin decimales": aquí el dinero lleva dos decimales y el costo unitario cuatro (sección 10 del requerimiento).

Ya adoptadas en el requerimiento: las existencias solo cambian mediante movimientos de inventario (sección 10) y los identificadores internos llevan prefijo y UUID (sección 15).

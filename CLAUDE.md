# amiva.pet (AppMascotas, nombre técnico provisional) — guía para Claude

Proyecto nuevo: SaaS multi-tenant, online, para veterinarias y estéticas de mascotas, con app gratuita para el dueño. Diseño con núcleo genérico para poder aplicarse después a otros tipos de negocio.

Nació de la app **App-Ventas** (`c:\Apps\App-Ventas`, Flutter, offline). App-Ventas **no se modifica** desde este proyecto; se usa como referencia funcional del punto de venta, inventario y promociones.

## Lee primero

1. `docs/00-contexto-de-trabajo.md`: de dónde viene el proyecto, dónde nos quedamos y cómo retomar.
2. `docs/01-estrategia-trabajo-paralelo.md`: cómo se organiza el trabajo (repositorios, ramas, documentos por feature).
3. `docs/02-requerimiento.md`: **única fuente de verdad** del producto (versión 3.14).
4. `docs/03-casos-uso-mvp.md`: casos de uso del MVP (aprobados).
5. `docs/04-pendientes.md`: pendientes vigentes (PEN-32 y PEN-33).
6. `docs/05-inventario.md`: operación de inventario aprobada; detalla la sección 10 del requerimiento.
7. `docs/06-modelo-conceptual.md`: modelo conceptual del dominio por bloques (bloques 1 a 8 aprobados).

Si algo no está en `docs/02-requerimiento.md`, no se asume: se pregunta al usuario. No se citan ni se reconstruyen documentos anteriores.

Organización de carpetas:

- `docs/`: documentos vigentes, numerados en orden de lectura.
- `docs/estudio/`: material de estudio sobre técnicas que usa el proyecto (por ejemplo, enlaces universales).
- `infra/dev/`: entorno local de desarrollo (PostgreSQL + PostGIS y Keycloak en Podman).
- `infra/ovh/`: ficha con los datos de infraestructura de OVH por llenar.
- `analisis/`: historial de versiones anteriores del requerimiento y respuestas; solo consulta, no se actualizan.

## Estado actual

Fase de **definición**. El requerimiento está cerrado en su versión 3.14 y la arquitectura base está decidida (sección 15 de `docs/02-requerimiento.md`): PostgreSQL/PostGIS en contenedor dentro del VPS, API ASP.NET Core .NET 10 como monolito modular con cortes verticales por feature (VSA) y único acceso a datos, Keycloak para identidad, Flutter para el negocio (web y tablet) y para el dueño (iOS y Android), Vue 3 + TypeScript + Vite para `admin.amiva.pet` y OVH Object Storage. Todavía no hay código de aplicación ni modelo de datos; solo existe el entorno local en Podman (`infra/dev/compose.yaml`): PostgreSQL con la base `amiva-dev` en el puerto 5433 y Keycloak en el 8080.

## Reglas de trabajo

- **No escribir código** hasta que el usuario lo pida. Por ahora solo revisión y análisis.
- Ir **por partes**, un tema a la vez.
- Todo en español (documentos y nombres de dominio).
- Cuando el usuario resuelva un pendiente o tome una decisión: actualizar la sección afectada de `docs/02-requerimiento.md`, quitar el pendiente de su sección 19 y de `docs/04-pendientes.md`, y registrar el cambio en el historial (sección 20).
- Antes de sobrescribir o eliminar un archivo, confirmar.
- Cambios globales al equipo (instalaciones, actualizaciones) y `git push`: solo si el usuario lo pide.

## Orden de trabajo previsto

1. ~~Aprobar los casos de uso del MVP~~ (hecho, 2026-09-24).
2. Modelo conceptual del dominio (`docs/06-modelo-conceptual.md`), por bloques, separando núcleo genérico y vertical de mascotas. Bloques 1 a 5 aprobados (identidad y acceso; suscripciones, planes y parámetros; mascotas, propiedad y espacios; vinculación, privacidad y clientes provisionales; expediente, prevención y documentos; servicios, agenda y citas; inventario, promociones y ventas; referidos); sigue el bloque 9 (notificaciones, reseñas, campañas y auditoría).
3. Matriz de roles y permisos.
4. Modelo de privacidad.
5. Modelo de datos físico en PostgreSQL.

No se empieza por las tablas. Los pendientes de `docs/04-pendientes.md` no se resuelven por suposición: si alguno afecta una regla o entidad, se pregunta antes de seguir.

## Convenciones heredadas de App-Ventas (por confirmar cuando empiece el código)

Son las que se usaron allí y valdría la pena conservar, pero no son decisión de este proyecto hasta que el usuario las confirme:

- Campos y modelos con nombre completo (`ventaId`, no `id`).
- Toda operación multi-tabla en una transacción.

Ya no aplican:

- "El SQL solo en la capa de repositorios": con cortes verticales, el acceso a datos vive dentro de cada feature.
- "Dinero en enteros sin decimales": aquí el dinero lleva dos decimales y el costo unitario cuatro (sección 10 del requerimiento).

Ya adoptadas en el requerimiento: las existencias solo cambian mediante movimientos de inventario (sección 10) y los identificadores internos llevan prefijo y UUID (sección 15).

# amiva.pet (AppMascotas, nombre técnico provisional) — guía para Claude

Proyecto nuevo: SaaS multi-tenant, online, para veterinarias y estéticas de mascotas, con app gratuita para el dueño. Diseño con núcleo genérico para poder aplicarse después a otros tipos de negocio.

Nació de la app **App-Ventas** (`c:\Apps\App-Ventas`, Flutter, offline). App-Ventas **no se modifica** desde este proyecto; se usa como referencia funcional del punto de venta, inventario y promociones.

## Lee primero

1. `docs/00-contexto-de-trabajo.md`: de dónde viene el proyecto, dónde nos quedamos y cómo retomar.
2. `docs/01-estrategia-trabajo-paralelo.md`: cómo se organiza el trabajo (repositorios, ramas, documentos por feature).
3. `docs/02-requerimiento.md`: **única fuente de verdad** del producto (versión 3.19).
4. `docs/03-casos-uso-mvp.md`: casos de uso del MVP (aprobados).
5. `docs/04-pendientes.md`: pendientes vigentes (PEN-32 y PEN-33).
6. `docs/05-inventario.md`: operación de inventario aprobada; detalla la sección 10 del requerimiento.
7. `docs/06-modelo-conceptual.md`: modelo conceptual del dominio, aprobado completo (bloques 1 a 9).
8. `docs/07-modelo-datos.md`: modelo de datos físico en PostgreSQL (tablas, campos, tipos y relaciones), aprobado.
9. `docs/08-matriz-roles-permisos.md`: permisos de cada rol del negocio, aprobada.
10. `docs/09-modelo-privacidad.md`: reglas de aislamiento, acceso a mascotas y visibilidad sobre las tablas, aprobado.
11. `docs/10-plan-construccion.md`: etapas y features numeradas del MVP, con repositorios y dependencias.

Si algo no está en `docs/02-requerimiento.md`, no se asume: se pregunta al usuario. No se citan ni se reconstruyen documentos anteriores.

Organización de carpetas:

- `docs/`: documentos vigentes, numerados en orden de lectura.
- `docs/estudio/`: material de estudio sobre técnicas que usa el proyecto (por ejemplo, enlaces universales).
- `infra/dev/`: solo un aviso; el entorno local (PostgreSQL + PostGIS y Keycloak en Podman) vive en `app-mascotas-api/infra/dev/` desde el 2026-09-25.
- `infra/ovh/`: ficha con los datos de infraestructura de OVH por llenar.
- `analisis/`: historial de versiones anteriores del requerimiento y respuestas; solo consulta, no se actualizan.

## Estado actual

**Construcción en marcha** desde el 2026-09-25. La definición se cerró el 2026-09-24 y el plan de construcción está en `docs/10-plan-construccion.md`; la siguiente feature es F-001 (cimientos del API) en `app-mascotas-api`. El requerimiento está en su versión 3.19 y la arquitectura base está decidida (sección 15 de `docs/02-requerimiento.md`): PostgreSQL/PostGIS en contenedor dentro del VPS, API ASP.NET Core .NET 10 como monolito modular con cortes verticales por feature (VSA) y único acceso a datos, Keycloak para identidad, Flutter para el negocio (web y tablet) y para el dueño (iOS y Android), Vue 3 + TypeScript + Vite para `admin.amiva.pet` y OVH Object Storage. El acceso a datos del API es Dapper con migraciones en SQL puro con DbUp (versión 3.18). Los repositorios `app-mascotas-api`, `app-mascotas-negocio`, `app-mascotas-admin` y `app-mascotas-usuario` están preparados para construir con su propio `CLAUDE.md`, documentos de referencia y el `01-requerimiento.md` de cada feature (sección 6 del plan); si se cambia un documento de producto aquí, se actualizan esas copias. Hay modelo conceptual y modelo de datos aprobados. F-001 (cimientos del API) está construida en `app-mascotas-api`; el entorno local vive en `app-mascotas-api/infra/dev/`: PostgreSQL con la base `amiva-dev` en el puerto 5433 y Keycloak en el 8080 con el realm `amiva-dev`.

## Reglas de trabajo

- Este repositorio es **documentación de producto**: aquí no se escribe código. El código vive en los cuatro repositorios `app-mascotas-*` (en `C:\Apps`), cada uno con su propio `CLAUDE.md`.
- Equipo: Alex (responsable del API, trabaja con esta sesión de Claude) y Juan (responsable del admin, con su propia sesión de Claude en su laptop). Claude escribe código, pruebas y documentos; el responsable revisa, prueba e indica cuándo hacer commit y push.
- Una sola rama (`main`) en todos los repositorios; commit y push al cerrar cada feature, solo cuando el responsable lo indica (sección 6 de `docs/01-estrategia-trabajo-paralelo.md`).
- Ir **por partes**, un tema a la vez.
- Todo en español (documentos y nombres de dominio).
- Cuando el usuario resuelva un pendiente o tome una decisión: actualizar la sección afectada de `docs/02-requerimiento.md`, quitar el pendiente de su sección 19 y de `docs/04-pendientes.md`, y registrar el cambio en el historial (sección 20).
- Antes de sobrescribir o eliminar un archivo, confirmar.
- Cambios globales al equipo (instalaciones, actualizaciones) y `git push`: solo si el usuario lo indica.

## Orden de trabajo previsto

1. ~~Aprobar los casos de uso del MVP~~ (hecho, 2026-09-24).
2. Modelo conceptual del dominio (`docs/06-modelo-conceptual.md`), por bloques, separando núcleo genérico y vertical de mascotas. Aprobado completo (bloques 1 a 9).
3. Modelo de datos físico en PostgreSQL (`docs/07-modelo-datos.md`), aprobado. Se adelantó a petición del usuario.
4. Matriz de roles y permisos (`docs/08-matriz-roles-permisos.md`), aprobada.
5. Modelo de privacidad (`docs/09-modelo-privacidad.md`), aprobado.
6. ~~Planear la construcción~~ (hecho, 2026-09-25): `docs/10-plan-construccion.md`.
7. Construir por features, empezando por F-001 en `app-mascotas-api`.

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

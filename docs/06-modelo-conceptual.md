# Modelo conceptual del dominio — amiva.pet

**Versión:** 0.3  
**Fecha:** 2026-09-24  
**Fuente:** `docs/02-requerimiento.md` versión 3.7 y `docs/03-casos-uso-mvp.md` versión 1.6 (aprobados)  
**Estado:** en construcción por bloques. Cada bloque se revisa y aprueba antes de pasar al siguiente.

## 1. Propósito y alcance

Describe **qué cosas existen en el dominio, cómo se relacionan y qué reglas las gobiernan**, sin decidir todavía tablas, columnas, tipos ni índices. Eso corresponde al modelo físico, que se hará después.

Convenciones del documento:

- Los nombres de entidad van en singular y en español (`Negocio`, `Sucursal`).
- Las relaciones se leen en ambos sentidos: "un negocio tiene una o más sucursales; una sucursal pertenece a un solo negocio".
- Cada entidad indica si es del **núcleo genérico** (reutilizable en otros tipos de negocio) o del **vertical de mascotas**.
- Los diagramas usan Mermaid y solo muestran entidades y relaciones.

## 2. Bloques

| # | Bloque | Casos de uso | Capa | Estado |
|---|---|---|---|---|
| 1 | Identidad y acceso | UC-01 a UC-05, UC-44 | Núcleo | **Aprobado** (2026-09-24) |
| 2 | Suscripciones, planes y parámetros | UC-05, UC-29, UC-34 | Núcleo | **Aprobado** (2026-09-24) |
| 3 | Mascotas, propiedad y espacios | UC-06, UC-11, UC-12, UC-37, UC-39 | Vertical | Pendiente |
| 4 | Vinculación, privacidad y consentimientos | UC-07 a UC-10, UC-30 | Núcleo + vertical | Pendiente |
| 5 | Expediente, prevención y documentos | UC-13 a UC-17 | Vertical | Pendiente |
| 6 | Servicios, agenda y citas | UC-18 a UC-23 | Núcleo | Pendiente |
| 7 | Inventario, promociones y ventas | UC-24 a UC-28, UC-43 | Núcleo | Pendiente |
| 8 | Referidos | UC-38, UC-40 a UC-42 | Núcleo | Pendiente |
| 9 | Notificaciones, reseñas, campañas y auditoría | UC-31 a UC-33 | Núcleo | Pendiente |

Plan, Suscripción y Entitlement se mencionan en el bloque 1 solo en lo que afecta al acceso; su modelo completo es el bloque 2.

---

## 3. Bloque 1 — Identidad y acceso

### 3.1 Qué resuelve

- Quién es cada persona que entra al sistema y cómo se autentica.
- A qué negocio y a qué sucursales tiene acceso, y con qué permisos.
- Cómo se separan los datos de cada negocio (multi-tenant).
- Cómo se distingue al usuario final, al personal del negocio y al administrador de plataforma.

### 3.2 Separación entre Keycloak y amiva.pet

| Responsabilidad | Dónde vive |
|---|---|
| Autenticación: contraseña, Google, Facebook, Apple, verificación de correo, sesiones y tokens | **Keycloak** |
| Vinculación de cuentas de Google, Facebook y Apple a una misma persona | **Keycloak** |
| Identidad interna de la persona dentro del dominio | **amiva.pet** (`Usuario`, ligado al identificador de Keycloak) |
| Autorización: a qué negocio y sucursal accede y con qué rol y permisos | **amiva.pet** |

**Por qué la autorización no vive en Keycloak:** los permisos de amiva.pet dependen del negocio y de la sucursal (una persona puede ser veterinaria en una sucursal y administradora en otra, o trabajar en dos negocios). Los roles de Keycloak son globales y no modelan bien esa combinación. Keycloak dice **quién eres**; amiva.pet decide **qué puedes hacer y dónde**.

Consecuencia: la entidad `IdentidadExterna` de la sección 18 del requerimiento **no se modela en amiva.pet**. Las cuentas de Google, Facebook y Apple las guarda Keycloak como identidades federadas; amiva.pet solo guarda el identificador de Keycloak del usuario.

### 3.3 Entidades

| Entidad | Capa | Qué es | Reglas principales |
|---|---|---|---|
| **Usuario** | Núcleo | Una persona con cuenta en el sistema. Única en toda la plataforma. | Se liga 1 a 1 con una cuenta de Keycloak. Correo único y verificado. Estados: `pendiente de verificación`, `activo`, `bloqueado`, `eliminado` (lógico). Una misma persona puede ser dueño de mascotas y, además, personal de uno o varios negocios, con la misma cuenta. |
| **PerfilUsuarioFinal** | Vertical | Datos de la persona como dueño o usuario autorizado: nombre visible, teléfono, preferencias de notificación. | Se crea al registrarse en la app móvil (UC-01). Se liga a los espacios de mascotas y al código de invitación. |
| **Negocio** | Núcleo | La empresa cliente de la plataforma, identificada por RFC. **Es el tenant.** | RFC único. Lo da de alta solo el administrador de plataforma (UC-03). Toda la información operativa lleva su identificador (`negocioId`) como llave de aislamiento (RLS). Tiene políticas de negocio (UC-44). |
| **Sucursal** | Núcleo | Ubicación física donde opera el negocio. | Pertenece a un solo negocio. Tiene ubicación geográfica (PostGIS), horarios y estado (`activa`, `inactiva`). Es la unidad de inventario, agenda y ventas. |
| **MiembroNegocio** | Núcleo | La relación de un usuario con un negocio como personal. Equivale a `UsuarioTenant` del requerimiento. | Un usuario puede ser miembro de varios negocios. Estados: `activo`, `desactivado`. Lo crea el administrador de negocio (UC-04) o el de plataforma en el alta (UC-03). Desactivarlo corta el acceso a ese negocio sin afectar su cuenta ni sus otros negocios. |
| **AsignacionRol** | Núcleo | Qué rol tiene un miembro y dónde: en todo el negocio o en una sucursal concreta. | Un miembro puede tener varias asignaciones (por ejemplo, Veterinario en la sucursal Centro y Recepción en la sucursal Norte). Una asignación de alcance negocio aplica a todas sus sucursales. |
| **Rol** | Núcleo | Conjunto de permisos con nombre: Administrador de negocio, Recepción, Veterinario, Estilista. | Catálogo definido por la plataforma en el MVP. |
| **Permiso** | Núcleo | Acción concreta que se puede autorizar, por ejemplo `cita.aceptar`, `venta.cancelar`, `expediente.consultar`. | La matriz rol-permiso es el siguiente paso del plan de trabajo (matriz de roles y permisos). |
| **Profesional** | Núcleo | Datos profesionales de un miembro que presta servicios: especialidad y cédula profesional si aplica. | Solo para miembros que atienden citas o firman registros clínicos. Se usa en agenda y expediente. |
| **UsuarioPlataforma** | Núcleo | Marca a un usuario como administrador de `admin.amiva.pet`. | Separado por completo de los negocios: no es miembro de ningún negocio por serlo. Todas sus acciones se auditan. |
| **PoliticaNegocio** | Núcleo | Configuración que aplica por igual a todas las sucursales de un negocio. | En el MVP: aceptar productos proporcionados por el dueño (activada por defecto). Cambios auditados. |
| **Auditoria** | Núcleo | Registro de quién hizo qué, cuándo, dónde y sobre qué. | Transversal a todos los bloques. En este bloque: altas, bloqueos, asignaciones de rol, cambios de política, inicios de sesión de plataforma. |

### 3.4 Relaciones

```mermaid
erDiagram
    Usuario ||--o| PerfilUsuarioFinal : "tiene (si usa la app)"
    Usuario ||--o{ MiembroNegocio : "trabaja en"
    Usuario ||--o| UsuarioPlataforma : "puede ser"
    Negocio ||--|{ Sucursal : "tiene"
    Negocio ||--o{ MiembroNegocio : "tiene personal"
    Negocio ||--o{ PoliticaNegocio : "define"
    MiembroNegocio ||--|{ AsignacionRol : "recibe"
    AsignacionRol }o--|| Rol : "de"
    AsignacionRol }o--o| Sucursal : "en (vacío = todo el negocio)"
    Rol }o--o{ Permiso : "agrupa"
    MiembroNegocio ||--o| Profesional : "puede ser"
```

Lectura:

- Un **usuario** puede tener perfil de usuario final, ser miembro de cero o más negocios y, aparte, ser administrador de plataforma.
- Un **negocio** tiene una o más sucursales y cero o más miembros.
- Un **miembro** tiene una o más asignaciones de rol; cada una apunta a un rol y, opcionalmente, a una sucursal.
- Un **rol** agrupa muchos permisos y un permiso puede estar en muchos roles.

### 3.5 Cómo se decide el acceso

Para cada petición, el API:

1. Valida el token de Keycloak y obtiene el `Usuario`.
2. Si el usuario opera como personal, toma el **negocio y la sucursal activos** que eligió en `app.amiva.pet` o la tablet.
3. Verifica que sea `MiembroNegocio` activo de ese negocio.
4. Reúne los permisos de sus asignaciones que aplican a esa sucursal (las de la sucursal más las de alcance negocio).
5. Verifica el permiso que exige la operación.
6. Verifica el estado de la suscripción del negocio (bloque 2): en `solo lectura` rechaza escrituras; en `sin acceso` rechaza todo.
7. Fija el negocio en la sesión de base de datos para que RLS filtre los datos.

Para el usuario final, el acceso a una mascota o a un registro depende de la propiedad y la vinculación (bloques 3 y 4), no de roles.

### 3.6 Selección de negocio y sucursal

Una persona que trabaja en más de un negocio, o en varias sucursales, elige al entrar en cuál va a operar. El cambio de negocio o sucursal no requiere cerrar sesión. La sucursal activa determina agenda, inventario y POS.

### 3.7 Ciclos de vida

**Usuario:**

```
pendiente de verificación ──verifica correo──▶ activo ◀──desbloquea── bloqueado
                                                 │  ──bloquea──────────▶
                                                 └──solicita eliminación──▶ eliminado (lógico)
```

**MiembroNegocio:** `activo` ⇄ `desactivado`. No se elimina, para conservar la trazabilidad de lo que registró.

### 3.8 Configuración de Keycloak

| Elemento | Propuesta |
|---|---|
| Realm | `amiva`, uno solo para todas las personas. |
| Clientes | `app-usuario` (app móvil), `app-negocio` (Flutter web y tablet), `admin` (portal de plataforma), `api` (validación de tokens). |
| Proveedores de identidad | Google, Facebook y Apple, habilitados solo para `app-usuario`. |
| Usuario y contraseña | Para `app-negocio` y `admin`. |
| Segundo factor | Obligatorio para `admin`; opcional para administradores de negocio en el MVP. |
| Roles en Keycloak | Ninguno de negocio. Solo se usa para autenticar. |

### 3.9 Decisiones confirmadas

| # | Decisión |
|---|---|
| 1 | Una sola cuenta por persona: la misma cuenta sirve para la app del dueño y para `app.amiva.pet`. |
| 2 | El negocio es el tenant; no hay entidad `Tenant` aparte. |
| 3 | Roles fijos en el MVP (Administrador de negocio, Recepción, Veterinario, Estilista); roles propios del negocio en una versión posterior. |
| 4 | Un rol puede asignarse a una sucursal concreta o a todo el negocio. |
| 5 | El administrador de plataforma no es miembro de ningún negocio ni ve datos operativos, salvo las funciones de soporte que se definan. |
| 6 | Segundo factor obligatorio para administradores de plataforma; opcional para administradores de negocio en el MVP. |
| 7 | Un solo realm de Keycloak (`amiva`) para todos, con segundo factor en el cliente `admin`. |

---

## 4. Bloque 2 — Suscripciones, planes y parámetros

### 4.1 Qué resuelve

- Qué plan tiene cada negocio, qué incluye y cuánto cuesta.
- En qué estado está su suscripción y qué puede hacer en cada estado (operar, solo leer, nada).
- Qué se le cobra cada periodo, qué pagó y qué meses tiene a favor por referidos.
- Dónde viven los valores configurables de la plataforma y cómo cambian sin afectar el pasado.

En el MVP **el cobro es manual**: la plataforma genera los cargos, el negocio paga por fuera y el administrador de plataforma registra el pago.

### 4.2 Entidades

| Entidad | Capa | Qué es | Reglas principales |
|---|---|---|---|
| **Plan** | Núcleo | Oferta comercial: Básico, Extendido, Tienda Digital. | Estados: `disponible`, `oculto` (existe pero no se ofrece; Tienda Digital hasta que exista el módulo), `retirado` (ya no se vende; quien lo tiene lo conserva). |
| **PrecioPlan** | Núcleo | Precio mensual del plan y precio de cada sucursal adicional, con vigencia. | Un cambio de precio crea un precio nuevo con fecha de inicio; no modifica cargos ya generados. |
| **Entitlement** | Núcleo | Algo que el plan habilita o limita. En el MVP: sucursales incluidas, si admite sucursales adicionales y número de campañas activas. | Se define por plan. El API lo consulta para permitir o negar una función. Es la única forma de diferenciar planes; no se escriben reglas "si el plan es X" en el código. |
| **Suscripcion** | Núcleo | El contrato vigente de un negocio con la plataforma. | Una por negocio. Guarda plan actual, estado y fechas del periodo actual. La prueba se usa una sola vez por RFC. |
| **CambioSuscripcion** | Núcleo | Historial de la suscripción: cambios de plan y de estado. | Cada cambio guarda estado o plan anterior y nuevo, fecha, motivo y quién lo hizo (usuario o proceso). |
| **PeriodoFacturacion** | Núcleo | Un mes de servicio de un negocio. | Estados: `abierto`, `por pagar`, `pagado`, `bonificado` (cubierto con un mes a favor). Dos periodos pagados consecutivos es la condición del referido de negocio (bloque 8). |
| **Cargo** | Núcleo | Cada concepto que se cobra en un periodo. | Tipos: `plan`, `sucursal adicional`, `espacio pagado de mascota`. Guarda importe con dos decimales y el precio vigente al generarse. |
| **PagoSuscripcion** | Núcleo | Pago registrado manualmente por el administrador de plataforma. | Fecha, importe, medio, referencia y quién lo registró. Un pago puede cubrir uno o varios periodos. |
| **MovimientoMesAFavor** | Núcleo | Libro de meses gratuitos del negocio: ganados por referidos y consumidos en periodos. | Igual que el inventario: el saldo es la suma de los movimientos y no se edita. Los meses no caducan. |
| **CargoEspacioMascota** | Vertical | Registro de un espacio pagado vendido por una sucursal (UC-37). | Guarda sucursal, usuario final, fecha e importe vigente. Se incorpora como cargo al periodo del negocio. |
| **Parametro** | Núcleo | Valor configurable de la plataforma, identificado por una clave. | Tiene tipo (número, días, horas, importe, sí/no, lista). Lo cambia solo el administrador de plataforma. |
| **VersionParametro** | Núcleo | Cada valor que ha tenido un parámetro. | Guarda valor, vigente desde, quién lo cambió y motivo. Los procesos usan el valor vigente en el momento en que ocurre el hecho. |

Las políticas por negocio (`PoliticaNegocio`, bloque 1) no son parámetros de plataforma: las decide cada negocio.

### 4.3 Relaciones

```mermaid
erDiagram
    Plan ||--|{ PrecioPlan : "tiene precios"
    Plan ||--|{ Entitlement : "habilita"
    Negocio ||--|| Suscripcion : "tiene"
    Suscripcion }o--|| Plan : "de"
    Suscripcion ||--o{ CambioSuscripcion : "registra"
    Suscripcion ||--o{ PeriodoFacturacion : "se divide en"
    PeriodoFacturacion ||--o{ Cargo : "incluye"
    PeriodoFacturacion }o--o{ PagoSuscripcion : "cubierto por"
    Negocio ||--o{ MovimientoMesAFavor : "acumula"
    MovimientoMesAFavor }o--o| PeriodoFacturacion : "se consume en"
    Sucursal ||--o{ CargoEspacioMascota : "vende"
    CargoEspacioMascota }o--|| Cargo : "se cobra como"
    Parametro ||--|{ VersionParametro : "tiene valores"
```

### 4.4 Ciclo de vida de la suscripción

```mermaid
stateDiagram-v2
    [*] --> Prueba : alta del negocio (UC-03)
    Prueba --> Activa : registra pago
    Prueba --> Gracia : vence la prueba sin pago
    Activa --> Activa : periodo pagado o bonificado
    Activa --> Gracia : vence el periodo sin pago
    Gracia --> Activa : registra pago
    Gracia --> SoloLectura : pasan los días de gracia
    SoloLectura --> Activa : registra pago
    SoloLectura --> SinAcceso : pasan los días de solo lectura
    SinAcceso --> Activa : registra pago durante el resguardo
    SinAcceso --> Eliminada : termina el resguardo
    Eliminada --> [*]
```

| Estado | Qué puede hacer el negocio | Plazo (parámetro) |
|---|---|---|
| Prueba | Todo lo que incluye el plan | 10 días naturales |
| Activa | Todo lo que incluye el plan | Mientras pague |
| Gracia | Todo, con aviso de pago pendiente | 2 días |
| Solo lectura | Consultar; no registrar ni modificar | 5 días |
| Sin acceso | Nada; los datos se resguardan | 6 meses |
| Eliminada | Nada; se aplica la eliminación de la sección 7 del requerimiento (UC-36) | — |

Durante `sin acceso` los dueños de mascotas conservan su propia información (carnet, línea de tiempo); lo que se bloquea es la operación del negocio.

### 4.5 Cierre de periodo (UC-34)

Al vencer un periodo, el proceso nocturno:

1. Calcula los cargos: plan, sucursales adicionales y espacios pagados de mascotas vendidos en el periodo.
2. Si el negocio tiene meses a favor, consume uno y bonifica el cargo del plan.
3. Si queda algo por cobrar, deja el periodo `por pagar`; si no, lo deja `bonificado`.
4. Abre el siguiente periodo.
5. Si un periodo `por pagar` no se paga, la suscripción avanza por gracia, solo lectura y sin acceso.

### 4.6 Catálogo inicial de parámetros

| Grupo | Parámetro | Valor inicial |
|---|---|---|
| Suscripción | Días de prueba | 10 |
| Suscripción | Días de gracia | 2 |
| Suscripción | Días de solo lectura | 5 |
| Suscripción | Meses de resguardo | 6 |
| Mascotas | Espacios base por usuario | 2 |
| Mascotas | Máximo de espacios por beneficio | 5 |
| Mascotas | Máximo de espacios pagados | Sin tope |
| Mascotas | Cargo por espacio pagado | Por definir |
| Mascotas | Días para ocultar una mascota fallecida | 30 |
| Mascotas | Años sin actividad para eliminar una mascota | 5 |
| Referidos | Servicios pagados para el beneficio de usuario | 10 |
| Referidos | Meses consecutivos pagados del negocio referido | 2 |
| Agenda | Minutos antes para cancelar o reprogramar | 30 |
| Agenda | Tolerancia para marcar no atendida | Por definir |
| Notificaciones | Días antes del recordatorio de vacuna | 7 |
| Notificaciones | Horas antes del recordatorio de cita | 2 |
| Archivos | Tamaño máximo por tipo de documento | Sección 7 del requerimiento |
| Reseñas | Retención | Por definir |

### 4.7 Entitlements iniciales

| Entitlement | Básico | Extendido |
|---|---|---|
| Sucursales incluidas | 1 | Configurable |
| Admite sucursales adicionales con precio | No | Sí |
| Campañas activas al mismo tiempo | 1 | Configurable |

Todos los valores se configuran por plan desde `admin.amiva.pet`. Si un negocio Básico necesita otra sucursal, cambia a Extendido. El límite de campañas cuenta solo las activas: el negocio puede tener otras configuradas como borrador o inactivas.

### 4.8 Decisiones confirmadas

| # | Decisión |
|---|---|
| 1 | Básico: una sucursal y una campaña. Extendido: para varias sucursales. Sucursales y campañas son configurables por plan. |
| 2 | Periodos mensuales en el MVP. |
| 3 | El mes a favor bonifica solo el cargo del plan. |
| 4 | Una prueba vencida sin pago sigue el camino del impago. |
| 5 | Sucursales adicionales: se cobra el mayor número de sucursales activas en el periodo, sin prorrateo. |
| 6 | Los precios de plan incluyen IVA. |
| 7 | Se retira el "límite de mascotas por negocio" del requerimiento. |
| 8 | Todos los parámetros los fija la plataforma; los negocios solo deciden sus políticas. |

Los parámetros marcados "por definir" se configuran más adelante desde `admin.amiva.pet`; no bloquean el modelo.

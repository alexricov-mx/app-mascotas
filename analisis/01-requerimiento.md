# Plataforma para el Cuidado de Mascotas — Requerimientos consolidados

**Nombre del producto:** provisional (AppMascotas)
**Versión:** 1.1 (incorpora las respuestas del responsable del producto)
**Fecha:** 2026-09-21
**Estado:** documento único de trabajo. Ante cualquier duda de "qué se decidió", este es el documento que manda.

---

## 0. Cómo leer este documento

### Etiquetas de estado

| Etiqueta | Significado |
|---|---|
| **CONFIRMADO** | Decisión firme del responsable del producto. |
| **PROVISIONAL** | Intención clara pero sin confirmación final. Se puede construir sobre ella sabiendo que puede cambiar. |
| **PROPUESTA** | Sugerencia del analista (Claude) que el responsable del producto todavía no aprueba. |
| **PENDIENTE** | Falta decidir. Está en la sección 16. |
| **LEGAL** | Requiere asesoría especializada antes de convertirse en regla definitiva. |
| **FUTURO** | No bloquea el MVP, pero el diseño no debe impedirlo. |

### Prioridades e identificadores

- **P0:** indispensable. **P1:** alta. **P2:** evolución. **P3:** futuro.
- **D-xx:** decisión. **RN-xx:** regla de negocio. **RNF-xx:** requisito no funcional. **PEN-xx:** pendiente.

### Criterio

Las respuestas del responsable del producto prevalecen sobre cualquier sugerencia. Cuando dos respuestas se contradicen entre sí, no se elige por él: el punto queda como PENDIENTE con las lecturas posibles.

En este documento "dueño" y "usuario final" significan lo mismo.

---

## 1. Producto

### 1.1 Definición

Plataforma SaaS para negocios y profesionales de servicios para mascotas, con una app para los dueños. La **mascota es la entidad central**.

Conecta tres necesidades que normalmente están separadas:

1. La administración interna del negocio.
2. La relación digital con sus clientes y mascotas.
3. La comercialización de servicios y productos.

### 1.2 Clientes y usuarios

- **Clientes B2B (pagan):** negocios y profesionales de servicios para mascotas. **En esta primera versión: veterinarias y estéticas de mascotas** (D-20).
- **Usuarios B2C:** dueños de mascotas, familiares y cuidadores. La app es gratuita para el dueño hasta 2 mascotas (D-04).

### 1.3 Diseño general — CONFIRMADO

El producto es un **proyecto nuevo e independiente**. Su núcleo debe poder trasladarse después a otros tipos de negocio, no solo a mascotas (D-02).

```text
NÚCLEO GENÉRICO (reutilizable en cualquier negocio)
  Organizaciones y sucursales · Usuarios, roles y permisos · Identidad
  Suscripciones y entitlements · Auditoría · Notificaciones
  Servicios, variantes y precios · Agenda y citas · Clientes (CRM)
  Comercio · Inventario · Proveedores · Promociones · Métricas

MÓDULOS DE VERTICAL (específicos de mascotas)
  Mascotas y propietarios · Expediente clínico · Carnet de vacunas
  Ficha integral · Línea de tiempo de la mascota · Especies y razas
```

- El núcleo no menciona "mascota" ni "veterinaria" en su modelo. El vertical se apoya en el núcleo.
- Cada negocio tiene un **tipo de negocio** (veterinaria, estética) que determina qué módulos del vertical usa. Por ejemplo, el expediente clínico aplica a veterinarias; qué registra una estética es PEN-14. — PROPUESTA
- El vertical de mascotas es el primero. No se abstrae más de lo necesario antes de tener un segundo caso real.

### 1.4 Mercado inicial — CONFIRMADO

México. Arranque en los estados de **Guerrero, Puebla, Estado de México y Ciudad de México**.

### 1.5 Visión a largo plazo

Evolucionar de un SaaS para negocios de mascotas a un ecosistema digital que conecte dueños, veterinarias, estéticas, hoteles, paseadores, entrenadores, tiendas, laboratorios, proveedores y aseguradoras. No condiciona el MVP.

---

## 2. Decisiones confirmadas

| ID | Tema | Decisión |
|---|---|---|
| D-01 | Proyecto | Proyecto nuevo, independiente de App-Ventas, que no se modifica. |
| D-02 | Diseño general | El núcleo debe ser reutilizable en otros tipos de negocio (1.3). |
| D-03 | Centro del producto | La mascota es la entidad central del ecosistema. |
| D-04 | App del dueño | Gratuita. En esta versión el dueño puede tener hasta **2 mascotas**; cada mascota adicional cuesta **1 dólar, pago único** (RN-09). |
| D-05 | Historial del dueño | El dueño consulta la línea de tiempo completa de su mascota sin plan de pago, con el nombre del negocio de cada evento. |
| D-06 | Ingresos | Los negocios pagan la suscripción y una comisión de 7% sobre ventas de productos (12.5). El dueño solo paga la mascota adicional y, en compras, la comisión de la pasarela de pago. |
| D-07 | Aislamiento | Un negocio no puede buscar ni descubrir mascotas ni dueños. Solo accede tras una vinculación aceptada por el dueño, en nivel básico. Qué más ve de lo que generó otro negocio es PEN-01. |
| D-08 | Trazabilidad | Se conserva una línea de tiempo de eventos de la mascota con quién, dónde y cuándo (6.3). |
| D-09 | Arquitectura | Monolito modular; no se inicia con microservicios. |
| D-10 | Base de datos | PostgreSQL. Multi-tenant desde el inicio. |
| D-11 | Identidad | Usuario interno de la plataforma, independiente del proveedor de identidad externo. |
| D-12 | Integraciones | Los dominios no se acoplan a proveedores externos; se usan límites de integración. |
| D-13 | Funcionalidades por plan | Se controlan con entitlements o feature flags, no con código distinto por cliente. |
| D-14 | Impago | Ciclo con plazos definidos: 2 días de gracia, 5 de solo lectura, luego sin acceso, 6 meses de resguardo y borrado (12.3). Qué se borra exactamente es PEN-02. |
| D-15 | Multi-especie | Desde el inicio: especie, raza, sexo, estado reproductivo, microchip y fecha de nacimiento. |
| D-16 | Cargos y pagos | Servicio o producto → Cargo → Venta/pedido → Pago → Documento fiscal. |
| D-17 | Personalización | El branding por negocio se resuelve por configuración. |
| D-18 | IA | Un chatbot de síntomas queda fuera del MVP y nunca se presenta como diagnóstico. |
| D-19 | MVP | Alcance de la sección 14. |
| D-20 | Primer alcance | Veterinarias y estéticas de mascotas. |
| D-21 | Canales | El dueño usa **app móvil**. El negocio usa **web**. No hay web para el dueño en esta versión. |
| D-22 | Citas | Una cita por mascota. **Siempre** requiere aprobación del negocio. |
| D-23 | Propiedad de la información | La plataforma es la dueña de la información. (LEGAL, PEN-20) |
| D-24 | Precios | Los servicios se publican con su precio. Excepción: servicios por cotización (8.4). |
| D-25 | Registros clínicos | Se llevan por fecha. No se modifican registros pasados: una corrección es un registro nuevo. |
| D-26 | Alta de negocios | La hacen los administradores de la plataforma, que también activan su suscripción de prueba. Si esto aplica también a negocios que ya pagan es PEN-04. |
| D-27 | Geolocalización | Desde R1: el dueño busca en un mapa las sucursales afiliadas. Toda sucursal tiene ubicación registrada. |
| D-28 | Parámetros | Los valores de negocio (años de conservación, límites de mascotas, plazos de gracia, comisión) son parámetros que los administradores de la plataforma configuran, no valores fijos en código. |
| D-29 | Consentimiento | Se guarda el consentimiento y la bitácora del evento. No se conservan evidencias adicionales. |

---

## 3. Actores

| Código | Actor | Descripción |
|---|---|---|
| ACT-01 | Dueño principal | Único responsable de una mascota. Usuario final. |
| ACT-02 | Usuario autorizado | Familiar o cuidador que el dueño autoriza. |
| ACT-03 | Profesional | Veterinario, estilista u otro prestador. |
| ACT-04 | Personal de negocio | Empleado de una sucursal o negocio. |
| ACT-05 | Administrador de negocio | Configura sucursales, usuarios, roles, servicios, horarios, agenda y operación. |
| ACT-06 | Administrador de la plataforma | Único que da de alta negocios, activa pruebas y suspende o revoca cuentas. |
| ACT-07 | Sistema | Procesos automáticos y notificaciones. |
| ACT-08 | Proveedor externo | Identidad, pagos, correo, push, WhatsApp, mapas, paquetería. |

---

## 4. Mascotas y personas

### 4.1 Reglas

- **RN-01 — Una mascota puede relacionarse con varios negocios**, siempre mediante la vinculación de la sección 5. — CONFIRMADO
- **RN-02 — Propietario.** Una mascota tiene **un solo propietario principal** y cero o más usuarios autorizados. No hay disputa posible: el propietario principal es quien está registrado. Si se conservan propietarios secundarios es PEN-11. — CONFIRMADO
- **RN-03 — Autorizados.** Un familiar o cuidador puede llevar a la mascota a un servicio y recogerla. El resto de sus permisos es PEN-12. — PROVISIONAL
- **RN-04 — Compartir sin credenciales.** Un autorizado usa su propia cuenta. — CONFIRMADO
- **RN-05 — Edad calculada** a partir de la fecha de nacimiento. — CONFIRMADO
- **RN-06 — Transferencia de propiedad.** Deben existir ambos usuarios con perfil activo. El propietario actual inicia la transferencia, el nuevo propietario la acepta y se registra quién la pidió, quién la aceptó y cuándo. La historia se conserva. — CONFIRMADO
- **RN-07 — Fallecimiento.** El estado cambia a "fallecida". Solo se consulta. La información se conserva 1 mes y se puede entregar al dueño un respaldo, posiblemente un PDF. Qué pasa después del mes es PEN-02. — CONFIRMADO
- **RN-08 — Un negocio no crea mascotas sin dueño.** Primero da de alta al usuario final y luego hace el expediente de su mascota. — CONFIRMADO
- **RN-09 — Límite del dueño.** Hasta 2 mascotas por dueño en esta versión. Cada una adicional cuesta 1 dólar, pago único. A quién aplica (solo autoregistro o también lo que registra un negocio) y cómo se cobra es PEN-03. — CONFIRMADO / PENDIENTE
- **RN-10 — Límite por negocio.** Prueba: 50 mascotas, sin importar el plan. Con suscripción mensual: 1000. El esquema debe ser flexible. — PROVISIONAL (PEN-03)
- **RN-11 — Suspender o revocar cuentas** lo hace solo la administración de la plataforma. Si el dueño puede quitar a un autorizado es PEN-11. — CONFIRMADO

### 4.2 Alta de un usuario final desde el negocio — CONFIRMADO

1. El operador del negocio crea al usuario con un formulario de información general (PEN-22) y captura teléfono o correo.
2. El sistema envía un código por **WhatsApp o correo**.
3. El usuario le da el código al operador. Con eso se verifica que controla ese medio de contacto y se crea el usuario.
4. El operador da de alta la mascota y su expediente.
5. El usuario puede descargar la app y entrar con el correo que dio en la sucursal. Ya encuentra su mascota en su perfil.

Cualquier usuario final también puede registrarse por su cuenta en la app para buscar sucursales y acceder a tiendas en línea.

### 4.3 Invitaciones — CONFIRMADO

Se envían por correo o WhatsApp y valen **24 horas**. Si no se aceptan, se cancelan. No se guardan intentos de invitación. El texto del mensaje es PEN-22.

### 4.4 Datos de la mascota

Nombre, fotografía, especie, raza, sexo, estado reproductivo, fecha de nacimiento, edad calculada, peso, color y características físicas, señas particulares, microchip, alergias, condiciones especiales, medicamentos activos, dieta y veterinario habitual.

Especies iniciales: perro, gato, ave, roedor, reptil y otro. Estructura: Especie → Raza.

---

## 5. Privacidad y aislamiento entre negocios

Está en revisión legal antes de cualquier lanzamiento (PEN-20).

### 5.1 Regla base

- **RN-12 — Sin descubrimiento.** Un negocio no puede buscar, descubrir ni consultar mascotas o dueños que no haya atendido. — CONFIRMADO
- **RN-13 — Vinculación con consentimiento.** Cuando el dueño lleva su mascota a un negocio nuevo, puede dar su consentimiento para que ese negocio establezca la relación con él y sus mascotas **en nivel básico**. El dueño no autoriza cada acceso posterior. — CONFIRMADO
- **RN-14 — La vinculación queda registrada:** quién, qué negocio y sucursal, cuándo. — CONFIRMADO
- **RN-15 — Sucursales.** Las de un mismo negocio acceden según la configuración del negocio y los permisos de cada usuario. — PROVISIONAL

Cómo se vincula un usuario que ya tiene cuenta es PEN-08.

### 5.2 Niveles de visibilidad — CONFIRMADO (los niveles)

| Nivel | Contenido |
|---|---|
| 1. Perfil básico | Datos generales, fotografía, especie, raza y características que el dueño decida compartir. |
| 2. Prevención | Vacunas, desparasitación, tratamientos preventivos y certificados. |
| 3. Atención clínica | Motivo, diagnóstico, tratamiento, receta, estudio y procedimiento. |
| 4. Información interna | Notas administrativas, notas internas, observaciones comerciales, costos internos, márgenes y datos no compartibles. |
| 5. Auditoría | Quién consultó, creó, modificó o compartió información. |

Quién ve qué:

- **El dueño siempre ve:** vacunas, alergias, padecimientos, recetas médicas y los eventos de servicios y consultas. No ve el nivel 4.
- **El negocio que generó un registro** lo ve completo, incluido el nivel 4, que es privado de ese negocio y no se comparte.
- **Un negocio nuevo, tras la vinculación:** nivel básico. Si además ve algo de lo que generó otro negocio es **PEN-01** (bloqueante).

### 5.3 Notas internas y observaciones comerciales — CONFIRMADO

El sistema ofrece un espacio para que el negocio agregue notas internas y observaciones comerciales (por ejemplo, "cliente referido", precio estándar, precio aplicado). Son nivel 4 y se mantienen separadas de las observaciones clínicas.

### 5.4 Autorizaciones clínicas — CONFIRMADO

Las acciones que requieren autorización explícita (tratamiento, cirugía, eutanasia, servicios con costo) **quedan fuera del control de la app**. Son un acuerdo entre el negocio y el dueño. La app puede ofrecer un espacio para adjuntar al expediente el documento firmado por ambas partes, solo como archivo.

### 5.5 Acceso del dueño

- **RN-16 — El dueño consulta** vacunas, alergias, padecimientos, recetas, consultas, servicios, citas, documentos e información de sus mascotas. — CONFIRMADO
- **RN-17 — Toda compartición y vinculación se audita.** — CONFIRMADO

---

## 6. Expediente, carnet y línea de tiempo

### 6.1 Expediente clínico (veterinarias)

Cada visita genera un registro con: fecha, servicio, motivo, diagnóstico, tratamiento, medicamentos aplicados o prescritos, observaciones clínicas, receta, estudios, procedimientos, cirugías y signos vitales. Cada registro conserva mascota, negocio, sucursal, profesional, usuario que lo creó y fecha.

Los registros se llevan por fecha y no se modifican los pasados (D-25).

### 6.2 Carnet de vacunas y prevención

Vacuna, fecha de aplicación, próxima aplicación, lote, fabricante y veterinario. Incluye desparasitación, control antipulgas y tratamientos preventivos. Genera recordatorios.

### 6.3 Línea de tiempo — CONFIRMADO

Cada evento importante queda asociado a la mascota e identifica quién lo creó, el negocio, la sucursal, el profesional, la fecha y hora y el documento relacionado. El dueño ve la línea de tiempo con **el nombre del negocio de cada evento**; por ejemplo, qué veterinaria aplicó una vacuna o qué estética hizo un baño.

Eventos: registro y cambios de la mascota; cambios de propietario y autorizados; citas; consultas; diagnósticos, tratamientos y recetas; vacunas y desparasitaciones; estudios y documentos; peso y signos vitales; servicios no clínicos (baño, estética, hospedaje); transferencias.

### 6.4 Ficha integral — CONFIRMADO, P0

Pantalla central del negocio: foto, nombre, especie, raza, edad, sexo, alertas, alergias, condiciones especiales, propietario, próxima cita, próxima vacuna, última visita, últimos servicios, historial y documentos.

Acciones rápidas: nueva consulta, nueva cita, registrar vacuna, registrar servicio, agregar documento.

### 6.5 Documentos — CONFIRMADO

Se almacenan recetas, tickets y notas de servicio. Los documentos se **agregan, actualizan o eliminan**; no hay gestión de compartición ni revocación por documento. Cómo se registra una eliminación es PEN-15.

### 6.6 Signos vitales

- **R1 (P1):** peso, temperatura, frecuencia cardiaca y respiratoria, con valor, unidad, fecha, profesional y consulta.
- **Futuro:** rangos de referencia por especie, raza y edad. Sin alertas clínicas automáticas sin validación profesional.

### 6.7 Exportación al dueño

El dueño puede exportar su línea de tiempo como **imagen**. Al fallecer la mascota se puede generar un respaldo, posiblemente PDF. Si también habrá exportación a Excel es PEN-17.

### 6.8 Carga masiva — P1

Un negocio que ya opera con otro sistema necesita migrar sus datos o hacer una carga masiva, y las fotos de las mascotas se actualizan eventualmente. Cómo se verifican los dueños cargados así es PEN-09.

---

## 7. Agenda y citas

### 7.1 Reglas

- **RN-18 — Una cita por mascota.** Así quien atiende ve el nombre de la mascota y se calcula el tiempo del servicio. — CONFIRMADO
- **RN-19 — Aprobación obligatoria.** Toda cita la aprueba el negocio. Debe existir una pantalla para ver solicitudes y **aceptarlas o rechazarlas con un mensaje**. — CONFIRMADO
- **RN-20 — Duración.** Cada negocio define cuánto tarda cada servicio y los datos relevantes que afectan la duración (por ejemplo, tamaño). Si una cita tiene varios servicios, la duración es la suma más tiempos adicionales configurados. — CONFIRMADO / PROVISIONAL
- **RN-21 — Capacidad.** El negocio define **cuántas mascotas puede atender simultáneamente**, y puede cambiarlo por horario o día (por ejemplo, más personal en demanda alta). — CONFIRMADO
- **RN-22 — Cancelar o reprogramar** hasta **30 minutos antes** del servicio. Si es fijo o configurable es PEN-24. — CONFIRMADO
- **RN-23 — Inicio y no atención.** El negocio indica cuándo inicia el servicio. Si el dueño no llega dentro del tiempo de tolerancia, el operador, a su criterio, marca la cita como **no atendida** y el espacio vuelve a quedar disponible. — CONFIRMADO
- **RN-24 — Sin penalización.** No se cobra por no presentarse; solo se lleva bitácora para reportes de análisis. — CONFIRMADO
- **RN-25 — Reprogramar** es una acción sobre la cita, no un estado; conserva el historial. — PROVISIONAL
- **RN-26 — Servicio con varios profesionales.** No se modela; es decisión de cada negocio. La capacidad se controla por mascotas simultáneas. — CONFIRMADO

### 7.2 Flujo de reservación

Negocio → Mascota → Servicio(s) → Fecha → Horario. El negocio recibe la solicitud y la acepta o rechaza con mensaje. El dueño es notificado.

### 7.3 Estados

```text
SOLICITADA ──> CONFIRMADA ──> EN_PROCESO ──> COMPLETADA
    │              │
 RECHAZADA     CANCELADA        NO_ATENDIDA (desde CONFIRMADA, por el operador)
```

### 7.4 Lista de espera — fuera del MVP

Se deja para la versión siguiente, pero **el diseño la considera desde ahora**. Regla propuesta (PROVISIONAL): los usuarios se registran por orden de llegada; ante una cancelación elegible se notifica al primero; se considera hasta 30 minutos antes del inicio; **1 minuto 30 segundos** entre notificaciones (confirmado). Qué pasa si no responde, rechaza o dos toman el mismo espacio es PEN-26.

---

## 8. Servicios y precios

### 8.1 Servicio

Nombre, descripción, duración, precio, sucursal, disponibilidad, reglas de cancelación y estado publicado o no publicado.

### 8.2 Precios públicos — CONFIRMADO

Los servicios se publican con su precio.

### 8.3 Variantes y matriz de precios — CONFIRMADO, entra al MVP

El precio y la duración dependen de especie, tamaño, raza, peso, duración o condición clínica. Se requiere un **catálogo de variantes y reglas** para definir el precio y la duración de cada combinación.

```text
Servicio
  └── Grupo de variantes (especie, tamaño, tipo de servicio…)
        └── Opciones
Matriz de precios y duración por combinación
```

### 8.4 Servicios por cotización — CONFIRMADO (a detallar en PEN-23)

Un servicio por cotización no se publica con precio. Es un servicio "no listado" que el negocio selecciona de una lista y para el que arma los conceptos y costos de cada caso.

### 8.5 Precio por sucursal — CONFIRMADO

El precio y la duración se definen por defecto a nivel negocio y se llevan a sus sucursales, pero cada sucursal puede ajustarlos.

### 8.6 Descuentos — PROVISIONAL

Hay que estar preparados. Es decisión de cada negocio o sucursal activar la función y configurarla (PEN-27).

---

## 9. Notificaciones y comunicación

### 9.1 Canales

| Canal | Estado |
|---|---|
| Push | MVP. |
| Correo electrónico | MVP. |
| WhatsApp | MVP. Notificaciones y envío del código de alta. Incluido en el plan. |
| SMS | No está en el MVP. Cuando exista, incluido en el plan. |

WhatsApp Business tiene costo por mensaje y usa plantillas aprobadas; al ir incluido en el plan, ese costo lo absorbe la plataforma (PEN-19).

### 9.2 Reglas

- **RN-27 — Preferencias.** El dueño puede apagar todas las notificaciones de la app y, en una pantalla de perfil, prender o apagar cada tipo de evento. — CONFIRMADO
- **RN-28 — Recordatorios.** Se envían **1 semana antes** de la fecha registrada, o del calendario de vacunas de la mascota. Si aplica igual a citas es PEN-06. — CONFIRMADO / PENDIENTE
- **RN-29 — Fallas.** Se registra el error en bitácora. El dueño simplemente no recibe la notificación. No se envían mensajes atrasados. — CONFIRMADO
- **RN-30 — Sin registro de entrega o apertura.** — CONFIRMADO
- **RN-31 — Comunicación del negocio.** El negocio solo puede iniciar una conversación cuando el dueño lo contactó antes por mensaje, y solo dentro de esa sesión. Por lo demás se comunica con el dueño mediante **campañas o banners** en la app. — CONFIRMADO (mensajería en el MVP: PEN-05)

Notificaciones del MVP: confirmación de cita, rechazo, recordatorio, reprogramación, cancelación y vacuna próxima. Todas las de esta lista se construyen, y el dueño puede apagarlas.

---

## 10. Comercio, inventario y pagos — fuera del MVP

Cuándo entra el comercio, si en R3 o antes, es PEN-13.

### 10.1 Comercio

- Cada negocio tiene su tienda e inventario.
- **Carrito único, órdenes por negocio.** El dueño ve un carrito; si compra en varios negocios se generan órdenes distintas, cada una con su propio costo de envío o método de entrega. — CONFIRMADO
- Pasarelas candidatas: PayPal o Mercado Pago. Sin decisión (PEN-19).
- **Comisión de la plataforma: 7% del total de la venta de productos**, desde el inicio, sin incluir la comisión de la pasarela. Hay una fecha de corte para revisar con el cliente y, cuando ambos estén de acuerdo, se hace el cargo, la transferencia o el cobro. El negocio cobra al dueño los productos y, además, la comisión de la pasarela. — CONFIRMADO (cobrar la comisión de pasarela al consumidor: LEGAL)
- **Devoluciones, reembolsos y entregas** los responde el propio negocio. — CONFIRMADO

### 10.2 Inventario

Por **sucursal**. Entradas (compra, devolución, ajuste), salidas (venta, consumo interno, merma, caducidad), stock mínimo y alertas. Las existencias solo cambian mediante movimientos. Lotes y caducidad en R4.

### 10.3 Proveedores y compras (R4)

Proveedor → solicitud de compra → autorización → orden de compra → recepción → entrada a inventario. En el futuro, el negocio podría hacer órdenes de compra a sus proveedores dentro de la plataforma (PEN-31).

### 10.4 Campañas y promociones (R5, con campañas básicas en plan Extendido)

Campañas con imagen, vigencia, audiencia y canal; se muestran como banners en la app o como push (PEN-30).

---

## 11. Descubrimiento y reseñas

### 11.1 Búsqueda de sucursales — MVP (R1)

El dueño busca en un **mapa** las veterinarias y estéticas afiliadas y consulta su perfil, servicios, precios y horarios. Toda sucursal tiene ubicación registrada. Filtros avanzados, favoritos y ranking, en R2.

### 11.2 Reseñas — R2

Reseñas verificadas, ligadas a una cita o compra, con moderación y derecho de respuesta del negocio. La política de retención antes de publicar es PEN-28.

---

## 12. Modelo SaaS

### 12.1 Principio

Se cobra al negocio por su capacidad operativa y comercial. La línea de tiempo del dueño no depende de un plan. El dueño solo paga la mascota adicional (D-04).

### 12.2 Planes para negocios — CONFIRMADO (precios PENDIENTES, PEN-18)

| Plan | Módulos | Perfil |
|---|---|---|
| **Básico** | Clientes, mascotas, ficha integral, expediente básico, vacunas, documentos, agenda, servicios, citas, recordatorios básicos y reportes esenciales. | Empresas con **una sucursal**. |
| **Extendido** | Todo Básico + múltiples usuarios y roles, múltiples sucursales, expediente clínico avanzado, automatizaciones, campañas básicas, métricas avanzadas y mayor almacenamiento. | Empresas con más información y sucursales: **hasta 5 sucursales incluidas**; cada sucursal adicional tiene costo extra. |
| **Tienda Digital** | Todo Extendido + ecommerce, inventario, proveedores, compras, promociones avanzadas, permisos avanzados, reportes operativos y soporte prioritario. | Empresas que quieren manejar su inventario y tienda virtual con la plataforma. |

Los módulos de un plan que aún no estén construidos se activan cuando existan, mediante entitlements. El plan Enterprise y el white label no están definidos en esta versión (FUTURO).

### 12.3 Ciclo de vida de la suscripción — CONFIRMADO

```text
ACTIVA ─(vence el pago)→ GRACIA ─2 días→ SOLO_LECTURA ─5 días→ SIN_ACCESO ─6 meses→ BORRADA
   ↑                                                                │
   └────────────── se regulariza el pago ───────────────────────────┘ (antes de BORRADA)
```

- **Gracia (2 días):** el negocio opera normal, pero siempre ve un aviso persistente (ventana emergente periódica, barra o marca de agua).
- **Solo lectura (5 días):** puede consultar y no modificar.
- **Sin acceso:** no entra al sistema. La información se resguarda **6 meses** para intentar recuperar al cliente.
- **Borrada:** se elimina definitivamente. Recuperar información ya borrada, desde un respaldo, se cobra aparte.

Qué datos se borran exactamente, y cómo se concilia con los 5 años de conservación, es **PEN-02**. Al terminar una prueba sin acuerdo se aplica el mismo ciclo (PROVISIONAL).

### 12.4 Prueba gratuita — CONFIRMADO

- **10 días naturales**, sobre cualquiera de los planes.
- La activan los administradores de la plataforma cuando dan de alta al negocio.
- **Una sola vez** por empresa. No se pide tarjeta.
- Si se llega a un acuerdo, se puede asignar una suscripción mensual.
- **Requisito: RFC.** No puede haber dos empresas con el mismo RFC. Una empresa puede tener varias sucursales, pero solo un registro como empresa.

### 12.5 Monetización

1. **Suscripción mensual** por plan, más costo por sucursal adicional en Extendido y Tienda Digital.
2. **Comisión de 7%** sobre ventas de productos (10.1).
3. **Mascota adicional del dueño:** 1 dólar, pago único (RN-09).
4. **WhatsApp y SMS:** incluidos en el plan, no son add-on.
5. Almacenamiento adicional, white label y otros add-ons: sin definir (PEN-18).
6. Programa de recomendación y recompensas: FUTURO (PEN-25).

El cobro de la suscripción hoy parece manual (por acuerdo con el cliente). Ver PEN-04.

### 12.6 Administración de la plataforma (R0)

Alta de negocios y activación de pruebas, planes y funcionalidades, suscripciones, suspensión, reactivación y revocación de cuentas, métricas globales, parámetros de plataforma (D-28) y auditoría.

---

## 13. Identidad, auditoría y legal

### 13.1 Proveedores de identidad

El responsable pidió: **correo y contraseña, Gmail (Google), Microsoft, Facebook y X**. Apple no se mencionó. Disponibilidad, costo y reglas de tiendas de apps para estos proveedores es PEN-07.

### 13.2 Auditoría — PROPUESTA (el responsable pidió sugerencia; por aprobar en PEN-16)

**Auditoría completa** (quién, cuándo, valor anterior, valor nuevo, origen):

- Vinculaciones negocio–mascota y consentimientos.
- Transferencias de propiedad y cambios de autorizados y permisos.
- Acceso de lectura a información clínica (nivel 3): solo el registro de quién y cuándo consultó, no una copia del dato.
- Creación de registros clínicos y cualquier modificación o eliminación de un documento adjunto.
- Cambios en datos sensibles de la mascota: alergias, condiciones especiales, microchip, esterilización.
- Cambios de precios, servicios y variantes.
- Cambios de plan, suscripción y estado (gracia, suspensión, reactivación, prueba).
- Movimientos de inventario (los propios movimientos son la auditoría).
- Suspensiones y revocaciones de cuentas por administradores de la plataforma, y su acceso a datos de negocios.
- Cambios en los datos de contacto verificados del usuario.
- Cancelaciones y citas marcadas como no atendidas (para reportes).

**Solo fecha y usuario de la última modificación:**

- Perfil del negocio y de las sucursales, horarios y descripciones del catálogo.
- Preferencias de notificación.
- Foto, color y señas particulares de la mascota.

### 13.3 Legal

Antes del lanzamiento, validar: aviso de privacidad, consentimiento, tratamiento de datos personales, derechos ARCO, conservación y eliminación, responsabilidad de la plataforma, del negocio y del profesional, términos de uso, pagos, comisión de pasarela al consumidor, devoluciones, facturación e impuestos.

- **La plataforma es dueña de la información** (D-23). Esto tiene consecuencias legales sobre sus obligaciones como responsable de datos personales (PEN-20).
- **Solicitudes de eliminación:** las atiende manualmente la plataforma. **No hay eliminación automática** de datos a solicitud del usuario.
- **Consentimiento:** se guarda el consentimiento y la bitácora del evento (D-29).
- **Conservación:** **5 años**, parámetro configurable por la plataforma (D-28). Su relación con el borrado por impago y con el fallecimiento es PEN-02.
- **Facturación:** en México se prevé integrar un PAC. P2. Debe ir desacoplada de ventas y pagos (D-16).

---

## 14. Alcance por release

| Release | Nombre | Contenido |
|---|---|---|
| R0 | Fundaciones | Arquitectura, PostgreSQL, identidad, negocios, sucursales, usuarios, roles, multi-tenant, auditoría, suscripciones y entitlements, administración de la plataforma. |
| **R1** | **MVP** | Ver 14.1. |
| R2 | Engagement | Lista de espera, reseñas, favoritos, filtros avanzados y ranking, SMS, Ctrl+K. |
| R3 | Comercio | Catálogo, carrito multi-negocio, pedidos, pagos, comisión, inventario básico. |
| R4 | Operaciones | Inventario avanzado, lotes, caducidades, proveedores, órdenes de compra. |
| R5 | Crecimiento | Segmentación, campañas, promociones avanzadas, automatizaciones, métricas avanzadas, recompensas. |
| R6 | Ecosistema | Marketplace B2B, integraciones con laboratorios, facturación electrónica, hospitalización. |

### 14.1 MVP (R1)

Pregunta que debe responder: *¿una veterinaria o estética puede administrar sus clientes y mascotas y gestionar sus servicios y citas, y el dueño puede encontrarla y reservar desde su celular?*

**Negocio (web):**
- Alta del negocio y su prueba por administradores de la plataforma; RFC único; sucursales con ubicación.
- Usuarios y roles.
- Alta del usuario final con verificación por código; mascotas; ficha integral.
- Expediente básico, vacunas y carnet, documentos (recetas, tickets, notas), signos vitales básicos.
- Notas internas y observaciones comerciales.
- Servicios con variantes y matriz de precios, por negocio y por sucursal.
- Capacidad por horario (mascotas simultáneas).
- Solicitudes de cita (aceptar o rechazar con mensaje), iniciar servicio, marcar no atendida.
- Línea de tiempo, búsqueda global, auditoría, reportes esenciales.

**Dueño (app móvil):**
- Registro propio o por alta del negocio; perfil y hasta 2 mascotas.
- Búsqueda de sucursales en mapa; perfil, servicios, precios y horarios.
- Solicitar, cancelar y reprogramar citas (hasta 30 minutos antes).
- Línea de tiempo con exportación a imagen; carnet.
- Transferir mascota; invitar familiar o cuidador.
- Notificaciones por push, correo y WhatsApp, configurables.

**Plataforma:** alta de negocios, planes, pruebas, suscripciones, suspensiones, parámetros y bitácora.

**Fuera del MVP:** comercio y tiendas en línea, lista de espera (se diseña considerándola), reseñas, SMS, campañas avanzadas, chatbot de síntomas, hospitalización, laboratorios, white label, automatizaciones, facturación electrónica.

---

## 15. Historial de versiones

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-09-21 | Consolidación de las definiciones iniciales en un único documento. |
| 1.1 | 2026-09-21 | Se incorporan las respuestas del responsable del producto: planes, prueba, límites, impago, canales, agenda, servicios, notificaciones, comercio, legal y respaldo. Los pendientes se renumeran. |

---

## 16. Pendientes consolidados

La columna "Sugerencia" es la propuesta actual del analista, no una decisión.

### 16.1 Bloqueantes

| ID | Pendiente | Sugerencia |
|---|---|---|
| PEN-01 | **Qué ve un negocio de lo que generó otro.** Las respuestas chocan: (a) tras la vinculación, el negocio nuevo ve solo el nivel básico; (b) el negocio nuevo puede ver eventos no confidenciales del negocio inicial; (c) los negocios no ven información de otros negocios. | Opción A: nivel básico y lo que el propio negocio genere. Opción B: además, el nivel 2 (vacunas y desparasitación), que resuelve la necesidad real de una estética u hotel de validar vacunas. El nivel 3 nunca. |
| PEN-02 | **Conservación y borrado.** Chocan: 5 años configurables; borrado a los 6 meses tras el impago; "no hay eliminación automática"; fallecida se conserva 1 mes. ¿Qué se borra si un negocio deja de pagar, los eventos de la mascota o solo los datos del negocio? ¿Qué pasa tras el mes de una mascota fallecida? | Separar datos del negocio (clientes propios, agenda, inventario, notas internas: se borran tras el resguardo) de datos de la mascota (línea de tiempo: 5 años, por ser la plataforma dueña de la información). Tras el mes, la mascota fallecida sale de la app pero se conserva. |
| PEN-03 | **Límites de mascotas.** ¿El límite de 2 aplica también a las mascotas que registra un negocio para el dueño, o solo a las que el dueño registra? El pago de 1 dólar dentro de una app móvil normalmente debe pasar por la compra dentro de la app de las tiendas de aplicaciones, que cobran comisión y usan la moneda local. El límite de 1000 mascotas por negocio es bajo para una clínica grande. | Que el límite de 2 aplique solo al dueño que se autoregistra, y cobrar en MXN. Revisar el esquema de límites por negocio como parámetro. |
| PEN-04 | **Alta de negocios y cobro.** ¿El alta por administradores aplica a todos los negocios en el MVP o solo a la prueba, y habrá autoregistro después? ¿El cobro de la suscripción es manual o por pasarela? | Alta y cobro manuales en el MVP, con estados y fechas registrados en el sistema. |
| PEN-05 | **Mensajería dueño–negocio.** Las respuestas mencionan que el negocio puede conversar solo tras un mensaje del dueño, lo que implica un chat. ¿Entra al MVP? | Fuera del MVP; en el MVP, contacto por el teléfono del negocio y notificaciones. |
| PEN-06 | **Recordatorio de citas.** ¿"1 semana antes" aplica a citas o solo al calendario de vacunas? Una cita puede reservarse con menos de una semana. | Vacunas: 1 semana antes. Citas: 24 horas antes. |
| PEN-07 | **Plataformas móviles y login.** ¿Android, iOS o ambas? Si hay iOS, Apple exige ofrecer también Inicio de sesión con Apple cuando hay login social de terceros. Verificar costo y requisitos de Facebook y X. | Confirmar plataformas antes de fijar la lista de proveedores. |
| PEN-08 | **Vincular a un usuario que ya tiene cuenta con un negocio nuevo.** No se definió el mecanismo. | El operador busca por teléfono o correo y el sistema envía un código de consentimiento, igual que el alta. |
| PEN-09 | **Carga masiva.** ¿Cómo se verifican los dueños cargados así, si el código se da en persona? ¿Qué datos entran? | Cargar como "sin verificar" y verificar en la primera visita. |
| PEN-10 | **Aislamiento técnico.** ¿`tenant_id`, esquemas separados o combinación? Además, las mascotas son del dueño (global) y los registros son del negocio. | `tenant_id` con seguridad a nivel de fila (RLS) en PostgreSQL; no un esquema por negocio. |
| PEN-11 | **Propietario secundario y revocación.** ¿Se elimina el propietario secundario? ¿El dueño puede quitar a un autorizado o a un negocio vinculado, o solo la plataforma (RN-11)? | Sin secundarios. El dueño puede quitar a sus autorizados; la cuenta solo la revoca la plataforma. |
| PEN-12 | **Permisos mínimos por rol.** Autorizado (solo se definió llevar y recoger) y personal del negocio (recepción, veterinario, estilista). | — |
| PEN-13 | **Comercio.** ¿Entra en R3 o antes? El plan Tienda Digital y la comisión de 7% existen desde el inicio, pero el dueño no compra en la primera versión. | R3; el plan se ofrece cuando el módulo exista. |

### 16.2 Altas

| ID | Pendiente | Sugerencia |
|---|---|---|
| PEN-14 | **Estéticas.** Qué registran y qué módulos usan (no aplican expediente clínico ni diagnóstico). | El tipo de negocio activa módulos. |
| PEN-15 | **Eliminar documentos.** ¿Se borran de verdad? ¿Quién puede? | Borrado lógico con bitácora; solo el negocio que lo subió. |
| PEN-16 | **Auditoría.** Aprobar la propuesta de 13.2. | — |
| PEN-17 | **Exportaciones.** Imagen de la línea de tiempo (decidido) frente a Excel (mencionado). ¿Para quién es el Excel? | Excel para el negocio; imagen para el dueño. |
| PEN-18 | **Precios de planes** y de la sucursal adicional; límites de usuarios y almacenamiento; add-ons y plan Enterprise. | — |
| PEN-19 | **Proveedores externos:** pagos (PayPal o Mercado Pago), mapas y WhatsApp Business (costo por mensaje y plantillas). | — |
| PEN-20 | **Legal.** Aviso de privacidad y obligaciones de la plataforma como dueña de la información; qué evidencia mínima guardar del consentimiento; cobro de la comisión de pasarela al consumidor. | Guardar con cada consentimiento la versión del texto aceptado. |
| PEN-21 | **Respaldos.** Diario incremental con retención de 1 semana; "recuperar la BD". Restaurar toda la base afecta a todos los negocios; recuperar solo uno requiere restaurar a una copia y extraer sus datos. | Revisar qué ofrece nativamente el proveedor de base de datos antes de diseñar respaldos propios. |
| PEN-22 | **Textos y formularios:** formulario de alta del usuario final, mensaje de invitación, vigencia e intentos del código de verificación. | — |
| PEN-23 | **Servicios por cotización.** Cómo se arman los conceptos y cómo los acepta el dueño. | — |
| PEN-24 | **Ventana de 30 minutos y tolerancia.** ¿Fijas o configurables por negocio o servicio? | Parámetros. |

### 16.3 Medias y futuras

| ID | Pendiente |
|---|---|
| PEN-25 | Programa de recomendación: beneficios por invitar usuarios y recompensas ligadas a la facturación de las empresas afiliadas. |
| PEN-26 | Lista de espera (versión siguiente): qué pasa si el primero no responde, rechaza, dos toman el mismo espacio o se vuelve a cancelar. |
| PEN-27 | Descuentos y promociones configurables por negocio o sucursal. |
| PEN-28 | Reseñas (R2): retención antes de publicar y moderación. |
| PEN-29 | Almacenamiento de archivos: proveedor y tiempo de retención. |
| PEN-30 | Campañas y banners: contenido, audiencia y cómo se muestran. |
| PEN-31 | Marketplace B2B de proveedores. |

---

## 17. Requisitos no funcionales y arquitectura

### 17.1 Requisitos no funcionales — CONFIRMADO

- **RNF-01 Seguridad:** autenticación fuerte, autorización granular, mínimo privilegio, cifrado en tránsito y en reposo, secretos seguros.
- **RNF-02 Multi-tenant:** cada negocio solo accede a su información.
- **RNF-03 Trazabilidad:** operaciones críticas auditables.
- **RNF-04 Escalabilidad:** crecer en usuarios, mascotas, negocios, sucursales, citas y documentos.
- **RNF-05 Integraciones:** siempre detrás de límites de integración.
- **RNF-06 Experiencia rápida:** pocos clics, búsqueda rápida, información en contexto.
- **RNF-07 Parámetros:** los valores de negocio se configuran, no se programan (D-28).
- **RNF-08 Respaldos:** incrementales diarios con retención de 1 semana; la recuperación es restaurar la base de datos (PEN-21).

### 17.2 Arquitectura propuesta — EN ANÁLISIS, todavía no es decisión

```text
Navegador (negocio) ──> BFF (.NET 10, reverse proxy) ──> API (.NET, monolito modular) ──> PostgreSQL (Neon)
                                                                 │
App móvil del dueño ─────────────── (tokens) ───────────────────┤
                                                                 └──> Almacenamiento de archivos
```

| Capa | Propuesta | Estado |
|---|---|---|
| Base de datos | PostgreSQL en Neon, con PostGIS para el mapa (R1). | Base decidida (D-10, D-27); proveedor en análisis. |
| Backend | ASP.NET Core (.NET 10), monolito modular. | Propuesta. |
| BFF | Servicio .NET 10 que publica el sitio, actúa como reverse proxy y aporta la seguridad (sesión con cookie HttpOnly). | En análisis. |
| Web del negocio | Vue 3 + TypeScript + Nuxt UI. Falta decidir Nuxt como SPA (sin servidor propio) o Vue con Vite. | En análisis. |
| App móvil del dueño | **Necesaria en el MVP** (D-21). Flutter propuesto; usa el API con tokens y no se conecta a la base de datos. Plataformas: PEN-07. | Tecnología propuesta. |
| Archivos | Neon Object Storage está en beta y hoy solo en `aws-us-east-2` y `aws-eu-central-1`. Se diseña detrás de una interfaz para poder cambiar de proveedor (PEN-29). | En análisis. |

Notas que afectan el diseño:

- El BFF con cookie sirve a la web; la app móvil necesita tokens. El API se diseña una sola vez.
- Los identificadores no deben depender de una tabla de secuencia central (UUID o `bigint`); con muchos usuarios simultáneos generan contención. El formato visible puede mantener prefijos.
- Neon escala a cero: la primera consulta tras inactividad puede tardar más.
- **La plataforma es online.** Si algún negocio necesita operar sin conexión, es un requisito nuevo que hoy no existe.
- Los registros clínicos son de solo agregar (D-25), lo que simplifica el versionado y la auditoría.

### 17.3 Módulos del backend

Core (organizaciones, sucursales, usuarios, roles, suscripciones, parámetros) · Identidad · CRM · Mascotas y expediente (vertical) · Servicios y agenda · Notificaciones · Comercio · Inventario · Compras · Marketing · Descubrimiento y reseñas · Analítica.

---

## 18. Fuera de alcance por ahora (FUTURO)

- Hospitalización con pizarra digital.
- Integración con laboratorios y equipos.
- Facturación electrónica mediante PAC.
- Motor de automatizaciones (Evento → Regla → Acción).
- Rangos clínicos por especie y raza.
- Chatbot de síntomas (solo educativo, nunca diagnóstico).
- Acceso de emergencia entre negocios.
- GPS, seguro y servicios funerarios como productos independientes.
- Marketplace B2B de proveedores y publicidad avanzada.
- White label y plan Enterprise.
- Programa de recomendación y recompensas.

---

## 19. Entidades conceptuales y siguiente paso

```text
Usuario · Mascota · UsuarioMascota · Negocio · Sucursal · Cliente
Profesional · Servicio · Variante · Cita · EventoMascota · RegistroClinico
Vacuna · Documento · Vinculación · Notificación · Auditoría
Suscripción · Plan · Entitlement · Parámetro
```

Orden de trabajo recomendado:

1. Resolver los pendientes bloqueantes de 16.1.
2. Modelo conceptual del dominio, separando núcleo y vertical.
3. Matriz de roles y permisos.
4. Modelo de privacidad (qué ve cada actor).
5. Casos de uso del MVP.
6. Modelo de datos físico en PostgreSQL.

**Decisión guía:**

> El dueño no paga por usar la app ni por consultar la historia de su mascota. La plataforma monetiza principalmente a los negocios y mantiene la trazabilidad completa bajo reglas claras de autorización, privacidad y auditoría.

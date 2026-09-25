# Matriz de roles y permisos — amiva.pet

**Versión:** 1.0  
**Fecha:** 2026-09-24  
**Fuente:** `docs/03-casos-uso-mvp.md` versión 1.15, bloque 1 de `docs/06-modelo-conceptual.md` y tablas `rol`, `permiso` y `rol_permiso` de `docs/07-modelo-datos.md`  
**Estado:** aprobado el 2026-09-24.

## 1. Propósito

Define **qué puede hacer cada rol del negocio**. Es el contenido inicial de las tablas `permiso` y `rol_permiso`.

Reglas del bloque 1 que se aplican aquí:

- Los roles son fijos en el MVP: **Administrador de negocio**, **Recepción**, **Veterinario** y **Estilista**.
- Una persona puede tener **varios roles**, en todo el negocio o en una sucursal concreta. Sus permisos son la suma de sus roles. Ejemplo: la dueña de una veterinaria pequeña tiene Administrador y Veterinario.
- **Mínimo privilegio** (sección 3 del requerimiento): un administrador no obtiene automáticamente funciones que no correspondan a su rol. Por eso el Administrador no ve lo clínico si no tiene también el rol Veterinario.
- El API verifica el permiso en cada operación, además del estado de la suscripción y el aislamiento por negocio.

Lo que hacen el **dueño** y el **usuario autorizado** no depende de roles, sino de la propiedad y la autorización (bloque 3, sección 5.4). El **administrador de plataforma** tiene su propio conjunto, en la sección 5.

## 2. Abreviaturas

| Abreviatura | Rol |
|---|---|
| ADM | Administrador de negocio |
| REC | Recepción |
| VET | Veterinario |
| EST | Estilista |

✓ = tiene el permiso. — = no lo tiene.

## 3. Matriz del negocio

### 3.1 Configuración del negocio

| Permiso | Qué permite | UC | ADM | REC | VET | EST |
|---|---|---|:-:|:-:|:-:|:-:|
| `negocio.configurar` | Datos del negocio, logo, pie de ticket y políticas | UC-44 | ✓ | — | — | — |
| `sucursal.administrar` | Datos de sucursales | UC-03 | ✓ | — | — | — |
| `personal.administrar` | Alta, baja y roles del personal | UC-04 | ✓ | — | — | — |
| `servicio.administrar` | Catálogo de servicios, variantes y precios | UC-18 | ✓ | — | — | — |
| `agenda.configurar` | Horarios, días especiales y capacidad | UC-50 | ✓ | — | — | — |
| `suscripcion.consultar` | Plan, cargos, pagos y meses a favor | UC-05 | ✓ | — | — | — |
| `negocio.invitar` | Invitar otros negocios (referidos) | UC-40 | ✓ | — | — | — |
| `auditoria.consultar` | Auditoría del negocio | UC-53 | ✓ | — | — | — |

### 3.2 Clientes

| Permiso | Qué permite | UC | ADM | REC | VET | EST |
|---|---|---|:-:|:-:|:-:|:-:|
| `cliente.consultar` | Buscar y ver clientes y sus datos de contacto | UC-10 | ✓ | ✓ | ✓ | ✓ |
| `cliente.registrar_provisional` | Registrar cliente y mascota provisionales y enviar la invitación | UC-47 | ✓ | ✓ | — | — |
| `cliente.notas_internas` | Ver y escribir notas internas del cliente | — | ✓ | ✓ | — | — |

### 3.3 Mascotas y expediente

| Permiso | Qué permite | UC | ADM | REC | VET | EST |
|---|---|---|:-:|:-:|:-:|:-:|
| `mascota.consultar` | Ficha y línea de tiempo en niveles 1 y 2 | UC-10 | ✓ | ✓ | ✓ | ✓ |
| `expediente.consultar_clinico` | Nivel 3 que generó el negocio (se audita cada acceso) | UC-10 | — | — | ✓ | — |
| `expediente.consultar_estetica` | Servicios de estética que hizo el negocio | UC-10 | ✓ | ✓ | ✓ | ✓ |
| `consulta.registrar` | Consulta, signos vitales, recetas, estudios y procedimientos | UC-14 | — | — | ✓ | — |
| `aplicacion.registrar` | Vacunas, desparasitaciones y preventivos, del inventario o del dueño | UC-15 | — | — | ✓ | — |
| `certificado.emitir` | Certificados de vacunación, salud o viaje | UC-15 | — | — | ✓ | — |
| `servicio_estetica.registrar` | Baño, estética y otros servicios no clínicos | UC-16 | — | — | — | ✓ |
| `registro.corregir` | Corregir un registro propio con un registro nuevo | UC-14 | — | — | ✓ | ✓ |
| `nota_mascota.registrar` | Notas internas sobre la mascota | UC-14 | — | — | ✓ | ✓ |
| `receta.imprimir` | Imprimir recetas | UC-14 | ✓ | ✓ | ✓ | — |
| `documento.agregar` | Subir documentos (estudios, responsivas, fotos) | UC-13 | ✓ | ✓ | ✓ | ✓ |
| `documento.eliminar` | Eliminar (lógico) documentos que subió el negocio | UC-13 | ✓ | — | ✓ | — |
| `fallecimiento.registrar` | Registrar el fallecimiento de una mascota | UC-12 | ✓ | — | ✓ | — |

### 3.4 Agenda

| Permiso | Qué permite | UC | ADM | REC | VET | EST |
|---|---|---|:-:|:-:|:-:|:-:|
| `cita.consultar` | Ver la agenda de la sucursal | UC-20 a UC-23 | ✓ | ✓ | ✓ | ✓ |
| `cita.agendar` | Agendar citas desde el negocio | UC-49 | ✓ | ✓ | — | — |
| `cita.responder` | Aceptar o rechazar solicitudes | UC-21 | ✓ | ✓ | ✓ | ✓ |
| `cita.atender` | Iniciar, completar o marcar no atendida | UC-22 | ✓ | ✓ | ✓ | ✓ |
| `cita.cancelar` | Cancelar o reprogramar desde el negocio | UC-23 | ✓ | ✓ | — | — |

### 3.5 Inventario y promociones

| Permiso | Qué permite | UC | ADM | REC | VET | EST |
|---|---|---|:-:|:-:|:-:|:-:|
| `producto.administrar` | Productos, precios, tasas de IVA y mínimos | UC-24 | ✓ | — | — | — |
| `promocion.administrar` | Promociones y sus componentes | UC-25 | ✓ | — | — | — |
| `inventario.consultar` | Existencias y agotados, sin costos | UC-24 | ✓ | ✓ | ✓ | ✓ |
| `inventario.costos` | Costos, kardex y valuación | UC-24 | ✓ | — | — | — |
| `inventario.entrada` | Entradas manuales | UC-24 | ✓ | — | — | — |
| `inventario.consumo` | Consumo interno | UC-24 | ✓ | ✓ | ✓ | ✓ |
| `inventario.merma` | Mermas y caducidades | UC-24 | ✓ | — | — | — |
| `inventario.conteo` | Iniciar y autorizar conteos físicos | UC-43 | ✓ | — | — | — |
| `inventario.contar` | Capturar cantidades de un conteo | UC-43 | ✓ | ✓ | — | — |

### 3.6 Punto de venta

| Permiso | Qué permite | UC | ADM | REC | VET | EST |
|---|---|---|:-:|:-:|:-:|:-:|
| `venta.registrar` | Cobrar en el POS e imprimir el ticket | UC-26 | ✓ | ✓ | ✓ | ✓ |
| `venta.consultar` | Consultar ventas y reimprimir tickets | UC-28 | ✓ | ✓ | — | — |
| `venta.cancelar` | Cancelar una venta | UC-27 | ✓ | — | — | — |
| `espacio_mascota.vender` | Vender un espacio pagado de mascota | UC-37 | ✓ | ✓ | — | — |
| `corte_caja.propio` | Su propio corte de caja | UC-51 | ✓ | ✓ | ✓ | ✓ |
| `corte_caja.sucursal` | Corte de caja de toda la sucursal | UC-51 | ✓ | — | — | — |

### 3.7 Comunicación

| Permiso | Qué permite | UC | ADM | REC | VET | EST |
|---|---|---|:-:|:-:|:-:|:-:|
| `campana.administrar` | Crear, copiar, activar y desactivar campañas | UC-32 | ✓ | — | — | — |
| `avisos.consultar` | Bandeja de avisos del personal | UC-52 | ✓ | ✓ | ✓ | ✓ |

## 4. Resumen por rol

| Rol | En pocas palabras |
|---|---|
| **Administrador** | Configura y administra todo el negocio: personal, catálogo, agenda, inventario con costos, cancelaciones, corte de la sucursal, campañas y auditoría. **No** ve ni registra lo clínico. |
| **Recepción** | Clientes, agenda completa, cobro, espacios pagados, clientes provisionales y su propio corte. Ve niveles 1 y 2, no lo clínico. |
| **Veterinario** | Todo lo clínico: consultas, vacunas, certificados, correcciones y expediente nivel 3. Responde y atiende citas, consume inventario y cobra. |
| **Estilista** | Servicios de estética y sus notas; responde y atiende citas, consume inventario y cobra. Ve niveles 1 y 2, no lo clínico. |

## 5. Administrador de plataforma

No es un rol del negocio ni usa esta matriz: tiene un conjunto fijo en `admin.amiva.pet`.

| Puede | UC |
|---|---|
| Dar de alta negocios, sucursales y su usuario inicial | UC-03 |
| Administrar planes, precios, entitlements y suscripciones; registrar pagos | UC-05 |
| Atender solicitudes de afiliación | UC-41 |
| Configurar parámetros y tasas de IVA | UC-29 |
| Publicar versiones de textos legales | UC-30 |
| Ocultar campañas | UC-32 |
| Consultar auditoría de toda la plataforma, solo para soporte (queda auditado) | UC-53 |

No ve datos operativos ni clínicos de un negocio.

## 6. Decisiones confirmadas

| # | Decisión |
|---|---|
| 1 | El Administrador no ve lo clínico (nivel 3) ni registra consultas si no tiene también el rol Veterinario. |
| 2 | Recepción y Estilista no ven nivel 3. |
| 3 | Costos y valuación de inventario solo para el Administrador. |
| 4 | Cancelar ventas solo el Administrador. |
| 5 | Los cuatro roles cobran en el POS. |
| 6 | Los cuatro roles responden y atienden citas. |
| 7 | Recepción puede imprimir recetas registradas por el veterinario. |
| 8 | Recepción captura conteos; solo el Administrador los inicia y autoriza. |

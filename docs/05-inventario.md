# Operación de inventario — amiva.pet

**Versión:** 1.0  
**Fecha:** 2026-09-24  
**Relacionado con:** `docs/02-requerimiento.md` versión 3.7 (sección 10)  
**Estado:** aprobado. Detalla la sección 10 del requerimiento; si hay diferencia, manda el requerimiento.

## 1. Propósito

Describir cómo opera el inventario de amiva.pet siguiendo prácticas estándar, sin reinventarlo. Separa lo que forma parte del MVP (R1) de lo que llega después: traspasos con el ecommerce (R3), y proveedores, compras y lotes (R4).

## 2. Principios

1. **Las existencias solo cambian mediante movimientos.** Nadie edita la existencia directamente. La existencia actual es la suma de los movimientos.
2. **El inventario es por sucursal.** Cada sucursal tiene su propia existencia de cada producto; el catálogo de productos es del negocio.
3. **Todo movimiento es trazable:** tipo, cantidad, sucursal, usuario, fecha, motivo y documento de origen (venta, cita, registro clínico, conteo, orden de compra).
4. **Los movimientos no se borran ni se editan.** Un error se corrige con un movimiento contrario.
5. **No se permite existencia negativa.** Una salida que dejaría la existencia en negativo se rechaza.
6. **Las operaciones que afectan varias entidades son transaccionales.** Por ejemplo, venta, detalle y movimientos se guardan juntos o no se guarda nada.

## 3. Conceptos

| Concepto | Descripción |
|---|---|
| Producto | Artículo que se vende o se consume: nombre, imagen, descripción breve, categoría, unidad de medida, código de barras opcional, precio de venta y estado visible u oculto. Pertenece al negocio. |
| Unidad de medida | La que se indique para el producto: pieza, mililitro, gramo, dosis, etc. Las cantidades siempre son **enteras** en esa unidad; no hay fracciones. |
| Precio de venta | Incluye IVA. En pesos MXN con dos decimales. |
| Existencia | Cantidad de un producto en una sucursal. |
| Stock mínimo | Cantidad por debajo de la cual se genera una alerta de reabasto. Se define **por sucursal**. |
| Stock máximo | Tope sugerido para compras. Opcional, por sucursal. |
| Movimiento | Registro de una entrada o salida con su tipo, cantidad y origen. |
| Kardex | Historial cronológico de movimientos de un producto en una sucursal, con la existencia resultante tras cada uno. |
| Costo unitario | Lo que cuesta al negocio una unidad, con cuatro decimales (1,000 ml a $250.00 = $0.2500 por ml). Se usa para margen y valuación; nunca se muestra al dueño. |
| Valuación | Existencia multiplicada por su costo. Dice cuánto dinero hay en inventario. |

## 4. Tipos de movimiento

| Tipo | Efecto | Origen | Autorización | Release |
|---|---|---|---|---|
| Entrada inicial | + | Alta de producto o arranque de sucursal | Administrador de negocio | R1 |
| Entrada manual | + | Compra registrada sin orden de compra | Administrador de negocio | R1 |
| Salida por venta | − | Venta en POS | Automática | R1 |
| Devolución por cancelación | + | Cancelación de venta | Automática | R1 |
| Aplicación clínica | − | Vacuna, desparasitante o medicamento aplicado en consulta | Automática al registrar | R1 |
| Consumo interno | − | Uso en un servicio o en la operación | Personal autorizado | R1 |
| Merma | − | Daño, rotura o pérdida | Administrador de negocio | R1 |
| Caducidad | − | Producto vencido | Administrador de negocio | R1 |
| Ajuste positivo o negativo | ± | Diferencia en un conteo físico | Administrador de negocio | R1 |
| Traspaso salida / traspaso entrada | − / + | Envío entre sucursales del mismo negocio | Administrador de negocio | R3 |
| Entrada por recepción de compra | + | Recepción de orden de compra | Personal autorizado | R4 |
| Devolución a proveedor | − | Producto regresado al proveedor | Administrador de negocio | R4 |

Las promociones compuestas no tienen existencia propia: al venderse generan salidas de cada componente, y al cancelarse, las devoluciones correspondientes (igual que en App-Ventas).

## 5. Operaciones del MVP (R1)

### 5.1 Alta de producto y existencia inicial

El administrador crea el producto en el catálogo del negocio con su unidad de medida y precio con IVA. Por cada sucursal que lo maneje captura existencia inicial, stock mínimo y costo. La existencia inicial se guarda como movimiento de entrada inicial.

### 5.2 Entrada manual

Mientras no existan órdenes de compra (R4), la mercancía que llega se registra como entrada manual con cantidad, costo unitario, fecha y referencia libre (por ejemplo, número de nota del proveedor).

### 5.3 Venta y cancelación

La venta genera salidas por cada producto y por cada componente de promoción. La cancelación genera las devoluciones exactas de la venta original. Está descrito en UC-26 y UC-27.

### 5.4 Aplicación clínica

Al registrar una vacuna, desparasitante o medicamento aplicado en consulta (UC-14 y UC-15), el veterinario elige el producto del inventario de la sucursal y la cantidad aplicada. El sistema genera la salida automáticamente, en la misma transacción que el registro clínico. Si no hay existencia suficiente, no se puede registrar la aplicación con ese producto.

Si el producto lo proporciona el dueño, no se genera ningún movimiento: se captura como dato del registro clínico (nombre comercial, laboratorio, lote y caducidad) y no toca existencias ni costo promedio. Las reglas completas están en la sección 7.1 del requerimiento.

### 5.5 Consumo interno, merma y caducidad

Salidas que no son venta. Requieren motivo. El consumo interno **puede** ligarse a una cita o servicio para saber qué se usó (por ejemplo, shampoo en un baño); la liga es opcional.

### 5.6 Conteo físico

Es la forma estándar de conciliar el sistema con la realidad:

1. El administrador inicia un conteo de toda la sucursal o de una categoría (conteo cíclico).
2. El sistema guarda la existencia teórica de cada producto al inicio del conteo.
3. El personal captura lo que cuenta físicamente.
4. El sistema muestra las diferencias.
5. El administrador autoriza y el sistema genera un ajuste positivo o negativo por cada diferencia.

Recomendación: conteos cíclicos frecuentes por categoría en lugar de uno total al año.

### 5.7 Alertas de stock mínimo

Cuando un movimiento deja la existencia en o por debajo del mínimo de esa sucursal, se genera una notificación interna para su administrador. Los productos sin existencia se muestran como agotados en el POS.

### 5.8 Consultas

- Existencias por sucursal, con filtro de agotados y bajo mínimo.
- Kardex por producto y sucursal.
- Valuación del inventario por sucursal.
- Movimientos por tipo y periodo (por ejemplo, mermas del mes).

## 6. Costeo

Se usa **costo promedio ponderado**:

```
nuevo costo promedio = (existencia × costo promedio actual + cantidad entrante × costo entrante)
                       ÷ (existencia + cantidad entrante)
```

- Solo las entradas con costo (inicial, manual, recepción de compra) recalculan el promedio.
- Las salidas se valúan al costo promedio vigente en ese momento, que queda guardado en el movimiento.
- El costo promedio se guarda con cuatro decimales; los importes y totales se redondean a dos.

## 7. Traspasos entre sucursales (R3)

Llegan con el ecommerce. Un traspaso genera una salida en la sucursal de origen y una entrada en la de destino, con el mismo costo promedio de origen. Se detalla al planear R3.

## 8. Proveedores y compras (R4)

### 8.1 Proveedores

Datos: razón social, RFC, contacto, teléfono, correo, condiciones de pago, productos que surte y último costo por producto. Pertenecen al negocio y los comparten sus sucursales.

### 8.2 Órdenes de compra

| Estado | Significado | Siguiente |
|---|---|---|
| Borrador | Se captura proveedor, sucursal destino, productos, cantidades y costos. Editable. Si no se usa, se elimina y no queda registro. | En proceso |
| En proceso | Autorizada por el administrador y enviada al proveedor. Ya no se edita. Admite recepciones. | Concluida |
| Concluida | Se recibió todo, o el administrador la cerró aunque falten partidas. | — |

No existe estado `cancelada`.

### 8.3 Recepción

Cada recepción registra qué llegó de cada partida. Genera entradas por recepción de compra y recalcula el costo promedio. Una orden puede tener varias recepciones (recepción parcial). Si llega de más o con otro costo, se registra lo real y se señala la diferencia.

### 8.4 Sugerencia de compra

Con stock mínimo y máximo de la sucursal, el sistema puede sugerir una orden: por cada producto bajo mínimo, pedir hasta el máximo.

### 8.5 Lotes y caducidades

Cada entrada puede llevar número de lote y fecha de caducidad. Las salidas consumen primero el lote que caduca antes (FEFO). Esto permite alertas de caducidad próxima, importante para medicamentos y vacunas.

## 9. Decisiones tomadas en la revisión

| # | Pregunta | Decisión |
|---|---|---|
| 1 | Traspasos entre sucursales | No en el MVP; llegan en R3, con el ecommerce. |
| 2 | Liga del consumo interno con cita o servicio | Opcional. |
| 3 | Descuento automático de vacunas y medicamentos aplicados | Sí. |
| 4 | Método de costeo | Costo promedio ponderado. |
| 5 | Estado `cancelada` en órdenes de compra | No. Un borrador que no se usa se elimina. |
| 6 | Unidades de medida | Las que se indiquen por producto, sin fracciones. |
| 7 | Precio de venta | Incluye IVA. |
| 8 | Stock mínimo | Por sucursal. |
| 9 | Decimales en dinero | Sí: dos decimales en precios y totales, cuatro en el costo unitario. Las cantidades siguen enteras. |
| 10 | Producto proporcionado por el dueño | No mueve inventario. Política por negocio; aplica a vacunas, desparasitantes y medicamentos. |

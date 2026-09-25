# Modelo de datos — amiva.pet

**Versión:** 1.0  
**Fecha:** 2026-09-24  
**Fuente:** `docs/06-modelo-conceptual.md` versión 1.0 (aprobado)  
**Base de datos:** PostgreSQL 18 + PostGIS 3.6  
**Estado:** aprobado el 2026-09-24. Todavía no es un script de creación; índices, políticas RLS y migraciones se detallan después. Los diagramas se validaron con el analizador oficial de Mermaid.

## 1. Propósito

Traduce el modelo conceptual a **tablas, campos, tipos de datos y relaciones**. Cada sección corresponde a un bloque del modelo conceptual y trae su diagrama entidad-relación.

Los diagramas usan Mermaid. En VS Code se ven con la vista previa de Markdown (`Ctrl+Shift+V`) y la extensión *Markdown Preview Mermaid Support*. Los diagramas grandes se pueden ampliar con el zoom de la vista previa.

## 2. Convenciones

| Tema | Convención |
|---|---|
| Nombres | Tablas y columnas en español, en `snake_case` y con nombre completo: `venta_id`, `producto_id`, nunca `id`. |
| Llave primaria | `<tabla>_id` de tipo `uuid` (versión 7, ordenable por tiempo), generado por el API. |
| Identificador visible | El prefijo (`ven_`, `mas_`, `neg_`...) lo agrega el API al exponer el identificador; no se guarda. El folio de venta es un campo aparte. |
| Aislamiento | Toda tabla con datos de un negocio lleva `negocio_id` y una política RLS que filtra por el negocio de la sesión. |
| Columnas comunes | Toda tabla tiene `creado_en timestamptz` y `actualizado_en timestamptz`; las que registran una acción de una persona tienen además `creado_por_usuario_id uuid`. No se repiten en los diagramas. |
| Estados y tipos | Columnas `text` con restricción `CHECK` de valores permitidos, no tipos `enum` de PostgreSQL, para poder agregar valores sin migraciones complejas. |
| Fechas | `timestamptz` para momentos (se guarda en UTC); `date` para fechas sin hora; `time` para horarios. |
| Borrado | Donde el requerimiento pide borrado lógico, columna `eliminado_en timestamptz`. Las tablas de historial (movimientos, cambios, auditoría) solo aceptan inserciones. |
| Correos | Tipo `citext` (extensión de PostgreSQL) para comparar sin distinguir mayúsculas. |

### 2.1 Dominios

Tipos propios para que el dinero y las medidas se guarden siempre igual:

| Dominio | Tipo base | Uso |
|---|---|---|
| `importe` | `numeric(12,2)` | Precios, totales, pagos, cambio, cargos. |
| `costo` | `numeric(14,4)` | Costo unitario y costo promedio de inventario. |
| `porcentaje` | `numeric(5,2)` | Tasas de IVA. |
| `peso_kg` | `numeric(6,2)` | Peso de la mascota. |

`geography` es `geography(Point, 4326)` de PostGIS (latitud y longitud).

### 2.2 Notación de los diagramas

- `PK` llave primaria, `FK` llave foránea, `UK` valor único.
- `||--o{` uno a muchos, `||--o|` uno a cero o uno, `}o--o{` muchos a muchos.
- Una tabla de otro bloque aparece solo con su nombre, sin campos.

---

## 3. Identidad y acceso (bloque 1)

```mermaid
erDiagram
    usuario {
        uuid usuario_id PK
        text keycloak_sub UK "identificador de Keycloak"
        citext correo UK
        text estado "pendiente_verificacion, activo, bloqueado, eliminado"
        timestamptz eliminado_en
    }
    perfil_usuario_final {
        uuid usuario_id PK, FK
        text nombre_visible
        text telefono
    }
    usuario_plataforma {
        uuid usuario_id PK, FK
        boolean activo
    }
    negocio {
        uuid negocio_id PK
        text rfc UK
        text razon_social
        text nombre_comercial
        uuid logo_documento_id FK
        text pie_ticket
        boolean acepta_productos_dueno "politica del negocio, true por defecto"
        text estado "activo, eliminado"
    }
    sucursal {
        uuid sucursal_id PK
        uuid negocio_id FK
        text nombre
        text direccion
        text telefono
        geography ubicacion
        text estado "activa, inactiva"
    }
    miembro_negocio {
        uuid miembro_negocio_id PK
        uuid negocio_id FK
        uuid usuario_id FK "UK junto con negocio_id"
        text estado "activo, desactivado"
    }
    rol {
        uuid rol_id PK
        text clave UK "administrador_negocio, recepcion, veterinario, estilista"
        text nombre
    }
    permiso {
        uuid permiso_id PK
        text clave UK "cita.aceptar, venta.cancelar, ..."
        text descripcion
    }
    rol_permiso {
        uuid rol_id PK, FK
        uuid permiso_id PK, FK
    }
    asignacion_rol {
        uuid asignacion_rol_id PK
        uuid negocio_id FK
        uuid miembro_negocio_id FK
        uuid rol_id FK
        uuid sucursal_id FK "nulo = todo el negocio"
    }
    profesional {
        uuid miembro_negocio_id PK, FK
        uuid negocio_id FK
        text especialidad
        text cedula_profesional
    }

    usuario ||--o| perfil_usuario_final : "tiene"
    usuario ||--o| usuario_plataforma : "puede ser"
    usuario ||--o{ miembro_negocio : "trabaja en"
    negocio ||--|{ sucursal : "tiene"
    negocio ||--o{ miembro_negocio : "tiene"
    miembro_negocio ||--|{ asignacion_rol : "recibe"
    rol ||--o{ asignacion_rol : "se asigna en"
    sucursal |o--o{ asignacion_rol : "limita"
    rol ||--o{ rol_permiso : "agrupa"
    permiso ||--o{ rol_permiso : "pertenece a"
    miembro_negocio ||--o| profesional : "puede ser"
```

La política del negocio del bloque 1 (`PoliticaNegocio`) queda como columna de `negocio` (`acepta_productos_dueno`), porque en el MVP es una sola. Si crecen, pasan a su propia tabla.

---

## 4. Suscripciones, planes y parámetros (bloque 2)

```mermaid
erDiagram
    plan {
        uuid plan_id PK
        text clave UK "basico, extendido, tienda_digital"
        text nombre
        text estado "disponible, oculto, retirado"
    }
    precio_plan {
        uuid precio_plan_id PK
        uuid plan_id FK
        importe precio_mensual
        importe precio_sucursal_adicional
        date vigente_desde
        date vigente_hasta "nulo = vigente"
    }
    entitlement {
        uuid entitlement_id PK
        uuid plan_id FK "UK junto con clave"
        text clave "sucursales_incluidas, admite_sucursales_adicionales, campanas_activas"
        integer valor_entero
        boolean valor_booleano
    }
    suscripcion {
        uuid suscripcion_id PK
        uuid negocio_id FK, UK
        uuid plan_id FK
        text estado "prueba, activa, gracia, solo_lectura, sin_acceso, eliminada"
        timestamptz estado_desde
        boolean prueba_usada
        date periodo_inicio
        date periodo_fin
    }
    cambio_suscripcion {
        uuid cambio_suscripcion_id PK
        uuid suscripcion_id FK
        uuid negocio_id FK
        text estado_anterior
        text estado_nuevo
        uuid plan_anterior_id FK
        uuid plan_nuevo_id FK
        text motivo
        text realizado_por "usuario o proceso"
        timestamptz realizado_en
    }
    periodo_facturacion {
        uuid periodo_facturacion_id PK
        uuid suscripcion_id FK
        uuid negocio_id FK
        date inicio
        date fin
        text estado "abierto, por_pagar, pagado, bonificado"
        importe total
    }
    cargo {
        uuid cargo_id PK
        uuid periodo_facturacion_id FK
        uuid negocio_id FK
        text tipo "plan, sucursal_adicional, espacio_mascota"
        text descripcion
        integer cantidad
        importe precio_unitario
        importe importe
        boolean bonificado
    }
    pago_suscripcion {
        uuid pago_suscripcion_id PK
        uuid negocio_id FK
        date fecha
        importe importe
        text medio
        text referencia
        uuid registrado_por_usuario_id FK
    }
    pago_periodo {
        uuid pago_suscripcion_id PK, FK
        uuid periodo_facturacion_id PK, FK
        importe importe_aplicado
    }
    movimiento_mes_a_favor {
        uuid movimiento_mes_a_favor_id PK
        uuid negocio_id FK
        text tipo "ganado, consumido"
        integer meses "+1 o -1"
        uuid beneficio_referido_id FK
        uuid periodo_facturacion_id FK
        timestamptz ocurrido_en
    }
    cargo_espacio_mascota {
        uuid cargo_espacio_mascota_id PK
        uuid negocio_id FK
        uuid sucursal_id FK
        uuid usuario_id FK "dueño que compra el espacio"
        uuid venta_detalle_id FK
        uuid cargo_id FK "nulo hasta el cierre del periodo"
        importe importe
        timestamptz vendido_en
    }
    parametro {
        uuid parametro_id PK
        text clave UK
        text grupo
        text tipo_dato "entero, dias, horas, importe, booleano, lista"
        text descripcion
    }
    version_parametro {
        uuid version_parametro_id PK
        uuid parametro_id FK
        jsonb valor
        timestamptz vigente_desde
        uuid cambiado_por_usuario_id FK
        text motivo
    }

    plan ||--|{ precio_plan : "tiene"
    plan ||--|{ entitlement : "habilita"
    negocio ||--|| suscripcion : "tiene"
    plan ||--o{ suscripcion : "se contrata en"
    suscripcion ||--o{ cambio_suscripcion : "registra"
    suscripcion ||--o{ periodo_facturacion : "se divide en"
    periodo_facturacion ||--o{ cargo : "incluye"
    pago_suscripcion ||--|{ pago_periodo : "se aplica en"
    periodo_facturacion ||--o{ pago_periodo : "recibe"
    negocio ||--o{ movimiento_mes_a_favor : "acumula"
    periodo_facturacion |o--o{ movimiento_mes_a_favor : "consume"
    sucursal ||--o{ cargo_espacio_mascota : "vende"
    cargo |o--o{ cargo_espacio_mascota : "cobra"
    parametro ||--|{ version_parametro : "tiene"
```

---

## 5. Mascotas, propiedad y espacios (bloque 3)

```mermaid
erDiagram
    especie {
        uuid especie_id PK
        text nombre UK "perro, gato, ave, roedor, reptil, otro"
    }
    raza {
        uuid raza_id PK
        uuid especie_id FK "UK junto con nombre"
        text nombre
    }
    mascota {
        uuid mascota_id PK
        text nombre
        uuid especie_id FK
        uuid raza_id FK
        text raza_texto "Otra o Mestizo"
        text sexo "macho, hembra"
        text estado_reproductivo
        date fecha_nacimiento
        text color
        text caracteristicas_fisicas
        text senas_particulares
        text microchip "UK entre mascotas activas"
        text alergias
        text condiciones_especiales
        text medicamentos_activos
        text dieta
        uuid veterinario_habitual_negocio_id FK
        text veterinario_habitual_texto
        uuid foto_documento_id FK
        text estado "provisional, activa, fallecida, oculta, fusionada, eliminada"
        text tipo_espacio "base, beneficio, pagado; nulo si provisional"
        uuid negocio_custodio_id FK "solo si es provisional"
        uuid cliente_custodio_id FK "solo si es provisional"
        uuid fusionada_en_mascota_id FK
    }
    propiedad {
        uuid propiedad_id PK
        uuid mascota_id FK
        uuid usuario_id FK
        timestamptz desde
        timestamptz hasta "nulo = propietario vigente; una sola abierta por mascota"
    }
    autorizacion {
        uuid autorizacion_id PK
        uuid mascota_id FK
        uuid propietario_usuario_id FK
        uuid autorizado_usuario_id FK "nulo hasta que acepta"
        citext correo_invitado
        text codigo UK
        text estado "pendiente, vigente, rechazada, cancelada, vencida, retirada"
        timestamptz vence_en
        timestamptz respondida_en
        timestamptz terminada_en
    }
    transferencia_propiedad {
        uuid transferencia_propiedad_id PK
        uuid mascota_id FK
        uuid usuario_origen_id FK
        uuid usuario_destino_id FK
        text estado "solicitada, aceptada, rechazada, cancelada, vencida"
        timestamptz vence_en
        timestamptz respondida_en
    }
    fallecimiento {
        uuid mascota_id PK, FK
        date fecha
        uuid registrado_por_usuario_id FK
        uuid negocio_id FK "nulo si lo registró el dueño"
        uuid sucursal_id FK
    }

    especie ||--o{ raza : "tiene"
    especie ||--o{ mascota : "clasifica"
    raza |o--o{ mascota : "clasifica"
    mascota ||--|{ propiedad : "historial"
    usuario ||--o{ propiedad : "es dueño en"
    mascota ||--o{ autorizacion : "concede"
    usuario ||--o{ autorizacion : "recibe"
    mascota ||--o{ transferencia_propiedad : "tiene"
    mascota ||--o| fallecimiento : "puede tener"
    mascota |o--o| mascota : "fusionada en"
```

Los **espacios** no tienen tabla: se calculan con el parámetro de espacios base, los beneficios de referidos (`beneficio_referido`) y los espacios pagados (`cargo_espacio_mascota`), contra las mascotas activas por `tipo_espacio`. El **último peso** tampoco: sale del evento de peso más reciente.

---

## 6. Vinculación, privacidad y clientes (bloque 4)

```mermaid
erDiagram
    vinculacion {
        uuid vinculacion_id PK
        uuid usuario_id FK
        uuid negocio_id FK
        uuid sucursal_origen_id FK
        uuid aceptacion_id FK
        text estado "vigente, retirada; una sola vigente por usuario y negocio"
        timestamptz vinculada_en
        timestamptz retirada_en
    }
    mascota_vinculada {
        uuid vinculacion_id PK, FK
        uuid mascota_id PK, FK
        uuid negocio_id FK
        timestamptz desde
        timestamptz hasta "nulo = compartida"
    }
    cliente {
        uuid cliente_id PK
        uuid negocio_id FK
        uuid usuario_id FK "nulo si es provisional"
        text estado "provisional, vinculado"
        text nombre
        text telefono
        citext correo
        text notas_internas
        text_array etiquetas "text[]"
    }
    invitacion_activacion {
        uuid invitacion_activacion_id PK
        uuid negocio_id FK
        uuid cliente_id FK
        text codigo UK
        citext correo_destino
        text estado "enviada, aceptada, vencida, cancelada"
        timestamptz enviada_en
        timestamptz vence_en
        timestamptz aceptada_en
        uuid aceptada_por_usuario_id FK
    }
    invitacion_activacion_mascota {
        uuid invitacion_activacion_id PK, FK
        uuid mascota_id PK, FK
    }
    documento_legal {
        uuid documento_legal_id PK
        text clave UK "aviso_privacidad, terminos, consentimiento_vinculacion, responsiva, ..."
        text nombre
    }
    version_documento_legal {
        uuid version_documento_legal_id PK
        uuid documento_legal_id FK "UK junto con numero"
        integer numero
        text texto
        boolean obligatoria
        timestamptz publicada_en
    }
    aceptacion {
        uuid aceptacion_id PK
        uuid usuario_id FK
        uuid version_documento_legal_id FK
        text contexto "registro, vinculacion, activacion, nueva_version"
        uuid negocio_id FK
        uuid sucursal_id FK
        timestamptz aceptada_en
    }

    usuario ||--o{ vinculacion : "se vincula"
    negocio ||--o{ vinculacion : "recibe"
    vinculacion ||--|{ mascota_vinculada : "comparte"
    mascota ||--o{ mascota_vinculada : "compartida en"
    aceptacion ||--o| vinculacion : "respalda"
    negocio ||--o{ cliente : "tiene"
    usuario |o--o{ cliente : "es"
    cliente ||--o{ invitacion_activacion : "recibe"
    invitacion_activacion ||--|{ invitacion_activacion_mascota : "incluye"
    documento_legal ||--|{ version_documento_legal : "tiene"
    version_documento_legal ||--o{ aceptacion : "aceptada en"
    usuario ||--o{ aceptacion : "otorga"
```

En la tabla, `etiquetas` es de tipo `text[]`; en el diagrama aparece como `text_array` porque Mermaid no acepta corchetes en ese lugar.

---

## 7. Expediente, prevención y documentos (bloque 5)

```mermaid
erDiagram
    evento_mascota {
        uuid evento_mascota_id PK
        uuid mascota_id FK
        uuid negocio_id FK "nulo si lo registró el dueño"
        uuid sucursal_id FK
        uuid registrado_por_usuario_id FK
        uuid profesional_id FK "miembro_negocio"
        uuid cita_id FK
        text tipo "consulta, aplicacion_preventiva, certificado, servicio_no_clinico, nota_interna, evento_dueno"
        text nivel "1, 2, 3, interno"
        timestamptz ocurrido_en
        text estado "vigente, corregido"
        uuid corrige_evento_id FK
        text motivo_correccion
    }
    consulta {
        uuid evento_mascota_id PK, FK
        text motivo
        text diagnostico
        text tratamiento
        text observaciones
    }
    signos_vitales {
        uuid signos_vitales_id PK
        uuid evento_mascota_id FK
        peso_kg peso "nivel 1"
        numeric temperatura_c "numeric(4,1)"
        smallint frecuencia_cardiaca
        smallint frecuencia_respiratoria
        smallint condicion_corporal "escala 1 a 9"
    }
    receta {
        uuid receta_id PK
        uuid evento_mascota_id FK
        text indicaciones
    }
    receta_medicamento {
        uuid receta_medicamento_id PK
        uuid receta_id FK
        text medicamento
        text dosis
        text frecuencia
        text duracion
    }
    estudio {
        uuid estudio_id PK
        uuid evento_mascota_id FK
        text tipo "laboratorio, imagen"
        text descripcion
        text resultado
    }
    procedimiento {
        uuid procedimiento_id PK
        uuid evento_mascota_id FK
        text tipo "procedimiento, cirugia"
        text descripcion
        text observaciones
    }
    aplicacion_preventiva {
        uuid evento_mascota_id PK, FK
        text tipo "vacuna, desparasitacion, preventivo"
        text origen_producto "inventario, dueno"
        uuid producto_id FK "si viene del inventario"
        integer cantidad
        text nombre_comercial
        text laboratorio
        text lote
        date caducidad
        date proxima_dosis
        boolean revision_confirmada "solo producto del dueño"
        uuid responsiva_documento_id FK "obligatoria si es del dueño"
    }
    certificado {
        uuid evento_mascota_id PK, FK
        text tipo "vacunacion, salud, viaje"
        uuid documento_id FK
    }
    servicio_no_clinico {
        uuid evento_mascota_id PK, FK
        timestamptz inicio
        timestamptz conclusion
        text observaciones
    }
    nota_interna {
        uuid evento_mascota_id PK, FK
        text texto
    }
    evento_dueno {
        uuid evento_mascota_id PK, FK
        text tipo "peso, nota"
        peso_kg peso
        text texto
    }
    documento {
        uuid documento_id PK
        uuid negocio_id FK "nulo si lo subió el dueño"
        uuid subido_por_usuario_id FK
        uuid mascota_id FK
        uuid evento_mascota_id FK
        text tipo "fotografia, receta, estudio, firmado, responsiva, logo, producto"
        text nombre_archivo
        text tipo_contenido "image/jpeg, image/png, image/webp, application/pdf"
        bigint tamano_bytes
        text clave_almacenamiento "ruta en Object Storage"
        text clave_miniatura
        integer version
        uuid reemplaza_documento_id FK
        timestamptz eliminado_en
    }

    mascota ||--o{ evento_mascota : "tiene"
    evento_mascota ||--o| consulta : "es"
    evento_mascota ||--o| aplicacion_preventiva : "es"
    evento_mascota ||--o| certificado : "es"
    evento_mascota ||--o| servicio_no_clinico : "es"
    evento_mascota ||--o| nota_interna : "es"
    evento_mascota ||--o| evento_dueno : "es"
    evento_mascota ||--o{ signos_vitales : "incluye"
    evento_mascota ||--o{ receta : "incluye"
    receta ||--|{ receta_medicamento : "indica"
    evento_mascota ||--o{ estudio : "incluye"
    evento_mascota ||--o{ procedimiento : "incluye"
    evento_mascota ||--o{ documento : "adjunta"
    evento_mascota |o--o| evento_mascota : "corrige a"
    documento |o--o| documento : "reemplaza a"
```

`evento_mascota` es la tabla base; cada tipo tiene su tabla de detalle con la misma llave (herencia por tabla).

---

## 8. Servicios, agenda y citas (bloque 6)

```mermaid
erDiagram
    servicio {
        uuid servicio_id PK
        uuid negocio_id FK
        text nombre
        text descripcion
        text categoria "clinico, preventivo, estetica, otro"
        integer duracion_min
        integer tiempo_adicional_min
        importe precio
        boolean precio_publicado "false = no listado"
        uuid tasa_iva_id FK
        integer ventana_cancelacion_min "nulo = la de la plataforma"
        boolean publicado
        text estado "activo, inactivo"
    }
    variante_servicio {
        uuid variante_servicio_id PK
        uuid servicio_id FK
        uuid negocio_id FK
        text nombre
        uuid especie_id FK
        text tamano
        uuid raza_id FK
        peso_kg peso_min
        peso_kg peso_max
        text condicion_clinica
        boolean producto_del_dueno "Aplicación con producto del dueño"
        importe precio
        integer duracion_min
    }
    servicio_sucursal {
        uuid servicio_id PK, FK
        uuid sucursal_id PK, FK
        uuid negocio_id FK
        boolean ofrecido
        importe precio "nulo = precio del negocio"
        integer duracion_min
    }
    horario_sucursal {
        uuid horario_sucursal_id PK
        uuid sucursal_id FK
        uuid negocio_id FK
        smallint dia_semana "1 lunes a 7 domingo"
        time abre
        time cierra
    }
    dia_especial {
        uuid dia_especial_id PK
        uuid sucursal_id FK
        uuid negocio_id FK
        date fecha
        boolean cerrado
        time abre
        time cierra
    }
    regla_capacidad {
        uuid regla_capacidad_id PK
        uuid sucursal_id FK
        uuid negocio_id FK
        text categoria
        smallint dia_semana
        time desde
        time hasta
        integer mascotas_simultaneas
    }
    cita {
        uuid cita_id PK
        uuid negocio_id FK
        uuid sucursal_id FK
        uuid cliente_id FK
        uuid mascota_id FK
        text origen "app_dueno, negocio"
        uuid solicitada_por_usuario_id FK
        uuid profesional_id FK
        timestamptz inicio
        timestamptz fin
        text estado "solicitada, confirmada, en_proceso, completada, rechazada, vencida, cancelada, no_atendida"
        importe precio_estimado
        importe precio_final
    }
    servicio_cita {
        uuid servicio_cita_id PK
        uuid cita_id FK
        uuid negocio_id FK
        uuid servicio_id FK
        uuid variante_servicio_id FK
        importe precio
        integer duracion_min
    }
    cambio_cita {
        uuid cambio_cita_id PK
        uuid cita_id FK
        uuid negocio_id FK
        text estado_anterior
        text estado_nuevo
        timestamptz inicio_anterior
        timestamptz inicio_nuevo
        text mensaje
        uuid realizado_por_usuario_id FK
        timestamptz realizado_en
    }

    servicio ||--o{ variante_servicio : "tiene"
    servicio ||--o{ servicio_sucursal : "se ajusta en"
    sucursal ||--o{ servicio_sucursal : "ofrece"
    sucursal ||--|{ horario_sucursal : "atiende"
    sucursal ||--o{ dia_especial : "excepciones"
    sucursal ||--o{ regla_capacidad : "limita"
    sucursal ||--o{ cita : "agenda"
    mascota ||--o{ cita : "tiene"
    cliente ||--o{ cita : "de"
    cita ||--|{ servicio_cita : "incluye"
    servicio ||--o{ servicio_cita : "se agenda en"
    variante_servicio |o--o{ servicio_cita : "aplica"
    cita ||--o{ cambio_cita : "registra"
    cita |o--o{ evento_mascota : "origina"
```

La **disponibilidad** no tiene tabla: se calcula con horarios, días especiales, reglas de capacidad y citas que se traslapan.

---

## 9. Inventario, promociones y ventas (bloque 7)

```mermaid
erDiagram
    tasa_iva {
        uuid tasa_iva_id PK
        text nombre
        porcentaje porcentaje "16.00, 8.00, 0.00"
        boolean por_defecto
        boolean activa
    }
    categoria_producto {
        uuid categoria_producto_id PK
        uuid negocio_id FK
        text nombre
    }
    producto {
        uuid producto_id PK
        uuid negocio_id FK
        uuid categoria_producto_id FK
        text nombre
        text descripcion
        text unidad_medida "pieza, ml, g, dosis"
        text codigo_barras
        importe precio "con IVA"
        uuid tasa_iva_id FK
        uuid imagen_documento_id FK
        boolean visible
        text estado "activo, inactivo"
    }
    producto_sucursal {
        uuid producto_id PK, FK
        uuid sucursal_id PK, FK
        uuid negocio_id FK
        integer existencia "solo cambia con movimientos, nunca negativa"
        integer stock_minimo
        integer stock_maximo
        costo costo_promedio
        importe precio "nulo = precio del negocio"
    }
    movimiento_inventario {
        uuid movimiento_inventario_id PK
        uuid negocio_id FK
        uuid sucursal_id FK
        uuid producto_id FK
        text tipo "entrada_inicial, entrada_manual, venta, devolucion_cancelacion, aplicacion_clinica, consumo_interno, merma, caducidad, ajuste"
        integer cantidad "positiva entra, negativa sale"
        costo costo_unitario
        integer existencia_resultante
        text motivo
        text origen_tipo "venta_detalle, evento_mascota, cita, conteo_fisico"
        uuid origen_id
        uuid realizado_por_usuario_id FK
        timestamptz realizado_en
    }
    conteo_fisico {
        uuid conteo_fisico_id PK
        uuid negocio_id FK
        uuid sucursal_id FK
        uuid categoria_producto_id FK "nulo = toda la sucursal"
        text estado "en_captura, autorizado"
        timestamptz iniciado_en
        timestamptz autorizado_en
        uuid autorizado_por_usuario_id FK
    }
    conteo_detalle {
        uuid conteo_fisico_id PK, FK
        uuid producto_id PK, FK
        uuid negocio_id FK
        integer existencia_teorica
        integer cantidad_contada
        integer diferencia
    }
    promocion {
        uuid promocion_id PK
        uuid negocio_id FK
        text nombre
        uuid imagen_documento_id FK
        importe precio "con IVA"
        uuid tasa_iva_id FK
        date vigente_desde
        date vigente_hasta
        text estado "activa, inactiva"
    }
    componente_promocion {
        uuid promocion_id PK, FK
        uuid producto_id PK, FK
        uuid negocio_id FK
        integer cantidad
    }
    venta {
        uuid venta_id PK
        uuid negocio_id FK
        uuid sucursal_id FK
        text folio "UK por sucursal, VE-00001"
        uuid cliente_id FK
        uuid cita_id FK
        uuid realizada_por_usuario_id FK
        timestamptz realizada_en
        importe total
        importe recibido
        importe cambio
        text estado "registrada, cancelada"
        uuid llave_idempotencia UK "evita doble envío"
    }
    venta_detalle {
        uuid venta_detalle_id PK
        uuid venta_id FK
        uuid negocio_id FK
        text tipo "producto, promocion, servicio, espacio_mascota"
        uuid producto_id FK
        uuid promocion_id FK
        uuid servicio_id FK
        uuid variante_servicio_id FK
        text descripcion
        integer cantidad
        importe precio_unitario
        importe importe
        porcentaje tasa_iva
        importe iva
    }
    venta_detalle_componente {
        uuid venta_detalle_id PK, FK
        uuid producto_id PK, FK
        integer cantidad
    }
    pago_venta {
        uuid pago_venta_id PK
        uuid venta_id FK
        uuid negocio_id FK
        text medio "efectivo, tarjeta_terminal_propia, transferencia"
        importe importe
    }
    cancelacion_venta {
        uuid venta_id PK, FK
        uuid negocio_id FK
        text motivo
        uuid cancelada_por_usuario_id FK
        timestamptz cancelada_en
    }
    impresion_ticket {
        uuid impresion_ticket_id PK
        uuid venta_id FK
        uuid negocio_id FK
        text tipo "original, copia, cancelada"
        uuid impreso_por_usuario_id FK
        timestamptz impreso_en
    }
    folio_sucursal {
        uuid sucursal_id PK, FK
        text tipo PK "venta"
        integer ultimo
    }

    tasa_iva ||--o{ producto : "aplica"
    categoria_producto ||--o{ producto : "agrupa"
    producto ||--o{ producto_sucursal : "se maneja en"
    sucursal ||--o{ producto_sucursal : "tiene"
    producto_sucursal ||--o{ movimiento_inventario : "registra"
    sucursal ||--o{ conteo_fisico : "realiza"
    conteo_fisico ||--|{ conteo_detalle : "incluye"
    promocion ||--|{ componente_promocion : "se compone de"
    producto ||--o{ componente_promocion : "forma"
    sucursal ||--o{ venta : "cobra"
    venta ||--|{ venta_detalle : "incluye"
    venta_detalle ||--o{ venta_detalle_componente : "desglosa"
    venta ||--|{ pago_venta : "se paga con"
    venta ||--o| cancelacion_venta : "puede tener"
    venta ||--o{ impresion_ticket : "se imprime"
    cliente |o--o{ venta : "compra"
    cita |o--o{ venta : "se cobra en"
    sucursal ||--|{ folio_sucursal : "numera"
```

El **corte de caja** no tiene tabla: se calcula con las ventas, pagos y cancelaciones del día.

---

## 10. Referidos (bloque 8)

```mermaid
erDiagram
    codigo_invitacion {
        uuid codigo_invitacion_id PK
        text codigo UK
        uuid usuario_id FK "uno de los dos"
        uuid negocio_id FK "uno de los dos"
    }
    referido_usuario {
        uuid referido_usuario_id PK
        uuid usuario_referidor_id FK
        uuid usuario_referido_id FK, UK
        uuid codigo_invitacion_id FK
        text estado "en_seguimiento, cumplido, cumplido_sin_beneficio, anulado"
        integer servicios_contados
        timestamptz evaluado_en
        timestamptz cumplido_en
    }
    solicitud_afiliacion {
        uuid solicitud_afiliacion_id PK
        uuid codigo_invitacion_id FK
        text nombre_negocio
        text contacto_nombre
        citext correo
        text telefono
        text rfc
        text mensaje
        text estado "nueva, en_contacto, dada_de_alta, descartada"
        uuid atendida_por_usuario_id FK
    }
    referido_negocio {
        uuid referido_negocio_id PK
        uuid negocio_referidor_id FK
        uuid negocio_referido_id FK, UK
        uuid solicitud_afiliacion_id FK
        text estado "en_seguimiento, cumplido, anulado"
        integer periodos_pagados_consecutivos
        timestamptz evaluado_en
        timestamptz cumplido_en
    }
    beneficio_referido {
        uuid beneficio_referido_id PK
        text tipo "espacio_mascota, mes_gratuito"
        uuid referido_usuario_id FK
        uuid referido_negocio_id FK
        uuid beneficiario_usuario_id FK
        uuid beneficiario_negocio_id FK
        timestamptz otorgado_en
    }

    codigo_invitacion ||--o{ referido_usuario : "registra"
    codigo_invitacion ||--o{ solicitud_afiliacion : "origina"
    solicitud_afiliacion ||--o| referido_negocio : "se convierte en"
    referido_usuario ||--o| beneficio_referido : "otorga"
    referido_negocio ||--o| beneficio_referido : "otorga"
    beneficio_referido ||--o| movimiento_mes_a_favor : "genera"
```

---

## 11. Notificaciones, reseñas, campañas y auditoría (bloque 9)

```mermaid
erDiagram
    tipo_notificacion {
        uuid tipo_notificacion_id PK
        text clave UK
        text nombre
        text_array canales "text[]: correo, push, buzon"
        integer tiempo_util_min
        text destinatario "dueno, personal, cliente_provisional"
        boolean es_campana
    }
    preferencia_notificacion {
        uuid usuario_id PK, FK
        uuid tipo_notificacion_id PK, FK
        text canal PK "correo, push"
        boolean activa
    }
    dispositivo_push {
        uuid dispositivo_push_id PK
        uuid usuario_id FK
        text plataforma "ios, android"
        text token UK
        timestamptz dado_de_baja_en
    }
    notificacion {
        uuid notificacion_id PK
        uuid tipo_notificacion_id FK
        uuid usuario_id FK
        uuid cliente_id FK "cliente provisional"
        citext correo_destino
        uuid negocio_id FK
        uuid campana_id FK
        text canal "correo, push, buzon"
        text titulo
        text cuerpo
        timestamptz programada_para
        timestamptz descartar_despues_de
        text estado "pendiente, enviada, fallida, descartada, leida"
        timestamptz enviada_en
        timestamptz leida_en
    }
    error_envio {
        uuid error_envio_id PK
        uuid notificacion_id FK
        text proveedor
        text mensaje
        timestamptz ocurrido_en
    }
    resena {
        uuid resena_id PK
        uuid negocio_id FK
        uuid sucursal_id FK
        uuid cita_id FK
        uuid usuario_id FK
        smallint calificacion "1 a 5"
        text comentario
        text estado "recibida, en_revision, publicada, oculta, retirada"
        timestamptz publicada_en
    }
    respuesta_resena {
        uuid resena_id PK, FK
        uuid negocio_id FK
        text texto
        text estado "en_revision, publicada, oculta, retirada"
        timestamptz publicada_en
    }
    campana {
        uuid campana_id PK
        uuid negocio_id FK
        uuid sucursal_id FK "nulo = todo el negocio"
        uuid copia_de_campana_id FK
        text titulo
        text texto
        uuid imagen_documento_id FK
        text_array canales "text[]: correo, push, banner"
        date vigente_desde
        date vigente_hasta
        smallint frecuencia_por_semana
        smallint prioridad
        text estado "borrador, activa, inactiva, oculta, finalizada"
        timestamptz publicada_en
        uuid oculta_por_usuario_id FK
    }
    criterio_audiencia {
        uuid criterio_audiencia_id PK
        uuid campana_id FK
        uuid negocio_id FK
        text atributo "especie, raza, sexo, edad, sucursal, servicio_previo"
        text operador "igual, entre, en"
        jsonb valor
    }
    registro_auditoria {
        uuid registro_auditoria_id PK
        uuid negocio_id FK
        uuid sucursal_id FK
        uuid usuario_id FK
        text proceso "si lo hizo un proceso"
        text accion
        text entidad
        uuid entidad_id
        jsonb antes
        jsonb despues
        text origen "app_dueno, app_negocio, admin, proceso"
        timestamptz ocurrido_en
    }

    tipo_notificacion ||--o{ notificacion : "clasifica"
    tipo_notificacion ||--o{ preferencia_notificacion : "se configura"
    usuario ||--o{ preferencia_notificacion : "define"
    usuario ||--o{ dispositivo_push : "registra"
    usuario |o--o{ notificacion : "recibe"
    notificacion ||--o{ error_envio : "puede fallar"
    campana |o--o{ notificacion : "genera"
    campana ||--o{ criterio_audiencia : "filtra"
    campana |o--o{ campana : "copia de"
    sucursal ||--o{ resena : "recibe"
    resena ||--o| respuesta_resena : "tiene"
```

`resena` y `respuesta_resena` son de R2; se incluyen para que el modelo quede completo, pero no se crean en el MVP. `registro_auditoria` solo acepta inserciones y conviene particionarla por mes por su volumen.

---

## 12. Resumen

| Bloque | Tablas |
|---|---|
| 1. Identidad y acceso | 11 |
| 2. Suscripciones, planes y parámetros | 13 |
| 3. Mascotas, propiedad y espacios | 7 |
| 4. Vinculación, privacidad y clientes | 8 |
| 5. Expediente, prevención y documentos | 13 |
| 6. Servicios, agenda y citas | 9 |
| 7. Inventario, promociones y ventas | 16 |
| 8. Referidos | 5 |
| 9. Notificaciones, reseñas, campañas y auditoría | 10 (2 de R2) |
| **Total** | **92** |

Se calculan y no tienen tabla: espacios de mascota, último peso, disponibilidad de agenda, corte de caja, línea de tiempo y carnet.

## 13. Decisiones confirmadas

| # | Decisión |
|---|---|
| 1 | Nombres en `snake_case` y con nombre completo (`venta_id`). Sustituye la forma `ventaId` de App-Ventas. |
| 2 | Llave primaria UUID versión 7 generada por el API; el prefijo solo se agrega al exponerla. |
| 3 | Estados y tipos como `text` con `CHECK`, no `enum` de PostgreSQL. |
| 4 | Dominios `importe`, `costo`, `porcentaje` y `peso_kg`. |
| 5 | La existencia se guarda en `producto_sucursal` y se actualiza en la misma transacción que cada movimiento. |
| 6 | La política del negocio es una columna de `negocio` mientras sea una sola. |
| 7 | `registro_auditoria` se particiona por mes. |

## 14. Siguientes pasos

1. Matriz de roles y permisos: llena `permiso` y `rol_permiso`.
2. Modelo de privacidad: políticas RLS por `negocio_id` y reglas de los niveles de visibilidad sobre `evento_mascota`.
3. Script de creación (migraciones), índices y datos iniciales (especies, roles, tasas de IVA, tipos de notificación, parámetros), cuando empiece el repositorio del API.

# Estrategia de trabajo paralelo y documentación

**Proyecto:** Plataforma para el Cuidado de Mascotas  
**Fecha:** 2026-09-25  
**Versión:** 1.3  
**Estado:** vigente. La versión 1.2 fija el equipo real (sección 4) y el trabajo en una sola rama con push al cerrar cada feature (sección 6); la 1.3, la estructura autosuficiente de cada repositorio (sección 8), preparada en los cuatro repositorios.

## 1. Propósito

Este documento define una forma común de planear, analizar, construir, revisar y documentar features en los cuatro repositorios de AppMascotas.

El objetivo es que dos desarrolladores puedan avanzar en paralelo sin perder la trazabilidad entre:

- Requerimiento de negocio.
- Decisiones técnicas.
- Cambios en el API.
- Cambios en cada cliente.
- Pruebas y puntos de verificación.
- Conocimiento necesario para mantener el sistema.

La documentación general vive en este repositorio inicial. El código vive en los repositorios de cada componente.

## 2. Repositorios del ecosistema

| Repositorio | Responsabilidad principal | Tecnología prevista |
|---|---|---|
| `app-mascotas-usuario` | App del dueño de la mascota | Flutter, iOS y Android |
| `app-mascotas-negocio` | Operación del negocio en web y tablet | Flutter Web y Flutter para tablet |
| `app-mascotas-admin` | Portal de administración de la plataforma | Vue 3, TypeScript y Vite |
| `app-mascotas-api` | API común, reglas de negocio, persistencia e integraciones | ASP.NET Core .NET 10, PostgreSQL/PostGIS y Object Storage |

El API es el único componente que se conecta a PostgreSQL y a Object Storage. Ningún cliente contiene credenciales ni se conecta directamente con esos servicios.

## 3. Fuente de verdad y precedencia

El orden de autoridad documental es:

1. Decisiones aprobadas por el responsable del producto.
2. `docs/02-requerimiento.md`, versión vigente del requerimiento consolidado.
3. Documento de pendientes vigente (`docs/04-pendientes.md`).
4. Documentos de requerimiento de cada feature.
5. Análisis técnico y planes de trabajo.
6. Código y comentarios de implementación.

Si el código contradice el requerimiento aprobado, el equipo debe registrar la diferencia como una decisión pendiente o actualizar formalmente el requerimiento. No se resuelven contradicciones importantes solo modificando código.

Los documentos anteriores se conservan como historial, pero no deben usarse para recuperar decisiones sustituidas.

## 4. Equipo y responsabilidades

El equipo son dos personas, Alex y Juan, y cada uno trabaja con su propia sesión de Claude. Claude escribe el código, las pruebas automáticas y la documentación de cada feature; la persona responsable del repositorio revisa, prueba, resuelve las dudas de producto y decide cuándo se cierra una feature.

| Repositorio | Responsable | Quién construye | Cuándo arranca |
|---|---|---|---|
| `app-mascotas-api` | Alex | Claude, en la sesión de Alex | Etapa 0 |
| `app-mascotas-admin` | Juan | Claude, en la sesión de Juan (su laptop) | R0 |
| `app-mascotas-negocio` | Por asignar (Alex o Juan); mientras tanto aprueba Alex | Claude | R0 |
| `app-mascotas-usuario` | Por asignar; mientras tanto aprueba Alex | Claude | R1b |

El orden de las etapas y las features está en `docs/10-plan-construccion.md`.

### Qué hace Claude

- Analiza el código real antes de ajustar el plan de cada feature.
- Escribe el código junto con sus pruebas automáticas, no al final.
- Escribe los documentos `01` a `04` de cada feature (y `05` cuando aplique).
- Pregunta al responsable cuando algo no está en el requerimiento; no lo resuelve por suposición.
- Prepara el commit de cierre, pero solo hace commit y push cuando el responsable lo indica.

### Qué hace el responsable

- Aprueba el requerimiento y el plan de cada feature antes de construir.
- Revisa el código, baja los cambios y prueba.
- Pide ajustes y, cuando todo está bien, indica el commit y el push.

### Coordinación entre las dos sesiones

- `app-mascotas-api` es la fuente de los contratos HTTP (sección 16). La sesión de Juan construye el admin contra el contrato publicado en el repositorio del API.
- Este repositorio (`app-mascotas`) es la documentación de producto que comparten ambas sesiones: requerimiento, modelos, estrategia y plan de construcción.
- Si una sesión necesita un cambio en un repositorio que no es el suyo, lo pide a su responsable; no lo modifica directamente.
- Ningún repositorio copia reglas de negocio críticas que deban vivir en el API.

## 5. Estrategia para trabajar en paralelo

### 5.1 Trabajo orientado a features

Una feature se identifica globalmente con un código, por ejemplo `F-001-alta-mascota`. El mismo código se usa en todos los repositorios involucrados:

```text
docs/features/F-001-alta-mascota/
```

Una feature puede tener cambios en uno o varios repositorios. No se considera terminada hasta que se verifique el flujo completo o se documente claramente qué parte queda fuera.

### 5.2 División por capas

Cuando una feature requiere API y clientes, se trabaja en este orden:

1. Requerimiento y alcance.
2. Análisis de cada repositorio afectado.
3. Diseño del contrato del API.
4. Implementación del API y pruebas del contrato.
5. Implementación de clientes usando el contrato acordado.
6. Integración con datos reales.
7. Verificación transversal.
8. Resumen de lo construido y decisiones tomadas.

Los clientes pueden avanzar en paralelo con estados de carga, error y datos simulados documentados, pero no deben cerrar la feature usando mocks como sustituto de la integración real.

Dentro de cada repositorio se puede trabajar por fases o incrementos, pero cada incremento debe dejar el proyecto compilable y verificable. Una feature transversal no obliga a que los cuatro repositorios avancen al mismo ritmo: el contrato del API y los puntos de integración son los que coordinan el trabajo.

### 5.3 Matriz de impacto

Cada plan debe indicar el impacto:

| Repositorio | Tipo de cambio | Responsable | Dependencia |
|---|---|---|---|
| API | Endpoint, dominio, migración o integración | Nombre | Ninguna o lista |
| Usuario | Pantalla, estado, navegación o integración | Nombre | Contrato API |
| Negocio | Flujo web/tablet o integración | Nombre | Contrato API |
| Admin | Pantalla administrativa o configuración | Nombre | Contrato API |

Si una feature solo afecta un repositorio, no se crean documentos artificiales en los demás.

## 6. Ramas y commits

### 6.1 Una sola rama

Para no perdernos, cada repositorio trabaja en **una sola rama: `main`**. No hay ramas por feature ni pull requests mientras el equipo sea de dos personas.

### 6.2 Ciclo de una feature

1. Claude construye la feature completa en su equipo, con pruebas y documentos.
2. El responsable revisa y prueba; si detecta algo, Claude lo ajusta.
3. Cuando todo está bien, **el responsable indica** el commit y el push.
4. La otra persona baja los cambios (`git pull`) y prueba lo que le toca.

No se hace push de trabajo incompleto. Cada push deja el repositorio compilable, con las pruebas en verde y con la feature documentada.

### 6.3 Contenido del commit de cierre

- Mensaje identificable por feature: `F-001: cimientos del API`.
- Código, pruebas y documentos de la feature en el mismo commit.
- Sin secretos, bases locales, archivos de credenciales ni binarios innecesarios.
- Migraciones revisadas por el responsable antes del commit.
- Un cambio incompatible del API requiere una estrategia de compatibilidad o una nueva versión, y aviso a la otra persona.

Si el equipo crece, se retoma el esquema de `develop`, ramas por feature y pull requests con revisor distinto al autor.

## 7. Checkpoints de cada feature

### Checkpoint 0 — Entrada

La feature tiene código, objetivo, alcance, fuera de alcance, dependencias, repositorios afectados, responsable, revisor, requerimientos que cubre y criterios de aceptación.

**Salida:** requerimiento aprobado para análisis.

### Checkpoint 1 — Análisis

Se revisa el estado actual de cada repositorio afectado. El análisis debe responder:

- Qué existe.
- Qué se puede reutilizar.
- Qué falta.
- Qué riesgos hay.
- Qué archivos, módulos o capas se modificarán.
- Qué prueba barata puede detectar un error de enfoque.

**Salida:** análisis firmado por el responsable y el revisor.

El análisis debe mirar el código real y dejar una hipótesis concreta sobre dónde se controla el comportamiento. Si encuentra una decisión de producto o una contradicción documental, la feature se pausa y se solicita definición antes de construir.

### Checkpoint 2 — Contrato

Si hay API, se acuerdan antes de construir:

- Rutas y versión.
- Autenticación y permisos.
- Request y response.
- Errores.
- Paginación y filtros.
- Estados de carga y ausencia de datos.
- Reglas de compatibilidad.

**Salida:** contrato documentado y aceptado por consumidores.

### Checkpoint 3 — Construcción vertical

Se implementa una ruta funcional mínima de extremo a extremo. Por ejemplo: crear mascota en API, persistirla y mostrarla en el cliente correspondiente.

**Salida:** flujo básico verificable con datos reales.

### Checkpoint 4 — Calidad

Se ejecutan pruebas unitarias, de integración, contrato, autorización y UI según el riesgo de la feature.

**Salida:** resultados documentados y defectos críticos resueltos.

### Checkpoint 5 — Integración

Se verifica el flujo entre los repositorios afectados, incluyendo autenticación, errores, permisos, migraciones y datos reales.

**Salida:** prueba transversal aprobada.

### Checkpoint 6 — Cierre

Se actualiza el resumen de construcción, README si cambió el conocimiento general, historial de decisiones y pendientes.

**Salida:** feature cerrada o marcada explícitamente como bloqueada.

El cierre debe distinguir entre:

- Verificado automáticamente.
- Verificado manualmente en dispositivo o navegador.
- No verificado, con motivo explícito.
- Desviaciones respecto al plan.
- Deuda o backlog generado durante la construcción.

## 8. Estructura documental por repositorio

Cada repositorio tiene esta estructura (creada en los cuatro repositorios el 2026-09-25):

```text
README.md
CLAUDE.md                     instrucciones completas para construir en ese repositorio
/docs/
  arquitectura.md
  decisiones.md               registro de decisiones técnicas
  contratos/                  solo en el API: contrato base y OpenAPI exportado
  referencia/                 copias de los documentos de producto que el repositorio necesita
  features/
    README.md                 índice con orden, dependencias y estado
    _plantillas/              02, 03, 04 y 05 para copiar al empezar una feature
    F-001-cimientos-api/
      01-requerimiento.md     escrito de antemano y autosuficiente
      02-analisis-situacion.md
      03-plan-ejecucion.md
      04-construido.md
      05-verificacion.md (cuando la feature sea transversal o requiera un cierre separado)
```

**Autosuficiencia:** quien construye en un repositorio lee solo sus documentos (más el contrato del API, en los clientes). `docs/referencia/` guarda copias con la versión de su fuente; si la fuente cambia en `app-mascotas`, se actualizan la copia y los `01-requerimiento.md` de las features no construidas.

El formato base probado en App-Ventas es de cuatro documentos: `01-requerimiento.md`, `02-analisis-situacion.md`, `03-plan-ejecucion.md` y `04-construido.md`. El quinto documento, `05-verificacion.md`, se usa cuando la feature cruza repositorios, tiene una aceptación transversal o necesita evidencias separadas del resumen de construcción.

El requerimiento y el análisis deben existir antes de construir; el plan se ajusta después del análisis y se aprueba antes de implementar; el resumen y la verificación se completan al cerrar.

### Contenido del README de cada repo

Cada README debe explicar, en español:

1. Propósito y límites del repositorio.
2. Usuario o actor al que sirve.
3. Arquitectura y flujo principal.
4. Estructura de carpetas.
5. Cómo instalar y ejecutar.
6. Variables de configuración, sin incluir secretos.
7. Librerías principales y por qué se usan.
8. Ciclo de vida de la aplicación.
9. Manejo de navegación, estado, errores y sesión.
10. Comunicación con el API.
11. Pruebas y comandos de validación.
12. Cómo agregar una feature.
13. Decisiones conocidas y pendientes.

El README debe enseñar el proyecto a una persona que no lo construyó. La documentación de una librería debe explicar su uso dentro del proyecto, no repetir toda su documentación oficial.

## 9. Plantilla: requerimiento de feature

Archivo: `01-requerimiento.md`

```markdown
# F-000 — Nombre de la feature

**Estado:** propuesta | aprobada | bloqueada | terminada
**Responsable:** nombre
**Revisor:** nombre
**Fecha:** AAAA-MM-DD
**Repositorios afectados:** lista
**Requerimientos cubiertos:** IDs del requerimiento general

## Objetivo

Qué problema resuelve y para quién.

## Alcance

Qué debe permitir el sistema.

## Fuera de alcance

Qué no se construirá en esta feature.

## Actores y permisos

Quién puede ejecutar cada acción.

## Reglas de negocio

Reglas identificadas y referencia al requerimiento general.

## Flujo principal

1. ...
2. ...
3. ...

## Estados y errores esperados

Tabla de estados, errores y comportamiento visible.

## Criterios de aceptación

- [ ] ...
- [ ] ...

## Dependencias

Features, contratos, migraciones o decisiones requeridas.

## Pruebas exigidas

Qué pruebas automáticas, de integración, manuales o de dispositivo se deben ejecutar.

## Decisiones que necesita el responsable

Preguntas que no deben resolverse por suposición durante la construcción.
```

## 10. Plantilla: análisis previo

Archivo: `02-analisis-situacion.md`

```markdown
# F-000 — Nombre de la feature · Análisis de situación

**Fecha:** AAAA-MM-DD
**Analista:** nombre

## Estado actual

Qué existe hoy en cada repositorio afectado.

## Hipótesis de trabajo

Una explicación concreta de dónde debe resolverse la feature.

## Evidencia revisada

Archivos, módulos, endpoints, pruebas y configuraciones consultados.

## Impacto por repositorio

| Repositorio | Módulos | Cambio esperado | Riesgo |
|---|---|---|---|
| ... | ... | ... | ... |

## Contrato necesario

Endpoints, eventos, permisos, request, response y errores.

## Alternativas consideradas

Opciones descartadas y motivo.

## Riesgos y preguntas abiertas

Qué puede bloquear o cambiar el diseño.

## Prueba discriminante

La prueba más barata que puede demostrar que la hipótesis es incorrecta.

## Recomendación

Enfoque recomendado antes de construir.

## Decisiones necesarias

Preguntas que bloquean el inicio o el cierre.
```

## 11. Plantilla: plan de trabajo

Archivo: `03-plan-ejecucion.md`

```markdown
# F-000 — Nombre de la feature · Plan de ejecución

**Responsable:** nombre
**Revisor:** nombre
**Estado:** pendiente | aprobado | en progreso | terminado

## Orden de construcción

1. Contrato y decisiones.
2. API y persistencia.
3. Cliente usuario.
4. Cliente negocio.
5. Portal administrativo.
6. Integración.
7. Pruebas y documentación.

## Tareas

| ID | Repositorio | Tarea | Responsable | Dependencia | Verificación |
|---|---|---|---|---|---|
| T-001 | api | ... | ... | ... | ... |

Cada tarea debe tener una prueba asociada. Las tareas que cambien comportamiento crítico deben indicar también los archivos principales o módulos afectados.

## Cambios de contrato

Rutas, modelos, errores y permisos.

## Migraciones y datos

Tablas, índices, RLS, datos de prueba y reversibilidad.

## Pruebas

Pruebas unitarias, integración, contrato, autorización, UI y regresión.

## Checkpoints

- [ ] Entrada aprobada
- [ ] Análisis revisado
- [ ] Contrato aprobado
- [ ] Flujo vertical funcionando
- [ ] Pruebas ejecutadas
- [ ] Integración aprobada
- [ ] Documentación cerrada

## Criterio de terminado

Qué debe ser cierto para cerrar la feature.

## Commit de cierre

Mensaje propuesto, archivos incluidos y condiciones para solicitar aprobación.
```

## 12. Plantilla: resumen de construcción

Archivo: `04-construido.md`

```markdown
# Construido — F-000 Nombre de la feature

**Fecha de cierre:** AAAA-MM-DD
**Responsable:** nombre
**Revisor:** nombre
**Versión o commit:** referencia

## Resultado

Qué quedó funcionando.

## Requerimientos cubiertos

| Requerimiento | Estado | Dónde | Prueba |
|---|---|---|---|
| ... | ... | ... | ... |

## Cambios por repositorio

| Repositorio | Cambios realizados | Pruebas ejecutadas |
|---|---|---|
| ... | ... | ... |

## Contrato final

Qué se implementó y qué diferencias existen respecto al plan.

## Decisiones tomadas

Decisiones que deben conservarse para features futuras.

## Pendientes conocidos

Lo que no se resolvió y por qué.

## Deuda y backlog

Ideas, mejoras o cambios fuera de alcance que no deben entrar silenciosamente en otra feature.

## Cómo probarlo

Pasos reproducibles para validar el flujo.

## Commit

Hash y mensaje del commit de cierre, después de la aprobación correspondiente.

## Conocimiento nuevo

Librerías, ciclo de vida, patrones o comandos que conviene agregar al README.
```

## 13. Plantilla: verificación

Archivo: `05-verificacion.md`

```markdown
# Verificación — F-000 Nombre de la feature

**Fecha:** AAAA-MM-DD
**Ejecutó:** nombre
**Revisó:** nombre

## Entorno

Versiones de SDK, base de datos, API y clientes.

## Casos ejecutados

| Caso | Resultado esperado | Resultado obtenido | Estado |
|---|---|---|---|
| ... | ... | ... | PASS/FAIL |

## Seguridad

- [ ] Autenticación validada
- [ ] Autorización por rol validada
- [ ] Aislamiento por tenant validado
- [ ] Datos sensibles no expuestos
- [ ] Archivos protegidos por el API

## Regresión

Comandos y pruebas existentes ejecutados.

## Evidencias

Logs, capturas, respuestas HTTP o referencias a la CI.

## Resultado final

Aprobada | Aprobada con pendientes | Rechazada

## Acciones posteriores

Incidencias o tareas derivadas.
```

## 14. Pruebas y definición de terminado

La cobertura se diseña desde el requerimiento, como en App-Ventas: cada requisito funcional cubierto debe tener al menos una prueba automática o, si es visual, táctil o dependiente del dispositivo, un caso manual documentado.

Según el repositorio, la evidencia puede incluir:

| Repositorio | Verificaciones mínimas |
|---|---|
| API | Compilación, pruebas unitarias, integración, contrato, autorización, aislamiento por tenant, migraciones y errores |
| Usuario | Análisis, pruebas de estado y widgets, integración API y verificación en iOS/Android cuando aplique |
| Negocio | Análisis, pruebas de estado y widgets, Flutter Web, tablet y flujos de operación |
| Admin | Typecheck, lint, pruebas de componentes, navegación, permisos y flujo web |

En features con base de datos o inventario se deben probar transacciones, rollback, consistencia, duplicados y límites. En features con archivos se debe probar autorización, tamaño, tipo, referencia, eliminación lógica y ausencia de credenciales en los clientes.

La definición de terminado de una feature es:

- [ ] Criterios de aceptación cumplidos.
- [ ] Pruebas automáticas nuevas y regresión en verde.
- [ ] Verificación manual ejecutada o declarada como no disponible.
- [ ] Seguridad y permisos revisados.
- [ ] Documentos `01` a `04` completos; `05` cuando corresponda.
- [ ] Desviaciones y deuda registradas.
- [ ] README actualizado si cambió el conocimiento general.
- [ ] Commit de cierre propuesto y listo para aprobación.

Claude puede preparar el commit y mostrar el resultado de las pruebas, pero espera la indicación del responsable antes de hacer commit y push (sección 6.2).

## 15. Solicitudes de cambio posteriores

Una necesidad descubierta después de cerrar una feature o después de una release se registra como solicitud de cambio, no se agrega directamente al código existente.

La solicitud debe indicar:

- Código y fecha.
- Solicitante.
- Problema o necesidad.
- Repositorios afectados.
- Requerimientos nuevos o modificados.
- Riesgos de migración y compatibilidad.
- Fuera de alcance.
- Versión o feature que la entregará.

Si se aprueba, sigue el mismo ciclo de requerimiento, análisis, plan, construcción, pruebas y cierre. Este mecanismo toma la práctica de la solicitud de cambio `SC-01` de App-Ventas.

## 16. Contratos entre repositorios

El repositorio `app-mascotas-api` es la fuente de los contratos HTTP. Cada cambio de API debe documentar:

- Versión del endpoint.
- Actor y permisos requeridos.
- Request y response.
- Códigos de respuesta.
- Formato de errores.
- Reglas de paginación y ordenamiento.
- Compatibilidad hacia atrás.
- Cliente consumidor y feature relacionada.

Se recomienda publicar un contrato OpenAPI versionado y generar o validar los clientes a partir de él cuando la herramienta elegida lo permita. Los clientes no deben duplicar manualmente modelos críticos sin revisar el contrato.

Para evitar bloqueo entre desarrolladores:

- El API puede publicar primero un contrato aprobado.
- Los clientes pueden construir adaptadores contra ese contrato.
- Los mocks solo sirven para desarrollo temporal y deben tener una fecha de retiro.
- Un cambio incompatible requiere nueva versión o migración coordinada.

## 17. Puntos de verificación del equipo

### Reunión breve de inicio de ciclo

Revisar features activas, bloqueos, cambios de contrato y dependencias entre repositorios.

### Revisión de contrato

Debe ocurrir antes de que el cliente y el API implementen modelos incompatibles.

### Integración semanal

Ejecutar al menos un flujo real entre API, app del usuario, app/web del negocio y portal administrativo cuando corresponda. Registrar el resultado y los bloqueos.

### Revisión de cierre

Comprobar criterios de aceptación, pruebas, seguridad, documentación y pendientes. Una feature no se cierra solo porque compila.

## 18. Orden para iniciar

El orden de construcción (etapas, features y dependencias) está en `docs/10-plan-construccion.md`. Los cuatro repositorios ya existen en GitHub con su `CLAUDE.md`, su estructura `docs/` y el requerimiento de cada una de sus features (sección 8).

## 19. Lecciones adoptadas de App-Ventas

Se incorporan explícitamente estas prácticas porque funcionaron en la construcción de App-Ventas:

1. Analizar el estado real del código antes de ajustar el plan.
2. Escribir las pruebas junto con el código, no al final.
3. No marcar como hecho algo que no se ejecutó.
4. Mantener un checklist manual para tablet, navegador y flujos reales.
5. Registrar desviaciones respecto al plan en el cierre, sin ocultarlas.
6. Registrar decisiones técnicas que afectarán features futuras.
7. Separar deuda y backlog de la feature actual.
8. Probar migraciones con datos reales o una copia representativa cuando haya persistencia.
9. Hacer commits de cierre identificables por feature o fase.
10. Tratar los cambios posteriores a una versión como solicitudes de cambio con alcance propio.

La diferencia necesaria para AppMascotas es que una feature puede distribuirse entre cuatro repositorios. Por eso se agregan contrato de API, matriz de impacto, responsable por repositorio y verificación transversal.

## 20. Regla de simplicidad

Con dos personas, no se deben abrir simultáneamente demasiadas features que crucen los cuatro repositorios. Se recomienda mantener como máximo:

- Una feature transversal en integración.
- Una feature de API o plataforma.
- Una feature de experiencia de usuario.

Cuando una feature no tenga contrato claro o dependa de decisiones abiertas, se documenta y se bloquea antes de construir. Esto reduce retrabajo y evita que cada cliente invente su propia versión de la regla de negocio.

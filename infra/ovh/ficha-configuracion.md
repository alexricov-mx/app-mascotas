# Ficha de configuración OVH — amiva.pet

**Para:** quien administre la cuenta de OVH.  
**Propósito:** reunir en un solo lugar los datos de infraestructura que faltan (PEN-33 de `docs/04-pendientes.md`). Llena la columna **Valor**; si un dato no aplica o no se sabe todavía, escribe "no sé" o "no aplica".  
**Importante:** aquí **no** se escriben contraseñas, llaves de acceso ni secretos. Esos se guardan aparte, en un gestor de secretos.

## 1. Cuenta

| Dato | Valor | Nota |
|---|---|---|
| Tipo de cuenta: OVHcloud (global) u OVHcloud US | | Son empresas y catálogos distintos. |
| Región elegida | Canadá | Confirmado. Anotar el centro de datos exacto (por ejemplo, Beauharnois, BHS). |
| Quién administra la cuenta | | Nombre y correo de contacto. |

## 2. VPS

| Dato | Valor | Nota |
|---|---|---|
| Modelo o plan del VPS | | |
| vCPU / RAM / disco | | |
| Sistema operativo | | |
| Centro de datos | | Idealmente el mismo que el Object Storage. |
| Respaldos o snapshots incluidos | | El requerimiento pide respaldos diarios con retención de una semana. |
| Topología recomendada por OVH que se seguirá | | Enlace o nombre de la guía. |

## 3. Object Storage

| Dato | Valor | Nota |
|---|---|---|
| Región del Object Storage | | La misma región que el VPS o la más cercana. |
| Endpoint S3 | | Lo muestra OVH al crear el contenedor, por ejemplo `https://s3.<region>.io.cloud.ovh.net`. |
| Clase de almacenamiento | | Estándar, alto rendimiento o acceso poco frecuente, según ofrezca la cuenta. |
| Precio por GB al mes | | |
| Precio de transferencia de salida | | |
| Cifrado en reposo disponible | | Y si lo administra OVH o nosotros. |
| Versionado disponible | | Útil para no perder documentos clínicos. |
| Bloqueo de objetos disponible | | |
| Presupuesto mensual aproximado, primer año | | |

### Buckets

Uno por ambiente, como mínimo.

| Ambiente | Nombre del bucket | Usuario S3 asignado |
|---|---|---|
| Desarrollo | | |
| Staging | | |
| Producción | | |

## 4. Dominio, DNS y certificados

| Dato | Valor | Nota |
|---|---|---|
| Dónde está registrado `amiva.pet` | | |
| DNS administrado en Cloudflare | | |
| Subdominios a usar | `amiva.pet`, `app.amiva.pet`, `admin.amiva.pet`, API por definir, staging por definir | |
| Certificados | | Cloudflare, Let's Encrypt u OVH. |

## 5. Staging

| Dato | Valor | Nota |
|---|---|---|
| ¿Staging en el mismo VPS o en otro? | | |
| Dominio de staging | | Por ejemplo `staging.amiva.pet`. |

## Qué pasa después

Cuando esta ficha esté llena, se revisa, se cierran los puntos de PEN-33 y el resultado se integra a la sección 15 de `docs/02-requerimiento.md`. Los valores que usa el API (endpoint, región, bucket) irán en su configuración por ambiente; las llaves de acceso, en secretos.

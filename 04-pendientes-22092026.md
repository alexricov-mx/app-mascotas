# Pendientes de definición — Plataforma para el Cuidado de Mascotas

**Fecha:** 2026-09-22  
**Relacionado con:** `requerimiento.md`  
**Estado:** pendientes restantes después de integrar las respuestas ampliadas.

## PEN-28 — Derecho de respuesta en reseñas

El usuario final puede publicar una reseña después de la solicitud por correo y de la moderación del operador y de la plataforma. La publicación requiere una acción del administrador de plataforma.

**Pendiente de confirmar:** si el negocio tendrá derecho a responder públicamente.

**Sugerencia:** permitir una sola respuesta pública por negocio, vinculada a la reseña, sin editar la reseña original. La respuesta debe quedar sujeta a la misma moderación y el administrador de plataforma puede ocultarla o retirarla por incumplimiento.

## PEN-29 — Límites de archivos

Se confirmó OVH Object Storage y que la retención será configurable. Cada documento tendrá una referencia desde las tablas del dominio.

**Pendiente de confirmar:** límites de tamaño y tipos de archivo.

**Sugerencia inicial para el MVP:**

| Tipo de archivo | Tamaño máximo sugerido |
|---|---:|
| Fotografías de mascotas | 10 MB |
| Recetas, tickets y notas | 15 MB |
| Estudios clínicos | 25 MB |
| Documentos firmados | 25 MB |
| Exportaciones generadas por el sistema | 50 MB |

Permitir `JPEG`, `PNG`, `WEBP` y `PDF`. Rechazar ejecutables, archivos comprimidos y formatos editables en el MVP. Los límites deben ser parámetros configurables.

## PEN-30 — Campañas dirigidas a atributos sensibles

Se confirmó que las sucursales podrán dirigir campañas por sucursal y atributos de mascotas, usando correo, banner y push. La plataforma podrá ocultar campañas inadecuadas.

**Pendiente de confirmar:** reglas para atributos sensibles.

**Sugerencia:**

- Permitir segmentación por especie, raza, sexo, edad, sucursal y servicios previos.
- No permitir segmentación directa por diagnóstico, alergias, padecimientos, medicamentos, estado reproductivo ni notas clínicas.
- Permitir usar atributos clínicos únicamente para recordatorios asistenciales previamente autorizados por el dueño, nunca para promociones comerciales.
- Registrar quién creó, aprobó, publicó, modificó u ocultó cada campaña.
- Mostrar al administrador una advertencia cuando la audiencia pueda inferirse a partir de datos sensibles.

## PEN-31 — Regla detallada de inventarios y proveedores

Se confirmó el flujo futuro de órdenes de compra: recepción parcial, autorización del administrador y estados `borrador`, `en proceso` y `concluida`.

**Pendiente posterior:** definir el modelo completo de proveedores, recepción, movimientos de inventario y conciliación con existencias, respetando las reglas que se adopten para el módulo de inventario.

## PEN-32 — Validación legal

La administración de la plataforma tendrá una sección para configurar documentos y textos legales, y cada consentimiento guardará la versión aceptada.

**Pendiente externo:** validación especializada sobre aviso de privacidad, derechos ARCO, conservación, eliminación, responsabilidades de plataforma y negocios, propiedad de la información y pagos.

## PEN-33 — Aspectos técnicos restantes

La arquitectura base quedó definida. Continúan pendientes únicamente estos aspectos de implementación:

- Configuración concreta del contenedor de PostgreSQL/PostGIS dentro del VPS.
- Topología de despliegue, Nginx, Cloudflare y certificados.
- Organización interna del monolito modular ASP.NET Core .NET 10.
- Límites, validaciones y estrategia de transferencia de archivos a través del API.
- Región y configuración operativa de OVH Object Storage.
- Proveedor de identidad y configuración final de Google, Microsoft, Facebook, X y Apple.

Estos puntos no cambian la decisión arquitectónica base, pero deben resolverse antes de iniciar la implementación.

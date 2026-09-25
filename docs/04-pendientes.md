# Pendientes de definición — amiva.pet

**Fecha:** 2026-09-24  
**Relacionado con:** `docs/02-requerimiento.md` versión 3.10  
**Estado:** pendientes restantes. PEN-28, PEN-29, PEN-30, PEN-31 y PEN-34 se resolvieron y ya están integrados en el requerimiento.

## PEN-32 — Revisión legal

**Decidido:** `admin.amiva.pet` tendrá una sección para configurar cada documento legal. El desarrollo avanza con textos provisionales.

**Pendiente externo:** revisión de un abogado sobre aviso de privacidad, derechos ARCO, conservación, eliminación, responsabilidades de plataforma y negocios, propiedad de la información y pagos. Incluye quién responde por los datos de clientes provisionales que captura un negocio antes de que el dueño acepte, y el envío de la invitación de activación a su correo.

**Impacto:** no bloquea el desarrollo; bloquea el inicio de la operación.

## PEN-33 — Datos de infraestructura de OVH

**Ya decidido** (sección 15 del requerimiento): desarrollo en Podman con PostgreSQL + PostGIS y Keycloak; producción en contenedores dentro del VPS de OVH en Canadá, con la topología recomendada por OVH; transferencia de archivos por streaming a través del API; API con arquitectura de cortes verticales por feature; Keycloak como servicio de identidad; enlaces universales y App Links.

**Falta:** los datos de la cuenta, el VPS, Object Storage, dominio y staging. Los tiene el socio que administra OVH y se capturan en `infra/ovh/ficha-configuracion.md`.

**Impacto:** no bloquea el modelo conceptual ni el desarrollo local; se necesita antes de montar staging.

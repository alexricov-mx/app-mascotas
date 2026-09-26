# Enlaces universales y App Links — material de estudio

**Fecha:** 2026-09-24  
**Aplicación en amiva.pet:** invitaciones de referidos (sección 11 de `docs/02-requerimiento.md`, UC-01, UC-38, UC-40 y UC-41), invitaciones de activación de clientes provisionales (sección 6.1, UC-47 y UC-48) y autorizaciones (UC-45).  
**Tipo:** documento de estudio. Explica el concepto y cómo se usará; los detalles de configuración se confirman al implementar.

## 1. El problema

Queremos un solo enlace, por ejemplo `https://amiva.pet/i/ABC123`, que:

1. Si la app está instalada, abra la app directamente en la pantalla de registro con el código `ABC123`.
2. Si la app no está instalada, lleve a la tienda (App Store o Google Play).
3. Funcione igual en un QR, un correo, WhatsApp o copiado y pegado.

## 2. Conceptos

### 2.1 Enlace profundo (*deep link*)

Un enlace que no solo abre una app, sino una pantalla concreta de ella con datos. Ejemplo: abrir el registro con un código de invitación.

### 2.2 Esquema personalizado (*custom URL scheme*)

La forma antigua: `amiva://registro?codigo=ABC123`.

- **Ventaja:** fácil de configurar.
- **Desventajas:**
  - Si la app no está instalada, el enlace no hace nada o muestra un error.
  - Cualquier app puede registrar el mismo esquema, así que no hay garantía de quién lo abre.
  - Muchos clientes de correo y redes no lo muestran como enlace.

Por eso ya no se recomienda para enlaces que se comparten.

### 2.3 Enlace universal (iOS) y App Link (Android)

La forma actual: un enlace **https normal** de un dominio propio. El sistema operativo verifica que la app y el dominio pertenecen al mismo dueño; si la verificación es correcta y la app está instalada, el sistema abre la app en lugar del navegador.

| | iOS | Android |
|---|---|---|
| Nombre | Universal Links | Android App Links |
| Archivo en el sitio | `https://amiva.pet/.well-known/apple-app-site-association` | `https://amiva.pet/.well-known/assetlinks.json` |
| Qué dice el archivo | El identificador del equipo y de la app (`TEAMID.pet.amiva.app`) y qué rutas abre la app | El paquete de la app y la huella SHA-256 del certificado de firma |
| Configuración en la app | *Associated Domains*: `applinks:amiva.pet` | `intent-filter` con `android:autoVerify="true"` para `https://amiva.pet` |
| Cuándo se verifica | Al instalar o actualizar la app | Al instalar o actualizar la app |

**Idea clave:** la seguridad viene de que solo el dueño del dominio puede publicar esos archivos y solo el dueño del certificado puede firmar la app. Así nadie más puede "robar" los enlaces de `amiva.pet`.

### 2.4 Enlace profundo diferido (*deferred deep link*)

Es el caso difícil: la app **no** está instalada. La persona toca el enlace, va a la tienda, instala y abre la app. ¿Cómo sabe la app qué código traía el enlace?

- **Android:** Google Play ofrece la *Play Install Referrer API*. Si el enlace a la tienda lleva un parámetro `referrer`, la app puede leerlo una vez después de instalarse. Es confiable.
- **iOS:** no existe un mecanismo equivalente. Las técnicas conocidas (huella del dispositivo, portapapeles) son aproximadas o piden permiso al usuario.
- Firebase Dynamic Links resolvía esto y fue retirado por Google en 2025, así que no es opción.

**Decisión de amiva.pet:** la pantalla de registro siempre tiene el campo "Código de quien te invitó". Si el código llega por enlace o por Install Referrer, se llena solo; si no, la persona lo escribe o lo pega. Así el referido nunca depende de que el diferido funcione.

## 3. Cómo funciona en amiva.pet

### 3.1 Rutas

| Ruta | Quién la usa | Abre la app | Si no hay app |
|---|---|---|---|
| `https://amiva.pet/i/{codigo}` | Invitación de usuario final | Sí, pantalla de registro con código | Página que redirige a la tienda según el dispositivo |
| `https://amiva.pet/n/{codigo}` | Invitación de negocio | **No** | Página "Quiero afiliarme" (UC-41) |
| `https://amiva.pet/a/{codigo}` | Invitación de activación de un cliente provisional | Sí, registro o inicio de sesión y luego la pantalla de activación (UC-48) | Página que redirige a la tienda según el dispositivo |
| `https://amiva.pet/c/{codigo}` | Invitación de autorización sobre una mascota ("cuidar") | Sí, registro o inicio de sesión y luego aceptar o rechazar la autorización (UC-45) | Página que redirige a la tienda según el dispositivo |

La ruta `/n/` se excluye a propósito en `apple-app-site-association` y no se declara en Android. El personal de una veterinaria puede tener instalada la app del dueño, y la invitación de negocio siempre debe abrir la página web.

### 3.2 Flujo de una invitación de usuario final

```
Usuario A abre "Invitar y obtener beneficios"
  └─ la app muestra QR y enlace https://amiva.pet/i/ABC123

Usuario B escanea el QR o toca el enlace
  ├─ ¿Tiene la app?  → el sistema operativo abre la app
  │                    → la app lee /i/ABC123 → registro con código lleno
  └─ ¿No la tiene?   → el navegador abre amiva.pet/i/ABC123
                       → la página detecta iOS o Android
                       → redirige a App Store o a Google Play
                         (en Android, con referrer=ABC123)
                       → B instala y abre la app
                         ├─ Android: la app lee Install Referrer → código lleno
                         └─ iOS: B escribe o pega el código
```

### 3.3 El QR

El QR solo contiene el enlace `https://amiva.pet/i/ABC123`. La cámara de iOS y Android reconoce el enlace y aplica las mismas reglas que un toque. La app genera el QR localmente a partir del enlace; no hace falta guardarlo como imagen en el servidor.

## 4. Requisitos técnicos

1. **Dominio con HTTPS válido.** Los archivos `.well-known` deben servirse sin redirecciones y con `Content-Type: application/json`.
2. **Cloudflare no debe alterar esos archivos:** sin redirecciones, sin páginas de desafío y sin reescritura de contenido.
3. **La huella SHA-256** de `assetlinks.json` debe ser la de la llave con la que Google Play firma la app (*Play App Signing*), no solo la de la llave de carga. Si se usan ambas, se declaran ambas.
4. **Una configuración por ambiente.** Staging usa su propio dominio (por ejemplo `staging.amiva.pet`) y su propia app de pruebas, para no mezclar invitaciones de prueba con reales.
5. **En Flutter** se recibe el enlace con el paquete `app_links` y se enruta a la pantalla correcta, por ejemplo con `go_router`.

## 5. Casos en los que no abre la app

Conviene conocerlos para no confundirlos con errores:

- **iOS:** si la persona escribe o pega el enlace en la barra de Safari, se abre la web, no la app. El enlace universal solo se activa al tocarlo.
- **Navegadores dentro de otras apps** (Facebook, Instagram, algunos clientes de correo) a veces abren la web en lugar de la app. Por eso la página web debe mostrar un botón "Abrir en la app" y los botones de las tiendas.
- **Si el usuario eligió "abrir en Safari"** desde el aviso de iOS, el sistema lo recuerda para ese dominio hasta que elija lo contrario.
- **Android:** si la verificación de dominio falló al instalar, el sistema muestra el selector de apps o abre el navegador.

## 6. Cómo probarlo

| Plataforma | Prueba |
|---|---|
| Android | `adb shell am start -a android.intent.action.VIEW -d "https://amiva.pet/i/ABC123"` abre el enlace como si se tocara. |
| Android | `adb shell pm get-app-links pet.amiva.app` muestra si el dominio quedó verificado. |
| iOS simulador | `xcrun simctl openurl booted "https://amiva.pet/i/ABC123"`. |
| iOS | Pegar el enlace en Notas o en Mensajes y tocarlo; no en la barra de Safari. |
| Ambos | Abrir `https://amiva.pet/.well-known/...` en el navegador y validar que responde JSON sin redirecciones. |

## 7. Glosario

- **AASA:** abreviatura de `apple-app-site-association`.
- **Associated Domains:** capacidad de una app iOS que declara los dominios con los que se asocia.
- **Digital Asset Links:** el protocolo de Google detrás de `assetlinks.json`.
- **Install Referrer:** dato que Google Play entrega a la app sobre el enlace que originó la instalación.
- **Huella SHA-256:** resumen criptográfico del certificado con el que se firma la app.

## 8. Referencias para profundizar

- Apple Developer: *Supporting universal links in your app* y *Supporting associated domains*.
- Android Developers: *About App Links* y *Verify App Links*.
- Android Developers: *Play Install Referrer Library*.
- Flutter: *Deep linking* (docs.flutter.dev) y el paquete `app_links` en pub.dev.

Los identificadores `TEAMID` y `pet.amiva.app` de este documento son ejemplos; los reales se definen al crear las apps en las tiendas.

## 9. Invitación de autorización (`/c/`)

Agregada el 2026-09-25 (requerimiento 3.19):

- El código es de **un solo uso** y vence a los 7 días (parámetro), a diferencia del código de referido, que es permanente.
- Si la invitación fue por correo, solo esa cuenta la acepta; si fue por enlace o QR, la acepta la primera cuenta que llegue, y el propietario ve quién fue y puede retirarla.
- Abrir el enlace no da acceso a nada: siempre se acepta con sesión iniciada. El propietario puede cancelarla mientras esté pendiente.
- Si quien acepta se registra en ese momento, el campo "Código de quien te invitó" llega con el código del propietario; la persona puede borrarlo.
- Ruta separada de `/i/` y `/a/` porque tiene otro significado y otro vencimiento; así un código nunca se interpreta mal.

## 10. Desarrollo local

Sin dominio verificado ni cuentas de las tiendas, la app acepta además un esquema propio solo de desarrollo con las mismas rutas (`amivadev://i/{codigo}`, `amivadev://a/{codigo}`, `amivadev://c/{codigo}`). No se incluye en producción.

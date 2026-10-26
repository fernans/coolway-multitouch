# coolway-multitouch

Interactive multi-touch storefront installation for the shoe brand **Coolway**, developed for **Hampa Studio** (Valencia, 2011) with the Adobe Flash Platform: a fullscreen AIR desktop app (`desktop.exe`) driven by multi-touch captures via **TUIO** (`ftp://`-free, local `udp-flashlc-bridge-win.exe` bridge).

The screen is a "sky" with animated clouds acting as a menu; each cloud opens a section:

- **Game** — pop the clouds by launching balls (with/without bounce), shoes or a real slingshot; optionally sends name + e-mail through a SOAP web service.
- **Photo gallery** — client-provided photos displayed in exchangeable frames, with zoom gesture implemented on top of the TUIO AS3 library (no native zoom support at the time).
- **Web** — scripted local web navigation with event control and URL monitoring.
- **Personal Shopper** — navigable catalogue of shoes/bags/accessories (`personalshopper.xml`), on-screen keyboard and purchase flow with sending name + e-mail and the browsed route to the same web service.

Also included: **PSeditor** — an AIR editor (`PSeditor.exe` / source FLA) so the client could update and re-link the catalogue products by themselves ("design for update, B11" of the task plan).

> **This project is shared ONLY for educational purposes. Its use, direct or derived, for professional or economic purposes is not permitted.**

For security reasons, some parts of the project may have been edited or removed: the client's web-service URL and its access key were anonymized as `XXX-XXX-XXX` (see `dev/Juego.as`, `dev/PS.as`, `dev/Web.as`, `PSeditor/PS.as`), the standalone AIR executables were not published because the original compiled strings (URL + key) remain embedded inside them (`coolway*.exe`, `PSeditor.exe`), and the client's brand media is not published (gallery photos in `dev/fotos/` and `entregas/pantalla/fotos/`, catalogue images in `dev/ps/TREE/` and `entregas/pantalla/ps/TREE/`, and the campaign videos in `entregas/pantalla/microsite/`) — the app loads all of them from the local filesystem at runtime.

Also included: the delivered retail runtime (`entregas/pantalla/` — `desktop.swf`, `microsite.swf`, catalogue XML, TUIO bridge) and the simplified web-view source (`simpleWeb/`).

## Requirements / How to run

- Adobe AIR (desktop) runtime and Flash Professional with the sources in `dev/` (`desktop.fla` main document + `lib*.fla` libraries in the classpath; ActionScript 3).
- Third-party code kept in-tree: `dev/org/tuio/*` (TUIO AS3 library, fiducialtuioas3, CC-BY 3.0 by Frédéric Friess & Johannes Luderschmidt) and `dev/greensock.swc` (GreenSock TweenLite/Nano).
- To test on a touch screen: launch `dev/udp-flashlc-bridge-win.exe` (local TUIO bridge on 127.0.0.1:3000) before the app; `MOUSE` flag in `dev/Desktop.as` enables mouse-driven fallback testing.
- Pre-built compiled views are included (`desktop.swf`, `desktop_raton.swf`, `lib*.swf`, `PSeditor.swf`, `dev/udp-flashlc-bridge-win.exe`); the installable AIR executables are excluded (see the security note).
- The SOAP web service (name+mail persistence) is the client's own private service, no longer available; the app still runs with its calls erroring silently.

No warranty of any kind is provided, and no liability is accepted for errors or damages resulting from its use of this software.

Additionally, the use of this project's content (code, documentation or assets) to train artificial intelligence or machine-learning systems is not permitted without the explicit permission of the author. Licensed under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — see [`LICENSE`](LICENSE).

---

# coolway-multitouch

Instalación interactiva multi-touch de escaparate para la marca de calzado **Coolway**, desarrollada para **Hampa Studio** (Valencia, 2011) con la plataforma Adobe Flash: una app AIR de escritorio a pantalla completa (`desktop.exe`) controlada por capturas multi-touch vía **TUIO** (con el brigue local `udp-flashlc-bridge-win.exe`).

La pantalla es un "cielo" con nubes animadas a modo de menú; cada nube abre un apartado:

- **Juego** — explotar nubes lanzando pelotas (con/sin rebote), zapatillas o un tirachinas; opcionalmente envía nombre + e-mail a través de un web service SOAP.
- **Galería de fotos** — fotos sugeridas por el cliente con marcos intercambiables y zoom por gestos implementado sobre la biblioteca TUIO AS3 (sin soporte nativo de zoom en aquel momento).
- **Web** — navegación de web local controlada por eventos y monitorizando las URLs visitadas.
- **Personal Shopper** — catálogo navegable de calzado/bolsitos/ornamentos (`personalshopper.xml`), teclado en pantalla y flujo de compra con envío de nombre + e-mail y la ruta navegada al mismo web service.

También incluido: **PSeditor** — un editor AIR (`PSeditor.exe` / fuente FLA) para que el cliente actualizara y cambiara los vínculos de los productos del catálogo por sí mismo ("diseño para actualización, B11" del plan de tareas).

> **Este proyecto se comparte SOLO con valor educativo. No está permitido su uso (directo o derivado) para fines profesionales o económicos.**

Por motivos de seguridad, algunas partes del proyecto pueden encontrarse editadas o eliminadas: la URL del web service del cliente y su clave de acceso quedaron anonimizadas como `XXX-XXX-XXX` (ver `dev/Juego.as`, `dev/PS.as`, `dev/Web.as`, `PSeditor/PS.as`), los ejecutables AIR autónomos no se publican porque los strings compilados originales (URL + clave) siguen incrustados dentro de ellos (`coolway*.exe`, `PSeditor.exe`), y los medios de la marca del cliente no se publican (las fotos de galería en `dev/fotos/` y `entregas/pantalla/fotos/`, las imágenes del catálogo en `dev/ps/TREE/` y `entregas/pantalla/ps/TREE/`, y los videos de campaña en `entregas/pantalla/microsite/`) — la app los carga desde el sistema de archivos local en ejecución.

También se incluyen: el runtime entregado en tienda (`entregas/pantalla/` — `desktop.swf`, `microsite.swf`, XML del catálogo, bridge TUIO) y la fuente simplificada del visor web (`simpleWeb/`).

## Requisitos / Cómo ejecutar

- El runtime de Adobe AIR (escritorio) y Flash Professional con el código en `dev/` (`desktop.fla` documento principal + bibliotecas `lib*.fla` en la ruta de clases; ActionScript 3).
- Código de terceros incluido en el árbol: `dev/org/tuio/*` (biblioteca TUIO AS3, fiducialtuioas3, CC-BY 3.0 de Frédéric Friess & Johannes Luderschmidt) y `dev/greensock.swc` (GreenSock TweenLite/Nano).
- Para probar en pantalla táctil: lanzar `dev/udp-flashlc-bridge-win.exe` (brigue TUIO local en 127.0.0.1:3000) antes de la app; la bandera `MOUSE` en `dev/Desktop.as` permite probar con ratón como respaldo.
- Se incluyen las vistas compiladas (`desktop.swf`, `desktop_raton.swf`, `lib*.swf`, `PSeditor.swf`, `dev/udp-flashlc-bridge-win.exe`); los ejecutables instalables de AIR están excluidos (ver la nota de seguridad).
- El web service SOAP (persistencia de nombre+mail) era el servicio privado del cliente, ya no disponible; la app sigue funcionando con sus llamadas fallando en silencio.

Este software se suministra sin garantía de ningún tipo, y no se asume ninguna responsabilidad por errores o daños que puedan producirse a partir de su uso.

Adicionalmente, no está permitido el uso del contenido de este proyecto (código, documentación o assets) para entrenar sistemas de inteligencia artificial o de aprendizaje automático sin el permiso explícito del autor. Licenciado bajo [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — ver [`LICENSE`](LICENSE).

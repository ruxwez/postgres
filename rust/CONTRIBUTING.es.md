# Contribuir al proyecto

¡Gracias por tu interés en contribuir! Este documento explica cómo reportar problemas, proponer características, contribuir con código y cómo preparar un Pull Request (PR) claro para que los mantenedores puedan revisar y fusionar tus cambios con rapidez.

Contenido
- Reportar problemas o proponer características
- Contribuir con código (flujo de trabajo)
- Lista de verificación para PR
- Notas de codificación y estilo
- Integración continua / pruebas
- Documentación y actualizaciones
- Licencia y soporte

---

## 1) Reportar un problema o proponer una característica

- Para bugs: abre un Issue usando la plantilla **Bug report** en `.github/ISSUE_TEMPLATE/bug_report.md`.
- Para propuestas: abre un Issue usando la plantilla **Feature request** en `.github/ISSUE_TEMPLATE/feature_request.md`.

Incluye en el Issue:
- Título claro y resumen conciso.
- Pasos para reproducir (si aplica).
- Comportamiento esperado vs comportamiento observado.
- Entorno: versión de Postgres solicitada, imagen base, sistema operativo, CI, etc.
- Logs o salidas relevantes (copiar/pegar fragmentos útiles).
- Comandos ejecutados (por ejemplo, comandos `docker build` o `cargo`).

Antes de abrir un Issue:
1. Busca Issues y PRs abiertos para evitar duplicados.
2. Si piensas implementar la solución, indícalo en el Issue para coordinar trabajo.

---

## 2) Contribuir con código — flujo general

1. Haz fork del repositorio.
2. Crea una rama con un nombre descriptivo:
   - `fix/<breve-descripción>`
   - `feat/<breve-descripción>`
   - `chore/<breve-descripción>`
3. Si el cambio es significativo, abre un Issue antes de implementar o vincula uno existente.
4. Implementa los cambios con commits atómicos y descriptivos.
5. Construye localmente: `cargo build --release`.
6. Prueba en un entorno representativo (contenedor Linux si procede).
7. Abre un PR hacia `main` indicando:
   - Motivación y resumen de cambios.
   - Cómo probar localmente (comandos y ejemplos).
   - Número del Issue relacionado.
   - Notas de compatibilidad y dependencias del sistema.

---

## 3) Lista de verificación para PR

Antes de solicitar revisión:
- [ ] Existe un Issue que describa el cambio o el PR lo referencia.
- [ ] La rama está basada en `main` actualizada.
- [ ] El código compila: `cargo build --release`.
- [ ] La descripción del PR contiene pasos de prueba reproducibles.
- [ ] Documentaste cualquier cambio en comportamiento público o flags.
- [ ] Actualizaste documentación relevante (`README.md`, `README.es.md`, u otros).

---

## 4) Notas de codificación y estilo

- Usamos Rust estable; sigue las prácticas idiomáticas de Rust.
- Mantén el código claro y robusto; detecta y maneja errores en vez de suprimirlos.
- Para ejecutar comandos shell desde Rust utiliza los helpers existentes (si los hay) en lugar de duplicar lógica.
- Comenta y documenta funciones públicas y comportamientos no triviales.
- Evita introducir dependencias innecesarias; prioriza soluciones simples.

---

## 5) Integración continua y pruebas

- Los PRs disparan workflows de GitHub Actions definidos en `.github/workflows/` (p. ej. `pr-test.yml`) que construyen la imagen en una matriz de versiones.
- Asegúrate de que tus cambios sean compatibles con las versiones y plataformas probadas en CI.
- Si tu cambio añade dependencias del sistema o modifica el proceso de build, indica claramente el motivo y los pasos de validación en el PR.

---

## 6) Documentación y actualizaciones

- Mantén `README.md` actualizado con cambios relevantes para usuarios.
- Para contenido en español, actualiza `README.es.md` o abre un Issue solicitando ayuda con la traducción si corresponde.
- Añade notas de cambios en la descripción del PR para facilitar la revisión.

---

## 7) Licencia y soporte

- Contribuciones están sujetas a la licencia del proyecto (archivo `LICENSE`).
- Si necesitas orientación antes de empezar, abre un Issue describiendo tu plan y marca la conversación como `discussion` o `help wanted`.

---

Gracias por querer mejorar este proyecto. Tu colaboración ayuda a que el software sea más útil y robusto para todos.
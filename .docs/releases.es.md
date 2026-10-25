# Releases

> [Read in English](./releases.md)

## Tags

Cada build publica los tags móviles. Una release publica además los que llevan versión:

| Tag | Lo publica | ¿Cambia? |
|-----|------------|----------|
| `18-v1.4.0` | la release `v1.4.0` | Nunca. El CI se niega a publicar una release que ya existe. |
| `18-v1` | cada release `v1.x.y` | Pasa a la release `v1` más reciente. |
| `18`, `latest` | cada build (push a `main`, semanal, release) | Siempre el último build. |

El rebuild semanal (parches de seguridad de la imagen base) solo mueve `18` y `latest`. Los tags con versión solo cambian cuando sacas una release.

## Versionado

La versión describe **lo que contiene la imagen**, siguiendo semver desde el punto de vista de quien la usa:

| Subida | Cuándo | Ejemplos |
|--------|--------|----------|
| **patch** `v1.4.0 → v1.4.1` | Mismas versiones de extensiones, reconstruidas o con un arreglo | Llevar a `18-v1` los parches de seguridad de la imagen base o una nueva versión menor de PostgreSQL; arreglar algo del build |
| **minor** `v1.4.x → v1.5.0` | Cambios compatibles | Una extensión recibe una actualización compatible (pgvector 0.8.2 → 0.8.7); se añade una extensión; se añade una versión mayor de PostgreSQL |
| **major** `v1.x.y → v2.0.0` | Algo puede romperse | Una extensión sube de versión mayor (pgmq 1.x → 2.x); se quita una extensión o una versión mayor de PostgreSQL |

Si no tienes claro si una actualización es compatible, lee el changelog de la extensión. Ante la duda, sube la major: una actualización nunca debería romperle nada a quien usa `-v1`.

## Publicar una release

Desde `main` actualizado:

```sh
git tag v1.4.0
git push origin v1.4.0
```

O crea la release desde la interfaz de GitHub con un tag nuevo. Después, el CI:

1. Comprueba que el tag tiene la forma `vX.Y.Z` y que es el tag de release **más reciente**. Publicar una versión antigua después de una más nueva haría retroceder `18-v1` y `latest`.
2. Comprueba que ninguno de los tags `<pg>-vX.Y.Z` existe todavía en Docker Hub.
3. Construye y prueba todas las versiones de PostgreSQL en ambas arquitecturas. No se publica nada si alguna falla.
4. Publica `<pg>-vX.Y.Z`, `<pg>-vX`, `<pg>` y `latest`.
5. Crea la release de GitHub con el changelog automático y una tabla con las versiones exactas de cada imagen. Si escribiste tú las notas de la release, la tabla se añade al final.

Si un job de publicación falla a medias (por ejemplo, por un error de Docker Hub), usa **Re-run failed jobs**. Si relanzas todo el workflow, se detendrá en el paso 2, porque algunos tags ya existen.

## Qué contiene una imagen

Cada imagen incluye la lista de sus extensiones con sus versiones:

```sh
docker run --rm ruxwez/postgres:18-v1 cat /usr/share/postgres-extensor/extensions.txt
```

Y lleva estos labels:

```sh
docker inspect ruxwez/postgres:18-v1 --format '{{json .Config.Labels}}'
```

| Label | Valor |
|-------|-------|
| `org.opencontainers.image.version` | release del proyecto (`1.4.0`); vacío fuera de las releases |
| `org.opencontainers.image.revision` | commit de git |
| `io.github.ruxwez.postgres.postgresql.version` | versión del paquete de PostgreSQL |

# Guía del proyecto: corpus EpiDoc de grafitos

Corpus de los **grafitos sobre cerámica** publicados por Pablo Ozcáriz Gil (solo grafitos: no sellos ni *tituli picti*).
El usuario es epigrafista, no programa y habla español: explicar todo sin tecnicismos.

- Repositorio público: https://github.com/pozcariz/grafitos-epidoc (licencia CC BY 4.0)
- Web: https://pozcariz.github.io/grafitos-epidoc/ (GitHub Pages desde la carpeta `docs/` de la rama main)
- En este equipo no hay Git: el usuario sube los archivos a mano en GitHub (Add file → Upload files, arrastrando carpetas, y Commit changes).

## Flujo para cada artículo

1. Leer el PDF una sola vez y listar los grafitos que contiene (ignorar sellos y *tituli picti*).
2. Crear una ficha por grafito en `epidoc/`, tomando `epidoc/cara-001-mitrh.xml` como modelo.
   - Nombre: `<yacimiento>-<nnn>-<palabra>.xml` (p. ej. `cara-002-euteri.xml`), numeración correlativa por yacimiento.
   - Si un grafito ya tiene ficha (publicado en otro artículo), no duplicar: añadir la nueva referencia a su bibliografía.
   - Lecturas alternativas con `<app type="alternative">` (`lem` = preferida, `rdg` = las demás).
   - No inventar datos: lo que el artículo no dice, se omite.
   - Añadir una fila a `catalogo.csv` y a la tabla del README (la web usa su soporte y forma para la lista y los filtros).
   - Yacimiento nuevo: añadir una fila a `herramientas/yacimientos.csv` con sus coordenadas para el mapa,
     y pedir al usuario que las confirme (no inventarlas).
3. Validar todas las fichas nuevas contra el esquema EpiDoc con Jing
   (`java -jar jing.jar tei-epidoc.rng ficha.xml`). Si no están en la carpeta temporal de la sesión, pedir permiso al usuario
   para descargarlos: esquema de https://epidoc.stoa.org/schema/latest/tei-epidoc.rng y Jing de
   https://github.com/relaxng/jing-trang/releases (V20220510). Nunca guardarlos dentro del repositorio.
4. Regenerar la web: `powershell -NoProfile -ExecutionPolicy Bypass -File .\herramientas\generar-web.ps1`.
5. Decir al usuario exactamente qué subir: normalmente `epidoc/`, `docs/`, `catalogo.csv` y `README.md`
   (y `herramientas/` si ha cambiado). La carpeta `.claude/` no se sube.

## La web (carpeta `herramientas/`)

- `generar-web.ps1` crea `docs/` entera: portada con mapa, buscador y filtros (`indice.xsl`), una página por ficha
  (`ficha.xsl`), «Criterios de edición» y «Cómo citar» (`paginas.xsl`), y copia fotos y XML.
- Partes comunes (menú, pie) en `comun.xsl`; transcripción de Leiden en `leiden.xsl`; estilo en `estilo.css`;
  buscador, mapa (Leaflet + OpenStreetMap) y botones en `web.js`.
- El tipo de grafito (texto, dibujo, signo) sale de las palabras clave (`<term>`) de la ficha.
- `generar-web.ps1` debe guardarse en UTF-8 con BOM (Windows PowerShell 5.1 lo exige por las tildes).
- Sin edición diplomática automática: el usuario no la quiere.

## Eficiencia

- Trabajar por lotes: todas las fichas de un artículo de una vez; en artículos largos, tandas de 20-30 grafitos por sesión.
- Fotos de museos/instituciones: no incluirlas sin permiso.

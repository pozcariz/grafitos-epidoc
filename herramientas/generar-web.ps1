# Genera la web del corpus (carpeta docs/) a partir de las fichas EpiDoc de epidoc/.
# Uso: abrir PowerShell en la carpeta del repositorio y ejecutar
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\herramientas\generar-web.ps1
#
# Usa además:
#   catalogo.csv                 -> soporte y forma de cada grafito (para la lista y el filtro «Soporte»)
#   herramientas/yacimientos.csv -> coordenadas de cada yacimiento para el mapa

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
$herr = Join-Path $raiz 'herramientas'
$docs = Join-Path $raiz 'docs'
$repo = 'https://github.com/pozcariz/grafitos-epidoc'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$teiNs = 'http://www.tei-c.org/ns/1.0'

New-Item -ItemType Directory -Force $docs | Out-Null

function Nueva-Transformacion($xsl) {
    $t = New-Object System.Xml.Xsl.XslCompiledTransform
    $t.Load((Join-Path $herr $xsl), (New-Object System.Xml.Xsl.XsltSettings($false, $false)), (New-Object System.Xml.XmlUrlResolver))
    return $t
}

function Transformar($t, $doc, $salida, $extra) {
    $parametros = New-Object System.Xml.Xsl.XsltArgumentList
    $parametros.AddParam('repo', '', $repo)
    if ($extra) { foreach ($k in $extra.Keys) { $parametros.AddParam($k, '', $extra[$k]) } }
    $ms = New-Object System.IO.MemoryStream
    $t.Transform($doc, $parametros, $ms)
    $texto = [System.Text.Encoding]::UTF8.GetString($ms.ToArray()).TrimStart([char]0xFEFF)
    # Une corchetes contiguos: [i][- - -] -> [i- - -]
    $html = "<!DOCTYPE html>`n" + ($texto -replace '\]\[', '')
    [System.IO.File]::WriteAllText($salida, $html, $utf8)
}

function Limpio($s) { if ($null -eq $s) { return '' } return (($s -replace '\s+', ' ').Trim()) }

# Agrupa los soportes del catálogo para el filtro
function Grupo-Soporte($s) {
    $s = "$s".ToLower()
    if ($s -match 'sigillata') { return 'Terra sigillata' }
    if ($s -match 'ánfora|anfora') { return 'Ánfora' }
    if ($s -match 'barnizada|pigmentada') { return 'Cerámica barnizada o pigmentada' }
    if ($s -match 'común|comun') { return 'Cerámica común' }
    if ($s -match 'de mesa') { return 'Cerámica de mesa' }
    return 'Cerámica (sin especificar)'
}

# Tipo de grafito según las palabras clave de la ficha
function Tipo-Grafito($terminos) {
    foreach ($t in $terminos) {
        if ($t -in @('grafito figurativo', 'palma', 'tridente')) { return 'dibujo' }
    }
    foreach ($t in $terminos) { if ($t -eq 'signo') { return 'signo' } }
    return 'texto'
}
$nombresTipo = [ordered]@{ texto = 'Texto (letras o palabras)'; dibujo = 'Dibujo'; signo = 'Signo' }

function Romano([int]$n) {
    $r = @('', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X')
    if ($n -ge 1 -and $n -le 10) { return $r[$n] } else { return "$n" }
}

# ---------- Datos auxiliares ----------
$catalogo = @{}
$rutaCatalogo = Join-Path $raiz 'catalogo.csv'
if (Test-Path $rutaCatalogo) {
    foreach ($fila in (Import-Csv $rutaCatalogo -Encoding UTF8)) { $catalogo[$fila.id] = $fila }
}
$coordenadas = @{}
$rutaYac = Join-Path $herr 'yacimientos.csv'
if (Test-Path $rutaYac) {
    foreach ($fila in (Import-Csv $rutaYac -Encoding UTF8)) { $coordenadas[$fila.ciudad_antigua] = $fila }
}

# ---------- Lee todas las fichas ----------
$fichas = @()
foreach ($f in Get-ChildItem (Join-Path $raiz 'epidoc') -Filter *.xml | Sort-Object Name) {
    $doc = New-Object System.Xml.XmlDocument
    $doc.PreserveWhitespace = $true
    $doc.Load($f.FullName)
    $fichas += [pscustomobject]@{ Archivo = $f; Doc = $doc }
}

# ---------- Prepara el corpus para la portada y para enlazar fichas ----------
$corpus = New-Object System.Xml.XmlDocument
$raizCorpus = $corpus.AppendChild($corpus.CreateElement('corpus'))
$nsm = New-Object System.Xml.XmlNamespaceManager($corpus.NameTable)
$nsm.AddNamespace('t', $teiNs)

$cuentaYac = [ordered]@{}
$lugarYac = @{}
$soportes = @{}
$tiposUsados = @{}
$siglosUsados = @{}
$publicaciones = @{}

foreach ($ficha in $fichas) {
    $doc = $ficha.Doc
    $n = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
    $n.AddNamespace('t', $teiNs)
    $id = Limpio ($doc.SelectSingleNode('//t:publicationStmt/t:idno[@type="filename"]', $n).InnerText)
    if (-not $id) { $id = $ficha.Archivo.BaseName }
    $nodoYac = $doc.SelectSingleNode('//t:origin/t:origPlace/t:placeName[@type="ancient"]', $n)
    $yac = if ($nodoYac) { Limpio $nodoYac.InnerText } else { 'Sin yacimiento' }
    $nodoLugar = $doc.SelectSingleNode('//t:origin/t:origPlace', $n)
    $lugar = if ($nodoLugar) { Limpio $nodoLugar.InnerText } else { '' }
    $nodoFecha = $doc.SelectSingleNode('//t:origin/t:origDate', $n)
    $datacion = if ($nodoFecha) { Limpio $nodoFecha.InnerText } else { '' }
    $fila = $catalogo[$id]
    if (-not $datacion -and $fila) { $datacion = Limpio $fila.datacion }

    # Soporte (del catálogo; si falta, del elemento <material> de la ficha)
    $soporteTexto = ''
    if ($fila) {
        $soporteTexto = Limpio $fila.soporte
        if ((Limpio $fila.forma) -ne '') { $soporteTexto += ', ' + (Limpio $fila.forma) }
    } else {
        $mat = $doc.SelectSingleNode('//t:material', $n)
        if ($mat) { $soporteTexto = Limpio $mat.InnerText }
    }
    $grupo = Grupo-Soporte $(if ($fila) { $fila.soporte } else { $soporteTexto })
    $soportes[$grupo] = $true

    # Tipo
    $terminos = @($doc.SelectNodes('//t:keywords/t:term', $n) | ForEach-Object { (Limpio $_.InnerText).ToLower() })
    $tipo = Tipo-Grafito $terminos
    $tiposUsados[$tipo] = $true

    # Siglos que abarca la datación (según notBefore/notAfter)
    $siglos = @()
    if ($nodoFecha) {
        $desde = $nodoFecha.GetAttribute('notBefore-custom'); if (-not $desde) { $desde = $nodoFecha.GetAttribute('notBefore') }
        $hasta = $nodoFecha.GetAttribute('notAfter-custom'); if (-not $hasta) { $hasta = $nodoFecha.GetAttribute('notAfter') }
        if (-not $desde -and $nodoFecha.GetAttribute('when')) { $desde = $nodoFecha.GetAttribute('when'); $hasta = $desde }
        if ($desde -match '^-?\d+' -and $hasta -match '^-?\d+') {
            $a = [int]($desde -replace '^(-?\d+).*', '$1'); $b = [int]($hasta -replace '^(-?\d+).*', '$1')
            if ($a -gt 0 -and $b -ge $a) {
                $s1 = [math]::Floor(($a - 1) / 100) + 1; $s2 = [math]::Floor(($b - 1) / 100) + 1
                for ($s = $s1; $s -le $s2; $s++) { $siglos += $s; $siglosUsados[[int]$s] = $true }
            }
        }
    }

    # Publicaciones distintas (por el título del trabajo)
    foreach ($b in $doc.SelectNodes('//t:div[@type="bibliography"]//t:bibl', $n)) {
        $ta = $b.SelectSingleNode('t:title[@level="a"]', $n)
        if (-not $ta) { $ta = $b.SelectSingleNode('t:title', $n) }
        if ($ta) { $publicaciones[(Limpio $ta.InnerText).ToLower()] = $true }
    }

    $palabras = ($terminos -join ' ')
    if ($fila) { $palabras += ' ' + $fila.lectura_leiden + ' ' + $fila.publicacion + ' ' + $fila.museo }

    if (-not $cuentaYac.Contains($yac)) { $cuentaYac[$yac] = 0; $lugarYac[$yac] = $lugar }
    $cuentaYac[$yac]++

    $e = $corpus.CreateElement('entrada')
    $e.SetAttribute('id', $id)
    $e.SetAttribute('yac', $yac)
    $e.SetAttribute('lugar', $lugar)
    $e.SetAttribute('datacion', $datacion)
    $e.SetAttribute('soporte', $grupo)
    $e.SetAttribute('soporte-texto', $soporteTexto)
    $e.SetAttribute('tipo', $tipo)
    $e.SetAttribute('siglos', ($siglos -join ' '))
    $e.SetAttribute('palabras', (Limpio $palabras))
    $e.AppendChild($corpus.ImportNode($doc.DocumentElement, $true)) | Out-Null
    $raizCorpus.AppendChild($e) | Out-Null
}

# Yacimientos (para el mapa)
foreach ($yac in $cuentaYac.Keys) {
    $y = $corpus.CreateElement('yacimiento')
    $y.SetAttribute('clave', $yac)
    $y.SetAttribute('n', $cuentaYac[$yac])
    $c = $coordenadas[$yac]
    if ($c) {
        $y.SetAttribute('nombre', $c.nombre_actual)
        $y.SetAttribute('lat', $c.latitud)
        $y.SetAttribute('lon', $c.longitud)
    } else {
        $y.SetAttribute('nombre', $lugarYac[$yac])
        Write-Warning "El yacimiento '$yac' no tiene coordenadas en herramientas/yacimientos.csv: no saldrá en el mapa."
    }
    $raizCorpus.AppendChild($y) | Out-Null
}

# Opciones de los filtros
function Opcion($grupo, $valor, $texto) {
    $o = $corpus.CreateElement('opcion')
    $o.SetAttribute('grupo', $grupo); $o.SetAttribute('valor', $valor); $o.SetAttribute('texto', $texto)
    $raizCorpus.AppendChild($o) | Out-Null
}
foreach ($yac in ($cuentaYac.Keys | Sort-Object)) { Opcion 'yac' $yac $yac }
foreach ($k in $nombresTipo.Keys) { if ($tiposUsados[$k]) { Opcion 'tipo' $k $nombresTipo[$k] } }
foreach ($s in ($soportes.Keys | Sort-Object)) { Opcion 'soporte' $s $s }
foreach ($s in ($siglosUsados.Keys | Sort-Object)) { Opcion 'siglo' "$s" ("s. " + (Romano $s) + " d.C.") }

$raizCorpus.SetAttribute('grafitos', $fichas.Count)
$raizCorpus.SetAttribute('yacimientos', $cuentaYac.Count)
$raizCorpus.SetAttribute('publicaciones', $publicaciones.Count)

# ---------- Genera las páginas ----------
# Borra las páginas antiguas (se vuelven a crear todas)
Get-ChildItem $docs -Filter *.html | Remove-Item -Force

$tFicha = Nueva-Transformacion 'ficha.xsl'
$tIndice = Nueva-Transformacion 'indice.xsl'
$tPaginas = Nueva-Transformacion 'paginas.xsl'
$navCorpus = $corpus.CreateNavigator()

foreach ($ficha in $fichas) {
    $nombre = $ficha.Archivo.BaseName
    Transformar $tFicha $ficha.Doc (Join-Path $docs ($nombre + '.html')) @{ corpus = $navCorpus }
    Write-Host "Ficha generada: docs/$nombre.html"
}

Transformar $tIndice $corpus (Join-Path $docs 'index.html') $null
Write-Host 'Portada generada: docs/index.html'

$vacio = New-Object System.Xml.XmlDocument
$vacio.LoadXml('<vacio/>')
Transformar $tPaginas $vacio (Join-Path $docs 'criterios.html') @{ pagina = 'criterios' }
Transformar $tPaginas $vacio (Join-Path $docs 'citar.html') @{ pagina = 'citar' }
Write-Host 'Páginas generadas: docs/criterios.html, docs/citar.html'

# ---------- Copia estilo, funciones, fichas XML y fotos ----------
Copy-Item (Join-Path $herr 'estilo.css') (Join-Path $docs 'estilo.css') -Force
Copy-Item (Join-Path $herr 'web.js') (Join-Path $docs 'web.js') -Force

$docsXml = Join-Path $docs 'xml'
if (Test-Path $docsXml) { Remove-Item $docsXml -Recurse -Force }
New-Item -ItemType Directory -Force $docsXml | Out-Null
Copy-Item (Join-Path $raiz 'epidoc\*.xml') $docsXml -Force

if (Test-Path (Join-Path $raiz 'imagenes')) {
    $docsImg = Join-Path $docs 'imagenes'
    if (Test-Path $docsImg) { Remove-Item $docsImg -Recurse -Force }
    New-Item -ItemType Directory -Force $docsImg | Out-Null
    Copy-Item (Join-Path $raiz 'imagenes\*') $docsImg -Recurse -Force
}
Write-Host "Web generada en docs/ ($($fichas.Count) fichas)."

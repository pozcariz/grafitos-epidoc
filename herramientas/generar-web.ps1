# Genera la web del corpus (carpeta docs/) a partir de las fichas EpiDoc de epidoc/.
# Uso: abrir PowerShell en la carpeta del repositorio y ejecutar  .\herramientas\generar-web.ps1

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
$herr = Join-Path $raiz 'herramientas'
$docs = Join-Path $raiz 'docs'
$repo = 'https://github.com/pozcariz/grafitos-epidoc'
$utf8 = New-Object System.Text.UTF8Encoding($false)

New-Item -ItemType Directory -Force $docs | Out-Null

function Nueva-Transformacion($xsl) {
    $t = New-Object System.Xml.Xsl.XslCompiledTransform
    $t.Load((Join-Path $herr $xsl), (New-Object System.Xml.Xsl.XsltSettings($false, $false)), (New-Object System.Xml.XmlUrlResolver))
    return $t
}

function Transformar($t, [System.Xml.XmlDocument]$doc, $salida) {
    $parametros = New-Object System.Xml.Xsl.XsltArgumentList
    $parametros.AddParam('repo', '', $repo)
    $sw = New-Object System.IO.StringWriter
    $t.Transform($doc, $parametros, $sw)
    # Une corchetes contiguos: [i][- - -] -> [i- - -]
    $html = "<!DOCTYPE html>`n" + ($sw.ToString() -replace '\]\[', '')
    [System.IO.File]::WriteAllText($salida, $html, $utf8)
}

$tFicha = Nueva-Transformacion 'ficha.xsl'
$tIndice = Nueva-Transformacion 'indice.xsl'

$corpus = New-Object System.Xml.XmlDocument
$corpus.AppendChild($corpus.CreateElement('corpus')) | Out-Null

foreach ($f in Get-ChildItem (Join-Path $raiz 'epidoc') -Filter *.xml) {
    $doc = New-Object System.Xml.XmlDocument
    $doc.PreserveWhitespace = $true
    $doc.Load($f.FullName)
    Transformar $tFicha $doc (Join-Path $docs ($f.BaseName + '.html'))
    $corpus.DocumentElement.AppendChild($corpus.ImportNode($doc.DocumentElement, $true)) | Out-Null
    Write-Host "Ficha generada: docs/$($f.BaseName).html"
}

Transformar $tIndice $corpus (Join-Path $docs 'index.html')
Copy-Item (Join-Path $herr 'estilo.css') (Join-Path $docs 'estilo.css') -Force
Write-Host 'Portada generada: docs/index.html'

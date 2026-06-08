param(
    [Parameter(Position=0)][string]$UrlOrCommand,
    [Parameter(Position=1)][string]$OutputName,
    [string]$OutputDir,
    [Alias("x")][int]$Connections = 8
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $OutputDir) {
    $OutputDir = Join-Path $Root "downloads"
}

function Show-Usage {
    Write-Host @"
Uso:
  dl URL [nombre_salida]
  dl -OutputDir CARPETA URL [nombre_salida]
  dl -Connections 16 URL [nombre_salida]
  dl list ARCHIVO.txt
  dl where
"@
}

if (-not $UrlOrCommand -or $UrlOrCommand -in @("-h", "--help")) {
    Show-Usage
    exit 0
}

if (-not (Get-Command aria2c -ErrorAction SilentlyContinue)) {
    throw "Falta aria2c. Ejecuta START-HERE.cmd otra vez o instala aria2 con winget."
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

if ($UrlOrCommand -eq "where") {
    Write-Host $Root
    Write-Host $OutputDir
    exit 0
}

if ($UrlOrCommand -eq "list") {
    if (-not $OutputName -or -not (Test-Path $OutputName)) {
        throw "Archivo de lista invalido: $OutputName"
    }
    aria2c --dir="$OutputDir" --input-file="$OutputName" --continue=true --max-connection-per-server="$Connections" --split="$Connections" --min-split-size=1M --summary-interval=5
    exit $LASTEXITCODE
}

$args = @(
    "--dir=$OutputDir",
    "--continue=true",
    "--max-connection-per-server=$Connections",
    "--split=$Connections",
    "--min-split-size=1M",
    "--summary-interval=5"
)
if ($OutputName) {
    $args += "--out=$OutputName"
}
$args += $UrlOrCommand

aria2c @args


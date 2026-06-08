param(
    [Parameter(Position=0)][string]$Url,
    [Parameter(Position=1)][string]$Language = "es",
    [Parameter(Position=2)][string]$Model = "small"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutDir = Join-Path $Root "output"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Require-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Falta '$Name'. Ejecuta START-HERE.cmd otra vez o instala dependencias con winget."
    }
}

function Get-CondaExe {
    $candidates = @(
        "$env:USERPROFILE\miniconda3\Scripts\conda.exe",
        "$env:LOCALAPPDATA\miniconda3\Scripts\conda.exe",
        "$env:ProgramData\miniconda3\Scripts\conda.exe",
        "$env:USERPROFILE\anaconda3\Scripts\conda.exe",
        "$env:ProgramData\anaconda3\Scripts\conda.exe"
    )
    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) { return $candidate }
    }
    return $null
}

if (-not $Url -or $Url -in @("-h", "--help")) {
    Write-Host "Uso: transcribir-video URL [idioma] [modelo]"
    Write-Host 'Ejemplo: transcribir-video "https://www.youtube.com/watch?v=..." es small'
    exit 0
}

$conda = Get-CondaExe

Write-Host "Descargando audio..."
if ($conda) {
    & $conda run -n data python -m yt_dlp --restrict-filenames --no-playlist -x --audio-format mp3 -o "$OutDir/%(title).120s-%(id)s.%(ext)s" "$Url"
} else {
    Require-Command "yt-dlp"
    Require-Command "ffmpeg"
    yt-dlp --restrict-filenames --no-playlist -x --audio-format mp3 -o "$OutDir/%(title).120s-%(id)s.%(ext)s" "$Url"
}

$audio = Get-ChildItem -Path $OutDir -Filter "*.mp3" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $audio) {
    throw "No se encontro el audio descargado."
}

if ($conda) {
    Write-Host "Transcribiendo con faster-whisper: $($audio.FullName)"
    & $conda run -n data python (Join-Path $Root "transcribir_audio.py") $audio.FullName --language $Language --model $Model
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    Write-Host "Transcribiendo con Python del sistema: $($audio.FullName)"
    python (Join-Path $Root "transcribir_audio.py") $audio.FullName --language $Language --model $Model
} else {
    throw "No se encontro conda ni python."
}

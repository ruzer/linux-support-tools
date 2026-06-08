param(
    [Parameter(Position=0)][string]$Command,
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$Rest
)

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Show-Usage {
    Write-Host @"
Uso:
  vt transcribe URL [idioma]
  vt where

Ejemplos:
  vt transcribe "https://www.youtube.com/watch?v=..." es
  transcribir-video "https://www.youtube.com/watch?v=..." es
"@
}

switch ($Command) {
    { $_ -in @("transcribe", "transcribir") } {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root "transcribir-video.ps1") @Rest
        exit $LASTEXITCODE
    }
    { $_ -in @("where", "donde") } {
        Write-Host $Root
        Write-Host (Join-Path $Root "output")
    }
    { -not $_ -or $_ -in @("help", "-h", "--help") } {
        Show-Usage
    }
    default {
        Write-Host "Comando desconocido: $Command" -ForegroundColor Yellow
        Show-Usage
        exit 2
    }
}


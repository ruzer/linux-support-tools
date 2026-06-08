param(
    [Parameter(Position=0)][string]$Command = "help",
    [switch]$DevBranch
)

$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/pewdiepie-archdaemon/odysseus.git"
$Branch = if ($DevBranch) { "dev" } else { "main" }
$LabDir = Join-Path $env:USERPROFILE "AI\odysseus"

function Show-Usage {
    Write-Host @"
Uso:
  odysseus-lab setup       Clona/actualiza Odysseus y prepara .env seguro
  odysseus-lab start       Construye/levanta Docker Compose
  odysseus-lab stop        Detiene servicios
  odysseus-lab status      Muestra estado de contenedores
  odysseus-lab logs        Muestra logs de odysseus
  odysseus-lab password    Muestra lineas utiles para password inicial
  odysseus-lab urls        Muestra URL
  odysseus-lab where       Muestra carpeta local

Opcional:
  odysseus-lab setup -DevBranch

URL:
  http://localhost:7000
"@
}

function Require-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Falta '$Name'. Instala Git/Docker Desktop y reinicia Windows si acaba de instalarse."
    }
}

function Set-EnvValue {
    param([string]$Path, [string]$Key, [string]$Value)
    $line = "$Key=$Value"
    if (Test-Path $Path) {
        $content = Get-Content $Path
        if ($content -match "^\s*#?\s*$([regex]::Escape($Key))=") {
            $content = $content | ForEach-Object {
                if ($_ -match "^\s*#?\s*$([regex]::Escape($Key))=") { $line } else { $_ }
            }
            Set-Content -Path $Path -Value $content -Encoding UTF8
        } else {
            Add-Content -Path $Path -Value $line
        }
    } else {
        Set-Content -Path $Path -Value $line -Encoding UTF8
    }
}

function Ensure-Repo {
    Require-Command "git"
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $LabDir) | Out-Null

    if (Test-Path (Join-Path $LabDir ".git")) {
        Write-Host "Actualizando Odysseus..."
        git -C $LabDir fetch origin
        git -C $LabDir checkout $Branch
        git -C $LabDir pull --ff-only origin $Branch
    } else {
        Write-Host "Clonando Odysseus branch $Branch..."
        git clone --branch $Branch --depth 1 $RepoUrl $LabDir
    }

    $envPath = Join-Path $LabDir ".env"
    $envExample = Join-Path $LabDir ".env.example"
    if (-not (Test-Path $envPath) -and (Test-Path $envExample)) {
        Copy-Item $envExample $envPath
    }

    Set-EnvValue -Path $envPath -Key "APP_BIND" -Value "127.0.0.1"
    Set-EnvValue -Path $envPath -Key "APP_PORT" -Value "7000"
    Set-EnvValue -Path $envPath -Key "AUTH_ENABLED" -Value "true"
    Set-EnvValue -Path $envPath -Key "LOCALHOST_BYPASS" -Value "false"
    Set-EnvValue -Path $envPath -Key "ALLOWED_ORIGINS" -Value "http://localhost:7000,http://127.0.0.1:7000"

    Write-Host "Odysseus folder: $LabDir" -ForegroundColor Green
    Write-Host "Configured localhost-only APP_BIND=127.0.0.1" -ForegroundColor Green
}

function Invoke-Compose {
    param([string[]]$Args)
    Require-Command "docker"
    Push-Location $LabDir
    try {
        docker compose @Args
    } finally {
        Pop-Location
    }
}

switch ($Command) {
    "setup" {
        Ensure-Repo
        Write-Host ""
        Write-Host "Si Docker Desktop acaba de instalarse, reinicia Windows antes de start." -ForegroundColor Yellow
        Write-Host "Despues ejecuta: odysseus-lab start"
    }
    "start" {
        Ensure-Repo
        Invoke-Compose @("up", "-d", "--build")
        & $MyInvocation.MyCommand.Path "urls"
        Write-Host ""
        Write-Host "Para la password inicial: odysseus-lab password" -ForegroundColor Yellow
    }
    "stop" {
        Invoke-Compose @("stop")
    }
    "down" {
        Invoke-Compose @("down")
    }
    "status" {
        Invoke-Compose @("ps")
    }
    "logs" {
        Invoke-Compose @("logs", "--tail=160", "odysseus")
    }
    "password" {
        Invoke-Compose @("logs", "odysseus")
    }
    "urls" {
        Write-Host "Odysseus: http://localhost:7000"
        Write-Host "ChromaDB: http://localhost:8100"
        Write-Host "SearXNG:  http://localhost:8080"
        Write-Host "ntfy:     http://localhost:8091"
        Write-Host "All ports are configured as localhost-only."
    }
    "where" {
        Write-Host $LabDir
    }
    default {
        Show-Usage
    }
}


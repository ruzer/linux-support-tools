param(
    [Parameter(Position=0)][string]$Command = "help"
)

$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/ruzer/maestria-anahuac-datos-docker.git"
$LabDir = Join-Path $env:USERPROFILE "Maestria\maestria-anahuac-datos-docker"

function Show-Usage {
    Write-Host @"
Uso:
  maestria-lab setup    Clona/actualiza el repo y prepara .env
  maestria-lab start    Levanta MySQL, Adminer, Metabase, Superset, Jupyter y Streamlit
  maestria-lab stop     Detiene servicios
  maestria-lab status   Muestra estado de contenedores
  maestria-lab urls     Muestra URLs
  maestria-lab where    Muestra carpeta del laboratorio

URLs:
  Adminer:   http://localhost:8080
  Metabase:  http://localhost:3000
  Superset:  http://localhost:8088
  Streamlit: http://localhost:8501
  Jupyter:   http://localhost:8888
"@
}

function Require-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Falta '$Name'. Instala Git/Docker Desktop y reinicia Windows si acaba de instalarse."
    }
}

function Ensure-LabRepo {
    Require-Command "git"
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $LabDir) | Out-Null

    if (Test-Path (Join-Path $LabDir ".git")) {
        Write-Host "Actualizando repo..."
        git -C $LabDir pull
    } else {
        Write-Host "Clonando repo de maestria..."
        git clone $RepoUrl $LabDir
    }

    $envPath = Join-Path $LabDir ".env"
    $envExample = Join-Path $LabDir ".env.example"
    if (-not (Test-Path $envPath)) {
        if (Test-Path $envExample) {
            Copy-Item $envExample $envPath
        } else {
            @"
MYSQL_ROOT_PASSWORD=MaestriaAnah_R00t2024!
MYSQL_DATABASE=curso
MYSQL_USER=alumno
MYSQL_PASSWORD=MaestriaAnah_Us3r2024!
TZ=America/Mexico_City
SUPERSET_SECRET_KEY=R7mZkQ9hL2uW5pX0yT4aB8vN1jH6fC3eG9qK2sV7tM5rY8d
SUPERSET_ENV=development
SUPERSET_LOAD_EXAMPLES=yes
SUPERSET_ADMIN_USERNAME=admin
SUPERSET_ADMIN_PASSWORD=Admin123!
SUPERSET_ADMIN_EMAIL=admin@example.com
METABASE_JAVA_OPTS=-Xms512m -Xmx1g
METABASE_SITE_NAME=Maestria Anahuac - Analisis de Datos
METABASE_SITE_LOCALE=es
BACKUP_CRON_TIME=0 2 * * *
BACKUP_MAX_BACKUPS=30
MYSQL_PORT=3306
ADMINER_PORT=8080
METABASE_PORT=3000
SUPERSET_PORT=8088
STREAMLIT_PORT=8501
"@ | Set-Content -Path $envPath -Encoding UTF8
        }
    }

    foreach ($dir in @("data\mysql","data\metabase","data\superset","data\datasets","logs\mysql","logs\metabase","logs\superset","logs\streamlit","backups","notebooks","config\superset","mysql\init","mysql\conf.d","streamlit\app")) {
        New-Item -ItemType Directory -Force -Path (Join-Path $LabDir $dir) | Out-Null
    }

    Write-Host "Lab folder: $LabDir" -ForegroundColor Green
}

function Invoke-DockerCompose {
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
        Ensure-LabRepo
        Write-Host ""
        Write-Host "Si Docker Desktop acaba de instalarse, reinicia Windows antes de start." -ForegroundColor Yellow
        Write-Host "Despues ejecuta: maestria-lab start"
    }
    "start" {
        Ensure-LabRepo
        Invoke-DockerCompose @("pull")
        Invoke-DockerCompose @("up", "-d")
        & $MyInvocation.MyCommand.Path "urls"
    }
    "stop" {
        Invoke-DockerCompose @("stop")
    }
    "down" {
        Invoke-DockerCompose @("down")
    }
    "status" {
        Invoke-DockerCompose @("ps")
    }
    "urls" {
        Write-Host "Adminer:   http://localhost:8080"
        Write-Host "Metabase:  http://localhost:3000"
        Write-Host "Superset:  http://localhost:8088"
        Write-Host "Streamlit: http://localhost:8501"
        Write-Host "Jupyter:   http://localhost:8888"
        Write-Host "Jupyter token default: maestria2024"
    }
    "where" {
        Write-Host $LabDir
    }
    default {
        Show-Usage
    }
}


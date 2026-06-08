param(
    [switch]$PullSmallLlama,
    [switch]$InstallMalwarebytes,
    [switch]$InstallDocker,
    [switch]$InstallHyperspace,
    [switch]$InstallAcademicOpenSource,
    [switch]$InstallLocalAIApps,
    [switch]$InstallAutomationTools,
    [switch]$InstallGeoTools,
    [switch]$InstallSupportTools,
    [switch]$InstallMastersDockerLab,
    [switch]$InstallOdysseus,
    [switch]$InstallAllExtras,
    [switch]$NoMenu,
    [switch]$SkipCondaEnv
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$KitRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$LogDir = Join-Path $KitRoot "logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$LogFile = Join-Path $LogDir ("install-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
$TranscriptFile = Join-Path $LogDir ("transcript-{0}.txt" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
Start-Transcript -Path $TranscriptFile -Append | Out-Null

function Write-Step {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"), $Message
    Write-Host $line -ForegroundColor Cyan
    Add-Content -Path $LogFile -Value $line
}

function Assert-Admin {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Run START-HERE.cmd as Administrator, or right-click PowerShell and choose 'Run as administrator'."
    }
}

function Assert-Winget {
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        Write-Host ""
        Write-Host "winget is not installed or not available in PATH." -ForegroundColor Yellow
        Write-Host "On Windows 10, install 'App Installer' from Microsoft Store, restart, then run this kit again." -ForegroundColor Yellow
        Write-Host "Official guide: https://learn.microsoft.com/windows/package-manager/winget/"
        throw "winget missing"
    }
}

function Install-WingetPackage {
    param(
        [Parameter(Mandatory=$true)][string]$Id,
        [string]$Name = $Id
    )

    Write-Step "Installing $Name ($Id)"
    $args = @(
        "install", "--id", $Id, "--exact",
        "--accept-source-agreements", "--accept-package-agreements",
        "--silent"
    )

    $process = Start-Process -FilePath "winget.exe" -ArgumentList $args -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        Write-Host "Warning: $Name returned exit code $($process.ExitCode). Continuing." -ForegroundColor Yellow
        Add-Content -Path $LogFile -Value "Warning: $Name returned exit code $($process.ExitCode)."
        return $false
    }
    return $true
}

function Show-OptionalMenu {
    Write-Host ""
    Write-Host "Extras opcionales" -ForegroundColor Cyan
    Write-Host "1) Recomendado: academico/datos + apps IA locales ligeras"
    Write-Host "2) Todo: recomendado + Docker/automatizacion/geodatos pesados"
    Write-Host "3) Solo base: no instalar extras opcionales"
    Write-Host "4) Personalizado: elegir bloques"
    Write-Host "5) Maestria: IA + programacion + mineria de datos + soporte"
    Write-Host "6) Maestria Docker Lab: incluye Docker + MySQL/Adminer/Metabase/Superset/Jupyter/Streamlit"
    Write-Host "7) Odysseus: self-hosted AI workspace Docker, localhost-only"
    Write-Host ""
    $choice = Read-Host "Elige 1, 2, 3 o 4"

    switch ($choice) {
        "1" {
            $script:InstallAcademicOpenSource = $true
            $script:InstallLocalAIApps = $true
            $script:InstallSupportTools = $true
        }
        "2" {
            $script:InstallAllExtras = $true
            $script:InstallAcademicOpenSource = $true
            $script:InstallLocalAIApps = $true
            $script:InstallAutomationTools = $true
            $script:InstallGeoTools = $true
            $script:InstallSupportTools = $true
            $script:InstallDocker = $true
        }
        "3" {
            return
        }
        "4" {
            $script:InstallAcademicOpenSource = (Read-Host "Instalar academico/datos open source? Orange, KNIME, Weka, Calibre, Joplin, DVC, MLflow, Label Studio [s/N]") -match "^[sSyY]"
            $script:InstallLocalAIApps = (Read-Host "Instalar apps IA locales? AnythingLLM, Open WebUI, Jan, LM Studio [s/N]") -match "^[sSyY]"
            $script:InstallSupportTools = (Read-Host "Instalar soporte tecnico? diagnostico, remoto, discos, USB, sync [s/N]") -match "^[sSyY]"
            $script:InstallGeoTools = (Read-Host "Instalar geodatos? QGIS LTR, SAGA GIS [s/N]") -match "^[sSyY]"
            $script:InstallAutomationTools = (Read-Host "Instalar automatizacion? Docker, n8n/Node-RED por npm [s/N]") -match "^[sSyY]"
            if ($script:InstallAutomationTools) { $script:InstallDocker = $true }
            $script:InstallHyperspace = (Read-Host "Instalar Hyperspace node [s/N]") -match "^[sSyY]"
            $script:InstallMalwarebytes = (Read-Host "Instalar Malwarebytes [s/N]") -match "^[sSyY]"
        }
        "5" {
            $script:InstallAcademicOpenSource = $true
            $script:InstallLocalAIApps = $true
            $script:InstallSupportTools = $true
        }
        "6" {
            $script:InstallAcademicOpenSource = $true
            $script:InstallLocalAIApps = $true
            $script:InstallSupportTools = $true
            $script:InstallMastersDockerLab = $true
            $script:InstallDocker = $true
        }
        "7" {
            $script:InstallOdysseus = $true
            $script:InstallDocker = $true
        }
        default {
            Write-Host "Opcion no reconocida; se instalara solo base." -ForegroundColor Yellow
        }
    }
}

function Refresh-Path {
    $machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machine;$user"
}

function Add-UserPath {
    param([Parameter(Mandatory=$true)][string]$PathToAdd)

    $current = [Environment]::GetEnvironmentVariable("Path", "User")
    $parts = @()
    if ($current) {
        $parts = $current -split ";" | Where-Object { $_ }
    }
    if ($parts -notcontains $PathToAdd) {
        $updated = (@($parts) + $PathToAdd) -join ";"
        [Environment]::SetEnvironmentVariable("Path", $updated, "User")
        Refresh-Path
    }
}

function Save-HardwareReport {
    $report = Join-Path $LogDir "hardware-report.txt"
    Write-Step "Saving hardware report to $report"
    "Computer:" | Out-File $report
    Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model,TotalPhysicalMemory | Format-List | Out-File $report -Append
    "Video:" | Out-File $report -Append
    Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,AdapterRAM | Format-List | Out-File $report -Append
    "Disks:" | Out-File $report -Append
    Get-CimInstance Win32_DiskDrive | Select-Object Model,Size,InterfaceType | Format-Table -AutoSize | Out-File $report -Append
}

function Configure-Defender {
    Write-Step "Configuring Microsoft Defender baseline"
    try {
        Set-MpPreference -DisableRealtimeMonitoring $false
        Set-MpPreference -PUAProtection Enabled
        Update-MpSignature
    } catch {
        Write-Host "Warning: Defender configuration failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

function Configure-WindowsBasics {
    Write-Step "Configuring Windows Explorer basics"
    try {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force -ErrorAction Stop | Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -Type DWord -Value 0 -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Hidden -Type DWord -Value 1 -ErrorAction Stop
    } catch {
        Write-Host "Warning: Explorer configuration failed: $($_.Exception.Message)" -ForegroundColor Yellow
        Add-Content -Path $LogFile -Value "Warning: Explorer configuration failed: $($_.Exception.Message)"
    }
}

function Install-NpmGlobal {
    param([string]$Package, [string]$CommandName)
    Refresh-Path
    if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
        Write-Host "npm not found yet; skipping $Package." -ForegroundColor Yellow
        return
    }
    Write-Step "Installing npm global package $Package"
    npm.cmd install -g $Package | Tee-Object -FilePath $LogFile -Append
    if ($CommandName) {
        Refresh-Path
        & cmd.exe /c "$CommandName --version" 2>&1 | Tee-Object -FilePath $LogFile -Append
    }
}

function Install-OptionalPythonPackages {
    Refresh-Path
    $conda = Find-Conda
    if (-not $conda) {
        Write-Host "Conda not found; skipping optional Python packages." -ForegroundColor Yellow
        return
    }

    if ($InstallAcademicOpenSource -or $InstallAllExtras) {
        Write-Step "Installing optional academic/data Python packages"
        & $conda run -n data python -m pip install --upgrade dvc mlflow label-studio Orange3 docling datalad h2o streamlit gradio | Tee-Object -FilePath $LogFile -Append
    }
}

function Install-AutomationNpmTools {
    if (-not ($InstallAutomationTools -or $InstallAllExtras)) { return }
    Install-NpmGlobal -Package "n8n" -CommandName "n8n"
    Install-NpmGlobal -Package "node-red" -CommandName "node-red"
}

function Find-GitBash {
    $candidates = @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "${env:ProgramFiles(x86)}\Git\bin\bash.exe"
    )
    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) { return $candidate }
    }
    return $null
}

function Install-HyperspaceNode {
    if (-not $InstallHyperspace) { return }

    Refresh-Path
    $bash = Find-GitBash
    if (-not $bash) {
        Write-Host "Git Bash not found; skipping Hyperspace install. Re-run after Git is installed." -ForegroundColor Yellow
        return
    }

    Write-Step "Installing Hyperspace node via official installer"
    & $bash -lc "curl -fsSL https://download.hyper.space/api/install | bash" | Tee-Object -FilePath $LogFile -Append

    Refresh-Path
    & cmd.exe /c "hyperspace version && hyperspace system-info" 2>&1 | Tee-Object -FilePath $LogFile -Append
}

function Find-Conda {
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

function Install-MediaTools {
    Write-Step "Installing local media tools"

    $source = Join-Path $KitRoot "tools\media-tools"
    $target = Join-Path $env:USERPROFILE "Tools\media-tools"
    $bin = Join-Path $env:USERPROFILE "bin"

    New-Item -ItemType Directory -Force -Path $target | Out-Null
    New-Item -ItemType Directory -Force -Path $bin | Out-Null

    if (Test-Path $source) {
        Copy-Item -Path (Join-Path $source "*") -Destination $target -Recurse -Force
    } else {
        Write-Host "Warning: media-tools source folder not found on USB: $source" -ForegroundColor Yellow
        Add-Content -Path $LogFile -Value "Warning: media-tools source folder not found: $source"
    }

    $wrappers = @{
        "vt.cmd" = "@echo off`r`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File ""%USERPROFILE%\Tools\media-tools\vt.ps1"" %*`r`n"
        "transcribir-video.cmd" = "@echo off`r`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File ""%USERPROFILE%\Tools\media-tools\transcribir-video.ps1"" %*`r`n"
        "dl.cmd" = "@echo off`r`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File ""%USERPROFILE%\Tools\media-tools\dl.ps1"" %*`r`n"
        "to-markdown.cmd" = "@echo off`r`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File ""%USERPROFILE%\Tools\media-tools\to-markdown.ps1"" %*`r`n"
    }

    foreach ($name in $wrappers.Keys) {
        Set-Content -Path (Join-Path $bin $name) -Value $wrappers[$name] -Encoding ASCII
    }

    Add-UserPath -PathToAdd $bin

    Refresh-Path
    $conda = Find-Conda
    if ($conda) {
        Write-Step "Installing media Python packages into conda env: data"
        & $conda run -n data python -m pip install --upgrade yt-dlp faster-whisper "numpy<2.3" markitdown openai-whisper | Tee-Object -FilePath $LogFile -Append
    } else {
        Write-Host "Conda not found; media scripts will use system Python if available." -ForegroundColor Yellow
    }
}

function Install-SupportScripts {
    if (-not ($InstallSupportTools -or $InstallAllExtras)) { return }

    Write-Step "Installing local support scripts"
    $source = Join-Path $KitRoot "tools\support-tools"
    $target = Join-Path $env:USERPROFILE "Tools\support-tools"
    $bin = Join-Path $env:USERPROFILE "bin"

    New-Item -ItemType Directory -Force -Path $target | Out-Null
    New-Item -ItemType Directory -Force -Path $bin | Out-Null

    if (Test-Path $source) {
        Copy-Item -Path (Join-Path $source "*") -Destination $target -Recurse -Force
    } else {
        Write-Host "Warning: support-tools source folder not found on USB: $source" -ForegroundColor Yellow
        Add-Content -Path $LogFile -Value "Warning: support-tools source folder not found: $source"
    }

    $wrappers = @{
        "pc-audit.cmd" = "@echo off`r`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File ""%USERPROFILE%\Tools\support-tools\pc-audit.ps1"" %*`r`n"
    }

    foreach ($name in $wrappers.Keys) {
        Set-Content -Path (Join-Path $bin $name) -Value $wrappers[$name] -Encoding ASCII
    }

    Add-UserPath -PathToAdd $bin

    try {
        Write-Step "Ensuring OpenSSH Client capability"
        Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0 | Tee-Object -FilePath $LogFile -Append
    } catch {
        Write-Host "Warning: OpenSSH Client setup failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

function Install-MastersDockerLab {
    if (-not ($InstallMastersDockerLab -or $InstallAllExtras)) { return }

    Write-Step "Installing masters Docker lab helpers"
    $source = Join-Path $KitRoot "tools\masters-docker-lab"
    $target = Join-Path $env:USERPROFILE "Tools\masters-docker-lab"
    $bin = Join-Path $env:USERPROFILE "bin"

    New-Item -ItemType Directory -Force -Path $target | Out-Null
    New-Item -ItemType Directory -Force -Path $bin | Out-Null

    if (Test-Path $source) {
        Copy-Item -Path (Join-Path $source "*") -Destination $target -Recurse -Force
    } else {
        Write-Host "Warning: masters-docker-lab source folder not found on USB: $source" -ForegroundColor Yellow
        Add-Content -Path $LogFile -Value "Warning: masters-docker-lab source folder not found: $source"
    }

    $wrappers = @{
        "maestria-lab.cmd" = "@echo off`r`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File ""%USERPROFILE%\Tools\masters-docker-lab\maestria-lab.ps1"" %*`r`n"
    }

    foreach ($name in $wrappers.Keys) {
        Set-Content -Path (Join-Path $bin $name) -Value $wrappers[$name] -Encoding ASCII
    }

    Add-UserPath -PathToAdd $bin

    Write-Host "Masters Docker Lab helper installed. After reboot/Docker setup, run: maestria-lab setup" -ForegroundColor Green
}

function Install-OdysseusHelper {
    if (-not ($InstallOdysseus -or $InstallAllExtras)) { return }

    Write-Step "Installing Odysseus helper"
    $source = Join-Path $KitRoot "tools\odysseus"
    $target = Join-Path $env:USERPROFILE "Tools\odysseus"
    $bin = Join-Path $env:USERPROFILE "bin"

    New-Item -ItemType Directory -Force -Path $target | Out-Null
    New-Item -ItemType Directory -Force -Path $bin | Out-Null

    if (Test-Path $source) {
        Copy-Item -Path (Join-Path $source "*") -Destination $target -Recurse -Force
    } else {
        Write-Host "Warning: odysseus source folder not found on USB: $source" -ForegroundColor Yellow
        Add-Content -Path $LogFile -Value "Warning: odysseus source folder not found: $source"
    }

    Set-Content -Path (Join-Path $bin "odysseus-lab.cmd") -Value "@echo off`r`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File ""%USERPROFILE%\Tools\odysseus\odysseus-lab.ps1"" %*`r`n" -Encoding ASCII

    Add-UserPath -PathToAdd $bin
    Write-Host "Odysseus helper installed. After Docker setup/reboot, run: odysseus-lab setup" -ForegroundColor Green
}

function Find-RScript {
    $candidates = @(
        "$env:ProgramFiles\R\R-*\bin\Rscript.exe",
        "${env:ProgramFiles(x86)}\R\R-*\bin\Rscript.exe"
    )
    foreach ($pattern in $candidates) {
        $matches = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | Sort-Object FullName -Descending
        if ($matches) { return $matches[0].FullName }
    }
    return $null
}

function Install-RPackages {
    Refresh-Path
    $rscript = Find-RScript
    if (-not $rscript) {
        Write-Host "Rscript not found; skipping R package installation." -ForegroundColor Yellow
        return
    }

    Write-Step "Installing common R packages"
    $packages = @(
        "tidyverse", "data.table", "readxl", "openxlsx", "janitor",
        "lubridate", "skimr", "plotly", "shiny", "rmarkdown",
        "quarto", "reticulate", "DBI", "RSQLite", "broom",
        "caret", "glmnet"
    )
    $quoted = ($packages | ForEach-Object { "'$_'" }) -join ","
    $code = "options(repos=c(CRAN='https://cloud.r-project.org')); install.packages(c($quoted), dependencies=TRUE)"
    & $rscript -e $code | Tee-Object -FilePath $LogFile -Append
}

function Create-CondaDataEnv {
    if ($SkipCondaEnv) { return }

    Refresh-Path
    $conda = Find-Conda
    if (-not $conda) {
        Write-Host "Conda not found; skipping data environment creation." -ForegroundColor Yellow
        return
    }

    Write-Step "Creating conda environment: data"
    & $conda config --add channels conda-forge | Tee-Object -FilePath $LogFile -Append
    & $conda config --set channel_priority strict | Tee-Object -FilePath $LogFile -Append
    $envList = & $conda env list
    if ($envList -match "^\s*data\s") {
        Write-Step "Conda environment data already exists; installing/updating packages"
        & $conda install -y -n data python=3.12 pandas numpy scipy matplotlib seaborn scikit-learn jupyterlab ipykernel statsmodels plotly openpyxl xlrd sqlalchemy requests beautifulsoup4 lxml ffmpeg | Tee-Object -FilePath $LogFile -Append
    } else {
        & $conda create -y -n data python=3.12 pandas numpy scipy matplotlib seaborn scikit-learn jupyterlab ipykernel statsmodels plotly openpyxl xlrd sqlalchemy requests beautifulsoup4 lxml ffmpeg | Tee-Object -FilePath $LogFile -Append
    }
    & $conda run -n data python -m pip install --upgrade pip openai anthropic langchain llama-index notebook yt-dlp faster-whisper "numpy<2.3" markitdown openai-whisper | Tee-Object -FilePath $LogFile -Append
    & $conda run -n data python -m ipykernel install --user --name data --display-name "Python (data)" | Tee-Object -FilePath $LogFile -Append
}

function Pull-LlamaModel {
    if (-not $PullSmallLlama) { return }

    Refresh-Path
    if (-not (Get-Command ollama.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Ollama not found; skipping Llama model download." -ForegroundColor Yellow
        return
    }

    Write-Step "Pulling small local Llama model: llama3.2:3b"
    ollama.exe pull llama3.2:3b | Tee-Object -FilePath $LogFile -Append
}

try {
    Write-Step "Starting Windows 10 Data/AI setup"
    Write-Step "Kit root: $KitRoot"

    Assert-Admin
    if (-not $NoMenu) {
        Show-OptionalMenu
    }
    Save-HardwareReport
    Configure-WindowsBasics
    Configure-Defender
    Assert-Winget

    $packages = @(
        @{ Id = "7zip.7zip"; Name = "7-Zip" },
        @{ Id = "Git.Git"; Name = "Git for Windows" },
        @{ Id = "OpenJS.NodeJS.LTS"; Name = "Node.js LTS" },
        @{ Id = "Gyan.FFmpeg"; Name = "FFmpeg" },
        @{ Id = "yt-dlp.yt-dlp"; Name = "yt-dlp" },
        @{ Id = "aria2.aria2"; Name = "aria2" },
        @{ Id = "Pandoc.Pandoc"; Name = "Pandoc" },
        @{ Id = "Python.Python.3.12"; Name = "Python 3.12" },
        @{ Id = "Anaconda.Miniconda3"; Name = "Miniconda3" },
        @{ Id = "RProject.R"; Name = "R for Windows" },
        @{ Id = "Posit.RStudio"; Name = "RStudio Desktop" },
        @{ Id = "Posit.Quarto"; Name = "Quarto" },
        @{ Id = "Microsoft.VisualStudioCode"; Name = "Visual Studio Code" },
        @{ Id = "JetBrains.PyCharm.Community"; Name = "PyCharm Community" },
        @{ Id = "Google.Chrome"; Name = "Google Chrome" },
        @{ Id = "Microsoft.PowerToys"; Name = "Microsoft PowerToys" },
        @{ Id = "ShareX.ShareX"; Name = "ShareX screenshots" },
        @{ Id = "Notepad++.Notepad++"; Name = "Notepad++" },
        @{ Id = "TheDocumentFoundation.LibreOffice"; Name = "LibreOffice" },
        @{ Id = "Zotero.Zotero"; Name = "Zotero" },
        @{ Id = "DBeaver.DBeaver.Community"; Name = "DBeaver Community" },
        @{ Id = "DBBrowserForSQLite.DBBrowserForSQLite"; Name = "DB Browser for SQLite" },
        @{ Id = "Obsidian.Obsidian"; Name = "Obsidian" },
        @{ Id = "SumatraPDF.SumatraPDF"; Name = "SumatraPDF" },
        @{ Id = "Ollama.Ollama"; Name = "Ollama" },
        @{ Id = "GitHub.cli"; Name = "GitHub CLI" },
        @{ Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal" }
    )

    if ($InstallMalwarebytes) {
        $packages += @{ Id = "Malwarebytes.Malwarebytes"; Name = "Malwarebytes" }
    }

    if ($InstallDocker) {
        $packages += @{ Id = "Docker.DockerDesktop"; Name = "Docker Desktop" }
    }

    if ($InstallSupportTools -or $InstallAllExtras) {
        $packages += @(
            @{ Id = "Microsoft.Sysinternals"; Name = "Microsoft Sysinternals Suite" },
            @{ Id = "Microsoft.PowerShell"; Name = "PowerShell 7" },
            @{ Id = "voidtools.Everything"; Name = "Everything file search" },
            @{ Id = "AntibodySoftware.WizTree"; Name = "WizTree disk usage" },
            @{ Id = "CrystalDewWorld.CrystalDiskInfo"; Name = "CrystalDiskInfo" },
            @{ Id = "REALiX.HWiNFO"; Name = "HWiNFO" },
            @{ Id = "CPUID.CPU-Z"; Name = "CPU-Z" },
            @{ Id = "TechPowerUp.GPU-Z"; Name = "GPU-Z" },
            @{ Id = "RustDesk.RustDesk"; Name = "RustDesk remote support" },
            @{ Id = "Tailscale.Tailscale"; Name = "Tailscale" },
            @{ Id = "WireGuard.WireGuard"; Name = "WireGuard" },
            @{ Id = "PuTTY.PuTTY"; Name = "PuTTY" },
            @{ Id = "WinSCP.WinSCP"; Name = "WinSCP" },
            @{ Id = "FileZilla.FileZilla"; Name = "FileZilla" },
            @{ Id = "VideoLAN.VLC"; Name = "VLC" },
            @{ Id = "OBSProject.OBSStudio"; Name = "OBS Studio" },
            @{ Id = "HandBrake.HandBrake"; Name = "HandBrake" },
            @{ Id = "Audacity.Audacity"; Name = "Audacity" },
            @{ Id = "GIMP.GIMP"; Name = "GIMP" },
            @{ Id = "BleachBit.BleachBit"; Name = "BleachBit" },
            @{ Id = "Rufus.Rufus"; Name = "Rufus" },
            @{ Id = "Ventoy.Ventoy"; Name = "Ventoy" },
            @{ Id = "Balena.Etcher"; Name = "balenaEtcher" },
            @{ Id = "Syncthing.Syncthing"; Name = "Syncthing" },
            @{ Id = "LocalSend.LocalSend"; Name = "LocalSend" },
            @{ Id = "KDE.KDEConnect"; Name = "KDE Connect" }
        )
    }

    if ($InstallAcademicOpenSource -or $InstallAllExtras) {
        $packages += @(
            @{ Id = "Knime.AnalyticsPlatform.LTS"; Name = "KNIME Analytics Platform LTS" },
            @{ Id = "UniversityOfWaikato.Weka"; Name = "Weka" },
            @{ Id = "calibre.calibre"; Name = "Calibre" },
            @{ Id = "Joplin.Joplin"; Name = "Joplin" },
            @{ Id = "PanWriter.PanWriter"; Name = "PanWriter" },
            @{ Id = "Inkscape.Inkscape"; Name = "Inkscape" },
            @{ Id = "Gephi.Gephi"; Name = "Gephi graph analysis" },
            @{ Id = "Microsoft.PowerBI"; Name = "Power BI Desktop" },
            @{ Id = "PostgreSQL.pgAdmin"; Name = "pgAdmin" },
            @{ Id = "MongoDB.Compass.Full"; Name = "MongoDB Compass" },
            @{ Id = "JanProchazka.dbgate"; Name = "DbGate" },
            @{ Id = "WinMerge.WinMerge"; Name = "WinMerge" },
            @{ Id = "Bruno.Bruno"; Name = "Bruno API Client" },
            @{ Id = "Postman.Postman"; Name = "Postman" },
            @{ Id = "DevToys-app.DevToys"; Name = "DevToys" },
            @{ Id = "JASP.JASP"; Name = "JASP statistics" },
            @{ Id = "jamovi.jamovi"; Name = "jamovi statistics" }
        )
    }

    if ($InstallLocalAIApps -or $InstallAllExtras) {
        $packages += @(
            @{ Id = "MintplexLabs.AnythingLLM"; Name = "AnythingLLM" },
            @{ Id = "OpenWebUI.OpenWebUI"; Name = "Open WebUI" },
            @{ Id = "Jan.Jan"; Name = "Jan" },
            @{ Id = "ElementLabs.LMStudio"; Name = "LM Studio" }
        )
    }

    if ($InstallGeoTools -or $InstallAllExtras) {
        $packages += @(
            @{ Id = "OSGeo.QGIS_LTR"; Name = "QGIS LTR" },
            @{ Id = "SAGAUserGroupAssociation.SAGAGIS"; Name = "SAGA GIS" }
        )
    }

    foreach ($package in $packages) {
        Install-WingetPackage -Id $package.Id -Name $package.Name | Out-Null
    }

    Refresh-Path
    if (-not (Install-WingetPackage -Id "OpenAI.Codex" -Name "Codex CLI")) {
        Install-NpmGlobal -Package "@openai/codex" -CommandName "codex"
    }

    if (-not (Install-WingetPackage -Id "Anthropic.ClaudeCode" -Name "Claude Code")) {
        Write-Host "Claude Code winget package failed. Trying npm fallback." -ForegroundColor Yellow
        Install-NpmGlobal -Package "@anthropic-ai/claude-code" -CommandName "claude"
    }

    Create-CondaDataEnv
    Install-MediaTools
    Install-SupportScripts
    Install-MastersDockerLab
    Install-OdysseusHelper
    Install-OptionalPythonPackages
    Install-AutomationNpmTools
    Install-RPackages
    Install-HyperspaceNode
    Pull-LlamaModel

    Write-Step "Done. Restart Windows before using all tools."
    Write-Host ""
    Write-Host "Done. Log file: $LogFile" -ForegroundColor Green
    Write-Host "Transcript: $TranscriptFile" -ForegroundColor Green
    Write-Host "Next: restart Windows, run Windows Update, then check docs\POST-INSTALL.md."
} catch {
    Write-Host ""
    Write-Host "INSTALLER FAILED:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Add-Content -Path $LogFile -Value "INSTALLER FAILED: $($_.Exception.Message)"
    Add-Content -Path $LogFile -Value $_.ScriptStackTrace
    Write-Host ""
    Write-Host "Log file: $LogFile" -ForegroundColor Yellow
    Write-Host "Transcript: $TranscriptFile" -ForegroundColor Yellow
    exit 1
} finally {
    Stop-Transcript | Out-Null
}

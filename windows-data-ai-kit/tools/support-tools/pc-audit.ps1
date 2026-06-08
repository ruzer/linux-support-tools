param(
    [string]$OutputDir = "$env:USERPROFILE\Desktop\pc-audit"
)

$ErrorActionPreference = "Continue"
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$Report = Join-Path $OutputDir ("pc-audit-{0}.txt" -f (Get-Date -Format "yyyyMMdd-HHmmss"))

function Section {
    param([string]$Title)
    "`r`n=== $Title ===" | Tee-Object -FilePath $Report -Append
}

"PC audit generated: $(Get-Date)" | Tee-Object -FilePath $Report

Section "Computer"
Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model,TotalPhysicalMemory,UserName | Format-List | Tee-Object -FilePath $Report -Append

Section "BIOS"
Get-CimInstance Win32_BIOS | Select-Object Manufacturer,SMBIOSBIOSVersion,ReleaseDate,SerialNumber | Format-List | Tee-Object -FilePath $Report -Append

Section "CPU"
Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed | Format-List | Tee-Object -FilePath $Report -Append

Section "Memory"
Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer,Capacity,Speed,PartNumber | Format-Table -AutoSize | Tee-Object -FilePath $Report -Append

Section "Video"
Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,AdapterRAM,CurrentHorizontalResolution,CurrentVerticalResolution | Format-List | Tee-Object -FilePath $Report -Append

Section "Disks"
Get-CimInstance Win32_DiskDrive | Select-Object Model,Size,InterfaceType,MediaType,Status | Format-Table -AutoSize | Tee-Object -FilePath $Report -Append

Section "Volumes"
Get-Volume | Select-Object DriveLetter,FileSystemLabel,FileSystem,SizeRemaining,Size,HealthStatus | Format-Table -AutoSize | Tee-Object -FilePath $Report -Append

Section "Network"
Get-NetIPConfiguration | Format-List | Tee-Object -FilePath $Report -Append

Section "Battery"
Get-CimInstance Win32_Battery | Select-Object Name,EstimatedChargeRemaining,BatteryStatus | Format-List | Tee-Object -FilePath $Report -Append

Section "Windows"
Get-ComputerInfo | Select-Object WindowsProductName,WindowsVersion,OsHardwareAbstractionLayer,OsArchitecture,OsInstallDate | Format-List | Tee-Object -FilePath $Report -Append

Section "Installed tool checks"
$tools = "winget","git","python","conda","R","Rscript","jupyter","code","ffmpeg","yt-dlp","aria2c","ollama","codex","claude","vt","transcribir-video","dl","to-markdown"
foreach ($tool in $tools) {
    $cmd = Get-Command $tool -ErrorAction SilentlyContinue
    if ($cmd) {
        "{0,-20} OK {1}" -f $tool, $cmd.Source | Tee-Object -FilePath $Report -Append
    } else {
        "{0,-20} MISSING" -f $tool | Tee-Object -FilePath $Report -Append
    }
}

Write-Host ""
Write-Host "Report: $Report" -ForegroundColor Green


param(
    [Parameter(Position=0)][string]$InputPath,
    [Parameter(Position=1)][string]$OutputPath
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

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

if (-not $InputPath -or $InputPath -in @("-h", "--help")) {
    Write-Host "Uso: to-markdown ARCHIVO [SALIDA.md]"
    Write-Host 'Ejemplo: to-markdown ".\documento.pdf" ".\documento.md"'
    exit 0
}

if (-not (Test-Path $InputPath)) {
    throw "No existe el archivo: $InputPath"
}

if (-not $OutputPath) {
    $item = Get-Item $InputPath
    $OutputPath = Join-Path $item.DirectoryName ($item.BaseName + ".md")
}

$conda = Get-CondaExe
if ($conda) {
    & $conda run -n data python (Join-Path $Root "convert_to_markdown.py") $InputPath -o $OutputPath
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    python (Join-Path $Root "convert_to_markdown.py") $InputPath -o $OutputPath
} elseif (Get-Command pandoc -ErrorAction SilentlyContinue) {
    pandoc $InputPath -o $OutputPath
} else {
    throw "No se encontro markitdown/python ni pandoc."
}

Write-Host "Markdown: $OutputPath"

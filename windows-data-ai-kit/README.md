# Windows 10 Data/AI Setup Kit

Para usarlo en la laptop con Windows 10:

1. Copia esta carpeta completa a la USB.
2. En Windows, abre la USB.
3. Clic derecho en uno de los lanzadores.
4. Elige `Run as administrator` / `Ejecutar como administrador`.
5. Espera a que termine y reinicia Windows.

Lanzadores:

- `START-HERE.cmd`: abre menu interactivo.
- `START-RECOMMENDED.cmd`: recomendado para otra laptop; instala base + academico/datos + apps IA locales + soporte.
- `START-MAESTRIA.cmd`: perfil para IA, programacion, mineria de datos, estadistica, documentos y soporte.
- `START-BASE-ONLY.cmd`: solo base, lo mas rapido y conservador.
- `START-ALL-EXTRAS.cmd`: instala todo, incluyendo Docker/geodatos/automatizacion; puede tardar bastante.

Instala y configura:

- 7-Zip
- Git
- Node.js LTS
- FFmpeg
- yt-dlp
- aria2
- Pandoc
- Python 3.12
- Miniconda/conda
- Entorno conda `data` con pandas, numpy, scipy, scikit-learn, JupyterLab y librerias comunes
- R
- RStudio Desktop
- Quarto
- Paquetes R comunes: tidyverse, data.table, readxl, openxlsx, janitor, plotly, shiny, rmarkdown, reticulate, DBI, RSQLite, caret
- PyCharm
- Visual Studio Code
- Chrome
- PowerToys
- ShareX para screenshots
- Notepad++
- LibreOffice
- Zotero
- DBeaver
- DB Browser for SQLite
- Obsidian
- SumatraPDF
- Windows Terminal
- GitHub CLI
- Ollama
- Codex CLI
- Claude Code
- Microsoft Defender baseline
- Reporte de hardware para revisar pantalla/GPU/drivers
- Media tools locales: `vt`, `transcribir-video`, `dl`, `to-markdown`
- Support tools locales: `pc-audit`

Extras opcionales por menu:

- Academico/datos open source: KNIME, Weka, Calibre, Joplin, PanWriter, Inkscape, DVC, MLflow, Label Studio, Orange3, Gephi, Power BI, pgAdmin, MongoDB Compass, DbGate, WinMerge, Bruno, Postman, DevToys, JASP, jamovi.
- Apps IA locales: AnythingLLM, Open WebUI, Jan, LM Studio.
- Soporte tecnico: Sysinternals, PowerShell 7, Everything, WizTree, CrystalDiskInfo, HWiNFO, CPU-Z, GPU-Z, RustDesk, Tailscale, WireGuard, PuTTY, WinSCP, FileZilla, VLC, OBS, HandBrake, Audacity, GIMP, BleachBit, Rufus, Ventoy, Etcher, Syncthing, LocalSend, KDE Connect.
- Geodatos: QGIS LTR, SAGA GIS.
- Automatizacion: Docker Desktop, n8n, Node-RED.

La laptop necesita internet para descargar versiones actuales.

Si `winget` no existe en Windows 10, instala `App Installer` desde Microsoft Store y vuelve a correr `START-HERE.cmd`.

Para detalles despues de instalar, lee `docs\POST-INSTALL.md`.

Herramientas de video/Markdown:

```powershell
vt transcribe "URL_DEL_VIDEO" es small
transcribir-video "URL_DEL_VIDEO" es small
dl "https://example.com/archivo.zip"
to-markdown ".\documento.pdf" ".\documento.md"
pc-audit
```

Opcionales:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-WindowsDataLab.ps1 -InstallMalwarebytes
powershell -ExecutionPolicy Bypass -File .\scripts\Install-WindowsDataLab.ps1 -InstallDocker
powershell -ExecutionPolicy Bypass -File .\scripts\Install-WindowsDataLab.ps1 -InstallHyperspace
```

Sobre el nombre del repo:

- Si el repo solo mantiene Linux, `linux-support-tools` sigue siendo buen nombre.
- Si vamos a meter Windows y macOS, mejor crear o renombrar a `useful-tools` o `lab-bootstrap-tools`.
- Mi recomendacion: `lab-bootstrap-tools`, porque describe mejor que instala/configura laptops nuevas, no solo guarda utilidades sueltas.

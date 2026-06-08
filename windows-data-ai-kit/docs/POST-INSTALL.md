# Post-install checklist

Run `START-HERE.cmd` from the USB as Administrator.

For a fast repeat install on another laptop, run `START-RECOMMENDED.cmd`.

After the installer finishes:

1. Restart Windows.
2. Open Windows Update and install all updates, including optional driver updates.
3. Check `logs\hardware-report.txt` for the laptop manufacturer, model, and display adapter.
4. Install the exact display/GPU driver from the laptop maker, Intel, AMD, or NVIDIA if Windows Update does not fix resolution/brightness.
5. Open Anaconda Prompt or PowerShell and test:

```powershell
python --version
conda info
conda activate data
jupyter lab
codex --version
claude --version
ollama --version
R --version
quarto --version
ffmpeg -version
yt-dlp --version
aria2c --version
vt where
```

For local Llama:

```powershell
ollama run llama3.2:3b
```

For video transcription and Markdown conversion:

```powershell
vt transcribe "URL_DEL_VIDEO" es small
transcribir-video "URL_DEL_VIDEO" es small
to-markdown ".\documento.pdf" ".\documento.md"
```

Notes:

- Microsoft Defender is enough for most clean Windows 10 installs. The script enables PUA protection and updates signatures.
- Malwarebytes is optional. To include it, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-WindowsDataLab.ps1 -InstallMalwarebytes
```

- Claude Code and Codex require account login/API access after installation.
- Local Llama models need disk space and RAM. `llama3.2:3b` is the small default here; bigger models may be slow on older laptops.
- RStudio should automatically detect R. If it does not, open RStudio settings and point it to `C:\Program Files\R\R-*\bin\R.exe`.
- Docker Desktop is optional. It requires Windows 10 22H2, WSL 2, 8 GB+ RAM, and virtualization enabled in BIOS/UEFI.
- Media tools are copied to `%USERPROFILE%\Tools\media-tools` and wrappers are added to `%USERPROFILE%\bin`.
- Optional open-source apps can be installed from the interactive menu or by running `START-RECOMMENDED.cmd` / `START-ALL-EXTRAS.cmd`.
- Hyperspace AI node is optional. On the Dell Latitude 7490 with Intel UHD Graphics 620, use CPU/light capabilities first:

```powershell
hyperspace system-info
hyperspace start --profile embedding
hyperspace status
```

- For Hyperspace GPU inference, the project lists 4 GB VRAM as the minimum practical GPU tier. NVIDIA RTX-class GPUs are much better.

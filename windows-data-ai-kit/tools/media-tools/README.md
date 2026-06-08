# Media Tools

Comandos instalados en `%USERPROFILE%\bin`:

- `vt transcribe URL [idioma] [modelo]`
- `transcribir-video URL [idioma] [modelo]`
- `dl URL [nombre_salida]`
- `to-markdown ARCHIVO [SALIDA.md]`

Salidas:

- Transcripciones: `%USERPROFILE%\Tools\media-tools\output`
- Descargas: `%USERPROFILE%\Tools\media-tools\downloads`

Ejemplos:

```powershell
vt transcribe "https://www.youtube.com/watch?v=..." es small
transcribir-video "https://www.youtube.com/watch?v=..." es small
dl "https://example.com/archivo.zip"
to-markdown ".\documento.pdf" ".\documento.md"
```

Modelos Whisper recomendados en CPU:

- `tiny`: rapido, menos preciso.
- `base`: balance rapido.
- `small`: recomendado para la Dell Latitude 7490.
- `medium`: mas preciso, lento en CPU.


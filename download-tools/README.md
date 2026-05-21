# Download Tools

Herramienta local para descargas divididas en varias conexiones usando `aria2c`.

## Estado actual

En esta maquina ya esta disponible `aria2c`.

No hace falta correr ningun comando con `sudo` ahora.

## Estructura

- `bin/`: comandos CLI.
- `downloads/`: descargas por defecto.
- `lists/`: listas de URLs.

## Uso rapido

```bash
dl "URL_DEL_ARCHIVO"
```

Usar mas conexiones:

```bash
dl -x 16 "URL_DEL_ARCHIVO"
```

Guardar en otra carpeta:

```bash
dl -o "$HOME/Downloads" "URL_DEL_ARCHIVO"
```

Guardar con nombre especifico:

```bash
dl "URL_DEL_ARCHIVO" "archivo-final.zip"
```

Descargar una lista de URLs:

```bash
dl list "./download-tools/lists/urls.txt"
```

## Activar comando

El archivo `~/.bashrc` ya carga `download-tools/aliases.sh`, asi que en una terminal nueva puedes usar `dl`.

En la terminal actual, si todavia no lo reconoce:

```bash
source "./download-tools/aliases.sh"
```

## Reinstalar o reparar

Si `aria2c` falta en otra maquina:

```bash
sudo apt install -y aria2
```

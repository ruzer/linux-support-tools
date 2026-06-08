import argparse
import subprocess
import sys
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("-o", "--output")
    args = parser.parse_args()

    input_path = Path(args.input)
    if not input_path.exists():
        raise SystemExit(f"No existe el archivo: {input_path}")

    output_path = Path(args.output) if args.output else input_path.with_suffix(".md")

    try:
        from markitdown import MarkItDown

        converter = MarkItDown()
        result = converter.convert(str(input_path))
        output_path.write_text(result.text_content, encoding="utf-8")
        print(f"Markdown: {output_path}")
        return
    except Exception as exc:
        print(f"markitdown fallo, probando pandoc: {exc}", file=sys.stderr)

    try:
        subprocess.run(["pandoc", str(input_path), "-o", str(output_path)], check=True)
        print(f"Markdown: {output_path}")
    except Exception as exc:
        raise SystemExit(f"No se pudo convertir a Markdown: {exc}") from exc


if __name__ == "__main__":
    main()


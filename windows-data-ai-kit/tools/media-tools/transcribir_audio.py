import argparse
from pathlib import Path

from faster_whisper import WhisperModel


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("audio")
    parser.add_argument("--language", default="es")
    parser.add_argument("--model", default="small")
    args = parser.parse_args()

    audio_path = Path(args.audio)
    txt_path = audio_path.with_suffix(".txt")
    srt_path = audio_path.with_suffix(".srt")
    md_path = audio_path.with_suffix(".md")

    model = WhisperModel(args.model, device="cpu", compute_type="int8")
    segments, info = model.transcribe(str(audio_path), language=args.language, vad_filter=True)

    lines = []
    with txt_path.open("w", encoding="utf-8") as txt_file, srt_path.open("w", encoding="utf-8") as srt_file:
        for index, segment in enumerate(segments, start=1):
            text = segment.text.strip()
            if text:
                lines.append(text)
                txt_file.write(text + "\n")
            srt_file.write(f"{index}\n")
            srt_file.write(f"{format_srt_time(segment.start)} --> {format_srt_time(segment.end)}\n")
            srt_file.write(text + "\n\n")

    with md_path.open("w", encoding="utf-8") as md_file:
        md_file.write(f"# Transcripcion: {audio_path.stem}\n\n")
        md_file.write(f"- Idioma detectado: {info.language} ({info.language_probability:.2f})\n")
        md_file.write(f"- Audio: `{audio_path.name}`\n\n")
        md_file.write("## Texto\n\n")
        md_file.write("\n\n".join(lines))
        md_file.write("\n")

    print(f"Idioma detectado: {info.language} ({info.language_probability:.2f})")
    print(f"Texto: {txt_path}")
    print(f"Markdown: {md_path}")
    print(f"Subtitulos: {srt_path}")


def format_srt_time(seconds: float) -> str:
    millis = int(round(seconds * 1000))
    hours, remainder = divmod(millis, 3_600_000)
    minutes, remainder = divmod(remainder, 60_000)
    secs, millis = divmod(remainder, 1000)
    return f"{hours:02}:{minutes:02}:{secs:02},{millis:03}"


if __name__ == "__main__":
    main()


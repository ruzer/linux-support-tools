#!/usr/bin/env python3
import argparse
from pathlib import Path

from faster_whisper import WhisperModel


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("audio")
    parser.add_argument("--language", default="es")
    parser.add_argument("--model", default="medium")
    args = parser.parse_args()

    audio_path = Path(args.audio)
    txt_path = audio_path.with_suffix(".txt")
    srt_path = audio_path.with_suffix(".srt")

    model = WhisperModel(args.model, device="cpu", compute_type="int8")
    segments, info = model.transcribe(str(audio_path), language=args.language, vad_filter=True)

    with txt_path.open("w", encoding="utf-8") as txt_file, srt_path.open("w", encoding="utf-8") as srt_file:
        for index, segment in enumerate(segments, start=1):
            text = segment.text.strip()
            if text:
                txt_file.write(text + "\n")
            srt_file.write(f"{index}\n")
            srt_file.write(f"{format_srt_time(segment.start)} --> {format_srt_time(segment.end)}\n")
            srt_file.write(text + "\n\n")

    print(f"Idioma detectado: {info.language} ({info.language_probability:.2f})")
    print(f"Texto: {txt_path}")
    print(f"Subtitulos: {srt_path}")


def format_srt_time(seconds: float) -> str:
    millis = int(round(seconds * 1000))
    hours, remainder = divmod(millis, 3_600_000)
    minutes, remainder = divmod(remainder, 60_000)
    secs, millis = divmod(remainder, 1000)
    return f"{hours:02}:{minutes:02}:{secs:02},{millis:03}"


if __name__ == "__main__":
    main()


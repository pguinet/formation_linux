# Image de capture de l'installeur Debian : QEMU/KVM sans affichage,
# piloté par QMP (python3), reconnaissance d'écran par OCR (tesseract).
FROM debian:trixie-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        qemu-system-x86 qemu-utils \
        python3 python3-pil \
        tesseract-ocr tesseract-ocr-fra \
        pngquant optipng \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /outil
COPY piloter.py /outil/piloter.py
ENTRYPOINT ["python3", "/outil/piloter.py"]

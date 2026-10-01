# Image de génération des PDF de la formation Linux.
# Version figée par digest : ce qui passe en local passe en CI.
FROM pandoc/extra:3.11.0.0-debian@sha256:fa8ccae75418449568f10f1842706aee1885ab24fba54f5aec08516260fc0166

RUN apt-get update \
    && apt-get install -y --no-install-recommends poppler-utils shellcheck \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --break-system-packages -r /tmp/requirements.txt

ENTRYPOINT []
WORKDIR /data

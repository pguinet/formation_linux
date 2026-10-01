# Image de capture : VirtualBox 7.2.20 pour Linux, Xvfb, openbox, xdotool.
# Le paquet .deb est fourni par le contexte nomme « cache »
# (build/captures/vbox-contexte/, copie du cache dont capturer.sh a verifie
# le SHA256).
FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Versions non epinglees : outils generiques de Debian 13 ; seul VirtualBox
# (paquet officiel verifie par SHA256) doit etre a la version exacte.
# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      xvfb openbox xdotool xclip x11-utils imagemagick optipng locales \
      fonts-dejavu-core fonts-noto-core procps ca-certificates \
      dbus-x11 \
 && sed -i 's/^# *fr_FR.UTF-8/fr_FR.UTF-8/' /etc/locale.gen \
 && locale-gen \
 && rm -rf /var/lib/apt/lists/*

# Installation du paquet officiel ; le module noyau ne peut pas etre
# compile dans le conteneur (aucune VM n'est demarree, ce n'est pas utile).
# hadolint ignore=DL3008
RUN --mount=type=bind,from=cache,target=/cache \
    apt-get update \
 && apt-get install -y --no-install-recommends \
      "/cache/virtualbox-7.2_7.2.20-175154~Debian~trixie_amd64.deb" \
 ; dpkg -s virtualbox-7.2 | grep -q '^Status: install ok installed' \
 && rm -rf /var/lib/apt/lists/*

# Interface en francais. Le pilotage tourne en root : sous Linux,
# l'installation d'une extension exige les droits d'administration
# (sous Windows, l'assistant demande l'elevation UAC).
ENV LANG=fr_FR.UTF-8 LANGUAGE=fr_FR:fr LC_ALL=fr_FR.UTF-8 \
    USER=root LOGNAME=root HOME=/root XDG_RUNTIME_DIR=/tmp/xdg
WORKDIR /root

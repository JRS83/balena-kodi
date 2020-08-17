# see https://hub.docker.com/r/balenalib/raspberry-pi-node/tags
FROM balenalib/raspberrypi4-64-node:latest-stretch-run

RUN apt-get update && apt-get install software-properties-common

#RUN add-apt-repository ppa:ubuntu-raspi2/ppa

# 1.Install wget and curl.  Only wget is needed for downloading repository.sandmann79.plugins-1.0.2.zip
RUN apt-get clean && apt-get update && apt-get install -y \
  wget \
  curl

# 2. wget sandmann79 plugins repository (needed to install amazon VOD plug-in)
#RUN  wget https://github.com/Sandmann79/xbmc/releases/download/v1.0.2/repository.sandmann79.plugins-1.0.2.zip

# Install apt deps
RUN apt-get clean && apt-get update && apt-get upgrade -y && apt-get install \
  libraspberrypi-bin=1.20180328-1~nokernel1 libraspberrypi0=1.20180328-1~nokernel1 --allow-downgrades -y \
  apt-utils \
  build-essential \
  libasound2-dev \
  libffi-dev \
  libssl-dev \
  python-dev \
  python-pip \
  git \
  alsa-base \
  alsa-utils \
  fbset \
  kodi \
  kodi-inputstream-adaptive \
  libnss3 \
  && rm -rf /var/lib/apt/lists/*

# Configure for Kodi
COPY ./Dockerbin/99-input.rules /etc/udev/rules.d/99-input.rules
COPY ./Dockerbin/10-permissions.rules /etc/udev/rules.d/10-permissions.rules
RUN addgroup --system input && \
usermod -a -G audio root && \
usermod -a -G video root && \
usermod -a -G input root && \
usermod -a -G dialout root && \
usermod -a -G plugdev root && \
usermod -a -G tty root

# Set npm
RUN npm config set unsafe-perm true

# Uncomment if you want to Configure for pHAT DAC
# COPY ./Dockerbin/asound.conf /etc/asound.conf

# Save source folder
RUN printf "%s\n" "${PWD##}" > SOURCEFOLDER

# Move to app dir
WORKDIR /usr/src/app

# Move package.json to filesystem
COPY "$SOURCEFOLDER/app/package.json" ./

# NPM i app
RUN JOBS=MAX npm i --production

# Move app and advancedsetting.xml to filesystem
COPY "$SOURCEFOLDER/app" ./

# Move to /
WORKDIR /

## uncomment if you want systemd
ENV INITSYSTEM on

# Start app
CMD ["bash", "/usr/src/app/start.sh"]

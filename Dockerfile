FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ENV HOME="/config"

RUN \
  echo "**** install node repo ****" && \
  apt-get update && \
  apt-get install -y \
    gnupg && \
  curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
  echo 'deb https://deb.nodesource.com/node_14.x focal main' \
    > /etc/apt/sources.list.d/nodesource.list && \
  curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo 'deb https://dl.yarnpkg.com/debian/ stable main' \
    > /etc/apt/sources.list.d/yarn.list && \
  echo "**** install build dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    build-essential \
    libx11-dev \
    libxkbfile-dev \
    pkg-config \
    python3 && \
    automake && \
    bsdmainutils && \
    libdb-dev && \
    libminiupnpc-dev && \
    libzmq3-dev && \
    libdb++-dev && \
    make && \
    cmake && \
    g++-multilib && \
    binutils-gold && \
    patch && \
    libevent-dev && \
    libboost-system-dev && \
    libboost-filesystem-dev && \
    libboost-test-dev && \
    libboost-thread-dev && \
    libqt5gui5 && \
    libqt5core5a && \
    libqt5dbus5 && \
    qttools5-dev && \
    qttools5-dev-tools && \
    libqrencode-dev && \
  echo "**** install runtime dependencies ****" && \
  apt-get install -y \
    git \
    jq \
    nano \
    net-tools \
    nodejs \
    sudo \
    yarn && \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://registry.yarnpkg.com/code-server \
    | jq -r '."dist-tags".latest' | sed 's|^|v|'); \
  fi && \
  CODE_VERSION=$(echo "$CODE_RELEASE" | awk '{print substr($1,2); }') && \
  npm config set python python3 && \
  yarn config set network-timeout 600000 -g && \
  yarn --production --verbose --frozen-lockfile global add code-server@"$CODE_VERSION" && \
  yarn cache clean && \
  echo "**** clean up ****" && \
  apt-get purge --auto-remove -y \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    pkg-config && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

RUN wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz && \
    tar xf autoconf* && \
    cd autoconf-2.69 && \
    sh configure --prefix /usr/local && \
    make install

RUN wget http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz && \
    tar xf automake* && \
    cd automake-1.15 && \
    sh configure --prefix/usr/local && \
    make install

RUN wget http://mirror.jre655.com/GNU/libtool/libtool-2.4.6.tar.gz && \
    tar xf libtool* && \
    cd libtool-2.4.6 && \
    sh configure --prefix /usr/local && \
    make install 

# add local files
COPY /root /

# ports and volumes
EXPOSE 8443

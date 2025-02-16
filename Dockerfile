FROM gemfield/torchpod-ubuntu:24.04
LABEL maintainer="gemfield@civilnet.cn"

EXPOSE 5900
EXPOSE 7030
EXPOSE 3389
EXPOSE 20022

#workaround, just delete it in your local environment.
#COPY apt.conf /etc/apt/apt.conf
#base packages
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo keyboard-configuration keyboard-configuration/layout select 'English (US)' | debconf-set-selections && \
    echo keyboard-configuration keyboard-configuration/layoutcode select 'us' | debconf-set-selections && \
    echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections && \
    apt update && \
    apt dist-upgrade -y && \
    apt install -y --no-install-recommends build-essential vim wget curl bzip2 git git-lfs python3-pip bison flex autoconf automake libtool make unzip g++ binutils cmake locales \
        ca-certificates apt-transport-https gnupg gnupg2 software-properties-common iputils-ping net-tools tree openssh-server && \
    wget --no-check-certificate -q http://archive.neon.kde.org/public.key -O- | apt-key add - && \
    add-apt-repository -y http://archive.neon.kde.org/user && \
    apt update && \
    apt install -y ubuntu-minimal ubuntu-standard neon-desktop plasma-workspace-wayland kwin-wayland kwin-wayland-backend-x11 kwin-wayland-backend-wayland kwin-x11 \
        xrdp supervisor supervisor-doc tigervnc-standalone-server tigervnc-xorg-extension krfb fcitx5 fcitx5-chinese-addons default-jdk openjdk-21-jdk && \
    ln -fs /usr/bin/python3 /usr/bin/python && \
    apt purge -y firefox neon-repositories-mozilla-firefox grub* linux-headers* linux-modules-extra* linux-firmware* firmware-sof-signed* linux-tools-* hplip hplip-data fwupd printer-driver-* *-driver-* wireless-regdb && \
    rm -rf /usr/share/hplip/ /boot /usr/lib/modules && \
    cd /usr/share/wallpapers/ && rm -rf $(ls | grep -v Next) && \
    cd /usr/share/wallpapers/Next/contents/images_dark && find . -name '[3-7]*' -exec rm -f {} \;  && \
    cd /usr/share/wallpapers/Next/contents/images && find . -name '[3-7]*' -exec rm -f {} \; && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

#locale
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && dpkg-reconfigure -f noninteractive tzdata && locale-gen zh_CN.utf8

#code & firefox
RUN wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add - && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/gemfield-vs.list && \
    rm -f /etc/apt/sources.list.d/org.kde.neon.packages.mozilla.org.sources && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null && \
    bash -c 'echo -e "\nPackage: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n" | tee /etc/apt/preferences.d/mozilla'
    
#code & firefox
RUN apt update && \
    apt dist-upgrade -y && \
    apt install -y firefox code okular kdiff3 kompare gwenview kinfocenter libreoffice && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

#env
ENV LC_ALL=zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN.UTF-8
ENV XMODIFIERS=@im=fcitx
ENV GTK_IM_MODULE=fcitx
ENV QT_IM_MODULE=fcitx

ENV WAYLAND_DISPLAY=wayland-0
ENV DISPLAY=:0
ENV RENDER_ID=109
ENV PROTOCOL=X11

#VNC window size
ENV SCR_WIDTH=1920
ENV SCR_HEIGHT=1080

ENV TORCHPOD_VER=1.0
ENV TORCHPOD_MODE=RDP
ENV TORCHPOD_USER=gemfield
ENV TORCHPOD_PASSWORD=gemfield
ENV TORCHPOD_HOME=/home/gemfield
ENV XDG_RUNTIME_DIR=/run/gemfield
ENV HOME=$TORCHPOD_HOME

COPY torchpod_root/ /
RUN /gemfield/clean.sh

WORKDIR $HOME
ENTRYPOINT ["/init"]

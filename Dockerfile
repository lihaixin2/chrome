# This dockerfile will build an image that can run a full android emulator + the visual emulator over VNC.
# This is maintained and intended to be run in AWS Docker instances with ECS support.
# Based on the work by https://github.com/ConSol/docker-headless-vnc-container

FROM ubuntu:14.04

MAINTAINER lihaixin "15050999@qq.com"
ENV REFRESHED_AT 2015-12-02


ENV DEBIAN_FRONTEND noninteractive
ENV DISPLAY :1
ENV NO_VNC_HOME /root/noVNC
ENV VNC_COL_DEPTH 24
ENV VNC_RESOLUTION 1366x768
ENV VNC_PW vncpassword

ENV SAKULI_DOWNLOAD_URL https://labs.consol.de/sakuli/install

RUN set -x \
 && : \
 && : add linux-mint dependicies and update packages \
 && apt-key adv --recv-key --keyserver keyserver.ubuntu.com "3EE67F3D0FF405B2" \
 && echo "deb http://packages.linuxmint.com/ rafaela main upstream import" >> /etc/apt/sources.list.d/mint.list \
 && echo "deb http://extra.linuxmint.com/ rafaela main " >> /etc/apt/sources.list.d/mint.list \
 && : \
 && : xvnc / xfce installation \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
	firefox firefox-locale-zh-hans language-pack-zh-hans \
	supervisor \
	unzip \
	vim \
	vnc4server \
	wget \
	xfce4 \
 && mkdir -p $NO_VNC_HOME/utils/websockify \
 && wget -qO- https://github.com/kanaka/noVNC/archive/master.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME \
 && wget -qO- https://github.com/kanaka/websockify/archive/v0.7.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify \
 && chmod +x -v /root/noVNC/utils/*.sh \
 && : \
 && : Install chrome browser \
 && apt-get install -y \
	chromium-browser \
	chromium-browser-l10n \
	chromium-codecs-ffmpeg \
 && ln -s /usr/bin/chromium-browser /usr/bin/google-chrome \
 && echo "alias chromium-browser='/usr/bin/chromium-browser --user-data-dir'" >> /root/.bashrc \
 && apt-get clean \



# xvnc server porst, if $DISPLAY=:1 port will be 5901
# EXPOSE 5901
# novnc web port
EXPOSE 6901

ADD .vnc /root/.vnc
ADD .config /root/.config
ADD Desktop /root/Desktop
ADD scripts /root/scripts
RUN chmod +x /root/.vnc/xstartup /etc/X11/xinit/xinitrc /root/scripts/*.sh /root/Desktop/*.desktop

CMD ["/root/scripts/vnc_startup.sh", "--tail-log"]

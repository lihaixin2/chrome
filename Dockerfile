# This dockerfile will build an image that can run a full android emulator + the visual emulator over VNC.
# This is maintained and intended to be run in AWS Docker instances with ECS support.
# Based on the work by https://github.com/ConSol/docker-headless-vnc-container

FROM ubuntu:14.04

MAINTAINER Craig Williams "craig@ip80.com"
ENV REFRESHED_AT 2015-12-02

ENV DEBIAN_FRONTEND noninteractive
ENV DISPLAY :1
ENV NO_VNC_HOME /root/noVNC
ENV VNC_COL_DEPTH 24
ENV VNC_RESOLUTION 1280x1024
ENV VNC_PW vncpassword

ENV SAKULI_DOWNLOAD_URL https://labs.consol.de/sakuli/install

RUN set -x \
 && : \
 && apt-get update \
 && apt-get install wget -y \
 && : add google chrome dependicies and update packages \
 && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
 && : \
 && : xvnc / xfce installation \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
	supervisor \
	unzip \
	vim \
        language-pack-zh-hans \
	vnc4server \
	wget \
	xfce4 \
 && apt-get install -y --force-yes  google-chrome-stable \

 && mkdir -p $NO_VNC_HOME/utils/websockify \
 && wget -qO- https://github.com/kanaka/noVNC/archive/master.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME \
 && wget -qO- https://github.com/kanaka/websockify/archive/v0.7.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify \
 && chmod +x -v /root/noVNC/utils/*.sh \
 && apt-get clean \
 && rm -rf /var/cache/apt/* /var/lib/apt/lists/*


# xvnc server porst, if $DISPLAY=:1 port will be 5901
EXPOSE 5901
# novnc web port
EXPOSE 6901

ADD .vnc /root/.vnc
ADD .config /root/.config
ADD Desktop /root/Desktop
ADD scripts /root/scripts
RUN chmod +x /root/.vnc/xstartup /etc/X11/xinit/xinitrc /root/scripts/*.sh /root/Desktop/*.desktop

CMD ["/root/scripts/vnc_startup.sh", "--tail-log"]

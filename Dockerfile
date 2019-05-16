FROM ubuntu:latest
MAINTAINER niles.c@gmail.com
RUN apt-get update && apt-get -y install cron

RUN mkdir /opt/bin

ENV PATH="/opt/bin:${PATH}"

COPY capture_video /opt/bin/
COPY snapshot /opt/bin/

COPY video-cron /etc/cron.d/video-cron

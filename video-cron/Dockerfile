FROM python:3.6-alpine

RUN apk add --update coreutils && rm -rf /var/cache/apk/*
RUN apk add ffmpeg

RUN pip install awscli

RUN mkdir -p /opt/video-cron

COPY video-cron /etc/crontabs/root
COPY video-task.sh /opt/video-cron

RUN chmod 755 /opt/video-cron/*

CMD ["crond", "-f", "-d", "8"]

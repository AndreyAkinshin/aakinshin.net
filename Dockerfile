FROM ubuntu:22.04

WORKDIR /blog

RUN mkdir /tools
COPY ./init.sh /tools/init.sh

RUN apt-get update && \
    apt-get install -y wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN bash -c "cd /tools && /tools/init.sh"

EXPOSE 1313

CMD ["sh", "-c", "/tools/bin/tailwind -i ./assets/css/main-tailwindcss.css -o ./assets/css/main.css --watch & /tools/bin/hugo server --port 1313 --liveReloadPort 1313 --bind 0.0.0.0"]

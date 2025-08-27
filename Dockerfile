FROM alpine:latest

RUN apk add --no-cache curl bash unzip

# 下载并安装 Xray
RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip     && unzip xray.zip -d /usr/bin/     && rm xray.zip     && chmod +x /usr/bin/xray

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/bin/bash", "/start.sh"]

FROM alpine:latest
WORKDIR /app
COPY . .
RUN apk add --no-cache \
    bash \
    jq \
    coreutils \
    curl \
    tzdata \
    cronie
RUN chmod +x cronmate.sh
CMD ["./cronmate.sh"]

FROM python:3.11-alpine AS default

WORKDIR /seaside/echo

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

ENV BUFFER_SIZE=8192
ENV ECHO_PORT=5000

RUN apk add --no-cache tcpdump

# Copy and run echo server.
COPY echo.py ./
ENTRYPOINT ["sh", "-c", "tcpdump -i any tcp port ${ECHO_PORT}"]

HEALTHCHECK --interval=1m --timeout=1s --retries=3 --start-period=10s --start-interval=3s CMD netstat -tulpn | grep -q ":$ECHO_PORT"

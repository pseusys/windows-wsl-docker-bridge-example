FROM python:3.11-alpine AS default

WORKDIR /seaside/echo

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

ENV BUFFER_SIZE=8192
ENV ECHO_PORT=5000

# Copy and run echo server.
COPY viridian/algae/docker/echo_server.py ./
ENTRYPOINT ["python3", "echo_server.py"]

HEALTHCHECK --interval=1m --timeout=1s --retries=3 --start-period=10s --start-interval=3s CMD netstat -tulpn | grep -q ":$ECHO_PORT"

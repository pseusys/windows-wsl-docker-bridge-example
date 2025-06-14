from logging import StreamHandler, getLogger
from os import environ, getenv
from pickle import dumps
from socket import AF_INET, SOCK_STREAM, socket
from subprocess import Popen
from sys import stderr, stdout

LOG_LEVEL = getenv("LOG_LEVEL", "INFO")

handler = StreamHandler(stdout)
handler.setLevel(LOG_LEVEL)

logger = getLogger(__name__)
logger.setLevel(LOG_LEVEL)
logger.addHandler(handler)


# Start tcpdump and listen to packets on the default interface.
process = Popen(
    ["tcpdump", "-l", "-n", "-i", "any", "-v"],
    stdout=stdout,
    stderr=stderr,
    text=True,
    bufsize=1
)


# Create listener TCP socket and listen to all network interfaces.
sock = socket(AF_INET, SOCK_STREAM)
buffer = int(environ["BUFFER_SIZE"])
sock.bind(("0.0.0.0", int(environ["ECHO_PORT"])))
logger.info(f"Server bound to: {sock.getsockname()}")
sock.listen(1)

# Accept connections and return payload and incoming address in a loop.
while True:
    try:
        client, address = sock.accept()
        logger.info(f"Connection accepted from: {address}")
        message = client.recv(buffer)
        payload = {"message": message, "from": address}
        logger.info(f"Processing object: {payload}")
        client.sendall(dumps(payload))
    except KeyboardInterrupt:
        logger.info("Server stopped")
        process.terminate()
        process.wait()
        exit(0)

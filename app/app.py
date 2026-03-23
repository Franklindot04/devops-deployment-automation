import os

from fastapi import FastAPI
import logging

logging.basicConfig(
    filename="/logs/app.log",
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s"
)

logger = logging.getLogger(__name__)

app = FastAPI()

@app.get("/")
def read_root():
    logger.info("Root endpoint called")
    message = os.getenv("APP_MESSAGE", "Default message")
    return {"message": message}

@app.get("/health")
def health():
    logger.info("Health check called")
    return {"status": "ok"}

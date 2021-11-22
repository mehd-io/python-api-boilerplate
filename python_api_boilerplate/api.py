"""API routes
"""
from fastapi import FastAPI
from loguru import logger

tags_metadata = [
    {
        "name": "sentiment score",
        "description": "Scan tweets based on window and get the avg sentiment score",
    }
]

app = FastAPI(
    title="Tweet Sanalyzer",
    description="A simple API that ingest tweet and perform sentimental analysis",
    version="0.0.1",
    openapi_tags=tags_metadata,
)

logger.info("API docs available at /docs")


@app.get("/")
def read_root():
    return {"msg": "Hello World"}

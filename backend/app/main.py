import httpx
import psycopg
from fastapi import FastAPI, Response

from app.config import settings

app = FastAPI(
    title="Healthcare RAG Assistant",
    version="0.1.0",
)


def check_database() -> bool:
    try:
        with psycopg.connect(settings.database_url, connect_timeout=2) as conn:
            conn.execute("SELECT 1")
        return True
    except psycopg.Error:
        return False


def check_ollama() -> bool:
    try:
        response = httpx.get(f"{settings.ollama_url}/api/tags", timeout=2)
        response.raise_for_status()
        return True
    except httpx.HTTPError:
        return False


@app.get("/health")
def health(response: Response) -> dict:
    checks = {
        "database": check_database(),
        "ollama": check_ollama(),
    }
    healthy = all(checks.values())
    if not healthy:
        response.status_code = 503
    return {"status": "ok" if healthy else "degraded", "checks": checks}
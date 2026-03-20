from fastapi import FastAPI
from contextlib import asynccontextmanager
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ── Lifespan handler ──────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup — try to connect to DB gracefully
    try:
        from database import Base, engine
        Base.metadata.create_all(bind=engine)
        logger.info("✅ Database tables created successfully!")
    except Exception as e:
        logger.warning(f"⚠️ Database connection failed: {e}")
        logger.warning("App starting without DB — will retry on requests")
    yield
    # Shutdown
    logger.info("Shutting down...")

# ── FastAPI App ───────────────────────────────────────────────
app = FastAPI(
    title="Employee Management API",
    description="Production-grade Employee API on GCP Cloud Run",
    version="1.0.0",
    lifespan=lifespan
)

# ── Health Check ──────────────────────────────────────────────
# This MUST respond quickly — even if DB is not ready!
@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy", "service": "employee-api"}

# ── Routes ────────────────────────────────────────────────────
from routes.employees import router as employee_router
app.include_router(employee_router)
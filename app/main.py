from fastapi import FastAPI
from contextlib import asynccontextmanager
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    try:
        from database import Base, get_engine
        engine = get_engine()
        Base.metadata.create_all(bind=engine)
        logger.info("✅ Database tables created successfully!")
    except Exception as e:
        logger.warning(f"⚠️ Database not ready yet: {e}")
    yield
    logger.info("Shutting down...")

app = FastAPI(
    title="Employee Management API",
    description="Production-grade Employee API on GCP Cloud Run",
    version="1.0.0",
    lifespan=lifespan
)

# Health check — responds immediately, no DB needed!
@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy", "service": "employee-api"}

# Routes
from routes.employees import router as employee_router
app.include_router(employee_router)
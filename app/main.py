from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.requests import Request
from fastapi.responses import HTMLResponse
from contextlib import asynccontextmanager
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ── Lifespan ──────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        from database import Base, get_engine
        engine = get_engine()
        Base.metadata.create_all(bind=engine)
        logger.info("✅ Database tables created!")
    except Exception as e:
        logger.warning(f"⚠️ Database not ready: {e}")
    yield
    logger.info("Shutting down...")

# ── FastAPI App ───────────────────────────────────────────
app = FastAPI(
    title="Employee Management API",
    description="Production-grade Employee API on GCP Cloud Run",
    version="2.0.0",
    lifespan=lifespan
)

# ── Static Files ──────────────────────────────────────────
# Tells FastAPI where to find CSS, JS files
app.mount(
    "/static",
    StaticFiles(directory="static"),
    name="static"
)

# ── Templates ─────────────────────────────────────────────
# Tells FastAPI where to find HTML files
templates = Jinja2Templates(directory="templates")

# ── Health Check ──────────────────────────────────────────
@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy", "service": "employee-api"}

# ── Frontend Route ────────────────────────────────────────
# Serves our dashboard when user visits homepage
@app.get("/", response_class=HTMLResponse, tags=["Frontend"])
async def dashboard(request: Request):
    return templates.TemplateResponse(
        "index.html",
        {"request": request}
    )

# ── API Routes ────────────────────────────────────────────
from routes.employees import router as employee_router
app.include_router(employee_router)
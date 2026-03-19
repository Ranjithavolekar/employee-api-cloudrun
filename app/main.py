from fastapi import FastAPI
from database import Base, engine
from routes.employees import router as employee_router

# Create database tables on startup
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Employee Management API",
    description="A production-grade Employee API deployed on GCP Cloud Run",
    version="1.0.0"
)

# Health check endpoint — used by Cloud Run to verify app is running
@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy", "service": "employee-api"}

# Register routes
app.include_router(employee_router)

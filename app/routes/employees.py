from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel, EmailStr
from database import get_db, Base
from models import Employee
router = APIRouter(prefix="/employees", tags=["Employees"])

# ── Pydantic Schemas ──────────────────────────────────────────
class EmployeeCreate(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    department: str
    role: str

class EmployeeUpdate(BaseModel):
    first_name: str | None = None
    last_name: str | None = None
    department: str | None = None
    role: str | None = None

class EmployeeResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str
    department: str
    role: str

    class Config:
        from_attributes = True

# ── CRUD Endpoints ────────────────────────────────────────────

# CREATE employee
@router.post("/", response_model=EmployeeResponse, status_code=status.HTTP_201_CREATED)
def create_employee(employee: EmployeeCreate, db: Session = Depends(get_db)):
    existing = db.query(Employee).filter(Employee.email == employee.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    new_employee = Employee(**employee.dict())
    db.add(new_employee)
    db.commit()
    db.refresh(new_employee)
    return new_employee

# READ all employees
@router.get("/", response_model=List[EmployeeResponse])
def get_all_employees(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(Employee).offset(skip).limit(limit).all()

# READ single employee
@router.get("/{employee_id}", response_model=EmployeeResponse)
def get_employee(employee_id: int, db: Session = Depends(get_db)):
    employee = db.query(Employee).filter(Employee.id == employee_id).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")
    return employee

# UPDATE employee
@router.put("/{employee_id}", response_model=EmployeeResponse)
def update_employee(employee_id: int, updates: EmployeeUpdate, db: Session = Depends(get_db)):
    employee = db.query(Employee).filter(Employee.id == employee_id).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")
    for key, value in updates.dict(exclude_unset=True).items():
        setattr(employee, key, value)
    db.commit()
    db.refresh(employee)
    return employee

# DELETE employee
@router.delete("/{employee_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_employee(employee_id: int, db: Session = Depends(get_db)):
    employee = db.query(Employee).filter(Employee.id == employee_id).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")
    db.delete(employee)
    db.commit()

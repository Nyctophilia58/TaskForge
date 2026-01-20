from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.models import User
from app.deps import get_db
from app.auth import require_role, get_current_user
from app.schemas import UserOut

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/me")
def me(current_user = Depends(get_current_user)):
    return current_user

# Admin-only endpoint
@router.get("/", dependencies=[Depends(require_role("admin"))])
def list_users(db: Session = Depends(get_db)):
    return db.query(User).all()

# NEW: Get all developers (for task assignment)
@router.get("/developers", response_model=list[UserOut])
def get_developers(db: Session = Depends(get_db)):
    return db.query(User).filter(User.role == "developer").all()
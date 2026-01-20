from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.deps import get_db
from app.schemas import ProjectCreate
from app import crud
from app.models import Project
from app.auth import require_role

router = APIRouter(prefix="/projects", tags=["projects"])

# Create a new project (buyer only)
@router.post("/", status_code=201)
def create_project(
        project: ProjectCreate,
        db: Session = Depends(get_db),
        current_user = Depends(require_role("buyer"))
):
    project.buyer_id = current_user.id
    return crud.create_project(db, project)

# List projects owned by the current buyer
@router.get("/", status_code=200)
def list_projects(
        db: Session = Depends(get_db),
        current_user = Depends(require_role("buyer"))
):
    return db.query(Project).filter(Project.buyer_id == current_user.id).all()

# Get a specific project by ID (buyer only)
@router.get("/{project_id}", status_code=200)
def get_project(
        project_id: int,
        db: Session = Depends(get_db),
        current_user = Depends(require_role("buyer"))
):
    project = db.query(Project).filter(
        Project.id == project_id,
        Project.buyer_id == current_user.id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project


# DELETE project
@router.delete("/{project_id}", status_code=204)
def delete_project(
        project_id: int,
        db: Session = Depends(get_db),
        current_user=Depends(require_role("buyer"))
):
    project = db.query(Project).filter(Project.id == project_id, Project.buyer_id == current_user.id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found or not owned by you")

    db.delete(project)
    db.commit()
    return None


# UPDATE project
@router.put("/{project_id}")
def update_project(
        project_id: int,
        project_update: ProjectCreate,
        db: Session = Depends(get_db),
        current_user=Depends(require_role("buyer"))
):
    project = db.query(Project).filter(Project.id == project_id, Project.buyer_id == current_user.id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found or not owned by you")

    project.title = project_update.title
    project.description = project_update.description
    db.commit()
    db.refresh(project)
    return project
import uuid
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from app.deps import get_db
from app.schemas import TaskCreate
from app import crud
from app.models import Project, Task
from app.auth import require_role
import shutil, os
from fastapi.responses import FileResponse

router = APIRouter(prefix="/tasks", tags=["tasks"])

UPLOAD_DIR = "./uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# Buyer creates a task
@router.post("/", status_code=201)
def create_task(task: TaskCreate, db: Session = Depends(get_db),
                current_user = Depends(require_role("buyer"))):
    # Ensure the task belongs to a project owned by this buyer
    project = db.query(Project).filter(Project.id == task.project_id,
                                            Project.buyer_id == current_user.id).first()
    if not project:
        raise HTTPException(status_code=400, detail="Invalid project ID")
    return crud.create_task(db, task)


# Developer: Mark task as in_progress
@router.patch("/{task_id}/start")
def start_task(task_id: int, db: Session = Depends(get_db),
               current_user = Depends(require_role("developer"))):
    task = db.query(Task).filter(Task.id == task_id, Task.developer_id == current_user.id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found or not assigned to you")
    if task.status != "todo":
        raise HTTPException(status_code=400, detail="Task already started or completed")
    task.status = "in_progress"
    db.commit()
    return {"message": "Task started"}


# Developer submits task with ZIP & hours
@router.post("/{task_id}/submit")
def submit_task(task_id: int, hours: float = Form(...), file: UploadFile = File(...),
                db: Session = Depends(get_db),
                current_user = Depends(require_role("developer"))):
    task = db.query(Task).filter(Task.id == task_id,
                                      Task.developer_id == current_user.id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found or not assigned to you")

    if task.status not in ["todo", "in_progress"]:
        raise HTTPException(400, "Task already submitted")

    if hours <= 0:
        raise HTTPException(status_code=400, detail="Hours must be positive")

    ext = file.filename.split(".")[-1] if "." in file.filename else ""
    filename = f"{task_id}_{uuid.uuid4()}.{ext}"
    filepath = os.path.join(UPLOAD_DIR, filename)

    with open(filepath, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    task.zip_path = f"/uploads/{filename}"  # absolute path from root
    task.hours_spent = hours
    task.status = "submitted"
    db.commit()
    db.refresh(task)
    return {"message": "Task submitted successfully"}

@router.get("/", status_code=200)
def list_tasks(db: Session = Depends(get_db),
               current_user = Depends(require_role("buyer"))):
    return db.query(Task).join(Project).filter(Project.buyer_id == current_user.id).all()


@router.get("/project/{project_id}")
def get_tasks_for_project(project_id: int, db: Session = Depends(get_db), current_user = Depends(require_role("buyer"))):
    # Verify ownership
    project = db.query(Project).filter(Project.id == project_id, Project.buyer_id == current_user.id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    tasks = db.query(Task).filter(Task.project_id == project_id).all()
    return tasks

# Developer: List my assigned tasks
@router.get("/my")
def list_developer_tasks(db: Session = Depends(get_db),
                         current_user = Depends(require_role("developer"))):
    return db.query(Task).filter(Task.developer_id == current_user.id).all()


# Buyer downloads submitted task solution (ZIP) only if paid
@router.get("/{task_id}/download")
def download_task(task_id: int, db: Session = Depends(get_db),
                  current_user = Depends(require_role("buyer"))):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    # Ensure buyer owns the project
    project = db.query(Project).filter(Project.id == task.project_id,
                                            Project.buyer_id == current_user.id).first()
    if not project:
        raise HTTPException(status_code=403, detail="Not authorized for this task")

    # Check if task is paid
    if task.status != "paid":
        raise HTTPException(status_code=403, detail="Task not paid yet. Payment required to download solution.")

    # Ensure file exists
    if not task.zip_path or not os.path.exists(task.zip_path):
        raise HTTPException(status_code=404, detail="Solution file not found")

    # Return file response
    return FileResponse(path=task.zip_path, filename=os.path.basename(task.zip_path), media_type="application/zip")


# DELETE task
@router.delete("/{task_id}", status_code=204)
def delete_task(
        task_id: int,
        db: Session = Depends(get_db),
        current_user=Depends(require_role("buyer"))
):
    task = db.query(Task).join(Project).filter(
        Task.id == task_id,
        Project.buyer_id == current_user.id
    ).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found or not owned by you")

    if task.status != "todo":
        raise HTTPException(status_code=400, detail="Cannot delete task that has started")

    db.delete(task)
    db.commit()
    return None


# UPDATE task
@router.put("/{task_id}")
def update_task(
        task_id: int,
        task_update: TaskCreate,
        db: Session = Depends(get_db),
        current_user=Depends(require_role("buyer"))
):
    task = db.query(Task).join(Project).filter(
        Task.id == task_id,
        Project.buyer_id == current_user.id
    ).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found or not owned by you")

    if task.status != "todo":
        raise HTTPException(status_code=400, detail="Cannot update task that has started")

    task.title = task_update.title
    task.description = task_update.description
    task.hourly_rate = task_update.hourly_rate
    task.developer_id = task_update.developer_id

    db.commit()
    db.refresh(task)
    return task
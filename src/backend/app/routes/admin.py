from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.auth import require_role
from app.deps import get_db
from app.models import Project, Task, Payment, User

router = APIRouter(prefix="/admin", tags=["admin"])

@router.get("/stats")
def get_admin_stats(db: Session = Depends(get_db),
                    current_user = Depends(require_role("admin"))):
    # Total projects
    total_projects = db.query(Project).count()

    # Total tasks
    total_tasks = db.query(Task).count()

    # Completed tasks
    completed_tasks = db.query(Task).filter(Task.status.in_(["submitted", "paid"])).count()

    # Total payments received
    total_payments_received = db.query(Payment).count()

    # Pending payments (tasks submitted but not paid)
    pending_payments = db.query(Task).filter(Task.status == "submitted").count()

    # Total developer hours logged
    total_hours = db.query(Task).filter(Task.hours_spent != None).with_entities(Task.hours_spent).all()
    total_hours_sum = sum([h[0] for h in total_hours])

    # Revenue generated (hourly_rate × hours_spent, only for paid tasks)
    paid_tasks = db.query(Task).filter(Task.status == "paid").all()
    total_revenue = sum([t.hourly_rate * t.hours_spent for t in paid_tasks if t.hours_spent])

    # Total number of buyers & developers
    total_buyers = db.query(User).filter(User.role == "buyer").count()
    total_developers = db.query(User).filter(User.role == "developer").count()

    return {
        "total_projects": total_projects,
        "total_tasks": total_tasks,
        "completed_tasks": completed_tasks,
        "total_payments_completed": total_payments_received,
        "pending_payments": pending_payments,
        "total_hours_logged": total_hours_sum,
        "total_revenue": total_revenue,
        "total_buyers": total_buyers,
        "total_developers": total_developers
    }

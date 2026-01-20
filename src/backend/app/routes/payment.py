from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from app.deps import get_db
from app.models import Task, Project, Payment
from app.auth import require_role
from app.schemas import PaymentCreate

router = APIRouter(prefix="/payments", tags=["payments"])

# Buyer pays for a task
@router.post("/", status_code=201)
def create_payment(
    payment: PaymentCreate,
    db: Session = Depends(get_db),
    current_user = Depends(require_role("buyer"))
):
    task = db.query(Task).filter(Task.id == payment.task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    # Check ownership
    project = db.query(Project).filter(Project.id == task.project_id, Project.buyer_id == current_user.id).first()
    if not project:
        raise HTTPException(status_code=403, detail="Not authorized for this task")

    if task.status != "submitted":
        raise HTTPException(status_code=400, detail="Task must be submitted before payment")

    if task.hours_spent is None:
        raise HTTPException(status_code=400, detail="Hours spent not recorded")

    amount = task.hourly_rate * task.hours_spent

    # Create payment record
    db_payment = Payment(
        task_id = payment.task_id,
        buyer_id = current_user.id,
        amount = amount
    )
    db.add(db_payment)

    # Update task status to "paid"
    task.status = "paid"
    db.commit()

    return {"message": "Payment successful", "amount": amount, "task_id": payment.task_id}

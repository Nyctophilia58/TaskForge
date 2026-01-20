from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id"), nullable=False)
    developer_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    title = Column(String, index=True, nullable=False)
    description = Column(String, index=True)
    hourly_rate = Column(Float, nullable=False)
    hours_spent = Column(Float, nullable=True)
    status = Column(String, default="todo", index=True)  # todo | in_progress | submitted | paid
    zip_path = Column(String, nullable=True)

    project = relationship("Project", back_populates="tasks")
    developer = relationship("User", back_populates="tasks")
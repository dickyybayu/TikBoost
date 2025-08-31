from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import schemas
from app.core.database import get_db
from app.services.user_service import user_service
from app.services.notification_service import notification_service

router = APIRouter()

@router.get("/", response_model=List[schemas.Notification])
def read_notifications(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 50,
    unread_only: bool = False,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Retrieve notifications for current user
    """
    notifications = notification_service.get_by_user(
        db, 
        user_id=current_user.id, 
        skip=skip, 
        limit=limit,
        unread_only=unread_only
    )
    return notifications

@router.get("/unread", response_model=List[schemas.Notification])
def read_unread_notifications(
    db: Session = Depends(get_db),
    limit: int = 10,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get unread notifications
    """
    notifications = notification_service.get_unread_notifications(
        db, user_id=current_user.id, limit=limit
    )
    return notifications

@router.get("/count")
def get_unread_count(
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get count of unread notifications
    """
    count = notification_service.get_unread_count(db, user_id=current_user.id)
    return {"unread_count": count}

@router.post("/{notification_id}/read", response_model=schemas.Notification)
def mark_notification_as_read(
    *,
    db: Session = Depends(get_db),
    notification_id: int,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Mark notification as read
    """
    notification = notification_service.mark_as_read(
        db, notification_id=notification_id, user_id=current_user.id
    )
    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )
    return notification

@router.post("/mark-all-read")
def mark_all_notifications_as_read(
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Mark all notifications as read
    """
    updated_count = notification_service.mark_all_as_read(
        db, user_id=current_user.id
    )
    return {"updated_count": updated_count}

@router.post("/", response_model=schemas.Notification)
def create_notification(
    *,
    db: Session = Depends(get_db),
    notification_in: schemas.NotificationCreate,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Create custom notification (for testing or admin purposes)
    """
    notification = notification_service.create(
        db, obj_in=notification_in, user_id=current_user.id
    )
    return notification

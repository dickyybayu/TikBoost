from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.models import Notification
from app.schemas.schemas import NotificationCreate

class NotificationService:
    def create(
        self, db: Session, *, obj_in: NotificationCreate, user_id: int
    ) -> Notification:
        db_obj = Notification(
            title=obj_in.title,
            message=obj_in.message,
            type=obj_in.type,
            action_url=obj_in.action_url,
            action_text=obj_in.action_text,
            user_id=user_id
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_by_user(
        self, 
        db: Session, 
        user_id: int, 
        skip: int = 0, 
        limit: int = 50,
        unread_only: bool = False
    ) -> List[Notification]:
        query = db.query(Notification).filter(Notification.user_id == user_id)
        
        if unread_only:
            query = query.filter(Notification.is_read == False)
        
        return (
            query.order_by(Notification.created_at.desc())
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_unread_notifications(
        self, db: Session, user_id: int, limit: int = 10
    ) -> List[Notification]:
        return self.get_by_user(db, user_id, limit=limit, unread_only=True)

    def mark_as_read(self, db: Session, *, notification_id: int, user_id: int) -> Optional[Notification]:
        notification = (
            db.query(Notification)
            .filter(
                Notification.id == notification_id,
                Notification.user_id == user_id
            )
            .first()
        )
        
        if notification:
            notification.is_read = True
            db.add(notification)
            db.commit()
            db.refresh(notification)
        
        return notification

    def mark_all_as_read(self, db: Session, *, user_id: int) -> int:
        updated_count = (
            db.query(Notification)
            .filter(
                Notification.user_id == user_id,
                Notification.is_read == False
            )
            .update({"is_read": True})
        )
        db.commit()
        return updated_count

    def get_unread_count(self, db: Session, user_id: int) -> int:
        return (
            db.query(Notification)
            .filter(
                Notification.user_id == user_id,
                Notification.is_read == False
            )
            .count()
        )

    # System notifications
    def create_system_notification(
        self, 
        db: Session, 
        *,
        user_id: int,
        title: str,
        message: str,
        notification_type: str = "info",
        action_url: Optional[str] = None,
        action_text: Optional[str] = None
    ) -> Notification:
        notification_data = NotificationCreate(
            title=title,
            message=message,
            type=notification_type,
            action_url=action_url,
            action_text=action_text
        )
        return self.create(db, obj_in=notification_data, user_id=user_id)

    def notify_optimal_live_time(self, db: Session, user_id: int, optimal_time: str) -> Notification:
        return self.create_system_notification(
            db,
            user_id=user_id,
            title="Optimal Live Time",
            message=f"Best time to go live today: {optimal_time}",
            notification_type="info",
            action_text="Go Live"
        )

    def notify_performance_boost(self, db: Session, user_id: int, percentage: float) -> Notification:
        return self.create_system_notification(
            db,
            user_id=user_id,
            title="Performance Boost",
            message=f"Your live performance has increased by {percentage}% this week.",
            notification_type="success",
            action_text="View Report"
        )

    def notify_bundle_opportunity(
        self, db: Session, user_id: int, bundle_name: str, discount: str
    ) -> Notification:
        return self.create_system_notification(
            db,
            user_id=user_id,
            title="Bundling Opportunity",
            message=f"New bundle available: {bundle_name} ({discount} Off)",
            notification_type="promotion",
            action_text="Try Now"
        )

notification_service = NotificationService()

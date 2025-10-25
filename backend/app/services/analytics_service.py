from typing import List, Optional
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import date
from app.models.models import Analytics

class AnalyticsService:
    def get_total_viewers(self, db: Session, user_id: int, date: date) -> int:
        result = db.query(func.sum(Analytics.metric_value)).filter(
            Analytics.user_id == user_id,
            Analytics.metric_type == "viewers",
            func.date(Analytics.date) == date
        ).scalar()
        return int(result or 0)

    def get_avg_engagement(self, db: Session, user_id: int, date: date) -> float:
        result = db.query(func.avg(Analytics.metric_value)).filter(
            Analytics.user_id == user_id,
            Analytics.metric_type == "engagement_rate",
            func.date(Analytics.date) == date
        ).scalar()
        return float(result or 0.0)

    def get_total_revenue(self, db: Session, user_id: int, date: date) -> float:
        result = db.query(func.sum(Analytics.metric_value)).filter(
            Analytics.user_id == user_id,
            Analytics.metric_type == "revenue",
            func.date(Analytics.date) == date
        ).scalar()
        return float(result or 0.0)

    def create_metric(
        self,
        db: Session,
        user_id: int,
        metric_type: str,
        metric_value: float,
        platform: Optional[str] = None,
        session_id: Optional[int] = None
    ) -> Analytics:
        db_obj = Analytics(
            user_id=user_id,
            date=func.now(),
            metric_type=metric_type,
            metric_value=metric_value,
            platform=platform,
            session_id=session_id
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

analytics_service = AnalyticsService()

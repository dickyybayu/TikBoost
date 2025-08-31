from typing import List, Optional
from sqlalchemy.orm import Session
from datetime import datetime, date
from app.models.models import Analytics
from app.schemas.schemas import AnalyticsBase

class AnalyticsService:
    def create_metric(
        self, db: Session, *, user_id: int, metric_data: AnalyticsBase
    ) -> Analytics:
        db_obj = Analytics(
            user_id=user_id,
            date=metric_data.date,
            metric_type=metric_data.metric_type,
            metric_value=metric_data.metric_value,
            platform=metric_data.platform,
            session_id=metric_data.session_id
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_total_viewers(self, db: Session, user_id: int, date: date) -> int:
        result = db.query(Analytics).filter(
            Analytics.user_id == user_id,
            Analytics.metric_type == "viewers",
            Analytics.date >= datetime.combine(date, datetime.min.time()),
            Analytics.date < datetime.combine(date, datetime.max.time())
        ).first()
        return int(result.metric_value) if result else 0

    def get_avg_engagement(self, db: Session, user_id: int, date: date) -> float:
        result = db.query(Analytics).filter(
            Analytics.user_id == user_id,
            Analytics.metric_type == "engagement_rate",
            Analytics.date >= datetime.combine(date, datetime.min.time()),
            Analytics.date < datetime.combine(date, datetime.max.time())
        ).first()
        return float(result.metric_value) if result else 0.0

    def get_total_revenue(self, db: Session, user_id: int, date: date) -> float:
        result = db.query(Analytics).filter(
            Analytics.user_id == user_id,
            Analytics.metric_type == "revenue",
            Analytics.date >= datetime.combine(date, datetime.min.time()),
            Analytics.date < datetime.combine(date, datetime.max.time())
        ).first()
        return float(result.metric_value) if result else 0.0

    def get_metrics_by_period(
        self, 
        db: Session, 
        user_id: int, 
        start_date: datetime, 
        end_date: datetime,
        metric_type: Optional[str] = None
    ) -> List[Analytics]:
        query = db.query(Analytics).filter(
            Analytics.user_id == user_id,
            Analytics.date >= start_date,
            Analytics.date <= end_date
        )
        if metric_type:
            query = query.filter(Analytics.metric_type == metric_type)
        return query.all()

analytics_service = AnalyticsService()

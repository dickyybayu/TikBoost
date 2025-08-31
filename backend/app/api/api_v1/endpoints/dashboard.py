from typing import Any
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from app import schemas
from app.core.database import get_db
from app.services import user_service, analytics_service, live_session_service, product_service, notification_service

router = APIRouter()

@router.get("/", response_model=schemas.DashboardResponse)
def get_dashboard_data(
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get dashboard data including metrics, recent sessions, top products, and notifications
    """
    # Get today's metrics
    today = datetime.now().date()
    yesterday = today - timedelta(days=1)
    
    # Calculate metrics
    viewers_today = analytics_service.get_total_viewers(db, user_id=current_user.id, date=today)
    viewers_yesterday = analytics_service.get_total_viewers(db, user_id=current_user.id, date=yesterday)
    viewers_change = ((viewers_today - viewers_yesterday) / max(viewers_yesterday, 1)) * 100
    
    engagement_today = analytics_service.get_avg_engagement(db, user_id=current_user.id, date=today)
    engagement_yesterday = analytics_service.get_avg_engagement(db, user_id=current_user.id, date=yesterday)
    engagement_change = engagement_today - engagement_yesterday
    
    revenue_today = analytics_service.get_total_revenue(db, user_id=current_user.id, date=today)
    revenue_yesterday = analytics_service.get_total_revenue(db, user_id=current_user.id, date=yesterday)
    revenue_change = ((revenue_today - revenue_yesterday) / max(revenue_yesterday, 1)) * 100
    
    # Get recent data
    recent_sessions = live_session_service.get_recent_sessions(db, user_id=current_user.id, limit=3)
    top_products = product_service.get_top_products(db, user_id=current_user.id, limit=5)
    notifications = notification_service.get_unread_notifications(db, user_id=current_user.id, limit=5)
    
    metrics = schemas.DashboardMetrics(
        viewers_today=viewers_today,
        viewers_change=viewers_change,
        engagement_rate=engagement_today,
        engagement_change=engagement_change,
        revenue_today=revenue_today,
        revenue_change=revenue_change
    )
    
    return schemas.DashboardResponse(
        metrics=metrics,
        recent_sessions=recent_sessions,
        top_products=top_products,
        notifications=notifications
    )

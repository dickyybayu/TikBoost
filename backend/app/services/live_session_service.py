from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from datetime import datetime
from app.models.models import LiveSession, SessionProduct
from app.schemas.schemas import LiveSessionCreate, LiveSessionUpdate

class LiveSessionService:
    def create(
        self, db: Session, *, obj_in: LiveSessionCreate, owner_id: int
    ) -> LiveSession:
        db_obj = LiveSession(
            title=obj_in.title,
            description=obj_in.description,
            scheduled_start=obj_in.scheduled_start,
            scheduled_end=obj_in.scheduled_end,
            platform=obj_in.platform,
            owner_id=owner_id,
            status="scheduled"
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get(self, db: Session, session_id: int) -> Optional[LiveSession]:
        return db.query(LiveSession).filter(LiveSession.id == session_id).first()

    def get_by_owner(
        self, db: Session, owner_id: int, skip: int = 0, limit: int = 100
    ) -> List[LiveSession]:
        return (
            db.query(LiveSession)
            .filter(LiveSession.owner_id == owner_id)
            .order_by(LiveSession.scheduled_start.desc())
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_recent_sessions(
        self, db: Session, user_id: int, limit: int = 5
    ) -> List[LiveSession]:
        return (
            db.query(LiveSession)
            .filter(LiveSession.owner_id == user_id)
            .order_by(LiveSession.created_at.desc())
            .limit(limit)
            .all()
        )

    def get_upcoming_sessions(
        self, db: Session, user_id: int, limit: int = 10
    ) -> List[LiveSession]:
        now = datetime.utcnow()
        return (
            db.query(LiveSession)
            .filter(
                LiveSession.owner_id == user_id,
                LiveSession.scheduled_start > now,
                LiveSession.status.in_(["scheduled", "live"])
            )
            .order_by(LiveSession.scheduled_start.asc())
            .limit(limit)
            .all()
        )

    def update(
        self, db: Session, *, db_obj: LiveSession, obj_in: LiveSessionUpdate
    ) -> LiveSession:
        update_data = obj_in.dict(exclude_unset=True)
        for field in update_data:
            if hasattr(db_obj, field):
                setattr(db_obj, field, update_data[field])
        
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def start_session(self, db: Session, *, session_id: int) -> LiveSession:
        session = self.get(db, session_id)
        if session:
            session.status = "live"
            session.actual_start = datetime.utcnow()
            db.add(session)
            db.commit()
            db.refresh(session)
        return session

    def end_session(self, db: Session, *, session_id: int) -> LiveSession:
        session = self.get(db, session_id)
        if session:
            session.status = "completed"
            session.actual_end = datetime.utcnow()
            db.add(session)
            db.commit()
            db.refresh(session)
        return session

    def update_metrics(
        self, 
        db: Session, 
        *, 
        session_id: int, 
        viewer_count: int = None,
        engagement_rate: float = None,
        revenue: float = None
    ) -> LiveSession:
        session = self.get(db, session_id)
        if session:
            if viewer_count is not None:
                session.viewer_count = viewer_count
                if viewer_count > session.peak_viewers:
                    session.peak_viewers = viewer_count
            
            if engagement_rate is not None:
                session.engagement_rate = engagement_rate
                
            if revenue is not None:
                session.revenue_generated += revenue
            
            db.add(session)
            db.commit()
            db.refresh(session)
        return session

live_session_service = LiveSessionService()

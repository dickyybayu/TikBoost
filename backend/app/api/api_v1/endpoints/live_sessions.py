from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import schemas
from app.core.database import get_db
from app.services.user_service import user_service
from app.services.live_session_service import live_session_service

router = APIRouter()

@router.post("/", response_model=schemas.LiveSession)
def create_live_session(
    *,
    db: Session = Depends(get_db),
    session_in: schemas.LiveSessionCreate,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Create new live session
    """
    session = live_session_service.create(
        db, obj_in=session_in, owner_id=current_user.id
    )
    return session

@router.get("/", response_model=List[schemas.LiveSession])
def read_live_sessions(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Retrieve live sessions for current user
    """
    sessions = live_session_service.get_by_owner(
        db, owner_id=current_user.id, skip=skip, limit=limit
    )
    return sessions

@router.get("/upcoming", response_model=List[schemas.LiveSession])
def read_upcoming_sessions(
    db: Session = Depends(get_db),
    limit: int = 10,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get upcoming live sessions
    """
    sessions = live_session_service.get_upcoming_sessions(
        db, user_id=current_user.id, limit=limit
    )
    return sessions

@router.get("/{session_id}", response_model=schemas.LiveSession)
def read_live_session(
    *,
    db: Session = Depends(get_db),
    session_id: int,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get live session by ID
    """
    session = live_session_service.get(db, session_id=session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Live session not found"
        )
    if session.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions"
        )
    return session

@router.put("/{session_id}", response_model=schemas.LiveSession)
def update_live_session(
    *,
    db: Session = Depends(get_db),
    session_id: int,
    session_in: schemas.LiveSessionUpdate,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Update live session
    """
    session = live_session_service.get(db, session_id=session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Live session not found"
        )
    if session.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions"
        )
    
    session = live_session_service.update(db, db_obj=session, obj_in=session_in)
    return session

@router.post("/{session_id}/start", response_model=schemas.LiveSession)
def start_live_session(
    *,
    db: Session = Depends(get_db),
    session_id: int,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Start live session
    """
    session = live_session_service.get(db, session_id=session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Live session not found"
        )
    if session.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions"
        )
    
    session = live_session_service.start_session(db, session_id=session_id)
    return session

@router.post("/{session_id}/end", response_model=schemas.LiveSession)
def end_live_session(
    *,
    db: Session = Depends(get_db),
    session_id: int,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    End live session
    """
    session = live_session_service.get(db, session_id=session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Live session not found"
        )
    if session.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions"
        )
    
    session = live_session_service.end_session(db, session_id=session_id)
    return session

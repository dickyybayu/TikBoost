from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any
import json
import os
from pathlib import Path

router = APIRouter()

# Directory to store user sessions
SESSIONS_DIR = Path("user_sessions")
SESSIONS_DIR.mkdir(exist_ok=True)

class SessionsData(BaseModel):
    sessions: List[Dict[str, Any]]

@router.post("/user-sessions/save/{username}")
async def save_user_sessions(username: str, data: SessionsData):
    """Save user sessions to a file"""
    try:
        # Create file path for user sessions
        sessions_file = SESSIONS_DIR / f"{username}_sessions.json"
        
        # Save sessions to file
        with open(sessions_file, 'w') as f:
            json.dump({
                "username": username,
                "sessions": data.sessions
            }, f, indent=2)
            
        return {"status": "success", "message": f"Sessions saved for {username}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save sessions: {str(e)}")

@router.get("/user-sessions/load/{username}")
async def load_user_sessions(username: str):
    """Load user sessions from file"""
    try:
        sessions_file = SESSIONS_DIR / f"{username}_sessions.json"
        
        if not sessions_file.exists():
            return {"username": username, "sessions": []}
            
        with open(sessions_file, 'r') as f:
            data = json.load(f)
            
        return {
            "username": username,
            "sessions": data.get("sessions", [])
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to load sessions: {str(e)}")

@router.delete("/user-sessions/delete/{username}")
async def delete_user_sessions(username: str):
    """Delete user sessions file"""
    try:
        sessions_file = SESSIONS_DIR / f"{username}_sessions.json"
        
        if sessions_file.exists():
            os.remove(sessions_file)
            return {"status": "success", "message": f"Sessions deleted for {username}"}
        else:
            return {"status": "success", "message": f"No sessions found for {username}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete sessions: {str(e)}")

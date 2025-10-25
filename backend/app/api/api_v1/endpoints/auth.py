from datetime import timedelta
from typing import Any, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Body, Request
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from fastapi.responses import RedirectResponse, JSONResponse

from app import schemas
from app.core import security
from app.core.config import settings
from app.core.database import get_db
from app.services import user_service

try:
    from google.oauth2 import id_token as google_id_token
    from google.auth.transport import requests as google_requests
except Exception:  # pragma: no cover - optional at runtime if not used
    google_id_token = None  # type: ignore
    google_requests = None  # type: ignore

router = APIRouter()

@router.post("/login", response_model=schemas.Token)
def login_access_token(
    db: Session = Depends(get_db),
    form_data: OAuth2PasswordRequestForm = Depends()
) -> Any:
    """
    OAuth2 compatible token login, get an access token for future requests
    """
    user = user_service.authenticate(
        db, email=form_data.username, password=form_data.password
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password"
        )
    elif not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Inactive user"
        )
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return {
        "access_token": security.create_access_token(
            user.id, expires_delta=access_token_expires
        ),
        "token_type": "bearer",
    }

@router.post("/register", response_model=schemas.User)
def register(
    *,
    db: Session = Depends(get_db),
    user_in: schemas.UserCreate,
) -> Any:
    """
    Create new user account
    """
    user = user_service.get_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email already exists"
        )
    
    user = user_service.get_by_username(db, username=user_in.username)
    if user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this username already exists"
        )
    
    user = user_service.create(db, obj_in=user_in)
    return user

@router.post("/test-token", response_model=schemas.User)
def test_token(current_user: schemas.User = Depends(user_service.get_current_user)) -> Any:
    """
    Test access token
    """
    return current_user

# ---- Google Sign-In ----
@router.post("/google", response_model=schemas.Token)
def login_with_google(
    *,
    db: Session = Depends(get_db),
    id_token: str = Body(..., embed=True, description="Google ID token from client"),
) -> Any:
    if google_id_token is None or google_requests is None:
        raise HTTPException(status_code=500, detail="Google auth not available on server")

    try:
        req = google_requests.Request()
        audience: Optional[str] = settings.GOOGLE_OAUTH_CLIENT_ID
        idinfo = google_id_token.verify_oauth2_token(id_token, req, audience) if audience else google_id_token.verify_oauth2_token(id_token, req)
    except Exception:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid Google token")

    email: str = idinfo.get("email")
    if not email:
        raise HTTPException(status_code=400, detail="Google token missing email")

    # Find or create user
    user = user_service.get_by_email(db, email=email)
    if not user:
        # Build a username from email local-part; ensure uniqueness
        base_username = email.split("@")[0][:20]
        candidate = base_username or "user"
        suffix = 0
        while user_service.get_by_username(db, username=candidate):
            suffix += 1
            candidate = f"{base_username}{suffix}"
        from app.schemas.schemas import UserCreate
        import secrets
        user = user_service.create(
            db,
            obj_in=UserCreate(
                email=email,
                username=candidate,
                password=secrets.token_urlsafe(16),
            ),
        )

    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return {
        "access_token": security.create_access_token(user.id, expires_delta=access_token_expires),
        "token_type": "bearer",
    }


# ---- TikTok OAuth (scaffold) ----
@router.get("/tiktok/start")
def tiktok_oauth_start() -> Any:
    if not (settings.TIKTOK_CLIENT_KEY and settings.TIKTOK_REDIRECT_URI):
        raise HTTPException(status_code=400, detail="TikTok OAuth not configured")
    import secrets, urllib.parse
    state = secrets.token_urlsafe(16)
    params = {
        "client_key": settings.TIKTOK_CLIENT_KEY,
        "response_type": "code",
        "scope": "user.info.basic",
        "redirect_uri": settings.TIKTOK_REDIRECT_URI,
        "state": state,
    }
    url = "https://www.tiktok.com/v2/auth/authorize/?" + urllib.parse.urlencode(params)
    # Return URL so mobile can open it (or redirect directly if used from browser)
    return {"auth_url": url, "state": state}


@router.get("/tiktok/callback")
async def tiktok_oauth_callback(
    request: Request,
    code: Optional[str] = None,
    state: Optional[str] = None,
    db: Session = Depends(get_db),
):
    if not (settings.TIKTOK_CLIENT_KEY and settings.TIKTOK_CLIENT_SECRET and settings.TIKTOK_REDIRECT_URI):
        return JSONResponse(status_code=400, content={"detail": "TikTok OAuth not configured"})
    if not code:
        return JSONResponse(status_code=400, content={"detail": "Missing code"})

    import httpx
    token_url = "https://open.tiktokapis.com/v2/oauth/token/"
    data = {
        "client_key": settings.TIKTOK_CLIENT_KEY,
        "client_secret": settings.TIKTOK_CLIENT_SECRET,
        "code": code,
        "grant_type": "authorization_code",
        "redirect_uri": settings.TIKTOK_REDIRECT_URI,
    }
    async with httpx.AsyncClient(timeout=20) as client:
        token_resp = await client.post(token_url, data=data)
        if token_resp.status_code != 200:
            return JSONResponse(status_code=400, content={"detail": "Token exchange failed"})
        token_json = token_resp.json()
        access_token = token_json.get("access_token")
        if not access_token:
            return JSONResponse(status_code=400, content={"detail": "Missing access token"})

        # Fetch user info
        user_info_url = "https://open.tiktokapis.com/v2/user/info/"
        headers = {"Authorization": f"Bearer {access_token}"}
        params = {"fields": "open_id,display_name"}
        user_resp = await client.get(user_info_url, headers=headers, params=params)
        if user_resp.status_code != 200:
            return JSONResponse(status_code=400, content={"detail": "Failed to fetch user info"})
        info = user_resp.json()
        # Extract minimally needed identifiers
        open_id = (
            info.get("data", {})
            .get("user", {})
            .get("open_id")
        )
        display_name = (
            info.get("data", {})
            .get("user", {})
            .get("display_name")
        ) or "tiktok_user"
        if not open_id:
            return JSONResponse(status_code=400, content={"detail": "Missing open_id"})

    # Map TikTok account to an app user by synthetic email
    synthetic_email = f"{open_id}@tiktok.local"
    user = user_service.get_by_email(db, email=synthetic_email)
    if not user:
        from app.schemas.schemas import UserCreate
        import secrets
        # Ensure unique username
        base_username = display_name[:20]
        candidate = base_username or "tiktok_user"
        suffix = 0
        while user_service.get_by_username(db, username=candidate):
            suffix += 1
            candidate = f"{base_username}{suffix}"
        user = user_service.create(
            db,
            obj_in=UserCreate(
                email=synthetic_email,
                username=candidate,
                password=secrets.token_urlsafe(16),
            ),
        )

    token = security.create_access_token(user.id, expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES))
    # Redirect back to app via custom scheme with token
    scheme = settings.APP_SCHEME
    redirect_to = f"{scheme}://auth/callback?token={token}"
    return RedirectResponse(url=redirect_to)

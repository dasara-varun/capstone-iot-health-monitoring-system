"""Authentication endpoints for login, token refresh, and profile inspection."""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.db_models import UserDB
from ..models.schemas import LoginRequest, TokenResponse, RefreshTokenRequest, UserResponse
from ..services.auth_service import (
    verify_password,
    create_access_token,
    get_current_user,
    decode_access_token
)

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(UserDB).filter(UserDB.username == payload.username).first()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password"
        )
    token = create_access_token(username=user.username, role=user.role)
    return TokenResponse(
        access_token=token,
        token_type="bearer",
        role=user.role,
        username=user.username
    )

@router.post("/refresh", response_model=TokenResponse)
def refresh(payload: RefreshTokenRequest, current_user: dict = Depends(get_current_user)):
    token = create_access_token(username=current_user["sub"], role=current_user.get("role", "viewer"))
    return TokenResponse(
        access_token=token,
        token_type="bearer",
        role=current_user.get("role", "viewer"),
        username=current_user["sub"]
    )

@router.get("/me", response_model=UserResponse)
def get_me(current_user: dict = Depends(get_current_user)):
    return UserResponse(
        username=current_user["sub"],
        role=current_user.get("role", "viewer")
    )

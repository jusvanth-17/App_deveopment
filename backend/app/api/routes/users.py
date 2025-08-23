from fastapi import APIRouter, Depends

from app.api.deps.auth import get_current_user

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me")
async def read_me(current_user = Depends(get_current_user)) -> dict:
	return {"user": current_user}
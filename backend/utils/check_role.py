from fastapi import status, HTTPException, Depends
from functools import wraps
from models.enum_items import Role
from typing import Annotated
import routes.auth as auth

user_dependency = Annotated[dict, Depends(auth.get_current_user)]

def check_role(allowed_roles: list[Role]):
  def decorator(func):
    @wraps(func)
    async def wrapper(*args, user: user_dependency, **kwargs):
      user_role = user['role'].upper().replace('-', '_')
      try:
        if Role[user_role] not in [role.value for role in allowed_roles]:
          raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Operation not permitted"
          )
      except KeyError:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Invalid role: {user['role']}"
                )
      return await func(*args, user=user, **kwargs)
    return wrapper
  return decorator
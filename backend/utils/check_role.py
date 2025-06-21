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
      if Role[user['role']] not in [role.value for role in allowed_roles]:
        print(user['role'])
        print('allowed role: ', [role.value for role in allowed_roles])
        raise HTTPException(
          status_code=status.HTTP_403_FORBIDDEN, detail="Operation not permitted"
        )
      return await func(*args, user=user, **kwargs)
    return wrapper
  return decorator
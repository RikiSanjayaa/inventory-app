# used for request/response validation and serialization
from typing import Optional
from pydantic import BaseModel
from models.enum_items import Role

class CreateUserRequest(BaseModel):
  username: str
  password: str
  role: Optional[Role] = None
  
  model_config = {
    "json_schema_extra": {
            "examples": [
                {
                    # Basic user registration
                    "username": "user1",
                    "password": "password123"
                },
                {
                    # Admin registration
                    "username": "admin1",
                    "password": "password123",
                    "role": "admin"
                }
            ]
        }
  }
  
class Token(BaseModel):
  access_token: str
  token_type: str
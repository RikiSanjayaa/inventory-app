from enum import Enum

class Role(str, Enum):
    GENERAL_USER = "general-user"
    ADMIN = "admin"
    
class MovementType(str, Enum):
    IN = "in"
    OUT = "out"
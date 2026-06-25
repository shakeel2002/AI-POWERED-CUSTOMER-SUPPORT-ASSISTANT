from typing import List, Dict, Any
from pydantic import BaseModel

class ChatResponse(BaseModel):
    success: bool
    intent: str
    ui_type: str
    message: str
    data: List[Dict[str, Any]]
    memory: Dict[str, Any]

    class Config:
        arbitrary_types_allowed = True
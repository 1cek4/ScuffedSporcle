from pydantic import BaseModel, Field
from uuid import UUID
from typing import Optional
from quiz import CompletedQuiz

class User(BaseModel):
    userGuid: Optional[UUID] = None
    email: str
    password: str
    userName: str
    completedQuiz: list[CompletedQuiz]
    isAdmin: bool = False
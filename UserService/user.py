from pydantic import BaseModel, Field
from uuid import UUID
from quiz import CompletedQuiz

from typing import Optional

class User(BaseModel):
    userGuid: UUID
    email: str
    password: str
    userName: str
    completedQuiz: list[CompletedQuiz]
    isAdmin: bool = Field(default=False)
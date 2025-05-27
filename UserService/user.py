from pydantic import BaseModel
from typing import Optional
from quiz import CompletedQuiz

class UserCreate(BaseModel):
    email: str
    password: str
    username: str
    completedQuiz: list[CompletedQuiz]
    isAdmin: bool = False

class User(UserCreate):
    userGuid: str
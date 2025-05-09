from datetime import date
from pydantic import BaseModel, Field
from uuid import UUID

class CompletedQuiz(BaseModel):
    quizGuid: UUID
    quizName: str
    category: str
    quizDescription: str
    category: str
    score: UUID


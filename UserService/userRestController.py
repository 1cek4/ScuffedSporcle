from fastapi import FastAPI, Depends, HTTPException, status, Body
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import mariadb
from dotenv import load_dotenv
import os
import uuid
import py_eureka_client.eureka_client as eureka_client

load_dotenv()

SERVICE_NAME = os.getenv("SERVICE_NAME", "UserServiceAPI")
SERVICE_PORT = int(os.getenv("SERVICE_PORT", 8082))
SERVICE_IP = os.getenv("SERVICE_IP", "127.0.0.1")
CLASSICQUIZ_SERVICE_URL = os.getenv("CLASSICQUIZ_SERVICE_URL", "http://localhost:8081/classicQuiz")


class User(BaseModel):
    userGuid: str
    email: str
    password: str
    userName: str
    completedQuiz: Optional[List[str]] = None
    isAdmin: Optional[bool] = False

class UserCreate(BaseModel):
    email: str
    password: str
    userName: str
    completedQuiz: Optional[List[str]] = None
    isAdmin: Optional[bool] = False



# Dependency to get the database connection
def get_db_connection():
    try:
        conn = mariadb.connect(
            host=os.getenv("DB_HOST", "127.0.0.1"),
            user=os.getenv("DB_USER", "root"),
            password=os.getenv("DB_PASSWORD", "abc123"),
            port=int(os.getenv("DB_PORT", 3306)),
            database=os.getenv("DB_NAME", "usersdb")
        )
        return conn
    except mariadb.Error as e:
        print(f"Error connecting to MariaDB: {e}")
        raise HTTPException(status_code=500, detail="Database connection failed")  # Raise HTTPException

app = FastAPI()

@app.on_event("startup")
async def startup_event():
    await eureka_client.init_async(
        eureka_server="http://EurekaRegistry:8761/eureka/",
        app_name="UserServiceAPI",
        instance_port=8082,
        instance_host="UserServiceAPI"
    )

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/users/login", response_model=User)
def get_user_by_credentials(username: str, password: str, conn: mariadb.Connection = Depends(get_db_connection)):
    try:
        cur = conn.cursor()
        cur.execute(
            "SELECT UserGuid, Email, Password, Username, CompletedQuiz, IsAdmin FROM users WHERE Username = ? AND Password = ?",
            (username, password)
        )
        user = cur.fetchone()
        cur.close()
        if user:
            completed_quiz = user[4]
            if isinstance(completed_quiz, str):
                if completed_quiz.strip() == "":
                    completed_quiz = []
                else:
                    completed_quiz = [q.strip() for q in completed_quiz.split(",")]
            elif completed_quiz is None:
                completed_quiz = []
            return User(
                userGuid=user[0],
                email=user[1],
                password=user[2],
                userName=user[3],
                completedQuiz=completed_quiz,
                isAdmin=bool(user[5])
            )
        else:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Invalid username or password"
            )
    except mariadb.Error as e:
        print(f"Error fetching user by credentials: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve user from the database",
        )
    finally:
        conn.close()



# Define the API endpoint to get all users
@app.get("/users", response_model=List[User])
def get_users(conn: mariadb.Connection = Depends(get_db_connection)):
    try:
        cur = conn.cursor()
        cur.execute("SELECT UserGuid, Email, Password, Username, CompletedQuiz, IsAdmin FROM users")
        users_data = cur.fetchall()
        users = []
        for row in users_data:
            completed_quiz = row[4]
            if isinstance(completed_quiz, str):
                if completed_quiz.strip() == "":
                    completed_quiz = []
                else:
                    completed_quiz = [q.strip() for q in completed_quiz.split(",")]
            elif completed_quiz is None:
                completed_quiz = []
            users.append(User(
                userGuid=row[0],
                email=row[1],
                password=row[2],
                userName=row[3],
                completedQuiz=completed_quiz,
                isAdmin=bool(row[5]) if len(row) > 5 else False
            ))
        cur.close()
        return users
    except mariadb.Error as e:
        print(f"Error fetching users: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve users from the database",
        )
    finally:
        conn.close()


@app.get("/users/{user_id}", response_model=User)
def get_user_by_id(user_id: str, conn: mariadb.Connection = Depends(get_db_connection)):
    try:
        cur = conn.cursor()
        cur.execute(
            "SELECT UserGuid, Email, Password, Username, CompletedQuiz, IsAdmin FROM users WHERE UserGuid = ?",
            (user_id,)
        )
        user = cur.fetchone()
        cur.close()
        if user:
            completed_quiz = user[4]
            if isinstance(completed_quiz, str):
                if completed_quiz.strip() == "":
                    completed_quiz = []
                else:
                    completed_quiz = [q.strip() for q in completed_quiz.split(",")]
            elif completed_quiz is None:
                completed_quiz = []
            return User(
                userGuid=user[0],
                email=user[1],
                password=user[2],
                userName=user[3],
                completedQuiz=completed_quiz,
                isAdmin=bool(user[5]) if len(user) > 5 else False
            )
        else:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail=f"User with ID {user_id} not found"
            )
    except mariadb.Error as e:
        print(f"Error fetching user: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve user from the database",
        )
    finally:
        conn.close()


@app.post("/users", response_model=User, status_code=201)
def create_user(user: UserCreate, conn: mariadb.Connection = Depends(get_db_connection)):
    try:
        cur = conn.cursor()
        new_guid = str(uuid.uuid4())
        # Store as comma-separated string in DB
        completed_quiz_str = ",".join(user.completedQuiz) if user.completedQuiz else ""
        cur.execute(
            "INSERT INTO users (UserGuid, Email, Password, Username, CompletedQuiz, IsAdmin) VALUES (?, ?, ?, ?, ?, ?)",
            (new_guid, user.email, user.password, user.userName, completed_quiz_str, int(user.isAdmin))
        )
        conn.commit()
        cur.close()
        return User(
            userGuid=new_guid,
            email=user.email,
            password=user.password,
            userName=user.userName,
            completedQuiz=user.completedQuiz if user.completedQuiz else [],
            isAdmin=user.isAdmin
        )
    except mariadb.Error as e:
        print(f"Error creating user: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create user",
        )
    finally:
        conn.close()


@app.put("/users/{user_id}", response_model=User)
def update_user(user_id: str, user: User, conn: mariadb.Connection = Depends(get_db_connection)):
    try:
        cur = conn.cursor()
        # Store as comma-separated string in DB
        completed_quiz_str = ",".join(user.completedQuiz) if user.completedQuiz else ""
        cur.execute(
            "UPDATE users SET Email=?, Password=?, Username=?, CompletedQuiz=?, IsAdmin=? WHERE UserGuid=?",
            (user.email, user.password, user.userName, completed_quiz_str, int(user.isAdmin), user_id)
        )
        if cur.rowcount == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail=f"User with ID {user_id} not found"
            )
        conn.commit()
        cur.close()
        return User(
            userGuid=user_id,
            email=user.email,
            password=user.password,
            userName=user.userName,
            completedQuiz=user.completedQuiz if user.completedQuiz else [],
            isAdmin=user.isAdmin
        )
    except mariadb.Error as e:
        print(f"Error updating user: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update user",
        )
    finally:
        conn.close()


@app.delete("/users/{user_id}", status_code=204)
def delete_user(user_id: str, conn: mariadb.Connection = Depends(get_db_connection)):
    try:
        cur = conn.cursor()
        cur.execute("DELETE FROM users WHERE UserGuid = ?", (user_id,))
        if cur.rowcount == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail=f"User with ID {user_id} not found"
            )
        conn.commit()
        cur.close()
        return
    except mariadb.Error as e:
        print(f"Error deleting user: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete user",
        )
    finally:
        conn.close()




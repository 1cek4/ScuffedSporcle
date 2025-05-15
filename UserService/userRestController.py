
import mariadb
import mysql.connector

import sys

from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
import json
import requests
import os   
from uuid import UUID
from dotenv import load_dotenv
import py_eureka_client.eureka_client as eureka_client


try:
    conn = mysql.connector.connect(
    host="127.0.0.1",
    user="root",
    password="abc123",
    port=3306,
    database="userdb"
)

except mariadb.Error as e:
    print(f"Error connecting to MariaDB Platform: {e}")
    sys.exit(1)

cur = conn.cursor()

load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust for production
    allow_methods=["*"],
    allow_headers=["*"],
)

# Read environment variables with defaults for local development
SPACESHIP_SERVICE_URL = os.getenv("SPACESHIP_SERVICE_URL", "http://localhost:8081/api/spaceships")

EUREKA_SERVER = os.getenv("EUREKA_SERVER", "http://localhost:8761/eureka")
SERVICE_NAME = os.getenv("SERVICE_NAME", "BasketServiceAPI")
BASKET_SERVICE_PORT = int(os.getenv("BASKET_SERVICE_PORT", 8082))
BASKET_SERVICE_IP = os.getenv("BASKET_SERVICE_IP", "127.0.0.1")


@app.on_event("startup")
async def startup_event():
    await eureka_client.init_async(        
        eureka_server=EUREKA_SERVER,
        app_name=SERVICE_NAME,
        instance_port=BASKET_SERVICE_PORT,
        instance_ip=BASKET_SERVICE_IP
    )

@app.get("/Users", response_model=list[User])
def get_user(user_id: str):
    cur.execute(
    "SELECT * FROM users")
    vars = cur.fetchall();

    return user

@app.get("/Users/{user_id}", response_model=User)
def get_user_with_id(user_id: str):
    cur.execute(
    "SELECT * FROM users WHERE userGuid =?", 
    (user_id,))
    vars = cur.fetchall();

    return user
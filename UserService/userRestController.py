import mariadb
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
    conn = mariadb.connect(
        user="db_user",
        password="db_user_passwd",
        host="192.0.2.1",
        port=3306,
        database="employees"

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

@app.get("")
def get_user(user_id: str):
    cur.execute(
    "SELECT first_name,last_name FROM employees WHERE first_name=?", 
    (some_name,))
    vars = cur.fetchall();

    return basket

@app.get("/{user_id}", response_model=User)
def get_user_with_id(user_id: str):
    cur.execute(
    "SELECT first_name,last_name FROM employees WHERE first_name=?", 
    (some_name,))
    vars = cur.fetchall();

    return basket
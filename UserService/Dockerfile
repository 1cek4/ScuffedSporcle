FROM python:3.11-slim

WORKDIR /app

# Install build tools and MariaDB dev libs
RUN apt-get update && apt-get install -y \
    build-essential \
    libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set environment variables
ENV REDIS_HOST=UserServiceDBRedis
ENV REDIS_PORT=6379
ENV CLASSIC_QUIZ_SERVICE_URL=http://QuizServiceAPI:8080/classicQuiz
ENV SERVICE_NAME=UserServiceAPI
ENV USER_SERVICE_IP=UserServiceAPI
ENV USER_SERVICE_PORT=8082
ENV DB_HOST=UserServiceMariadb
ENV DB_USER=root
ENV DB_PASSWORD=abc123
ENV DB_NAME=usersdb
ENV DB_PORT=3306

EXPOSE 8082

CMD ["uvicorn", "userRestController:app", "--host", "0.0.0.0", "--port", "8082"]

@echo off
REM Start PANOR Backend API Server

cd "g:\PANOR-APP\backend"

REM Set environment variables if needed
set DATABASE_URL=postgresql+asyncpg://panor:panorpassword@localhost:5432/panor_db
set SECRET_KEY=supersecretjwtkey12345
set ALGORITHM=HS256

REM Start the server
echo [PANOR] Starting FastAPI server on http://0.0.0.0:8000
echo [PANOR] Docs available at http://localhost:8000/docs
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

"""Firebase-protected mutual fund basket API."""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from . import auth, database
from .routers import router
from dotenv import load_dotenv

load_dotenv()

@asynccontextmanager
async def lifespan(app: FastAPI):
    auth.initialize()
    database.initialize()
    yield

app = FastAPI(title='Mutual Fund Basket API', lifespan=lifespan)
# Flutter Android needs no CORS; localhost origins permit browser testing.
app.add_middleware(CORSMiddleware, allow_origins=['http://localhost:3000', 'http://localhost:8080'], allow_methods=['GET', 'POST', 'DELETE'], allow_headers=['Authorization', 'Content-Type'])
app.include_router(router)

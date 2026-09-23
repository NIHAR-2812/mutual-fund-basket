import os
from pathlib import Path
import firebase_admin
from firebase_admin import auth, credentials
from fastapi import Header, HTTPException
from dotenv import load_dotenv

load_dotenv()

def initialize():
    if firebase_admin._apps:
        return
    path = os.getenv('GOOGLE_APPLICATION_CREDENTIALS')
    if not path or not Path(path).is_file():
        raise RuntimeError('Set GOOGLE_APPLICATION_CREDENTIALS to your Firebase service-account JSON')
    firebase_admin.initialize_app(credentials.Certificate(path))

def user_id(authorization: str | None = Header(None)) -> str:
    if not authorization or not authorization.startswith('Bearer ') or not authorization[7:].strip():
        raise HTTPException(401, 'Sign in to access the API')
    try:
        return auth.verify_id_token(authorization[7:].strip())['uid']
    except Exception:
        raise HTTPException(401, 'Invalid or expired session; sign in again') from None

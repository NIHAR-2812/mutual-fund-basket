# Backend setup and behavior

The backend is a FastAPI service with SQLite persistence. [`../README.md`](../README.md) contains the full assignment overview, API contract, Android instructions, and submission checklist.

## Files

- `app/main.py` starts the app, registers routes, and sets local browser CORS origins.
- `app/auth.py` initializes Firebase Admin and verifies each `Authorization: Bearer <ID token>` header.
- `app/database.py` creates SQLite tables and inserts `app/funds.json` only when the fund table is empty.
- `app/routers.py` defines `GET /funds`, `GET /basket`, `POST /basket`, and `DELETE /basket/{fund_id}`.
- `app/schemas.py` validates requests and fund responses; `tests/test_api.py` checks basket isolation and error cases.

Every basket query uses the **verified Firebase UID**. The SQLite key `(user_id, fund_id)` prevents duplicates. No client-supplied user ID is accepted.

## Windows PowerShell setup

Use Python 3.11 or 3.12 if available. In the project root:

```powershell
cd backend
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

In Firebase Console, use **Project settings → Service accounts → Generate new private key** for the same Firebase project used by the Android app. Save it outside the repository. Set the variable **in the terminal that starts Uvicorn**:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\Users\cbec\firebase-private\service-account.json'
Test-Path $env:GOOGLE_APPLICATION_CREDENTIALS
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

`Test-Path` must print `True`; the server must print `Application startup complete`. A line saying “Uvicorn running” alone is insufficient because startup can fail afterward. This is a **private service-account key**, not Android's `google-services.json`. Do not commit or share it. `app/auth.py` deliberately refuses to start without it.

SQLite defaults to `backend/basket.sqlite3` and is created at startup. To choose a different database path, set `$env:DATABASE_PATH = 'C:\path\to\basket.sqlite3'` before starting Uvicorn. `.env.example` documents both variables; `.env` is **not auto-loaded**. The Python process must be restarted after changing environment variables.

## API and tests

All endpoints require a Firebase ID token, obtained by a logged-in client. Visit `http://127.0.0.1:8000/docs` for request schemas; the API contract and sample response live in the root README.

```powershell
python -m pytest -q
python -m compileall -q app tests
```

The automated test mocks Firebase verification. Complete a real sign-in and basket walkthrough with Flutter as a separate integration check. Do not delete `basket.sqlite3` if you want existing baskets to persist. The service account and SQLite database are excluded from the submission ZIP.

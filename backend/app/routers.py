import sqlite3
from fastapi import APIRouter, Depends, HTTPException
from .auth import user_id
from .database import connection
from .schemas import AddFund, Fund

router = APIRouter()

@router.get('/funds', response_model=list[Fund])
def funds(uid: str = Depends(user_id)):
    with connection() as db:
        return [dict(x) for x in db.execute('SELECT * FROM funds ORDER BY id')]

@router.get('/basket', response_model=list[Fund])
def basket(uid: str = Depends(user_id)):
    with connection() as db:
        return [dict(x) for x in db.execute('SELECT f.* FROM funds f JOIN basket b ON b.fund_id = f.id WHERE b.user_id = ? ORDER BY f.id', (uid,))]

@router.post('/basket', status_code=201, response_model=Fund)
def add(item: AddFund, uid: str = Depends(user_id)):
    with connection() as db:
        fund = db.execute('SELECT * FROM funds WHERE id = ?', (item.fundId,)).fetchone()
        if fund is None:
            raise HTTPException(404, 'Fund not found')
        try:
            db.execute('INSERT INTO basket VALUES (?, ?)', (uid, item.fundId))
            db.commit()
        except sqlite3.IntegrityError:
            raise HTTPException(409, 'Fund is already in your basket') from None
        return dict(fund)

@router.delete('/basket/{fund_id}', status_code=204)
def remove(fund_id: int, uid: str = Depends(user_id)):
    with connection() as db:
        deleted = db.execute('DELETE FROM basket WHERE user_id = ? AND fund_id = ?', (uid, fund_id))
        if deleted.rowcount == 0:
            raise HTTPException(404, 'Fund is not in your basket')

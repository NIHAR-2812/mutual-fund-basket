from fastapi.testclient import TestClient
from app import main, auth, database


def test_basket_scoping(tmp_path, monkeypatch):
    monkeypatch.setattr(database, 'DB', tmp_path / 'data.sqlite3')
    monkeypatch.setattr(auth.firebase_admin, '_apps', {'test': object()})
    monkeypatch.setattr(auth.auth, 'verify_id_token', lambda token: {'uid': token})
    with TestClient(main.app) as client:
        a = {'Authorization': 'Bearer alice'}
        b = {'Authorization': 'Bearer bob'}
        assert client.get('/funds').status_code == 401
        assert len(client.get('/funds', headers=a).json()) == 12
        assert client.post('/basket', headers=a, json={'fundId': 1}).status_code == 201
        assert client.post('/basket', headers=a, json={'fundId': 1}).status_code == 409
        assert client.post('/basket', headers=a, json={'fundId': 999}).status_code == 404
        assert client.get('/basket', headers=b).json() == []
        assert len(client.get('/basket', headers=a).json()) == 1
        assert client.delete('/basket/1', headers=b).status_code == 404
        assert client.delete('/basket/1', headers=a).status_code == 204
        assert client.get('/basket', headers=a).json() == []

from fastapi.testclient import TestClient
from app.main import app

def test_batches_crud():
    client = TestClient(app)
    # 1. Fetch batches - should have seeded records
    res = client.get("/batches")
    assert res.status_code == 200
    batches = res.json()
    assert isinstance(batches, list)
    assert len(batches) >= 5

    # 2. Register a new produce batch
    payload = {
        "title": "Fresh Alphonso Mango",
        "category": "Fruits",
        "quantity": "300 kg",
        "price": "$6.20",
        "status": "VERIFIED",
        "condition": "fresh",
        "confidence": 0.95,
        "visible_issues": [],
        "location": "Ratnagiri Orchard, Sector 4",
        "description": "Premium sweet alphonso mangoes verified by AI.",
    }
    create_res = client.post("/batches", json=payload)
    assert create_res.status_code == 201
    created_batch = create_res.json()
    assert created_batch["title"] == "Fresh Alphonso Mango"
    assert created_batch["status"] == "VERIFIED"
    assert created_batch["condition"] == "fresh"
    assert created_batch["confidence"] == 0.95
    assert created_batch["batch_id"].startswith("Batch #AG-")

    # 3. Fetch again - newly registered batch should be first (newest)
    res2 = client.get("/batches")
    assert res2.status_code == 200
    all_batches = res2.json()
    assert all_batches[0]["batch_id"] == created_batch["batch_id"]
    assert all_batches[0]["title"] == "Fresh Alphonso Mango"

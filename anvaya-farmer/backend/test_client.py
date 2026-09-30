import sys
import httpx
import asyncio
import json
import os

API_URL = "http://127.0.0.1:8000/ai/analyze"

async def test_image(image_path: str):
    if not os.path.exists(image_path):
        print(f"❌ Error: Image not found at '{image_path}'")
        return

    print(f"🚀 Sending '{image_path}' to {API_URL}...")
    
    try:
        async with httpx.AsyncClient(timeout=90.0) as client:
            with open(image_path, "rb") as f:
                files = {"image": (os.path.basename(image_path), f, "image/jpeg")}
                response = await client.post(API_URL, files=files)
        
        if response.status_code == 200:
            print("\n✅ Analysis Successful!\n")
            data = response.json()
            print(json.dumps(data, indent=4))
        else:
            print(f"\n❌ Server Error ({response.status_code}):")
            try:
                print(json.dumps(response.json(), indent=4))
            except:
                print(response.text)
                
    except httpx.RequestError as e:
        print(f"\n❌ Connection Error: {e}")
        print("Is the backend running? Make sure uvicorn is started on port 8000.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python test_client.py <path_to_image>")
        print("Example: python test_client.py my_tomato.jpg")
        sys.exit(1)
        
    asyncio.run(test_image(sys.argv[1]))

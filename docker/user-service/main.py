from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "User Service is running 🚀"}

@app.get("/users")
def get_users():
    return [
        {"id": 1, "name": "Alice"},
        {"id": 2, "name": "Bob"}
    ]

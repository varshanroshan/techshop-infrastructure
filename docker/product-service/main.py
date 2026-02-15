from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def health():
    return {"message": "Product Service is running ✅"}

@app.get("/products")
def list_products():
    return [
        {"id": 101, "name": "Laptop", "price": 999},
        {"id": 102, "name": "Headphones", "price": 79},
        {"id": 103, "name": "Keyboard", "price": 49}
    ]

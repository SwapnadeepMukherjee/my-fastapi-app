from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World", "Environment": "Production"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

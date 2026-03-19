from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Hello from your DevOps deployment pipeline!"}

@app.get("/health")
def health():
    return {"status": "ok"}

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
from scan import analyze_image

app = FastAPI(
    title="Verd API",
    description="Drone image crop disease detection for African smallholder farmers",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {
        "service": "Verd Drone Disease Detection API",
        "status": "running",
        "endpoints": {
            "POST /scan": "Upload a drone image, receive disease heatmap",
            "GET  /diseases": "List all detectable diseases and treatments",
            "GET  /health": "Health check",
        },
    }


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/scan")
async def scan_field(image: UploadFile = File(...)):
    """
    Upload a drone image (jpg/png).
    Returns a grid of disease zones overlaid on the image dimensions,
    with disease label, severity, confidence, and treatment per zone.
    """
    if image.content_type not in ("image/jpeg", "image/png", "image/jpg"):
        raise HTTPException(
            status_code=400,
            detail="Only JPEG and PNG images are supported.",
        )

    image_bytes = await image.read()
    if len(image_bytes) == 0:
        raise HTTPException(status_code=400, detail="Empty image file.")

    try:
        result = analyze_image(image_bytes, filename=image.filename or "scan.jpg")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

    return JSONResponse(content=result)


@app.get("/diseases")
def list_diseases():
    from disease_data import DISEASES
    return {
        "total": len(DISEASES),
        "diseases": [
            {
                "name": d["name"],
                "crop": d["crop"],
                "severity_potential": d["severity_potential"],
                "treatments": d["treatments"][:2],  # preview
            }
            for d in DISEASES
        ],
    }


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

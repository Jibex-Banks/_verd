"""
scan.py — Core analysis engine.

Takes a drone image, splits it into a GRID_ROWS × GRID_COLS grid,
simulates disease prediction for each patch (seeded from image content
so the same image always produces the same result), and returns the
full zone grid with metadata.
"""

import hashlib
import random
import math
from PIL import Image
import io
from disease_data import DISEASES, DISEASE_MAP

GRID_ROWS = 8
GRID_COLS = 8

# Diseases that can appear as hotspot clusters in a scan
FIELD_DISEASES = [d for d in DISEASES if d["name"] != "Healthy"]


def _image_seed(image_bytes: bytes) -> int:
    """Derive a stable integer seed from the image content."""
    digest = hashlib.md5(image_bytes).hexdigest()
    return int(digest[:8], 16)


def _get_image_size(image_bytes: bytes):
    img = Image.open(io.BytesIO(image_bytes))
    return img.width, img.height


def _severity_label(s: float) -> str:
    if s >= 0.75: return "critical"
    if s >= 0.45: return "moderate"
    if s >= 0.20: return "low"
    return "healthy"


def _pick_diseases_for_field(rng: random.Random) -> list:
    """
    Pick 1–2 diseases that will appear as hotspot clusters in this field.
    Weighted: cassava diseases appear more often (West African context).
    """
    cassava = [d for d in FIELD_DISEASES if d["crop"] == "cassava"]
    others  = [d for d in FIELD_DISEASES if d["crop"] != "cassava"]

    primary   = rng.choice(cassava)
    secondary = rng.choice(others) if rng.random() > 0.4 else None
    return [d for d in [primary, secondary] if d is not None]


def _build_severity_grid(rng: random.Random) -> list[list[float]]:
    """
    Generate a realistic severity field using gaussian hotspot clusters.
    Returns GRID_ROWS × GRID_COLS grid of severity values (0.0–1.0).
    """
    grid = [[0.0] * GRID_COLS for _ in range(GRID_ROWS)]

    # Place 2–4 hotspot centres
    n_hotspots = rng.randint(2, 4)
    hotspots = []
    for _ in range(n_hotspots):
        r = rng.uniform(0, GRID_ROWS - 1)
        c = rng.uniform(0, GRID_COLS - 1)
        strength = rng.uniform(0.7, 1.0)
        spread   = rng.uniform(1.2, 2.8)
        hotspots.append((r, c, strength, spread))

    for row in range(GRID_ROWS):
        for col in range(GRID_COLS):
            val = 0.0
            for (hr, hc, strength, spread) in hotspots:
                dist = math.sqrt((row - hr) ** 2 + (col - hc) ** 2)
                val  = max(val, strength * math.exp(-(dist ** 2) / (2 * spread ** 2)))
            # Add small background noise
            val = min(1.0, val + rng.uniform(0, 0.08))
            grid[row][col] = round(val, 3)

    return grid


def _assign_diseases(severity_grid, diseases: list, rng: random.Random) -> list[list[dict]]:
    """
    Map severity values to disease labels.
    High-severity cells → primary disease.
    Mid-severity cells → secondary disease (if exists).
    Low-severity cells → Healthy.
    """
    primary   = diseases[0]
    secondary = diseases[1] if len(diseases) > 1 else None
    healthy   = DISEASE_MAP["Healthy"]

    zones = []
    for row in range(GRID_ROWS):
        row_zones = []
        for col in range(GRID_COLS):
            s = severity_grid[row][col]
            label = _severity_label(s)

            if label in ("critical", "moderate"):
                disease = primary
            elif label == "low" and secondary:
                disease = secondary if rng.random() > 0.5 else primary
            elif label == "low":
                disease = primary
            else:
                disease = healthy

            confidence = round(rng.uniform(0.78, 0.97), 2) if label != "healthy" else round(rng.uniform(0.88, 0.99), 2)

            row_zones.append({
                "row":            row,
                "col":            col,
                "severity":       s,
                "severity_label": label,
                "disease":        disease["name"],
                "confidence":     confidence,
                "treatments":     disease["treatments"],
                "yield_impact":   disease["yield_impact"],
                "spread_note":    disease["spread"],
            })
        zones.append(row_zones)
    return zones


def analyze_image(image_bytes: bytes, filename: str = "scan.jpg") -> dict:
    """
    Main entry point. Returns full scan result dict ready for JSON response.
    """
    seed = _image_seed(image_bytes)
    rng  = random.Random(seed)

    width, height = _get_image_size(image_bytes)

    diseases      = _pick_diseases_for_field(rng)
    severity_grid = _build_severity_grid(rng)
    zone_grid     = _assign_diseases(severity_grid, diseases, rng)

    # Flatten zones for response
    flat_zones = [zone for row in zone_grid for zone in row]

    # Summary stats
    critical = sum(1 for z in flat_zones if z["severity_label"] == "critical")
    moderate = sum(1 for z in flat_zones if z["severity_label"] == "moderate")
    low      = sum(1 for z in flat_zones if z["severity_label"] == "low")
    healthy  = sum(1 for z in flat_zones if z["severity_label"] == "healthy")
    total    = len(flat_zones)
    affected_pct = round((critical + moderate + low) / total * 100, 1)

    unique_diseases = list({z["disease"] for z in flat_zones if z["disease"] != "Healthy"})

    return {
        "scan_id":       f"SCN-{seed % 99999:05d}",
        "filename":      filename,
        "image_width":   width,
        "image_height":  height,
        "grid_rows":     GRID_ROWS,
        "grid_cols":     GRID_COLS,
        "zones":         flat_zones,
        "summary": {
            "critical_zones":      critical,
            "moderate_zones":      moderate,
            "low_zones":           low,
            "healthy_zones":       healthy,
            "total_zones":         total,
            "affected_pct":        affected_pct,
            "diseases_detected":   unique_diseases,
            "recommended_action": (
                "Immediate intervention required"  if critical > 8 else
                "Targeted treatment recommended"   if moderate > 8 else
                "Monitor closely"                  if low > 10 else
                "Field is largely healthy"
            ),
        },
    }

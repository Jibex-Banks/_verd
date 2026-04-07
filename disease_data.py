# All diseases Verd can detect.
# These mirror the classes your TFLite model was trained on (PlantVillage-style).
# Treatments are agronomically accurate for West African conditions.

DISEASES = [
    {
        "name": "Cassava Mosaic",
        "crop": "cassava",
        "severity_potential": "critical",
        "yield_impact": "Up to 95% yield loss if untreated",
        "spread": "Spreads via whitefly and infected cuttings. Acts fast.",
        "treatments": [
            "Remove and burn all infected plants immediately (roguing)",
            "Plant mosaic-resistant varieties (TMS 30572, TMEB419)",
            "Control whitefly with neem oil spray (2 tbsp per litre)",
            "Use only certified disease-free stem cuttings",
            "Apply imidacloprid insecticide around field border",
        ],
    },
    {
        "name": "Cassava Bacterial Blight",
        "crop": "cassava",
        "severity_potential": "moderate",
        "yield_impact": "20–60% yield loss. Manageable with early action.",
        "spread": "Worsens in wet season. Spreads through water splash.",
        "treatments": [
            "Apply copper-based fungicide (Kocide 3000)",
            "Improve field drainage to reduce moisture",
            "Avoid working in the field when plants are wet",
            "Rotate with non-host crops (maize or cowpea)",
            "Plant resistant variety TMS 91934",
        ],
    },
    {
        "name": "Cassava Anthracnose",
        "crop": "cassava",
        "severity_potential": "low",
        "yield_impact": "15–40% post-harvest loss. Low in-field impact.",
        "spread": "Mainly damages stored cassava. Spreads via spores.",
        "treatments": [
            "Apply mancozeb or carbendazim fungicide",
            "Prune affected stems 10 cm below visible lesions",
            "Increase plant spacing for better airflow",
            "Avoid overhead irrigation",
            "Destroy all crop residue after harvest",
        ],
    },
    {
        "name": "Maize Leaf Blight",
        "crop": "maize",
        "severity_potential": "moderate",
        "yield_impact": "30–50% yield loss in severe outbreaks",
        "spread": "Airborne spores. Worst in humid, warm conditions.",
        "treatments": [
            "Apply mancozeb fungicide at first signs",
            "Use blight-resistant hybrid varieties (SAMMAZ 54)",
            "Ensure adequate spacing (75cm between rows)",
            "Remove and destroy infected leaves",
            "Avoid late-season planting in endemic areas",
        ],
    },
    {
        "name": "Tomato Late Blight",
        "crop": "tomato",
        "severity_potential": "critical",
        "yield_impact": "Can destroy entire crop within 2 weeks",
        "spread": "Extremely fast in wet and cool conditions.",
        "treatments": [
            "Apply chlorothalonil or copper fungicide immediately",
            "Remove all infected plant material and burn",
            "Avoid overhead watering — use drip irrigation",
            "Plant resistant varieties (Roma VF, Heinz 1350)",
            "Rotate tomatoes with non-solanaceous crops for 2 seasons",
        ],
    },
    {
        "name": "Healthy",
        "crop": "any",
        "severity_potential": "none",
        "yield_impact": "No impact",
        "spread": "N/A",
        "treatments": ["No action required", "Continue routine monitoring"],
    },
]

# Quick lookup by name
DISEASE_MAP = {d["name"]: d for d in DISEASES}

#!/usr/bin/env python3
"""
detect_all_FA_vision.py
-----------------------
Runs Google Cloud Vision API label detection on all *.png images
in folders starting with FA_ under /images. Reads the API key
securely from your environment variable GOOGLE_VISION_API_KEY.

Usage:
    python detect_all_FA_vision.py
"""

from pathlib import Path
import requests
import base64
import os

# ------------------------------------------------------------
# Secure configuration
# ------------------------------------------------------------
API_KEY = os.getenv("GOOGLE_VISION_API_KEY")
if not API_KEY:
    raise EnvironmentError("Missing GOOGLE_VISION_API_KEY in environment")

VISION_URL = f"https://vision.googleapis.com/v1/images:annotate?key={API_KEY}"

PROJECT_ROOT = Path(__file__).resolve().parents[1]
IMAGES_ROOT = PROJECT_ROOT / "images"

# ------------------------------------------------------------
# Process all FA_* folders
# ------------------------------------------------------------
for fa_dir in sorted(IMAGES_ROOT.glob("FA_*")):
    if not fa_dir.is_dir():
        continue
    print(f"\nProcessing folder: {fa_dir.name}")

    for img_path in sorted(fa_dir.glob("*.png")):
        try:
            number = img_path.stem
            out_path = fa_dir / f"{number}object.txt"

            # Read and encode the image
            with open(img_path, "rb") as image_file:
                content = base64.b64encode(image_file.read()).decode("utf-8")

            # Request body for label detection
            body = {
                "requests": [
                    {
                        "image": {"content": content},
                        "features": [{"type": "LABEL_DETECTION", "maxResults": 10}],
                    }
                ]
            }

            response = requests.post(VISION_URL, json=body)
            result = response.json()
            labels = result.get("responses", [{}])[0].get("labelAnnotations", [])

            # Write human-readable output
            with open(out_path, "w") as f:
                if not labels:
                    f.write("No labels detected\n")
                else:
                    for label in labels:
                        desc = label.get("description", "")
                        score = label.get("score", 0)
                        f.write(f"{desc}\t{score:.3f}\n")

            print(f"  {img_path.name} → {out_path.name}")

        except Exception as e:
            print(f"  Error on {img_path.name}: {e}")

print("\nAll FA_* images processed successfully.")


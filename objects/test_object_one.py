#!/usr/bin/env python3
"""
test_grounding_dino.py
----------------------
Detects a broad range of objects in a test image using Grounding DINO.
Run this from /Users/madelinesmac/bios611project/objects
"""

from groundingdino.util.inference import load_model, load_image, predict
import supervision as sv
from pathlib import Path
import torch

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
PROJECT_ROOT = Path(__file__).resolve().parents[1]
MODEL_CONFIG = PROJECT_ROOT / "models" / "GroundingDINO_SwinT_OGC.py"
MODEL_WEIGHTS = PROJECT_ROOT / "models" / "groundingdino_swint_ogc.pth"
TEST_IMAGE = PROJECT_ROOT / "images" / "FA_classic" / "81.png"  # change as needed
OUTPUT_DIR = PROJECT_ROOT / "objects" / "results"
OUTPUT_DIR.mkdir(exist_ok=True)

# ------------------------------------------------------------
# Load model
# ------------------------------------------------------------
print("Loading Grounding DINO model...")
model = load_model(str(MODEL_CONFIG), str(MODEL_WEIGHTS))

# ------------------------------------------------------------
# Load image and run detection
# ------------------------------------------------------------
print(f"Running detection on: {TEST_IMAGE}")
image_source, image = load_image(str(TEST_IMAGE))

prompt = "airplane, building, cloud, tree, light, reflection, monitor, screen, car, person, sky, water, window, text, animal"

boxes, logits, phrases = predict(
    model=model,
    image=image,
    caption=prompt,
    box_threshold=0.25,
    text_threshold=0.25
)

# ------------------------------------------------------------
# Annotate and save result
# ------------------------------------------------------------
annotator = sv.BoxAnnotator()
labels = [f"{phrase} ({logit.item():.2f})" for phrase, logit in zip(phrases, logits)]
detections = sv.Detections(xyxy=boxes)
annotated_image = annotator.annotate(scene=image_source.copy(), detections=detections, labels=labels)

out_path = OUTPUT_DIR / f"{TEST_IMAGE.stem}_annotated.jpg"
sv.plot_image(annotated_image, (12, 8), save_path=str(out_path))

print(f"Detections saved to {out_path}")
print(f"Detected objects: {phrases}")


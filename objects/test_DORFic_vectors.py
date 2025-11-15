import os
import re
import subprocess
import json

FA_DIR = "/Users/madelinesmac/bios611project/images/FA_DORFic"
OBJECT_FILE = os.path.join(FA_DIR, "object_instances.txt")
OUTPUT_FILE = os.path.join(FA_DIR, "vectors_object_instances.txt")

MODEL_ENDPOINT = f"https://us-central1-aiplatform.googleapis.com/v1/projects/serene-anagram-477223-t3/locations/us-central1/publishers/google/models/text-embedding-005:predict"

def clean_object_name(name: str) -> str:
    name = name.strip()
    name = re.sub(r"\s+", "_", name)
    name = name.replace("/", "_")
    return name

def embed_text(text: str):
    print(f"→ Embedding: {text}")

    payload = {
        "instances": [
            {"task_type": "CLUSTERING", "content": text}
        ]
    }

    result = subprocess.run(
        [
            "curl", "-s",
            "-X", "POST",
            "-H", f"Authorization: Bearer {subprocess.getoutput('gcloud auth print-access-token')}",
            "-H", "Content-Type: application/json",
            "-d", json.dumps(payload),
            MODEL_ENDPOINT
        ],
        capture_output=True,
        text=True
    )

    try:
        data = json.loads(result.stdout)
        return data["predictions"][0]["embeddings"]["values"]
    except Exception as e:
        print("ERROR parsing embedding:", e)
        print("Raw output:", result.stdout)
        return None


# -----------------------
# MAIN EXECUTION
# -----------------------

print(f"Reading: {OBJECT_FILE}")
with open(OBJECT_FILE, "r") as f:
    lines = f.readlines()

objects = []
for line in lines:
    if line.strip() == "" or line.startswith("#"):
        continue
    parts = line.strip().split("\t")
    if len(parts) < 3:
        continue
    obj = parts[0].strip()
    score = parts[1].strip()
    instances = parts[2].strip()
    objects.append((obj, score, instances))

print(f"Found {len(objects)} objects.")
print("Generating embeddings...")

output_lines = []

for (obj, score, inst) in objects:
    cleaned = clean_object_name(obj)

    vec = embed_text(obj)
    if vec is None:
        continue

    # Convert vector → one-line string
    vec_str = "[" + ", ".join(f"{v}" for v in vec) + "]"

    formatted = f"{cleaned}:{score}:{inst}:{vec_str}"
    output_lines.append(formatted)

print(f"\nWriting final file → {OUTPUT_FILE}\n")
with open(OUTPUT_FILE, "w") as f:
    f.write("\n".join(output_lines))

print("DONE.")


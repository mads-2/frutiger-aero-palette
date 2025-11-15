import os
import re
import json
import subprocess

BASE_DIR = "/Users/madelinesmac/bios611project/images"
MODEL_ENDPOINT = (
    "https://us-central1-aiplatform.googleapis.com/v1/"
    "projects/serene-anagram-477223-t3/locations/us-central1/"
    "publishers/google/models/text-embedding-005:predict"
)


def clean_object_name(name: str) -> str:
    """Convert spaces + illegal chars → underscores."""
    name = name.strip()
    name = re.sub(r"\s+", "_", name)
    name = name.replace("/", "_")
    return name


def embed_text(text: str):
    """Call Vertex AI embedding API via curl."""
    print(f"→ Embedding: {text}")

    payload = {
        "instances": [
            {
                "task_type": "CLUSTERING",
                "content": text
            }
        ]
    }

    result = subprocess.run(
        [
            "curl", "-s",
            "-X", "POST",
            "-H", f"Authorization: Bearer {subprocess.getoutput('gcloud auth print-access-token')}",
            "-H", "Content-Type: application/json",
            "-d", json.dumps(payload),
            MODEL_ENDPOINT,
        ],
        capture_output=True,
        text=True,
    )

    try:
        data = json.loads(result.stdout)
        return data["predictions"][0]["embeddings"]["values"]
    except Exception as e:
        print("ERROR extracting embedding:", e)
        print("RAW:", result.stdout)
        return None


def process_fa_folder(folder_path: str):
    """Process a single FA aesthetic folder."""
    object_file = os.path.join(folder_path, "object_instances.txt")
    output_file = os.path.join(folder_path, "vectors_object_instances.txt")

    if not os.path.exists(object_file):
        print(f"⚠️ Skipping {folder_path}: no object_instances.txt found.")
        return

    print(f"\n====================================")
    print(f"Processing: {folder_path}")
    print(f"====================================\n")

    with open(object_file, "r") as f:
        lines = f.readlines()

    objects = []
    for line in lines:
        if line.strip() == "" or line.startswith("#"):
            continue
        parts = line.strip().split("\t")
        if len(parts) < 3:
            continue
        obj, score, inst = parts[0].strip(), parts[1].strip(), parts[2].strip()
        objects.append((obj, score, inst))

    print(f"Found {len(objects)} objects. Generating embeddings...")

    output_lines = []

    for (obj, score, inst) in objects:
        cleaned = clean_object_name(obj)
        vec = embed_text(obj)

        if vec is None:
            print(f"❌ ERROR—no vector produced for {obj}")
            continue

        vec_str = "[" + ", ".join(str(v) for v in vec) + "]"
        formatted = f"{cleaned}:{score}:{inst}:{vec_str}"
        output_lines.append(formatted)

    print(f"\n→ Writing: {output_file}\n")
    with open(output_file, "w") as f:
        f.write("\n".join(output_lines))

    print("✔ Done\n")


# ===========================================================
# MAIN CONTROLLER — process all FA_* except FA_DORFic
# ===========================================================

all_dirs = sorted(d for d in os.listdir(BASE_DIR) if d.startswith("FA_"))
targets = [d for d in all_dirs if d != "FA_DORFic"]

print("FA aesthetics to process:")
for t in targets:
    print(" •", t)

for folder in targets:
    process_fa_folder(os.path.join(BASE_DIR, folder))

print("\n🎉 ALL DONE — embeddings generated for all FA aesthetics (except DORFic)!\n")


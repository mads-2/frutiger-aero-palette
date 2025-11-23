# Frutiger Aero — Analysis + Dashboard (bios611project)

## For Creatives (People Using the Dashboard for Inspiration)

This project provides an interactive exploration of the Frutiger Aero aesthetic through 3D color maps, semantic embeddings, and an aesthetic dashboard. No technical background is required.

Repository URL:  
https://github.com/mads-2/bios611project

---

### 1. Clone the Repository

```bash
git clone https://github.com/mads-2/bios611project
cd bios611project
```

---

### 2. Build the Dashboard Environment

```bash
docker build . -t aero
```

---

### 3. Run the Dashboard

```bash
docker run --rm     -e PASSWORD=mysecret     -p 8181:8181     -p 8787:8787     -v "$(pwd)":/home/rstudio/project     aero
```

Once it starts:

- RStudio: http://localhost:8787  
  username: `rstudio`  
  password: `mysecret`
- Dashboard (after running the pipeline):  
  http://localhost:8181

---

### 4. Build Everything (One Command)

Inside the RStudio terminal:

```bash
make all
```

This automatically:

- Regenerates all color files  
- Aggregates object metadata  
- Creates 3D color plots  
- Generates t-SNE embeddings  
- Produces random embedding plots  
- Launches the full dashboard  

---

# For Developers  
## (Adding New Data, Modifying Scripts, or Extending the Pipeline)

This section explains how the dataset works, how color extraction and embeddings are generated, and how to correctly add new images.

---

## Project Structure

```
bios611project/
├── images/FA_*/          
├── colors/               
├── objects/              
├── dashboard/            
├── Makefile              
└── Dockerfile            
```

---

## Adding New Images (Very Important)

To add more images to the project:

### 1. Place images in a folder like:

```
images/FA_<style>/
```

### 2. PNG filenames **must be numbered sequentially**, for example:

```
001.png
002.png
003.png
...
```

The pipeline depends on this ordering to match:

```
001.png  →  001object.txt
```

If the numbering is inconsistent, the Makefile will stop with an error.

---

## How `object.txt` Files Were Generated

Each `object.txt` file was produced using:

- **Google Vertex AI**
- **Google Vision API** (Object Detection)

For each PNG image, the Vision API returns a set of detected objects.  
These were saved as `<number>object.txt` files.

Example:

```
001.png
001object.txt
```

---

## How to Generate More `object.txt` Files

To generate new object metadata, developers must:

### 1. Obtain:

- A **Google Cloud Platform (GCP) account**
- A **Vertex AI API key**
- A **Vision API key**

### 2. Enable the following services:

- Vertex AI API  
- Cloud Vision API  

### 3. Write a small script (Python or R) to call the Vision API:

Example (Python pseudocode):

```python
from google.cloud import vision

client = vision.ImageAnnotatorClient()

with open("001.png", "rb") as f:
    content = f.read()

image = vision.Image(content=content)
response = client.object_localization(image=image)

with open("001object.txt", "w") as out:
    for obj in response.localized_object_annotations:
        out.write(obj.name + "\n")
```

### 4. Save the output as:

```
<matching-number>object.txt
```

Place it into the same directory as the image.

Once the `.png` and its `object.txt` file are present, the Makefile will automatically incorporate them.

---

## Color Extraction

Color files (`colors.txt` and numbered `*colors.txt`) are generated automatically.

Running:

```bash
make colors
```

will:

- Delete previous color files  
- Re-extract dominant colors using R scripts in `/colors`  
- Rebuild the full unified color dataset  

No manual intervention is required.

---

## Key Make Targets

```
make all               # Full pipeline
make dashboard         # Same as all
make colors            # Regenerate all color files
make colors-plot       # Create 3D color plot
make objects           # Aggregate Vision API metadata
make embeddings        # Build t-SNE embedding plot
make random-embeddings # Random baseline plot
make clean             # Remove generated HTML + temp files
make build             # Build Docker image
make run               # Start RStudio + dashboard
make stop              # Stop running containers
```

---

## Adding More Data

To extend the dataset:

1. Add new numbered `.png` files  
2. Generate matching `object.txt` using Vision or Vertex AI  
3. Run:

```bash
make all
```

---

This README provides all instructions for creatives and developers to run, extend, and understand the project.


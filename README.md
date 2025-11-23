# <span style="color:#2ecc71">Frutiger Aero — Analysis + Dashboard (bios611project)</span>

## <span style="color:#3498db">For Creatives (People Using the Dashboard for Inspiration)</span>

<span style="color:#555555">
This project lets you explore the Frutiger Aero aesthetic through interactive 3D color maps, semantic embeddings, and a visual dashboard. You do **not** need to understand Docker, R, or Python in detail—just follow the setup steps below.
</span>

---

### <span style="color:#3498db">1. Clone the Repository</span>

```bash
git clone <repository-url>
cd bios611project
```

---

### <span style="color:#3498db">2. Build the Dashboard Environment</span>

```bash
docker build . -t aero
```

---

### <span style="color:#3498db">3. Run the Dashboard</span>

```bash
docker run --rm     -e PASSWORD=mysecret     -p 8181:8181     -p 8787:8787     -v "$(pwd)":/home/rstudio/project     aero
```

Once it starts:

- **RStudio:** http://localhost:8787  
  login: `rstudio`, password: `mysecret`
- **Dashboard:** http://localhost:8181 (after running `make all`)

---

### <span style="color:#3498db">4. Build Everything (One Command)</span>

Inside the RStudio terminal:

```bash
make all
```

This will automatically:

- Regenerate Frutiger Aero color data
- Aggregate object metadata
- Create 3D color plots
- Create t-SNE embeddings
- Generate random embedding visualizations
- Launch the full dashboard

---

# <span style="color:#2ecc71">For Developers</span>
## <span style="color:#3498db">(People Modifying the Code or Adding New Data)</span>

<span style="color:#555555">
This section explains the code layout, Make targets, and how to extend the pipeline.
</span>

---

### <span style="color:#3498db">Project Structure</span>

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

### <span style="color:#3498db">Key Make Targets</span>

```
make all               # Full pipeline
make dashboard         # Same as all
make colors            # Regenerate all color files
make colors-plot       # 3D color plot
make objects           # Aggregate Vision API metadata
make embeddings        # t-SNE embedding plot
make random-embeddings # Random embedding plot
make clean             # Remove intermediate files + HTML outputs
make build             # Build Docker image
make run               # Run container with RStudio + dashboard
make stop              # Stop running containers
```

---

### <span style="color:#3498db">Adding New Images</span>

1. Create a folder under `images/` named `FA_<style>/`  
2. Add `.png` images and matching `object.txt` files  
3. Run:

```bash
make all
```


# ============================================================
# Frutiger Aero — Build and Run Environment
# ============================================================

IMAGE = aero
PORT = 8999
PASSWORD = mysecret

# ------------------------------------------------------------
# Build Docker image
# ------------------------------------------------------------
build:
	docker build -t $(IMAGE) .

# ------------------------------------------------------------
# Run RStudio Server in container
# ------------------------------------------------------------
run:
	docker run --rm -e PASSWORD=$(PASSWORD) -p $(PORT):8787 \
		-v "$(PWD)":/home/rstudio/project $(IMAGE)

# ------------------------------------------------------------
# Stop any running container
# ------------------------------------------------------------
stop:
	docker ps -q --filter ancestor=$(IMAGE) | xargs -r docker stop

# ------------------------------------------------------------
# Clean up dangling images
# ------------------------------------------------------------
clean:
	docker image prune -f


# ============================================================
# Frutiger Aero — Analysis + Dashboard Environment
# ============================================================

IMAGE = aero
RSTUDIO_PORT = 8787
DASHBOARD_PORT = 8181
PASSWORD = mysecret
R = Rscript

# ------------------------------------------------------------
# Dockerized RStudio environment
# ------------------------------------------------------------
build:
	docker build -t $(IMAGE) .

run:
	docker run --rm \
		-e PASSWORD=$(PASSWORD) \
		-p $(DASHBOARD_PORT):$(DASHBOARD_PORT) \
		-p $(RSTUDIO_PORT):8787 \
		-v "$(PWD)":/home/rstudio/project \
		$(IMAGE)

stop:
	docker ps -q --filter ancestor=$(IMAGE) | xargs -r docker stop

# ------------------------------------------------------------
# Clean — removes Docker leftovers and generated color files
# ------------------------------------------------------------
clean:
	@echo "Running clean..."
	@if command -v docker >/dev/null 2>&1; then \
		echo "Pruning unused Docker images..."; \
		docker image prune -f; \
	else \
		echo "Docker not available in this environment."; \
	fi
	@echo "Removing generated color files..."
	@find images/FA_* -type f \( -name "*color.txt" -o -name "colors.txt" \) -delete
	@echo "Clean complete."

# ------------------------------------------------------------
# Color data generation
# ------------------------------------------------------------
COLOR_TXT := $(wildcard images/FA_*/colors.txt)

colors: 
	@echo "Rebuilding all color data..."
	@find images/FA_* -type f \( -name "*color.txt" -o -name "colors.txt" \) -delete
	$(R) colors/extract_all_FA.R
	$(R) colors/aggregate_FA_colors.R
	@echo "All color data regenerated."

# ------------------------------------------------------------
# Report generation (no .Rmd dependency)
# ------------------------------------------------------------
report: $(COLOR_TXT)
	@echo "Color data up to date. Ready for downstream analysis or dashboard."

# ------------------------------------------------------------
# Dashboard viewer (uses committed HTML prototype)
# ------------------------------------------------------------
dashboard:
	cd dashboard && ./run_dashboard.sh

# ------------------------------------------------------------
# Help
# ------------------------------------------------------------
help:
	@echo ""
	@echo "Available targets:"
	@echo "  build              Build Docker RStudio environment"
	@echo "  run                Run RStudio (port $(RSTUDIO_PORT)) + dashboard (port $(DASHBOARD_PORT))"
	@echo "  stop               Stop running container(s)"
	@echo "  clean              Remove Docker leftovers and generated color files"
	@echo "  colors             Clean, extract, and aggregate all color data"
	@echo "  report             Verify or summarize color data (no .Rmd file required)"
	@echo "  dashboard          Launch local web dashboard"
	@echo ""

.PHONY: build run stop clean colors dashboard report help


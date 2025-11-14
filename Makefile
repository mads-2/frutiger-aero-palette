# ============================================================
# Frutiger Aero — Analysis + Dashboard Environment
# ============================================================

IMAGE = aero
RSTUDIO_PORT = 8787
DASHBOARD_PORT = 8181
PASSWORD = mysecret
R = Rscript

# ------------------------------------------------------------
# High-level build order
# ------------------------------------------------------------

# make all = build everything
.PHONY: all
all: colors objects colors-plot
	@echo "✔ Full project build complete."

# make dashboard = run dashboard ONLY
.PHONY: dashboard
dashboard:
	cd dashboard && ./run_dashboard.sh


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


# ============================================================
# COLOR PLOT + COLOR DATA GENERATION
# ============================================================

# Base colors.txt
COLOR_TXT := $(wildcard images/FA_*/colors.txt)

# Numbered color files (0colors.txt → 1000colors.txt → infinite)
NUMBERED_COLOR_TXT := $(wildcard images/FA_*/*colors.txt)

# Output HTML for Plotly figure
COLOR_PLOT := dashboard/color_plot_output.html


# ---------- COLOR DATA GENERATION ----------
colors:
	@echo "Rebuilding all color data..."
	@find images/FA_* -type f -name "colors.txt" -delete
	@find images/FA_* -type f -regex ".*[0-9]+colors\.txt" -delete
	$(R) colors/extract_all_FA.R
	$(R) colors/aggregate_FA_colors.R
	@echo "✔ Color data regenerated."


# ---------- ENSURE CORRECT ORDERING ----------
# colors-plot runs ONLY after colors is finished
colors-plot: colors $(COLOR_PLOT)
	@echo "✔ Colors 3D plot updated."


# ---------- PLOTLY GENERATION ----------
$(COLOR_PLOT): dashboard/color_plot.py $(COLOR_TXT)
	@echo "Generating 3D color plot..."
	python3 dashboard/color_plot.py


# ============================================================
# OBJECT DATA (Vision API aggregation)
# ============================================================

objects:
	@echo "Aggregating Vision API object data..."
	$(R) objects/aggregate_FA_objects.R
	@echo "✔ All object data aggregated."


# ------------------------------------------------------------
# Report generation
# ------------------------------------------------------------
report: $(COLOR_TXT)
	@echo "Color data up to date. Ready for downstream analysis."


# ------------------------------------------------------------
# Clean — removes Docker leftovers + intermediate txt files
# ------------------------------------------------------------
clean:
	@echo "Running clean..."
	@if command -v docker >/dev/null 2>&1; then \
		echo "Pruning unused Docker images..."; \
		docker image prune -f; \
	else \
		echo "Docker not available."; \
	fi

	@echo "Removing generated color files..."
	@find images/FA_* -type f -name "colors.txt" -delete
	@find images/FA_* -type f -regex ".*[0-9]+colors\.txt" -delete

	@echo "Removing generated color plot HTML..."
	@rm -f dashboard/color_plot_output.html

	@echo "✔ Clean complete."


# ------------------------------------------------------------
# Help
# ------------------------------------------------------------
help:
	@echo ""
	@echo "Available targets:"
	@echo "  all                Build ENTIRE project (colors → objects → plot)"
	@echo "  dashboard          Run the dashboard (assumes 'all' already run)"
	@echo "  colors             Rebuild color data (extract + aggregate)"
	@echo "  colors-plot        Generate 3D Plotly colors figure"
	@echo "  objects            Aggregate object.txt files (no API calls)"
	@echo "  report             Basic report readiness check"
	@echo "  clean              Remove intermediates + Docker leftovers"
	@echo "  build              Build Docker RStudio environment"
	@echo "  run                Start RStudio + dashboard container"
	@echo "  stop               Stop running container(s)"
	@echo ""

.PHONY: build run stop clean colors objects dashboard report help colors-plot


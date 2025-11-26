# Frutiger Aero Palette — Static Site

This repository contains a fully static, downloadable version of the **Frutiger Aero Palette Dashboard**, a visual exploration of color palettes, embeddings, and design elements found across Frutiger Aero and related aesthetics.

The site is hosted at:

https://mads-2.github.io/frutiger-aero-palette/

You may also download the entire repository and open it locally; all files are self-contained and require no build step.

## Contents of This Static Site

### Color Palettes
Precomputed dominant color palettes for multiple aesthetic categories. Each palette contains thirty representative colors extracted from curated image sets.

### Embedding Visualizations
t-SNE and color-space visualizations that map stylistic relationships between images.

### Dashboard Interface
A static HTML dashboard located at:

dashboard/prototype/prototype.html

This is the main entry point for exploring the palettes, embeddings, and drawn object categories.

## Repository Structure

index.html
dashboard/
    prototype/
    drawn/
    FA_embedding.html
    color_plot_output.html
images/
colors/
objects/
models/

All content is HTML, CSS, JS, and static assets. No backend or build pipeline is required.

## Local Use

To view the site offline:

1. Clone or download the repository.
2. Open index.html in any modern browser.
3. Navigate the dashboard from the automatic redirect or direct path:

dashboard/prototype/prototype.html

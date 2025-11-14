#!/usr/bin/env python3
import os
import numpy as np
import plotly.graph_objects as go
from scipy.spatial import ConvexHull

# ---------------------------------------------------------------------------
# Aesthetic → Display Name + Plotly marker symbol
# ---------------------------------------------------------------------------
AESTHETIC_MAP = {
    "FA_classic":       ("Frutiger Aero", "circle"),
    "FA_DORFic":        ("DORFic", "circle"),
    "FA_Dark_Aero":     ("Dark Aero", "square"),
    "FA_Frutiger_Metro":("Frutiger Metro", "square"),
    "FA_Technozen":     ("Technozen", "diamond"),
    "FA_Frutiger_Eco":  ("Frutiger Eco", "diamond"),
}

# Marker sizes
AESTHETIC_SIZE = {
    "FA_classic": 12,
    "FA_DORFic": 6,
    "FA_Dark_Aero": 12,
    "FA_Frutiger_Metro": 6,
    "FA_Technozen": 12,
    "FA_Frutiger_Eco": 6,
}

# ---------------------------------------------------------------------------
# Hex → RGB
# ---------------------------------------------------------------------------
def hex_to_rgb(hex_code):
    hex_code = hex_code.strip().lstrip("#")
    return tuple(int(hex_code[i:i+2], 16) / 255 for i in (0, 2, 4))

# ---------------------------------------------------------------------------
# Load ONLY colors.txt
# ---------------------------------------------------------------------------
def load_all_colors(base_dir="images"):
    data = {}
    for folder in AESTHETIC_MAP.keys():
        path = os.path.join(base_dir, folder, "colors.txt")
        pts = []
        if os.path.exists(path):
            with open(path, "r") as f:
                for line in f:
                    if line.strip():
                        pts.append(hex_to_rgb(line.strip()))
        data[folder] = pts
    return data

# ---------------------------------------------------------------------------
# Compute convex hull blob vertices
# ---------------------------------------------------------------------------
def compute_full_blob(points):
    pts = np.array(points)
    if len(pts) < 4:
        return None
    hull = ConvexHull(pts)
    return pts[hull.vertices]

# ---------------------------------------------------------------------------
# Build Plotly figure
# ---------------------------------------------------------------------------
def make_3d_plot(data):
    fig = go.Figure()

    for folder, pts in data.items():
        if not pts:
            continue

        name, marker_symbol = AESTHETIC_MAP[folder]
        size = AESTHETIC_SIZE[folder]

        xs = [p[0] for p in pts]
        ys = [p[1] for p in pts]
        zs = [p[2] for p in pts]

        point_colors = [
            f"rgb({int(r*255)}, {int(g*255)}, {int(b*255)})"
            for r, g, b in pts
        ]

        # Text labels (HEX without #)
        hex_labels = []
        text_colors = []
        for r, g, b in pts:
            hex_raw = f"{int(r*255):02X}{int(g*255):02X}{int(b*255):02X}"
            brightness = r + g + b
            if brightness < 0.5:
                text_colors.append("white")
            else:
                text_colors.append("black")
            hex_labels.append(hex_raw)

        # ------------------------------------------------------------------
        # POINTS
        # ------------------------------------------------------------------
        fig.add_trace(go.Scatter3d(
            x=xs,
            y=ys,
            z=zs,
            mode="markers+text",
            name=f"{name} — Points",
            marker=dict(
                size=size,
                symbol=marker_symbol,
                color=point_colors,
                line=dict(width=1, color="black"),
            ),
            text=hex_labels,
            textposition="bottom center",
            textfont=dict(size=5, color=text_colors),
            hoverinfo="skip",
            showlegend=True,
        ))

        # ------------------------------------------------------------------
        # 3D MESH BLOB
        # ------------------------------------------------------------------
        blob = compute_full_blob(pts)
        if blob is not None:
            bx, by, bz = blob[:, 0], blob[:, 1], blob[:, 2]
            r0, g0, b0 = pts[0]

            opacity = 0.32
            if folder == "FA_Frutiger_Metro":
                opacity = 0.55

            blob_color = (
                f"rgba({int(r0*255)}, {int(g0*255)}, {int(b0*255)}, {opacity})"
            )

            fig.add_trace(go.Mesh3d(
                x=bx,
                y=by,
                z=bz,
                alphahull=0,
                opacity=opacity,
                color=blob_color,
                name=f"{name} — Blob",
                hoverinfo="skip",
                showlegend=True,
            ))

    # Layout
    fig.update_layout(
        title=dict(
            text=(
                "Dominant Colors of Frutiger Aero and Related Aesthetics in RGB Space"
                "<br><sup>HEX codes shown directly on each point.</sup>"
            ),
            x=0.5, y=0.95,
        ),
        width=1300,
        height=900,
        legend=dict(
            orientation="v",
            yanchor="top",
            y=0.88,
            xanchor="left",
            x=1.05,
            bgcolor="rgba(255,255,255,0.85)",
            borderwidth=1,
        ),
        margin=dict(l=40, r=260, t=130, b=120),
        scene=dict(
            xaxis_title="Red",
            yaxis_title="Green",
            zaxis_title="Blue",
            xaxis=dict(range=[0,1]),
            yaxis=dict(range=[0,1]),
            zaxis=dict(range=[0,1]),
        ),
    )

    return fig

# ---------------------------------------------------------------------------
# MAIN — Generate static HTML
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    data = load_all_colors("images")
    fig = make_3d_plot(data)

    # Output path inside dashboard folder
    output_path = "dashboard/color_plot_output.html"

    # Save static HTML file
    fig.write_html(output_path, include_plotlyjs="cdn", full_html=True)

    print(f"Static HTML plot written to: {output_path}")


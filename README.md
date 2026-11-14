# CLICK
**A 2D Time-Attack Precision Platformer in Godot 4**

[![GitHub Pages](https://img.shields.io/badge/Play%20Online-GitHub%20Pages-brightgreen)](https://raghav-sharma-ai.github.io/CLICK/)

---

## 1. HOW CAN SOMEONE ACCESS AND PLAY THIS ON THEIR LAPTOP?

There are two easy ways for anyone to play **CLICK** on any laptop (Mac, Windows, Linux, or Chromebook):

### Option A: Play Instantly in Any Web Browser (No Install Needed!)
Since this is a web game, it can run directly inside Chrome, Safari, Firefox, or Edge:

1. **GitHub Pages URL**:
   👉 **`https://raghav-sharma-ai.github.io/CLICK/`**
2. **How to enable it on your repository**:
   - Go to your repository settings: [https://github.com/raghav-sharma-ai/CLICK/settings/pages](https://github.com/raghav-sharma-ai/CLICK/settings/pages)
   - Under **Build and deployment** > **Source**, select **GitHub Actions**.
   - The automated `.github/workflows/deploy.yml` workflow will automatically build and host the game live on the web! Anyone can simply open the link on their laptop and start playing immediately.

---

### Option B: Download & Run with the Godot Engine

If someone wants to run it natively or inspect/edit the levels:

1. **Download the project**:
   - Clone via git:
     ```bash
     git clone https://github.com/raghav-sharma-ai/CLICK.git
     ```
   - Or download the ZIP from GitHub: [Download ZIP](https://github.com/raghav-sharma-ai/CLICK/archive/refs/heads/main.zip) and extract it.
2. **Open in Godot 4**:
   - Download free [Godot 4](https://godotengine.org/download).
   - In the Project Manager, click **Import** ➔ select `project.godot` inside the folder.
   - Click **Import & Edit**, then press **F5** to play!

---

## 2. GAME CONTROLS

| Action | Primary Key | Secondary Key | Function |
| :--- | :--- | :--- | :--- |
| **Move Left / Right** | `A` / `D` | `Left` / `Right` Arrow | Lateral acceleration |
| **Jump** | `Space` | `W` / `Up` Arrow | Dynamic jump height (small hop or high leap) |
| **Instant Retry** | `R` or `Space` | `Enter` | Zero-delay instant retry after elimination |
| **Pause** | `Escape` | `P` | Technical pause menu |

---

## 3. THE 15 HANDCRAFTED FRAMES

The game features **15 progressively challenging frames**, each introducing new mechanical combinations:

| Frame | Title | Mechanics & Theme |
| :--- | :--- | :--- |
| **01** | **FIRST STEP** | Running acceleration, short vs. high jumps, ground spike clearance. |
| **02** | **PNEUMATICS** | Pneumatic spring launch pads and aerial steering. |
| **03** | **CLOCKWORK** | Horizontal moving platform traverse over a spike ocean. |
| **04** | **MOMENTUM ARC** | Angled diagonal launch trajectories and mid-air precision. |
| **05** | **ELEVATOR SHIFT** | Dual vertical elevators alternating heights over hazards. |
| **06** | **THE LEAP** | Full-momentum sprint and coyote time leap across a wide chasm. |
| **07** | **DUAL SPRING** | Chained launch pads: bouncing between springs mid-air without touching ground. |
| **08** | **HAZARD TUNNEL** | Low-ceiling corridor requiring short jump-cuts to avoid ceiling thorns. |
| **09** | **COUNTER-CLOCK** | Vertical climbing circuit traversing up to high rafters and back left. |
| **10** | **RUSH HOUR** | Rapid oscillating moving platforms with fast turnaround times. |
| **11** | **CHRONO RUN** | Extended obstacle gauntlet requiring collecting Time Fragments (+2s). |
| **12** | **PRECISION MATRIX**| Stepped narrow pillars with edge spike guards. |
| **13** | **THE GAUNTLET** | High launch into an aerial elevator catch over double spike barricades. |
| **14** | **SPLIT SECOND** | Branching paths: safe tight lower route vs. high-speed upper launch route. |
| **15** | **THE FINAL CLICK** | The Grand Finale combining moving platforms, pneumatic pads, chrono shards, and precision timing! |

---

## 4. VISUAL IDENTITY: PAPER-INDUSTRIAL

* **Warm Paper Background**: `#EDE7D8` with technical millimeter drafting lines.
* **Charcoal Chassis**: `#242521` for solid platforms and Unit 01 runner.
* **Signal Orange Accent**: `#E56B36` for optic visors, countdown warnings, and hazard edges.
* **Sage Green Accent**: `#A7B3A0` for portal iris and structural grip edges.
* **Sand Accent**: `#D7B96D` for chrono shards and drafting tick marks.

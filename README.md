# LAST FRAME
**An Original 2D Time-Attack Precision Platformer in Godot 4**

---

## 1. GAME CONCEPT & IDENTITY

**LAST FRAME** is a fast-paced 2D precision platformer built around an urgent premise: you have exactly **10 seconds** to reach the exit frame of each level. Every millisecond counts, momentum must be preserved, and hesitation is fatal.

### Visual Aesthetic: Paper-Industrial
LAST FRAME deliberately rejects generic neon and cyberpunk clichés in favor of a clean, technical **Paper-Industrial** aesthetic inspired by architectural blueprints, technical drafting, and minimalist machine design.

* **Warm Paper Background**: `#EDE7D8` with subtle drafting millimeter grid lines
* **Main Structures & Platforms**: `#242521` (Charcoal) with technical drafting ticks
* **Primary Accent**: `#E56B36` (Signal Orange) for optic visors, countdown urgency, and hazard blades
* **Secondary Accent**: `#A7B3A0` (Sage Green) for structural trims and the exit portal iris
* **Decorative Accent**: `#D7B96D` (Sand) for pivot bearings, skid pads, and time shards

---

## 2. HOW TO RUN AND PLAY ON MACOS

### Option A: From the Godot Editor (Recommended)
1. Open the **Godot Engine** application (`/Applications/Godot.app`).
2. Click **Import** in the Project Manager.
3. Browse to `/Users/raghavsharma/Downloads/CLICk/project.godot` and click **Import & Edit**.
4. Press **F5** (or the **Play** icon in the upper-right corner) to run the full game starting from the Main Menu.
5. To test an individual level directly, open any scene in `scenes/levels/` (e.g. `level_1.tscn`) and press **F6** (Play Current Scene).

### Option B: From the Terminal
Run the game directly with one command:
```bash
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/raghavsharma/Downloads/CLICk
```

---

## 3. CONTROLS

| Action | Primary Key | Secondary Key | Description |
| :--- | :--- | :--- | :--- |
| **Move Left** | `A` | `Left Arrow` | Smooth acceleration left |
| **Move Right** | `D` | `Right Arrow` | Smooth acceleration right |
| **Jump** | `Space` | `W` / `Up Arrow` | Dynamic jump with height cut & coyote time |
| **Instant Retry** | `R` | — | Instantly resets the frame and 10s timer |
| **Pause** | `Escape` | `P` | Opens the technical pause menu |

---

## 4. PROJECT ARCHITECTURE

```text
res://
├── assets/
│   ├── audio/           # Sound assets folder
│   ├── fonts/           # Typography resources
│   └── textures/        # Texture resources
├── icon.svg             # Original Paper-Industrial application icon
├── project.godot        # Engine configuration (1280x720, canvas_items, autoloads)
├── scenes/
│   ├── levels/
│   │   ├── level_1.tscn          # Frame 01: First Contact
│   │   ├── level_2.tscn          # Frame 02: Pneumatics & Launch Momentum
│   │   ├── level_3.tscn          # Frame 03: Clockwork Traverse
│   │   └── milestone1_test.tscn  # Movement testbed
│   ├── objects/
│   │   ├── goal.tscn             # Exit portal with animated geometric iris
│   │   ├── hazard.tscn           # Tuned spikes with industrial warning trim
│   │   ├── launch_pad.tscn       # Spring piston launching plate
│   │   ├── moving_platform.tscn  # Smooth Kinematic AnimatableBody2D platform
│   │   ├── platform.tscn         # Reusable charcoal static platform
│   │   └── time_fragment.tscn    # Collectible shard (+2.0s bonus time)
│   ├── player/
│   │   └── player.tscn           # CharacterBody2D Unit 01 runner
│   └── ui/
│       ├── hud.tscn              # Top bar, 10s timer, progress bar, overlays
│       └── main_menu.tscn        # Main menu, Level selection, System settings
├── scripts/
│   ├── audio/
│   │   └── sound_manager.gd      # Procedural 16-bit sound synthesizer singleton
│   ├── gameplay/
│   │   ├── game_manager.gd       # Progression, best records, save data autoload
│   │   └── level_controller.gd   # 10s timer, win/loss evaluator, state machine
│   ├── objects/
│   │   ├── goal.gd               # Goal detection and victory trigger
│   │   ├── hazard.gd             # Fair hitbox calculation and death trigger
│   │   ├── launch_pad.gd         # Upward/diagonal launch impulses & compression
│   │   ├── moving_platform.gd    # Waypoint oscillation and momentum transfer
│   │   ├── paper_background.gd   # Procedural millimeter drafting grid
│   │   ├── platform.gd           # Resizable procedural charcoal platform
│   │   └── time_fragment.gd      # Chrono shard floating and bonus time
│   ├── player/
│   │   ├── player.gd             # Physics solver, coyote time, jump buffering
│   │   └── player_visual.gd      # Procedural drawing of Unit 01 & death shards
│   └── ui/
│       ├── hud.gd                # UI updates, urgency audio ticks, pause/game over
│       └── main_menu.gd          # Menu views, animated blueprint grid, record display
└── test/
    ├── test_milestone1_runner.gd # Milestone 1 physics unit test
    └── test_full_game.gd         # End-to-end integration test suite
```

---

## 5. SCRIPT BREAKDOWN FOR BEGINNERS

### 1. `scripts/player/player.gd`
* **What it does**: Controls your character's physical movement.
* **Key Mechanics Explained**:
  * **Acceleration & Friction**: Rather than snapping instantly to full speed, the player ramps up velocity using `move_toward()`.
  * **Variable Jump Height**: When you release the jump button while rising, vertical velocity is cut (`velocity.y *= jump_cut_multiplier`), giving you pinpoint control between small hops and full jumps.
  * **Coyote Time**: Gives you a grace period (0.12s) after walking off a ledge where you can still jump.
  * **Jump Buffering**: If you press jump a fraction of a second before landing (0.12s), your jump triggers the exact instant you touch the ground.

### 2. `scripts/player/player_visual.gd`
* **What it does**: Procedurally draws "Unit 01", the player character.
* **Details**: Renders a faceted charcoal chassis with sage green architectural fold lines and a signal orange optic visor. The visor smoothly glances in the direction of travel, squats on landing, and stretches on takeoff. On death, fractures into 5 geometric paper shards.

### 3. `scripts/gameplay/level_controller.gd`
* **What it does**: The referee for each level. Decrements the 10.0-second countdown in `_process()`. If time hits 0.0s, it triggers `_on_time_expired()`. If the goal is reached, it computes your remaining time and records high scores.

### 4. `scripts/audio/sound_manager.gd`
* **What it does**: An embedded 16-bit procedural sound synthesizer. Generates custom wave audio (sine sweeps, harmonic chimes, white noise bursts) in pure GDScript at runtime. Ensures complete sound support without missing external audio files.

### 5. `scripts/gameplay/game_manager.gd`
* **What it does**: Global Autoload singleton that saves and loads your best records (`user://last_frame_save.cfg`), tracks unlocked levels, and registers default keyboard input bindings.

---

## 6. TUNING MOVEMENT IN THE GODOT INSPECTOR
Select the **Player** node in `scenes/player/player.tscn` to view exported parameters in the Inspector:
* `max_speed` (Default: `260.0`): Horizontal running speed.
* `acceleration` (Default: `1800.0`): How quickly the player reaches top speed.
* `friction` (Default: `2200.0`): How snappily the player halts when inputs are released.
* `jump_velocity` (Default: `-440.0`): Upward leap strength.
* `gravity` (Default: `1250.0`): Downward gravitational pull.
* `fall_gravity_multiplier` (Default: `1.4`): Extra gravity while descending for a crisp, responsive feel.

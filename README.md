# Sonic Obsidian

> A 2D Sonic the Hedgehog fan game built in Godot 4.6 with GDScript.

A passion project inspired by the handheld Sonic platformers, featuring momentum-based movement, original music, and a growing list of Sonic-faithful mechanics built from scratch in Godot.

---

## Features

- **Movement System** — Smooth, responsive running with acceleration and deceleration meant to emulate a mix of the Sonic Advance 2 and Sonic Rush Games.
- **Sonic Boom Speed Boost** — A dedicated high-speed burst mechanic that pushes Sonic past his normal top speed inspired off Sonic Advance 2's Boost Mode.
- **Original Soundtrack** — Custom-produced music tracks.
- **Controller Support** — Full gamepad input alongside keyboard (WASD / Arrow keys).
- **Mobile-Ready Input** — Virtual joystick addon included for touch screen support.
- **1280×720 Viewport** — Fixed resolution with a clean title screen flow into gameplay.

---

## Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Move Left | `A` / `←` | Left Stick / D-Pad Left |
| Move Right | `D` / `→` | Left Stick / D-Pad Right |
| Look Up | `W` / `↑` | Left Stick / D-Pad Up |
| Crouch / Look Down | `S` / `↓` | Left Stick / D-Pad Down |
| Jump | `Space` | `A` (South Button) |
| Stomp / Bounce | `F` | `B` (East Button) |
| Pause / Start | `Escape` | `Select` |

---

## Project Structure

```
2d-sonic-fangame/
├── Objects/          # Game object scenes and scripts (player, enemies, items)
├── Scene/            # Level and UI scenes
├── sprites/          # Sprite sheets and image assets
├── fonts/            # Custom fonts for UI
├── addons/           # Godot plugins (Script IDE, Virtual Joystick Plus)
├── exports/          # Export presets output
├── ost.mp3           # In-game soundtrack
├── titlemusic.mp3    # Title screen music
├── default_bus_layout.tres  # Audio bus config (includes phaser bus)
└── project.godot     # Godot project configuration
```

---

## Tech Stack

| | |
|---|---|
| **Engine** | Godot 4.6 |
| **Language** | GDScript (99.6%), GDShader (0.4%) |
| **Addons** | `script-ide`, `virtual_joystick_plus` |
| **Audio** | Custom MP3 tracks, Godot audio bus with phaser effect |
| **Target Platforms** | Windows, Linux, macOS, Android (Web/HTML5 via exports) |

---

## Getting Started

### Prerequisites

- [Godot Engine 4.6](https://godotengine.org/download) (standard or .NET build)

### Running the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/GreedyOyster241/2d-sonic-fangame.git
   ```
2. Open Godot and select **Import Project**.
3. Navigate to the cloned folder and open `project.godot`.
4. Press **F5** (or the Play button) to run.

---

## Disclaimer

This is a **fan-made, non-commercial project**. Sonic the Hedgehog and all related characters are trademarks of SEGA. This project is not affiliated with or endorsed by SEGA in any way.

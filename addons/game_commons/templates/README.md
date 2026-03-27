# Game Commons Templates

Ready-to-use templates for common game patterns.

## 📁 Available Templates

### 1. `constants_template.gd`
Game-wide constants (speeds, layers, paths, etc.)

**Setup:**
```bash
# Copy to your project
cp addons/game_commons/templates/constants_template.gd scripts/config/constants.gd
```

**Option A: Use as class_name (no Autoload)**
```gdscript
# Keep "class_name GameConstants" at top
# Access anywhere: GameConstants.PLAYER_SPEED
```

**Option B: Use as Autoload**
```gdscript
# Remove "class_name GameConstants" line
# Register: Project Settings > Autoload > "Constants"
# Access anywhere: Constants.PLAYER_SPEED
```

---

### 2. `enums_template.gd`
Common game enums (states, directions, rarities)

**Setup:**
```bash
cp addons/game_commons/templates/enums_template.gd scripts/config/enums.gd
```

**Usage:**
```gdscript
var state := GameEnums.PlayerState.IDLE

match state:
    GameEnums.PlayerState.IDLE:
        # ...
```

---

### 3. `game_manager_template.gd`
Core game manager (score, state, game over)

**Setup:**
```bash
cp addons/game_commons/templates/game_manager_template.gd scripts/autoload/game_manager.gd
```

**Register as Autoload:**
```
Project Settings > Autoload
Name: GameManager
Path: res://scripts/autoload/game_manager.gd
```

**Usage:**
```gdscript
GameManager.start_game()
GameManager.add_score(10)
GameManager.game_over()
```

---

## 🎯 Recommended Setup

```
your_game/
├── scripts/
│   ├── config/
│   │   ├── constants.gd     ← From constants_template.gd
│   │   └── enums.gd         ← From enums_template.gd
│   └── autoload/
│       └── game_manager.gd  ← From game_manager_template.gd
└── addons/
    └── game_commons/        ← This addon
```

**Autoloads (in order):**
1. SaveManager (auto-registered by addon)
2. SceneManager (auto-registered by addon)
3. AudioManager (auto-registered by addon)
4. SettingsManager (auto-registered by addon)
5. **GameManager** (your game logic)

---

## ✨ Clean Code Principles

These templates follow:
- **Single Responsibility** — Each file does one thing
- **Clear Naming** — No abbreviations, readable
- **Minimal Coupling** — Use signals, not direct references
- **Type Safety** — Explicit types everywhere
- **Documentation** — Comments explain *why*, not *what*

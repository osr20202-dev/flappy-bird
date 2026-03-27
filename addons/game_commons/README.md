# Game Commons Addon

Reusable game systems for Godot 4.x projects. Provides **logic** for common features, allowing you to apply your own **visual style**.

## 🎯 Philosophy

**Addon provides:** Structure, logic, functionality  
**Your game provides:** Art, theme, layout, styling

## 📦 What's Included

### Autoload Singletons (auto-registered)

- **SceneManager** — Scene transitions, reload
- **AudioManager** — Music/SFX playback with volume control
- **SaveManager** — Advanced save system (slots, encryption, backup, versioning)
- **SettingsManager** — Game settings (audio, display, input) with persistence

### UI Base Classes

- **BaseMenu** — Common menu logic (show/hide, fade)

### Templates

- **constants_template.gd** — Game constants (speeds, layers, paths)
- **enums_template.gd** — Common enums (states, directions)
- **game_manager_template.gd** — Core game manager (score, state)

### Examples

- `examples/main_menu_example.gd` — How to use BaseMenu
- `examples/options_menu_example.gd` — Settings/options menu with SettingsManager
- `examples/save_load_example.gd` — Complete save/load workflow with slots
- `examples/configure_save_manager.gd` — SaveManager configuration on startup

## 🚀 Installation

1. Copy `addons/game_commons/` to your project
2. Enable in: **Project > Project Settings > Plugins**
3. Autoloads are registered automatically

## 📖 Usage

### SceneManager

```gdscript
SceneManager.change_scene("res://scenes/game.tscn")
SceneManager.reload_current_scene()
```

### AudioManager

```gdscript
AudioManager.play_music(preload("res://assets/music.ogg"))
AudioManager.play_sfx(preload("res://assets/jump.wav"))
AudioManager.set_music_volume(0.7)
```

### SaveManager

**Basic usage:**
```gdscript
# Hierarchical game data
var game_data := {
    "player": { "hp": 100, "level": 5 },
    "world": { "day": 10, "flags": { "boss_defeated": true } }
}

# Save to slot 1 with metadata
var metadata := {
    "playtime_seconds": 3600,
    "player_name": "Hero",
    "location": "Town"
}
SaveManager.save_game(1, game_data, metadata)

# Load from slot 1
var loaded_data = SaveManager.load_game(1)
print(loaded_data["player"]["hp"])  # 100

# List all slots
var slots = SaveManager.list_slots()
for slot_meta in slots:
    print("Slot %d: %s" % [slot_meta.slot_index, slot_meta.save_time])

# Delete slot
SaveManager.delete_slot(1)

# Check if slot exists
if SaveManager.slot_exists(1):
    print("Save found!")
```

**Configuration (set on game startup):**
```gdscript
# In your game's autoload or main scene _ready()
func _ready() -> void:
    # Set max save slots (default: 3)
    SaveManager.set_max_slots(5)  # 1-99
    
    # Enable encryption (anti-cheat)
    SaveManager.set_encryption_enabled(true)
    
    # Configure backup settings
    SaveManager.set_auto_backup(true)
    SaveManager.max_backup_count = 3
```

**Advanced features:**
```gdscript
# Get metadata without loading full save
var meta = SaveManager.get_slot_metadata(1)
print("Playtime: %d seconds" % meta.playtime_seconds)

# Check current config
print("Max slots: %d" % SaveManager.get_max_slots())

# Signals
SaveManager.save_completed.connect(_on_save_done)
SaveManager.load_completed.connect(_on_load_done)
```

**Slot 0 is reserved for settings** (used by SettingsManager)

### SettingsManager

```gdscript
# Audio
SettingsManager.set_music_volume(0.7)
SettingsManager.set_sfx_volume(0.9)
var volume = SettingsManager.get_music_volume()

# Display
SettingsManager.set_fullscreen(true)
SettingsManager.set_vsync(false)
SettingsManager.set_window_size(Vector2i(1280, 720))

# Input rebinding
SettingsManager.rebind_action("jump", event)

# Reset
SettingsManager.reset_to_defaults()

# Listen for changes
SettingsManager.settings_changed.connect(_on_settings_changed)
```

### BaseMenu (UI)

**Step 1:** Create your menu scene with YOUR layout  
**Step 2:** Attach a script that extends BaseMenu

```gdscript
extends BaseMenu

@onready var play_button := $PlayButton

func _ready() -> void:
    super._ready()
    play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
    SceneManager.change_scene("res://scenes/game.tscn")
```

**Step 3:** Apply your game's Theme in the Inspector

## 🎨 Styling Your UI

The addon does **NOT** include:
- Fonts
- Button textures/styles
- Background images
- Color schemes

**You provide these via:**
1. **Theme resource** (Project Settings > GUI > Theme)
2. **Per-scene overrides** (select Control node > Theme Overrides)

## 📂 Structure

```
addons/game_commons/
├── plugin.cfg
├── plugin.gd
├── autoload/
│   ├── scene_manager.gd
│   ├── audio_manager.gd
│   └── save_manager.gd
├── ui_base/
│   └── base_menu.gd
└── examples/
    └── main_menu_example.gd
```

## 🔄 Reusing Across Projects

Just copy the `addons/game_commons/` folder to your new project and enable the plugin. Your visual assets stay separate in each game.

## 📚 Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** — Clean code guide & best practices
- **[templates/README.md](templates/README.md)** — Template usage guide

## 📝 License

MIT

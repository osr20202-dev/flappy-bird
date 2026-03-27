# Game Commons Addon

Reusable game systems for Godot 4.x projects. Provides **logic** for common features, allowing you to apply your own **visual style**.

## 🎯 Philosophy

**Addon provides:** Structure, logic, functionality  
**Your game provides:** Art, theme, layout, styling

## 📦 What's Included

### Autoload Singletons (auto-registered)

- **SceneManager** — Scene transitions, reload
- **AudioManager** — Music/SFX playback with volume control
- **SaveManager** — Save/load using ConfigFile
- **SettingsManager** — Game settings (audio, display, input) with persistence

### UI Base Classes

- **BaseMenu** — Common menu logic (show/hide, fade)

### Examples

- `examples/main_menu_example.gd` — How to use BaseMenu
- `examples/options_menu_example.gd` — Settings/options menu with SettingsManager

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

```gdscript
SaveManager.save_value("game", "high_score", 100)
var score = SaveManager.load_value("game", "high_score", 0)
```

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

## 📝 License

MIT

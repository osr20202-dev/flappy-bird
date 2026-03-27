# Game Commons — Clean Architecture Guide

> How to structure a Godot game with clean, maintainable code

---

## 🎯 Core Principles

1. **Separation of Concerns** — Each system does one thing well
2. **Signal-Based Communication** — Decouple components
3. **Single Source of Truth** — No duplicate state
4. **Type Safety** — Explicit types, no `var` for globals
5. **Documentation** — Code explains *why*, not *what*

---

## 📁 Recommended Project Structure

```
your_game/
├── addons/
│   └── game_commons/           ← This addon (reusable systems)
│
├── scenes/
│   ├── main/
│   │   └── main.tscn           ← Root scene
│   ├── game/
│   │   └── game.tscn           ← Gameplay scene
│   ├── entities/
│   │   ├── player/
│   │   │   ├── player.tscn
│   │   │   └── player.gd       ← Entity logic only
│   │   └── enemy/
│   │       ├── enemy.tscn
│   │       └── enemy.gd
│   └── ui/
│       ├── main_menu.tscn
│       ├── hud.tscn
│       └── game_over.tscn
│
├── scripts/
│   ├── config/
│   │   ├── constants.gd        ← Game constants
│   │   └── enums.gd            ← Game enums
│   └── autoload/
│       └── game_manager.gd     ← Your game logic
│
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── fonts/
│
└── project.godot
```

---

## 🔄 Data Flow

### Clean Architecture Flow

```
User Input
    ↓
Entity (player.gd)
    ↓ emit signal
Game Scene (game.gd)
    ↓ call method
GameManager (autoload)
    ↓ emit signal
UI (hud.gd)
    ↓
Display Update
```

**Example: Scoring**

```gdscript
# 1. Entity detects event
# entities/coin/coin.gd
func _on_player_collected() -> void:
    collected.emit()  # Signal only
    queue_free()

# 2. Game scene orchestrates
# scenes/game/game.gd
func _on_coin_collected() -> void:
    GameManager.add_score(10)  # Delegate to manager

# 3. Manager updates state
# autoload/game_manager.gd
func add_score(amount: int) -> void:
    score += amount
    score_changed.emit(score)  # Broadcast change

# 4. UI reacts
# ui/hud.gd
func _ready() -> void:
    GameManager.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int) -> void:
    score_label.text = str(new_score)
```

**Why this works:**
- ✅ Coin doesn't know about GameManager
- ✅ GameManager doesn't know about UI
- ✅ Each layer is testable independently

---

## 🧩 Component Responsibilities

### **Entities** (player.gd, enemy.gd)
- ✅ Own behavior (movement, animation)
- ✅ Collision detection
- ✅ Emit signals on events
- ❌ Don't access GameManager
- ❌ Don't modify global state

### **Game Scenes** (game.gd)
- ✅ Compose entities
- ✅ Spawn/destroy objects
- ✅ Connect entity signals to managers
- ❌ Don't handle UI directly
- ❌ Don't store game state

### **Managers** (game_manager.gd)
- ✅ Store game state (score, lives)
- ✅ Game logic (win/lose conditions)
- ✅ Emit state change signals
- ❌ Don't reference specific entities
- ❌ Don't handle input

### **UI** (hud.gd, game_over.gd)
- ✅ Display state
- ✅ Listen to manager signals
- ✅ Send user actions as signals
- ❌ Don't access entities
- ❌ Don't modify game state directly

---

## 🎮 Signal Patterns

### Pattern 1: Event Notification
```gdscript
# Entity
signal died

func take_damage(amount: int) -> void:
    hp -= amount
    if hp <= 0:
        died.emit()  # No parameters needed
```

### Pattern 2: Data Delivery
```gdscript
# Manager
signal score_changed(new_score: int)

func add_score(amount: int) -> void:
    score += amount
    score_changed.emit(score)  # Pass new value
```

### Pattern 3: Request/Response
```gdscript
# UI requests action
signal restart_requested

func _on_restart_button_pressed() -> void:
    restart_requested.emit()

# Manager responds
func _ready() -> void:
    UI.restart_requested.connect(restart_game)
```

---

## 🔐 State Management

### ✅ Good: Single Source of Truth
```gdscript
# GameManager (Autoload)
var score: int = 0  # Only place score exists

# UI reads from it
func update_display() -> void:
    label.text = str(GameManager.score)
```

### ❌ Bad: Duplicate State
```gdscript
# DON'T DO THIS
var score: int = 0  # Manager has it
var ui_score: int = 0  # UI has it (OUT OF SYNC!)
```

---

## 📦 Autoload Order

Autoloads run in **registration order**. Dependencies must come first.

**Correct Order:**
```
1. SaveManager     ← No dependencies
2. AudioManager    ← No dependencies
3. SceneManager    ← No dependencies
4. SettingsManager ← Depends on SaveManager, AudioManager
5. GameManager     ← Depends on SaveManager
```

**Check in:** Project Settings > Autoload

---

## 🧪 Testing Strategy

### Unit Tests (future)
```gdscript
# Test manager logic
func test_add_score() -> void:
    GameManager.score = 0
    GameManager.add_score(10)
    assert(GameManager.score == 10)
```

### Integration Tests
```gdscript
# Test signal flow
func test_game_over_flow() -> void:
    var signal_received := false
    GameManager.game_over_triggered.connect(
        func(): signal_received = true
    )
    GameManager.game_over()
    assert(signal_received)
```

---

## ✨ Clean Code Checklist

Before committing code, check:

- [ ] No magic numbers (use constants)
- [ ] No deep nesting (max 3 levels)
- [ ] Explicit types (`: int`, `: String`)
- [ ] Signal names past tense (`died`, not `die`)
- [ ] Function names verb-first (`add_score`, not `score_add`)
- [ ] No cyclic dependencies
- [ ] Comments explain *why*, not *what*
- [ ] One responsibility per file

---

## 🚫 Anti-Patterns to Avoid

### ❌ God Object
```gdscript
# DON'T: One script does everything
class_name GameController  # 5000 lines
var score, hp, enemies, ui, audio, ...
```

### ❌ Spaghetti References
```gdscript
# DON'T: Direct cross-references
get_node("/root/GameManager/Player/Inventory").add_item()
```

### ❌ Global Variables
```gdscript
# DON'T: Mutable globals
var global_player_hp := 100  # In autoload
```

Use signals or manager methods instead.

---

## 🎓 Further Reading

- Godot Docs: [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)
- GDScript Style Guide: [Official](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot Design Patterns](https://github.com/godotengine/godot-design-patterns)

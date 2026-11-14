extends Node

## GameManager
## Autoload singleton managing game state, level progression,
## best completion times, and input configurations.

signal level_started(level_id: int)
signal level_completed(level_id: int, time_left: float, is_new_record: bool)
signal level_failed(reason: String)

# Color Palette Constants (Paper-Industrial Aesthetic)
const COLOR_BACKGROUND: Color = Color("EDE7D8")   # Warm paper
const COLOR_CHARCOAL: Color = Color("242521")     # Solid platforms / structures
const COLOR_ORANGE: Color = Color("E56B36")       # Signal orange (accent, player visor, hazard highlight)
const COLOR_SAGE: Color = Color("A7B3A0")         # Sage green (goal, secondary accent)
const COLOR_SAND: Color = Color("D7B96D")         # Sand (decorative lines, collectibles)
const COLOR_MUTED: Color = Color("7A7D76")        # Muted grid lines

var current_level_id: int = 1
var total_levels: int = 3
var best_times: Dictionary = {1: 0.0, 2: 0.0, 3: 0.0}
var unlocked_levels: Array[int] = [1]
var sfx_enabled: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_default_inputs()
	_load_save_data()

func _setup_default_inputs() -> void:
	_register_action("move_left", [KEY_A, KEY_LEFT])
	_register_action("move_right", [KEY_D, KEY_RIGHT])
	_register_action("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_register_action("restart", [KEY_R])
	_register_action("pause", [KEY_ESCAPE, KEY_P])

func _register_action(action_name: String, keycodes: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for key in keycodes:
		var event := InputEventKey.new()
		event.physical_keycode = key
		if not InputMap.action_has_event(action_name, event):
			InputMap.action_add_event(action_name, event)

func record_completion(level_id: int, time_left: float) -> bool:
	var is_new_best: bool = false
	if not best_times.has(level_id) or time_left > best_times[level_id]:
		best_times[level_id] = snappedf(time_left, 0.01)
		is_new_best = true
	
	var next_level := level_id + 1
	if next_level <= total_levels and not unlocked_levels.has(next_level):
		unlocked_levels.append(next_level)
	
	_save_save_data()
	level_completed.emit(level_id, time_left, is_new_best)
	return is_new_best

func get_best_time(level_id: int) -> float:
	return best_times.get(level_id, 0.0)

func is_level_unlocked(level_id: int) -> bool:
	return unlocked_levels.has(level_id)

func _save_save_data() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "unlocked_levels", unlocked_levels)
	config.set_value("progress", "best_times", best_times)
	config.set_value("settings", "sfx_enabled", sfx_enabled)
	config.save("user://last_frame_save.cfg")

func _load_save_data() -> void:
	var config := ConfigFile.new()
	var err := config.load("user://last_frame_save.cfg")
	if err == OK:
		var loaded_unlocked = config.get_value("progress", "unlocked_levels", [1])
		if loaded_unlocked is Array:
			unlocked_levels.clear()
			for lvl in loaded_unlocked:
				unlocked_levels.append(int(lvl))
		var loaded_best = config.get_value("progress", "best_times", {})
		if loaded_best is Dictionary:
			for k in loaded_best.keys():
				best_times[int(k)] = float(loaded_best[k])
		sfx_enabled = config.get_value("settings", "sfx_enabled", true)

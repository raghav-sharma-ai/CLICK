extends Node2D
class_name LevelController

## Level Controller
## Coordinates gameplay rules, the 10-second countdown timer,
## win/loss state resolution, and HUD synchronization.

@export var level_id: int = 1
@export var initial_time: float = 10.0

enum LevelState {
	RUNNING,
	VICTORY,
	FAILED,
	PAUSED
}

var current_state: LevelState = LevelState.RUNNING
var time_remaining: float = 10.0
var _player_start_x: float = 0.0
var _goal_x: float = 1000.0

@onready var hud: CanvasLayer = $HUD
@onready var player: CharacterBody2D = $Player
@onready var goal: Area2D = $Goal

func _ready() -> void:
	time_remaining = initial_time
	GameManager.current_level_id = level_id
	GameManager.level_started.emit(level_id)
	
	if player:
		_player_start_x = player.position.x
		player.died.connect(_on_player_died)
	
	if goal:
		_goal_x = goal.position.x
		goal.goal_reached.connect(_on_goal_reached)
		
	if hud:
		hud.restart_requested.connect(restart_level)
		hud.next_level_requested.connect(load_next_level)
		hud.main_menu_requested.connect(go_to_main_menu)
		hud.pause_toggled.connect(_on_pause_toggled)

func _process(delta: float) -> void:
	if current_state != LevelState.RUNNING:
		return

	# Decrement countdown
	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		_on_time_expired()
		return

	# Calculate player progress toward goal
	var progress: float = 0.0
	if player and absf(_goal_x - _player_start_x) > 1.0:
		progress = clampf((player.position.x - _player_start_x) / (_goal_x - _player_start_x), 0.0, 1.0)

	if hud:
		hud.update_hud(time_remaining, level_id, progress)

# Called when 10-second timer reaches zero
func _on_time_expired() -> void:
	if current_state != LevelState.RUNNING:
		return
	current_state = LevelState.FAILED
	if player:
		player.kill("time_up")
	if hud:
		hud.update_hud(0.0, level_id, 0.0)
		hud.show_failure("time_up")
	GameManager.level_failed.emit("time_up")

# Called when player hits spikes or hazards
func _on_player_died() -> void:
	if current_state != LevelState.RUNNING:
		return
	current_state = LevelState.FAILED
	if hud:
		hud.show_failure("hazard")
	GameManager.level_failed.emit("hazard")

# Called when player touches the goal
func _on_goal_reached() -> void:
	if current_state != LevelState.RUNNING:
		return
	current_state = LevelState.VICTORY
	var is_new_record: bool = GameManager.record_completion(level_id, time_remaining)
	var has_next: bool = (level_id < GameManager.total_levels)
	if hud:
		hud.show_victory(level_id, time_remaining, is_new_record, has_next)

func _on_pause_toggled(is_paused: bool) -> void:
	if current_state == LevelState.RUNNING and is_paused:
		current_state = LevelState.PAUSED
	elif current_state == LevelState.PAUSED and not is_paused:
		current_state = LevelState.RUNNING

func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func load_next_level() -> void:
	get_tree().paused = false
	var next_id := level_id + 1
	var next_scene_path := "res://scenes/levels/level_%d.tscn" % next_id
	if ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		go_to_main_menu()

func go_to_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

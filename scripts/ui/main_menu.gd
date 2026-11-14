extends Control

## MainMenu
## Main title screen for LAST FRAME.
## Manages Title view, Level Select view, Settings view, and background animations.

@onready var main_view: Control = $MainView
@onready var level_select_view: Control = $LevelSelectView
@onready var settings_view: Control = $SettingsView

# Level Select Buttons
@onready var lvl_1_btn: Button = $LevelSelectView/Panel/VBox/LevelGrid/Level1Btn
@onready var lvl_2_btn: Button = $LevelSelectView/Panel/VBox/LevelGrid/Level2Btn
@onready var lvl_3_btn: Button = $LevelSelectView/Panel/VBox/LevelGrid/Level3Btn

@onready var lvl_1_time: Label = $LevelSelectView/Panel/VBox/LevelGrid/Level1Btn/BestLabel
@onready var lvl_2_time: Label = $LevelSelectView/Panel/VBox/LevelGrid/Level2Btn/BestLabel
@onready var lvl_3_time: Label = $LevelSelectView/Panel/VBox/LevelGrid/Level3Btn/BestLabel

# Settings
@onready var sfx_check: CheckBox = $SettingsView/Panel/VBox/SFXToggle

var _bg_timer: float = 0.0

const C_BACKGROUND: Color = Color("EDE7D8")
const C_CHARCOAL: Color = Color("242521")
const C_ORANGE: Color = Color("E56B36")
const C_SAGE: Color = Color("A7B3A0")
const C_SAND: Color = Color("D7B96D")
const C_GRID: Color = Color(0.48, 0.49, 0.46, 0.12)
const C_MAJOR_GRID: Color = Color(0.48, 0.49, 0.46, 0.22)

func _ready() -> void:
	_show_main_view()
	_connect_signals()
	_refresh_level_cards()
	if sfx_check:
		sfx_check.button_pressed = GameManager.sfx_enabled

func _process(delta: float) -> void:
	_bg_timer += delta
	queue_redraw()

func _draw() -> void:
	# Animated drafting grid background
	var rect := get_rect()
	draw_rect(rect, C_BACKGROUND, true)
	
	# Moving subtle paper blueprint grid
	var grid_size: float = 40.0
	var offset_x := fposmod(_bg_timer * 12.0, grid_size)
	var x: float = -grid_size + offset_x
	while x < rect.size.x:
		draw_line(Vector2(x, 0), Vector2(x, rect.size.y), C_GRID, 1.0)
		x += grid_size
		
	var y: float = 0.0
	while y < rect.size.y:
		draw_line(Vector2(0, y), Vector2(rect.size.x, y), C_GRID, 1.0)
		y += grid_size

	# Subtle decorative drafting frame
	var margin: float = 24.0
	var inner_rect := rect.grow(-margin)
	draw_rect(inner_rect, C_MAJOR_GRID, false, 1.5)
	
	# Architectural tick marks along header
	var tick_x := margin + 30.0
	while tick_x < rect.size.x - margin - 30.0:
		draw_line(Vector2(tick_x, margin), Vector2(tick_x, margin + 6.0), C_SAND, 1.2)
		tick_x += 40.0

func _connect_signals() -> void:
	# Main View
	$MainView/VBox/PlayBtn.pressed.connect(_on_play_pressed)
	$MainView/VBox/LevelSelectBtn.pressed.connect(_show_level_select)
	$MainView/VBox/SettingsBtn.pressed.connect(_show_settings)
	$MainView/VBox/QuitBtn.pressed.connect(_on_quit_pressed)

	# Level Select View
	lvl_1_btn.pressed.connect(_launch_level.bind(1))
	lvl_2_btn.pressed.connect(_launch_level.bind(2))
	lvl_3_btn.pressed.connect(_launch_level.bind(3))
	$LevelSelectView/Panel/VBox/BackBtn.pressed.connect(_show_main_view)

	# Settings View
	if sfx_check:
		sfx_check.toggled.connect(_on_sfx_toggled)
	$SettingsView/Panel/VBox/BackBtn.pressed.connect(_show_main_view)

func _refresh_level_cards() -> void:
	_setup_card(1, lvl_1_btn, lvl_1_time)
	_setup_card(2, lvl_2_btn, lvl_2_time)
	_setup_card(3, lvl_3_btn, lvl_3_time)

func _setup_card(level_id: int, btn: Button, label: Label) -> void:
	var unlocked := GameManager.is_level_unlocked(level_id)
	btn.disabled = not unlocked
	if unlocked:
		var best := GameManager.get_best_time(level_id)
		if best > 0.0:
			label.text = "BEST: %05.2fs" % best
			label.modulate = C_ORANGE
		else:
			label.text = "UNTOUCHED"
			label.modulate = C_SAGE
	else:
		label.text = "LOCKED"
		label.modulate = Color(0.5, 0.5, 0.5, 1.0)

func _show_main_view() -> void:
	SoundManager.play_click()
	main_view.visible = true
	level_select_view.visible = false
	settings_view.visible = false

func _show_level_select() -> void:
	SoundManager.play_click()
	_refresh_level_cards()
	main_view.visible = false
	level_select_view.visible = true
	settings_view.visible = false

func _show_settings() -> void:
	SoundManager.play_click()
	main_view.visible = false
	level_select_view.visible = false
	settings_view.visible = true

func _on_play_pressed() -> void:
	SoundManager.play_click()
	# Play lowest incomplete level or Level 1
	var target_level := 1
	for lvl in range(1, GameManager.total_levels + 1):
		if GameManager.is_level_unlocked(lvl) and GameManager.get_best_time(lvl) == 0.0:
			target_level = lvl
			break
	_launch_level(target_level)

func _launch_level(id: int) -> void:
	SoundManager.play_click()
	var scene_path := "res://scenes/levels/level_%d.tscn" % id
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)

func _on_sfx_toggled(toggled_on: bool) -> void:
	GameManager.sfx_enabled = toggled_on
	GameManager._save_save_data()
	if toggled_on:
		SoundManager.play_click()

func _on_quit_pressed() -> void:
	SoundManager.play_click()
	get_tree().quit()

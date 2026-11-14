extends Control

## MainMenu
## Main title screen for CLICK.
## Manages Title view, 15-Level Select grid, Settings view, and background animations.

@onready var main_view: Control = $MainView
@onready var level_select_view: Control = $LevelSelectView
@onready var settings_view: Control = $SettingsView
@onready var level_grid: GridContainer = $LevelSelectView/Panel/VBox/Scroll/LevelGrid
@onready var sfx_check: CheckBox = $SettingsView/Panel/VBox/SFXToggle

var _bg_timer: float = 0.0

const C_BACKGROUND: Color = Color("EDE7D8")
const C_CHARCOAL: Color = Color("242521")
const C_ORANGE: Color = Color("E56B36")
const C_SAGE: Color = Color("A7B3A0")
const C_SAND: Color = Color("D7B96D")
const C_GRID: Color = Color(0.48, 0.49, 0.46, 0.12)
const C_MAJOR_GRID: Color = Color(0.48, 0.49, 0.46, 0.22)

# Metadata for all 15 frames
const FRAME_INFO: Dictionary = {
	1: {"title": "FIRST STEP", "desc": "Basics & Spikes"},
	2: {"title": "PNEUMATICS", "desc": "Launch Momentum"},
	3: {"title": "CLOCKWORK", "desc": "Moving Platforms"},
	4: {"title": "MOMENTUM ARC", "desc": "Angled Trajectory"},
	5: {"title": "ELEVATOR SHIFT", "desc": "Dual Elevators"},
	6: {"title": "THE LEAP", "desc": "Full Sprint Edge"},
	7: {"title": "DUAL SPRING", "desc": "Chained Launches"},
	8: {"title": "HAZARD TUNNEL", "desc": "Low-Ceiling Hops"},
	9: {"title": "COUNTER-CLOCK", "desc": "Vertical Circuit"},
	10: {"title": "RUSH HOUR", "desc": "Fast Oscillators"},
	11: {"title": "CHRONO RUN", "desc": "Shard Economy"},
	12: {"title": "PRECISION MATRIX", "desc": "Narrow Pillars"},
	13: {"title": "THE GAUNTLET", "desc": "Aerial Catches"},
	14: {"title": "SPLIT SECOND", "desc": "Branching Paths"},
	15: {"title": "THE FINAL CLICK", "desc": "The Grand Finale"}
}

func _ready() -> void:
	_show_main_view()
	_connect_signals()
	_build_level_cards()
	if sfx_check:
		sfx_check.button_pressed = GameManager.sfx_enabled

func _process(delta: float) -> void:
	_bg_timer += delta
	queue_redraw()

func _draw() -> void:
	var rect := get_rect()
	draw_rect(rect, C_BACKGROUND, true)
	
	# Animated millimeter blueprint grid
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

	var margin: float = 24.0
	var inner_rect := rect.grow(-margin)
	draw_rect(inner_rect, C_MAJOR_GRID, false, 1.5)
	
	var tick_x := margin + 30.0
	while tick_x < rect.size.x - margin - 30.0:
		draw_line(Vector2(tick_x, margin), Vector2(tick_x, margin + 6.0), C_SAND, 1.2)
		tick_x += 40.0

func _connect_signals() -> void:
	$MainView/VBox/PlayBtn.pressed.connect(_on_play_pressed)
	$MainView/VBox/LevelSelectBtn.pressed.connect(_show_level_select)
	$MainView/VBox/SettingsBtn.pressed.connect(_show_settings)
	$MainView/VBox/QuitBtn.pressed.connect(_on_quit_pressed)
	$LevelSelectView/Panel/VBox/BackBtn.pressed.connect(_show_main_view)
	$SettingsView/Panel/VBox/BackBtn.pressed.connect(_show_main_view)
	if sfx_check:
		sfx_check.toggled.connect(_on_sfx_toggled)

func _build_level_cards() -> void:
	if not level_grid:
		return
	# Clear any previous buttons
	for child in level_grid.get_children():
		child.queue_free()

	for lvl_id in range(1, GameManager.total_levels + 1):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(165, 88)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var unlocked := GameManager.is_level_unlocked(lvl_id)
		btn.disabled = not unlocked
		
		# Card styling
		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(3)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		
		if unlocked:
			var best := GameManager.get_best_time(lvl_id)
			if best > 0.0:
				style.bg_color = Color("EDE7D8")
				style.border_color = C_SAGE # Completed (sage border)
			else:
				style.bg_color = Color("EDE7D8")
				style.border_color = C_ORANGE # Unlocked but untouched (orange border)
		else:
			style.bg_color = Color(0.85, 0.83, 0.78, 0.6)
			style.border_color = Color(0.6, 0.6, 0.6, 0.4)
			
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_stylebox_override("disabled", style)

		# VBox with level info inside button
		var vbox := VBoxContainer.new()
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 2)
		btn.add_child(vbox)

		# Level number
		var num_lbl := Label.new()
		num_lbl.text = "LEVEL %02d" % lvl_id
		num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num_lbl.add_theme_font_size_override("font_size", 14)
		num_lbl.add_theme_color_override("font_color", C_CHARCOAL if unlocked else Color(0.4, 0.4, 0.4))
		vbox.add_child(num_lbl)

		# Title
		var info: Dictionary = FRAME_INFO.get(lvl_id, {"title": "SECTOR", "desc": ""})
		var title_lbl := Label.new()
		title_lbl.text = info["title"]
		title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_lbl.add_theme_font_size_override("font_size", 10)
		title_lbl.add_theme_color_override("font_color", Color(0.45, 0.46, 0.43) if unlocked else Color(0.5, 0.5, 0.5))
		vbox.add_child(title_lbl)

		# Best time or status
		var status_lbl := Label.new()
		status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_lbl.add_theme_font_size_override("font_size", 11)
		if unlocked:
			var best := GameManager.get_best_time(lvl_id)
			if best > 0.0:
				status_lbl.text = "%05.2fs" % best
				status_lbl.add_theme_color_override("font_color", C_ORANGE)
			else:
				status_lbl.text = "READY"
				status_lbl.add_theme_color_override("font_color", C_SAGE)
		else:
			status_lbl.text = "LOCKED"
			status_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
		vbox.add_child(status_lbl)

		btn.pressed.connect(_launch_level.bind(lvl_id))
		level_grid.add_child(btn)

func _show_main_view() -> void:
	SoundManager.play_click()
	main_view.visible = true
	level_select_view.visible = false
	settings_view.visible = false

func _show_level_select() -> void:
	SoundManager.play_click()
	_build_level_cards()
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
	# Play lowest uncompleted level, or level 1
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

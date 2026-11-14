extends CanvasLayer
class_name HUD

## HUD & In-Game UI Controller
## Displays the 10-second countdown, level information, progress bar,
## and manages the Pause, Victory, and Failure overlay screens.

signal restart_requested
signal next_level_requested
signal main_menu_requested
signal pause_toggled(is_paused: bool)

@onready var timer_label: Label = $TopBar/TimerContainer/TimerLabel
@onready var timer_sublabel: Label = $TopBar/TimerContainer/SubLabel
@onready var level_label: Label = $TopBar/LevelBadge/LevelLabel
@onready var progress_bar: ProgressBar = $TopBar/ProgressBar
@onready var pause_button: Button = $TopBar/PauseButton

# Overlays
@onready var pause_overlay: Control = $Overlays/PauseOverlay
@onready var victory_overlay: Control = $Overlays/VictoryOverlay
@onready var failure_overlay: Control = $Overlays/FailureOverlay

# Victory screen labels
@onready var vic_title: Label = $Overlays/VictoryOverlay/Panel/VBox/TitleLabel
@onready var vic_time_label: Label = $Overlays/VictoryOverlay/Panel/VBox/TimeLabel
@onready var vic_best_label: Label = $Overlays/VictoryOverlay/Panel/VBox/BestLabel
@onready var vic_next_btn: Button = $Overlays/VictoryOverlay/Panel/VBox/Buttons/NextButton

# Failure screen labels
@onready var fail_title: Label = $Overlays/FailureOverlay/Panel/VBox/TitleLabel
@onready var fail_reason_label: Label = $Overlays/FailureOverlay/Panel/VBox/ReasonLabel

const C_CHARCOAL: Color = Color("242521")
const C_ORANGE: Color = Color("E56B36")
const C_SAGE: Color = Color("A7B3A0")
const C_SAND: Color = Color("D7B96D")

var _is_paused: bool = false
var _last_tick_sec: int = -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_hide_all_overlays()
	_connect_buttons()

func _connect_buttons() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed)
	
	# Pause overlay buttons
	$Overlays/PauseOverlay/Panel/VBox/ResumeBtn.pressed.connect(_resume_game)
	$Overlays/PauseOverlay/Panel/VBox/RestartBtn.pressed.connect(_on_restart_pressed)
	$Overlays/PauseOverlay/Panel/VBox/MenuBtn.pressed.connect(_on_menu_pressed)
	
	# Victory overlay buttons
	vic_next_btn.pressed.connect(_on_next_level_pressed)
	$Overlays/VictoryOverlay/Panel/VBox/Buttons/RetryButton.pressed.connect(_on_restart_pressed)
	$Overlays/VictoryOverlay/Panel/VBox/Buttons/MenuButton.pressed.connect(_on_menu_pressed)
	
	# Failure overlay buttons
	$Overlays/FailureOverlay/Panel/VBox/Buttons/RetryBtn.pressed.connect(_on_restart_pressed)
	$Overlays/FailureOverlay/Panel/VBox/Buttons/MenuBtn.pressed.connect(_on_menu_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_just_pressed("pause"):
		if not victory_overlay.visible and not failure_overlay.visible:
			_toggle_pause()
	elif event.is_action_just_pressed("restart"):
		if not victory_overlay.visible:
			_on_restart_pressed()
	elif failure_overlay.visible and (event.is_action_just_pressed("jump") or event.is_action_just_pressed("ui_accept")):
		_on_restart_pressed()

func update_hud(time_left: float, level_id: int, progress: float) -> void:
	level_label.text = "FRAME %02d" % level_id
	
	# Format countdown with hundredths of a second (e.g. 09.84)
	var formatted_time := "%05.2f" % maxf(time_left, 0.0)
	timer_label.text = formatted_time
	
	# Visual urgency warning when time is low (<= 3.0 seconds)
	if time_left <= 3.0 and time_left > 0.0:
		timer_label.modulate = C_ORANGE
		timer_sublabel.modulate = C_ORANGE
		# Warning tick audio on each whole second boundary (3s, 2s, 1s)
		var current_sec := int(ceilf(time_left))
		if current_sec != _last_tick_sec and current_sec > 0:
			_last_tick_sec = current_sec
			SoundManager.play_timer_warning()
	else:
		timer_label.modulate = C_CHARCOAL
		timer_sublabel.modulate = C_CHARCOAL
		_last_tick_sec = -1

	# Update level progress bar (0.0 to 1.0)
	progress_bar.value = clampf(progress * 100.0, 0.0, 100.0)

func show_victory(level_id: int, time_left: float, is_new_best: bool, has_next_level: bool) -> void:
	_hide_all_overlays()
	victory_overlay.visible = true
	vic_title.text = "FRAME %02d COMPLETE" % level_id
	vic_time_label.text = "TIME REMAINING: %05.2fs" % time_left
	
	var best := GameManager.get_best_time(level_id)
	if is_new_best:
		vic_best_label.text = "NEW BEST RECORD: %05.2fs!" % best
		vic_best_label.modulate = C_ORANGE
	else:
		vic_best_label.text = "BEST RECORD: %05.2fs" % best
		vic_best_label.modulate = C_CHARCOAL
		
	vic_next_btn.visible = has_next_level

func show_failure(reason: String) -> void:
	_hide_all_overlays()
	failure_overlay.visible = true
	if reason == "time_up":
		fail_title.text = "TIME EXPIRED"
		fail_reason_label.text = "Reached 00.00s before reaching the exit frame."
	else:
		fail_title.text = "FRAME COLLAPSED"
		fail_reason_label.text = "Contact with industrial hazard."

func _toggle_pause() -> void:
	_is_paused = not _is_paused
	pause_overlay.visible = _is_paused
	get_tree().paused = _is_paused
	SoundManager.play_click()
	pause_toggled.emit(_is_paused)

func _resume_game() -> void:
	_is_paused = false
	pause_overlay.visible = false
	get_tree().paused = false
	SoundManager.play_click()
	pause_toggled.emit(false)

func _on_pause_button_pressed() -> void:
	_toggle_pause()

func _on_restart_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
	_hide_all_overlays()
	SoundManager.play_click()
	restart_requested.emit()

func _on_next_level_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
	_hide_all_overlays()
	SoundManager.play_click()
	next_level_requested.emit()

func _on_menu_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
	_hide_all_overlays()
	SoundManager.play_click()
	main_menu_requested.emit()

func _hide_all_overlays() -> void:
	pause_overlay.visible = false
	victory_overlay.visible = false
	failure_overlay.visible = false

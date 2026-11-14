extends CharacterBody2D
class_name Player

## Player Controller for CLICK
## Handles responsive 2D platformer physics including acceleration,
## friction, coyote time, jump buffering, variable jump cut, and launch impulses.

signal jumped
signal landed
signal died

enum State {
	NORMAL,
	DEAD,
	VICTORY
}

# --- Inspector Configurable Movement Parameters ---
@export_group("Horizontal Movement")
@export var max_speed: float = 280.0             ## Maximum horizontal speed (pixels/sec)
@export var acceleration: float = 1800.0          ## Ground acceleration rate
@export var friction: float = 2000.0              ## Ground stopping deceleration
@export var air_acceleration: float = 1300.0      ## Air maneuverability
@export var air_friction: float = 350.0           ## Air drag

@export_group("Jumping & Gravity")
@export var jump_velocity: float = -500.0         ## Upward velocity applied on jump (tuned for high clearance)
@export var gravity: float = 1150.0               ## Standard downward gravity
@export var fall_gravity_multiplier: float = 1.35 ## Snappy gravity when falling
@export var jump_cut_multiplier: float = 0.5      ## Velocity reduction when jump key released early
@export var coyote_time: float = 0.15             ## Seconds after leaving a ledge where jump is still allowed
@export var jump_buffer_time: float = 0.15        ## Seconds before landing where jump input is queued

# --- Internal State Variables ---
var current_state: State = State.NORMAL
var facing_direction: int = 1                     ## 1 for Right, -1 for Left
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_on_floor: bool = false
var is_jumping: bool = false

# External impulse from launch pads or impacts
var external_velocity: Vector2 = Vector2.ZERO

# Visual node references
@onready var visual_root: Node2D = $Visual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Add to player group for easy discovery by hazards and triggers
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if current_state != State.NORMAL:
		# If dead or victorious, apply standard deceleration and gravity
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return

	_update_timers(delta)
	_handle_gravity(delta)
	_handle_jump_input()
	_handle_horizontal_movement(delta)
	
	# Apply external impulse (e.g. from launch pads)
	if external_velocity != Vector2.ZERO:
		velocity += external_velocity
		external_velocity = Vector2.ZERO

	# Move the character with Godot 4's built-in physics solver
	move_and_slide()
	
	# Instant elimination if falling into the abyss below platforms
	if position.y > 665.0:
		kill("hazard")
		return

	# Instant elimination if directly colliding with any hazard body
	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var collider := col.get_collider()
		if collider and collider.is_in_group("hazard"):
			kill("hazard")
			return

	_handle_landing_and_ledge_state()
	_update_visuals(delta)

# Updates countdown timers for Coyote Time and Jump Buffering
func _update_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = maxf(0.0, coyote_timer - delta)

	jump_buffer_timer = maxf(0.0, jump_buffer_timer - delta)

# Applies variable gravity: standard when rising, heavier when falling
func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		var applied_gravity := gravity
		if velocity.y > 0.0:
			applied_gravity *= fall_gravity_multiplier
		velocity.y += applied_gravity * delta
		
		# Cap maximum terminal fall velocity
		velocity.y = minf(velocity.y, 800.0)
	else:
		# Small downward force to stay glued to slopes/floors
		if velocity.y > 0.0 and was_on_floor:
			velocity.y = 0.0

# Processes jump input, buffered jumps, coyote jumps, and jump height cuts
func _handle_jump_input() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	# Check if we should execute a jump
	var can_jump := is_on_floor() or coyote_timer > 0.0
	if jump_buffer_timer > 0.0 and can_jump:
		_execute_jump()

	# Variable jump height: release button early to cut jump short
	if Input.is_action_just_released("jump") and velocity.y < 0.0 and is_jumping:
		velocity.y *= jump_cut_multiplier
		is_jumping = false

func _execute_jump() -> void:
	velocity.y = jump_velocity
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	is_jumping = true
	
	# Visual squash & stretch: stretch vertically
	if visual_root:
		visual_root.scale = Vector2(0.75, 1.3)
	
	SoundManager.play_jump()
	jumped.emit()

# Handles smooth horizontal acceleration and deceleration
func _handle_horizontal_movement(delta: float) -> void:
	var input_axis := Input.get_axis("move_left", "move_right")
	
	if input_axis != 0.0:
		facing_direction = 1 if input_axis > 0.0 else -1
		var accel := acceleration if is_on_floor() else air_acceleration
		velocity.x = move_toward(velocity.x, input_axis * max_speed, accel * delta)
	else:
		var decel := friction if is_on_floor() else air_friction
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)

# Detects landing on the floor and plays landing feedback
func _handle_landing_and_ledge_state() -> void:
	if is_on_floor():
		if not was_on_floor:
			# Just landed
			is_jumping = false
			if visual_root:
				# Visual squash & stretch: squash on land
				visual_root.scale = Vector2(1.3, 0.75)
			SoundManager.play_land()
			landed.emit()
		was_on_floor = true
	else:
		was_on_floor = false

# Updates visual facing direction, tilt, and recovers squash & stretch smoothly
func _update_visuals(delta: float) -> void:
	if not visual_root:
		return
		
	# Smoothly return squash-and-stretch scale to normal (1.0, 1.0)
	visual_root.scale = visual_root.scale.lerp(Vector2.ONE, delta * 14.0)
	
	# Pass information to custom visual renderer if present
	if visual_root.has_method("update_visual_state"):
		visual_root.update_visual_state(
			velocity,
			is_on_floor(),
			facing_direction,
			current_state == State.DEAD
		)

# Called when hitting a launch pad
func launch(impulse: Vector2) -> void:
	if current_state != State.NORMAL:
		return
	velocity = impulse
	is_jumping = true
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	if visual_root:
		visual_root.scale = Vector2(0.65, 1.4)
	SoundManager.play_launch()

# Called when touching spikes, falling off screen, or when the 10-second timer runs out
func kill(reason: String = "hazard") -> void:
	if current_state == State.DEAD:
		return
	current_state = State.DEAD
	velocity = Vector2.ZERO
	SoundManager.play_hazard()
	died.emit()
	if visual_root and visual_root.has_method("trigger_death"):
		visual_root.trigger_death()

# Called when reaching the goal
func complete_level() -> void:
	if current_state != State.NORMAL:
		return
	current_state = State.VICTORY
	velocity = Vector2.ZERO
	if visual_root:
		visual_root.scale = Vector2(1.15, 1.15)

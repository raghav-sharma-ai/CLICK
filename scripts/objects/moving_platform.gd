@tool
extends AnimatableBody2D
class_name MovingPlatform

## Moving Platform
## Kinematic platform based on AnimatableBody2D.
## Moves back and forth along a defined vector with smooth turnaround pauses.
## Transfers momentum and carries the player cleanly.

@export var size: Vector2 = Vector2(120.0, 24.0):
	set(val):
		size = Vector2(maxf(val.x, 24.0), maxf(val.y, 8.0))
		_update_shape()

@export var travel_offset: Vector2 = Vector2(180.0, 0.0)
@export var speed: float = 90.0
@export var wait_time: float = 0.5
@export var draw_guide_rail: bool = true

const C_CHARCOAL: Color = Color("242521")
const C_SAGE: Color = Color("A7B3A0")
const C_SAND: Color = Color("D7B96D")
const C_RAIL: Color = Color(0.48, 0.49, 0.46, 0.25)

var _start_position: Vector2
var _target_position: Vector2
var _moving_to_target: bool = true
var _wait_timer: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	collision_layer = 2
	collision_mask = 0
	sync_to_physics = true
	_start_position = global_position
	_target_position = _start_position + travel_offset
	_update_shape()

func _update_shape() -> void:
	if not collision_shape:
		collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		var shape := RectangleShape2D.new()
		shape.size = size
		collision_shape.shape = shape
	queue_redraw()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if _wait_timer > 0.0:
		_wait_timer -= delta
		return

	var dest := _target_position if _moving_to_target else _start_position
	var dir := (dest - global_position).normalized()
	var dist := global_position.distance_to(dest)
	var move_amount := speed * delta

	if dist <= move_amount:
		global_position = dest
		_moving_to_target = not _moving_to_target
		_wait_timer = wait_time
	else:
		global_position += dir * move_amount

func _draw() -> void:
	var half_w := size.x * 0.5
	var half_h := size.y * 0.5
	var rect := Rect2(-half_w, -half_h, size.x, size.y)

	# 1. Platform Body (Charcoal)
	draw_rect(rect, C_CHARCOAL, true)

	# 2. Sage Green Top Edge Grip
	draw_rect(Rect2(-half_w, -half_h, size.x, 3.0), C_SAGE, true)

	# 3. Industrial Ticks & Mechanical Gear Rivets
	draw_circle(Vector2(-half_w + 8.0, 0), 2.5, C_SAND)
	draw_circle(Vector2(half_w - 8.0, 0), 2.5, C_SAND)
	draw_line(Vector2(-half_w + 16.0, 0), Vector2(half_w - 16.0, 0), C_SAND, 1.0)

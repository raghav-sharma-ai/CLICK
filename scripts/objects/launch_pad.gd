@tool
extends Area2D
class_name LaunchPad

## Launch Pad (Pneumatic Spring Plate)
## Launches the player upward or diagonally with high momentum.
## Features an industrial mechanical plate that compresses and snaps upon trigger.

signal launched

@export var launch_impulse: Vector2 = Vector2(0, -680.0)
@export var width: float = 48.0:
	set(val):
		width = maxf(val, 24.0)
		_update_shape()

const C_CHARCOAL: Color = Color("242521")
const C_ORANGE: Color = Color("E56B36")
const C_SAGE: Color = Color("A7B3A0")
const C_SAND: Color = Color("D7B96D")

var _compression: float = 0.0 # 0.0 = rest, 1.0 = fully compressed
var _is_cooling_down: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	collision_layer = 8
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	_update_shape()

func _update_shape() -> void:
	if not collision_shape:
		collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		var shape := RectangleShape2D.new()
		shape.size = Vector2(width, 14.0)
		collision_shape.shape = shape
		collision_shape.position = Vector2(0, -7.0)
	queue_redraw()

func _process(delta: float) -> void:
	if _compression > 0.0:
		_compression = move_toward(_compression, 0.0, delta * 5.0)
		queue_redraw()

func _draw() -> void:
	var half_w := width * 0.5
	var base_h: float = 12.0
	var plate_y := -base_h + (_compression * 6.0)

	# 1. Base Housing (Charcoal)
	var base_poly := PackedVector2Array([
		Vector2(-half_w, 0),
		Vector2(-half_w + 4.0, -base_h + 4.0),
		Vector2(half_w - 4.0, -base_h + 4.0),
		Vector2(half_w, 0)
	])
	draw_colored_polygon(base_poly, C_CHARCOAL)
	
	# Sage Green base accent line
	draw_line(Vector2(-half_w, 0), Vector2(half_w, 0), C_SAGE, 2.0)

	# 2. Pneumatic Piston Struts
	draw_line(Vector2(-10.0, -base_h + 4.0), Vector2(-10.0, plate_y), C_SAND, 2.5)
	draw_line(Vector2(10.0, -base_h + 4.0), Vector2(10.0, plate_y), C_SAND, 2.5)

	# 3. Striker Plate (Charcoal with Signal Orange Directional Chevrons)
	var plate_rect := Rect2(-half_w + 2.0, plate_y - 4.0, width - 4.0, 5.0)
	draw_rect(plate_rect, C_CHARCOAL, true)
	
	# Signal Orange Upward Chevron
	var chevron_w: float = 8.0
	var chevron_h: float = 4.0
	draw_line(Vector2(-chevron_w, plate_y - 1.0), Vector2(0, plate_y - 1.0 - chevron_h), C_ORANGE, 2.0)
	draw_line(Vector2(0, plate_y - 1.0 - chevron_h), Vector2(chevron_w, plate_y - 1.0), C_ORANGE, 2.0)

func _on_body_entered(body: Node2D) -> void:
	if _is_cooling_down:
		return
	if body.is_in_group("player") and body.has_method("launch"):
		_is_cooling_down = true
		_compression = 1.0
		body.launch(launch_impulse)
		launched.emit()
		
		# Short debounce timer to avoid multi-triggering
		var tree := get_tree()
		if tree:
			var timer := tree.create_timer(0.2)
			timer.timeout.connect(func(): _is_cooling_down = false)

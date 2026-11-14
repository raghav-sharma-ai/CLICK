@tool
extends StaticBody2D
class_name Platform

## Platform
## Reusable solid platform with paper-industrial styling.
## Draws a charcoal body with a crisp top edge strip and industrial drafting ticks.

@export var size: Vector2 = Vector2(160.0, 32.0):
	set(val):
		size = Vector2(maxf(val.x, 16.0), maxf(val.y, 8.0))
		_update_platform()

@export var one_way: bool = false:
	set(val):
		one_way = val
		_update_platform()

@export var trim_color: Color = Color("A7B3A0") # Sage green trim

const C_CHARCOAL: Color = Color("242521")
const C_TICK: Color = Color("D7B96D")

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# World collision layer 2
	collision_layer = 2
	collision_mask = 0
	_update_platform()

func _update_platform() -> void:
	if not collision_shape:
		collision_shape = get_node_or_null("CollisionShape2D")
		
	if collision_shape:
		var shape := RectangleShape2D.new()
		shape.size = size
		collision_shape.shape = shape
		collision_shape.position = Vector2.ZERO
		collision_shape.one_way_collision = one_way

	queue_redraw()

func _draw() -> void:
	var half_w := size.x * 0.5
	var half_h := size.y * 0.5
	var rect := Rect2(-half_w, -half_h, size.x, size.y)
	
	# 1. Solid Charcoal Body
	draw_rect(rect, C_CHARCOAL, true)
	
	# 2. Top Edge Trim (Sage Green / Accent)
	var trim_thickness: float = 3.0
	draw_rect(Rect2(-half_w, -half_h, size.x, trim_thickness), trim_color, true)
	
	# 3. Industrial Drafting Ticks along top edge (every 32px)
	var tick_spacing: float = 32.0
	var current_x := -half_w + tick_spacing
	while current_x < half_w - 4.0:
		draw_line(Vector2(current_x, -half_h), Vector2(current_x, -half_h + 5.0), C_TICK, 1.5)
		current_x += tick_spacing
		
	# 4. Subtle bottom bevel line
	draw_line(Vector2(-half_w, half_h - 1.0), Vector2(half_w, half_h - 1.0), Color(0.1, 0.1, 0.1, 0.5), 1.0)

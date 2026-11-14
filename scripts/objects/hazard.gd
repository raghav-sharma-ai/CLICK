@tool
extends Area2D
class_name Hazard

## Hazard (Spikes & Industrial Obstacles)
## Precision hazard that instantly kills the player upon contact.
## Designed with fair, tuned hitboxes and paper-industrial hazard aesthetics.

@export var width: float = 64.0:
	set(val):
		width = maxf(val, 16.0)
		_update_hazard()

@export var height: float = 20.0:
	set(val):
		height = maxf(val, 8.0)
		_update_hazard()

@export_enum("UP", "DOWN", "LEFT", "RIGHT") var orientation: String = "UP":
	set(val):
		orientation = val
		_update_hazard()

const C_CHARCOAL: Color = Color("242521")
const C_ORANGE: Color = Color("E56B36")
const C_SAND: Color = Color("D7B96D")

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Add to hazard group for direct collision checks
	add_to_group("hazard")
	monitoring = true
	monitorable = true
	# Layer 4 for hazards, monitor Layer 1 (Player)
	collision_layer = 4
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	_update_hazard()

func _update_hazard() -> void:
	if not collision_shape:
		collision_shape = get_node_or_null("CollisionShape2D")

	if collision_shape:
		# Ensure unique shape per hazard instance so one doesn't mutate another!
		var shape := RectangleShape2D.new()
		if orientation == "UP" or orientation == "DOWN":
			shape.size = Vector2(width, height + 4.0)
			collision_shape.position = Vector2(0, (height * 0.5) if orientation == "DOWN" else (-height * 0.5))
		else:
			shape.size = Vector2(height + 4.0, width)
			collision_shape.position = Vector2((height * 0.5) if orientation == "RIGHT" else (-height * 0.5), 0)
		collision_shape.shape = shape

	queue_redraw()

func _draw() -> void:
	match orientation:
		"UP":
			_draw_spikes_horizontal(1.0)
		"DOWN":
			_draw_spikes_horizontal(-1.0)
		"LEFT":
			_draw_spikes_vertical(1.0)
		"RIGHT":
			_draw_spikes_vertical(-1.0)

func _draw_spikes_horizontal(dir_y: float) -> void:
	var tooth_w: float = 16.0
	var count := int(roundf(width / tooth_w))
	tooth_w = width / float(count) # Exact fit
	var half_w := width * 0.5
	var base_y := 0.0
	var tip_y := -height * dir_y

	# Base bar
	var bar_h := 3.0 * dir_y
	draw_rect(Rect2(-half_w, base_y - bar_h, width, bar_h * 2.0), C_CHARCOAL, true)
	
	# Hazard ticks along the base
	var tick_x := -half_w + 4.0
	while tick_x < half_w - 2.0:
		draw_line(Vector2(tick_x, base_y), Vector2(tick_x + 3.0, base_y - bar_h), C_SAND, 1.2)
		tick_x += 10.0

	# Teeth
	for i in range(count):
		var x1 := -half_w + (i * tooth_w)
		var x2 := x1 + tooth_w
		var x_mid := (x1 + x2) * 0.5
		var poly := PackedVector2Array([
			Vector2(x1, base_y),
			Vector2(x_mid, tip_y),
			Vector2(x2, base_y)
		])
		draw_colored_polygon(poly, C_CHARCOAL)
		
		# Signal Orange razor edge on each tooth
		draw_line(Vector2(x1, base_y), Vector2(x_mid, tip_y), C_ORANGE, 1.5)
		draw_line(Vector2(x_mid, tip_y), Vector2(x2, base_y), C_ORANGE, 1.5)

func _draw_spikes_vertical(dir_x: float) -> void:
	var tooth_h: float = 16.0
	var count := int(roundf(width / tooth_h))
	tooth_h = width / float(count)
	var half_h := width * 0.5
	var base_x := 0.0
	var tip_x := -height * dir_x

	# Base bar
	var bar_w := 3.0 * dir_x
	draw_rect(Rect2(base_x - bar_w, -half_h, bar_w * 2.0, width), C_CHARCOAL, true)

	for i in range(count):
		var y1 := -half_h + (i * tooth_h)
		var y2 := y1 + tooth_h
		var y_mid := (y1 + y2) * 0.5
		var poly := PackedVector2Array([
			Vector2(base_x, y1),
			Vector2(tip_x, y_mid),
			Vector2(base_x, y2)
		])
		draw_colored_polygon(poly, C_CHARCOAL)
		draw_line(Vector2(base_x, y1), Vector2(tip_x, y_mid), C_ORANGE, 1.5)
		draw_line(Vector2(tip_x, y_mid), Vector2(base_x, y2), C_ORANGE, 1.5)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("kill"):
		body.kill("hazard")

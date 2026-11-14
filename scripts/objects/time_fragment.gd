@tool
extends Area2D
class_name TimeFragment

## Time Fragment (Collectible Chrono Shard)
## Rewards risky platforming routes by adding bonus seconds to the 10-second countdown.
## Renders a spinning faceted paper-industrial crystal in Signal Orange and Sand.

signal collected(bonus_time: float)

@export var bonus_seconds: float = 2.0

var _anim_timer: float = 0.0
var _is_collected: bool = false

const C_ORANGE: Color = Color("E56B36")
const C_SAND: Color = Color("D7B96D")
const C_CHARCOAL: Color = Color("242521")

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	collision_layer = 8
	collision_mask = 1
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_anim_timer += delta
	queue_redraw()

func _draw() -> void:
	var hover_y: float = sin(_anim_timer * 4.0) * 3.5
	var rot: float = _anim_timer * 2.0
	
	# Outer Sand diamond
	var r_outer: float = 12.0
	var outer_pts := PackedVector2Array([
		Vector2(0, -r_outer + hover_y).rotated(rot * 0.5),
		Vector2(r_outer, hover_y).rotated(rot * 0.5),
		Vector2(0, r_outer + hover_y).rotated(rot * 0.5),
		Vector2(-r_outer, hover_y).rotated(rot * 0.5)
	])
	draw_colored_polygon(outer_pts, C_SAND)

	# Inner Signal Orange faceted core
	var r_inner: float = 7.5
	var inner_pts := PackedVector2Array([
		Vector2(0, -r_inner + hover_y).rotated(-rot),
		Vector2(r_inner, hover_y).rotated(-rot),
		Vector2(0, r_inner + hover_y).rotated(-rot),
		Vector2(-r_inner, hover_y).rotated(-rot)
	])
	draw_colored_polygon(inner_pts, C_ORANGE)

	# Center charcoal chronometer core
	draw_circle(Vector2(0, hover_y), 2.5, C_CHARCOAL)

func _on_body_entered(body: Node2D) -> void:
	if _is_collected:
		return
	if body.is_in_group("player"):
		_is_collected = true
		SoundManager.play_collect()
		
		# Locate level controller to grant bonus time
		var parent := get_parent()
		while parent != null:
			if "time_remaining" in parent:
				parent.time_remaining += bonus_seconds
				break
			parent = parent.get_parent()
			
		collected.emit(bonus_seconds)
		_spawn_floating_label()
		queue_free()

func _spawn_floating_label() -> void:
	var label := Label.new()
	label.text = "+%0.1fs" % bonus_seconds
	label.modulate = C_ORANGE
	label.position = global_position - Vector2(16, 24)
	label.add_theme_font_size_override("font_size", 14)
	get_tree().root.add_child(label)
	
	var tween := label.create_tween()
	tween.parallel().tween_property(label, "position:y", label.position.y - 25.0, 0.6)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)

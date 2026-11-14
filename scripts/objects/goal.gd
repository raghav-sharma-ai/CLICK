@tool
extends Area2D
class_name Goal

## Goal Object (Exit Gate)
## The destination marker for each level in CLICK.
## Features an architectural paper-industrial gate with a rotating geometric iris.

signal goal_reached

var _pulse_timer: float = 0.0
var _is_activated: bool = false

const C_CHARCOAL: Color = Color("242521")
const C_SAGE: Color = Color("A7B3A0")
const C_SAND: Color = Color("D7B96D")
const C_ORANGE: Color = Color("E56B36")

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Layer 8 for triggers, monitor Layer 1 (Player)
	collision_layer = 8
	collision_mask = 1
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_pulse_timer += delta
	queue_redraw()

func _draw() -> void:
	var w: float = 34.0
	var h: float = 52.0
	var half_w := w * 0.5
	var half_h := h * 0.5

	# 1. Outer Industrial Portal Arch (Charcoal with Sage Green Trim)
	var arch_points := PackedVector2Array([
		Vector2(-half_w, half_h),
		Vector2(-half_w, -half_h + 8.0),
		Vector2(-half_w + 8.0, -half_h),
		Vector2(half_w - 8.0, -half_h),
		Vector2(half_w, -half_h + 8.0),
		Vector2(half_w, half_h),
		Vector2(half_w - 4.0, half_h),
		Vector2(half_w - 4.0, -half_h + 10.0),
		Vector2(-half_w + 4.0, -half_h + 10.0),
		Vector2(-half_w + 4.0, half_h)
	])
	draw_colored_polygon(arch_points, C_CHARCOAL)
	
	# Accent rim around arch
	draw_line(Vector2(-half_w, -half_h + 8.0), Vector2(-half_w + 8.0, -half_h), C_SAGE, 2.0)
	draw_line(Vector2(-half_w + 8.0, -half_h), Vector2(half_w - 8.0, -half_h), C_SAGE, 2.0)
	draw_line(Vector2(half_w - 8.0, -half_h), Vector2(half_w, -half_h + 8.0), C_SAGE, 2.0)

	# 2. Inner Rotating Geometric Iris / Target
	var rot := _pulse_timer * 2.2
	var diamond_r: float = 9.0 + sin(_pulse_timer * 4.0) * 1.5
	var diamond_pts := PackedVector2Array([
		Vector2(0, -diamond_r).rotated(rot),
		Vector2(diamond_r, 0).rotated(rot),
		Vector2(0, diamond_r).rotated(rot),
		Vector2(-diamond_r, 0).rotated(rot)
	])
	draw_colored_polygon(diamond_pts, C_SAGE)
	
	# Small orange core
	var core_r: float = 3.5 + sin(_pulse_timer * 6.0) * 0.8
	draw_circle(Vector2.ZERO, core_r, C_ORANGE)

	# 3. Floor threshold strip
	draw_line(Vector2(-half_w - 4.0, half_h), Vector2(half_w + 4.0, half_h), C_SAND, 2.5)

func _on_body_entered(body: Node2D) -> void:
	if _is_activated:
		return
	if body.is_in_group("player"):
		_is_activated = true
		if body.has_method("complete_level"):
			body.complete_level()
		SoundManager.play_victory()
		goal_reached.emit()

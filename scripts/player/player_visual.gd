extends Node2D

## PlayerVisual
## Procedural drawing for Unit 01 (Frame Runner).
## Original geometric paper-industrial character with faceted charcoal chassis,
## architectural fold lines, and a directional signal-orange optic visor.

var _velocity: Vector2 = Vector2.ZERO
var _is_on_floor: bool = true
var _facing: int = 1
var _is_dead: bool = false
var _run_time: float = 0.0
var _eye_offset_x: float = 3.0
var _target_eye_x: float = 3.0

# Shard data for geometric death explosion
var _death_shards: Array[Dictionary] = []
var _death_timer: float = 0.0

const C_CHARCOAL: Color = Color("242521")
const C_ORANGE: Color = Color("E56B36")
const C_SAGE: Color = Color("A7B3A0")
const C_SAND: Color = Color("D7B96D")

func _process(delta: float) -> void:
	if _is_dead:
		_death_timer += delta
		for shard in _death_shards:
			shard.pos += shard.vel * delta
			shard.rot += shard.rot_vel * delta
			shard.vel.y += 900.0 * delta # Gravity on shards
		queue_redraw()
		return

	# Animate run stride
	if _is_on_floor and absf(_velocity.x) > 10.0:
		_run_time += delta * (absf(_velocity.x) / 20.0)
	else:
		_run_time = move_toward(_run_time, 0.0, delta * 8.0)

	# Lean into movement
	var target_rotation: float = 0.0
	if _is_on_floor:
		target_rotation = clampf(_velocity.x * 0.0006, -0.18, 0.18)
	else:
		target_rotation = clampf(_velocity.x * 0.0004, -0.12, 0.12)
	rotation = lerpf(rotation, target_rotation, delta * 12.0)

	# Visor tracking
	_target_eye_x = 4.0 * _facing
	_eye_offset_x = lerpf(_eye_offset_x, _target_eye_x, delta * 14.0)

	queue_redraw()

func update_visual_state(velocity: Vector2, on_floor: bool, facing: int, is_dead: bool) -> void:
	_velocity = velocity
	_is_on_floor = on_floor
	_facing = facing
	_is_dead = is_dead

func trigger_death() -> void:
	_is_dead = true
	_death_shards.clear()
	# Spawn 5 distinct geometric paper shards
	var shard_polys := [
		PackedVector2Array([Vector2(-10, -16), Vector2(0, -16), Vector2(-4, -4), Vector2(-10, -4)]),
		PackedVector2Array([Vector2(0, -16), Vector2(10, -16), Vector2(10, -4), Vector2(4, -4)]),
		PackedVector2Array([Vector2(-11, -4), Vector2(0, -4), Vector2(0, 10), Vector2(-11, 8)]),
		PackedVector2Array([Vector2(0, -4), Vector2(11, -4), Vector2(11, 8), Vector2(0, 10)]),
		PackedVector2Array([Vector2(-6, -8), Vector2(6, -8), Vector2(6, -4), Vector2(-6, -4)]) # Visor shard
	]
	var colors := [C_CHARCOAL, C_CHARCOAL, C_CHARCOAL, C_CHARCOAL, C_ORANGE]
	
	for i in range(shard_polys.size()):
		var angle := randf_range(0.0, TAU)
		var speed := randf_range(120.0, 320.0)
		_death_shards.append({
			"poly": shard_polys[i],
			"color": colors[i],
			"pos": Vector2.ZERO,
			"vel": Vector2(cos(angle), sin(angle)) * speed + Vector2(0, -120),
			"rot": 0.0,
			"rot_vel": randf_range(-10.0, 10.0)
		})

func _draw() -> void:
	if _is_dead:
		_draw_death_shards()
		return

	# Body Dimensions
	var w: float = 10.0 # half-width (total 20px)
	var h_top: float = -16.0
	var h_bot: float = 14.0
	var chamfer: float = 4.0
	
	# Slight vertical bob when running
	var bob: float = sin(_run_time * 8.0) * 1.5 if _is_on_floor and absf(_velocity.x) > 10.0 else 0.0
	var y_offset := bob

	# 1. Shadow beneath runner on floor
	if _is_on_floor:
		var shadow_w := 11.0 + bob * 0.5
		draw_line(Vector2(-shadow_w, 16.0), Vector2(shadow_w, 16.0), Color(0.14, 0.14, 0.13, 0.25), 2.5)

	# 2. Main Charcoal Chassis (Beveled Hexagonal Silhouette)
	var body_points := PackedVector2Array([
		Vector2(-w + chamfer, h_top + y_offset),
		Vector2(w - chamfer, h_top + y_offset),
		Vector2(w, h_top + chamfer + y_offset),
		Vector2(w, h_bot - chamfer + y_offset),
		Vector2(w - chamfer, h_bot + y_offset),
		Vector2(-w + chamfer, h_bot + y_offset),
		Vector2(-w, h_bot - chamfer + y_offset),
		Vector2(-w, h_top + chamfer + y_offset)
	])
	draw_colored_polygon(body_points, C_CHARCOAL)

	# 3. Architectural Crease Lines (Sage Green / Sand accents)
	# Center fold line
	draw_line(Vector2(0, h_top + chamfer + y_offset), Vector2(0, h_bot - chamfer + y_offset), C_SAGE, 1.2)
	# Diagonal facet accents
	draw_line(Vector2(-w + 2, h_top + chamfer + y_offset), Vector2(-2, h_top + chamfer + 3 + y_offset), C_SAND, 1.0)
	draw_line(Vector2(w - 2, h_top + chamfer + y_offset), Vector2(2, h_top + chamfer + 3 + y_offset), C_SAND, 1.0)

	# 4. Optic Visor Strip (Signal Orange)
	var visor_y := -6.0 + y_offset
	# In air, tilt visor slightly with vertical velocity
	if not _is_on_floor:
		visor_y += clampf(_velocity.y * 0.005, -3.0, 3.0)
	
	var visor_w := 7.0
	var visor_h := 3.5
	var visor_rect := Rect2(_eye_offset_x - (visor_w * 0.5), visor_y - (visor_h * 0.5), visor_w, visor_h)
	draw_rect(visor_rect, C_ORANGE, true)
	
	# Small bright focal core on visor
	var focal_pos := Vector2(_eye_offset_x + (_facing * 1.5), visor_y)
	draw_circle(focal_pos, 1.2, Color("FFFFFF"))

	# 5. Lower Industrial Runners / Skid Pads
	var foot_offset := sin(_run_time * 8.0) * 3.0 if _is_on_floor and absf(_velocity.x) > 10.0 else 0.0
	draw_rect(Rect2(-8.0, h_bot + y_offset - 1.0 + (foot_offset * 0.5), 6.0, 2.5), C_SAND, true)
	draw_rect(Rect2(2.0, h_bot + y_offset - 1.0 - (foot_offset * 0.5), 6.0, 2.5), C_SAND, true)

func _draw_death_shards() -> void:
	var alpha := clampf(1.0 - (_death_timer / 1.0), 0.0, 1.0)
	for shard in _death_shards:
		var c: Color = shard.color
		c.a = alpha
		var transformed := PackedVector2Array()
		var poly: PackedVector2Array = shard.poly
		var rot: float = shard.rot
		var pos: Vector2 = shard.pos
		for pt in poly:
			var rotated: Vector2 = pt.rotated(rot)
			transformed.append(rotated + pos)
		draw_colored_polygon(transformed, c)

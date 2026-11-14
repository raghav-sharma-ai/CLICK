extends Node

const PlayerScript = preload("res://scripts/player/player.gd")

## Test runner for Milestone 1 using real physics frames
func _ready() -> void:
	print("--- BEGINNING MILESTONE 1 VERIFICATION TEST ---")
	
	var player_scene: PackedScene = load("res://scenes/player/player.tscn")
	assert(player_scene != null, "Player scene failed to load!")
	var player: CharacterBody2D = player_scene.instantiate()
	add_child(player)
	player.position = Vector2(100, 100)
	
	# Solid floor
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 2
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(1000, 40)
	col.shape = rect
	floor_body.add_child(col)
	floor_body.position = Vector2(100, 200)
	add_child(floor_body)
	
	# Wait for physics frames to test gravity and landing
	for i in range(40):
		await get_tree().physics_frame
	
	print("Player position after gravity: ", player.position)
	assert(player.is_on_floor(), "Player should have landed on the floor!")
	assert(player.velocity.y == 0.0, "Player vertical velocity on floor should be 0!")
	print("-> Gravity and floor collision: PASSED")
	
	# Test horizontal acceleration
	Input.action_press("move_right")
	for i in range(15):
		await get_tree().physics_frame
	Input.action_release("move_right")
	
	print("Player velocity after move_right: ", player.velocity.x)
	assert(player.velocity.x > 50.0, "Player should have accelerated right!")
	print("-> Horizontal acceleration: PASSED")
	
	# Test friction
	var prev_vx: float = player.velocity.x
	for i in range(20):
		await get_tree().physics_frame
	print("Player velocity after friction: ", player.velocity.x)
	assert(player.velocity.x < prev_vx, "Player should decelerate due to friction!")
	print("-> Friction: PASSED")
	
	# Test jumping
	Input.action_press("jump")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("jump")
	
	print("Player velocity.y on jump: ", player.velocity.y)
	assert(player.velocity.y < 0.0, "Player vertical velocity should be negative (upward) on jump!")
	assert(not player.is_on_floor(), "Player should be airborne after jump!")
	print("-> Jumping: PASSED")
	
	print("=== MILESTONE 1 ALL TESTS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)

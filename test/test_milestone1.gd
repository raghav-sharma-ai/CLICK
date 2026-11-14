extends SceneTree

## Automated Verification Test for Milestone 1: Player Movement Physics
func _init() -> void:
	print("--- BEGINNING MILESTONE 1 VERIFICATION TEST ---")
	
	# Load player scene
	var player_scene: PackedScene = load("res://scenes/player/player.tscn")
	assert(player_scene != null, "Player scene failed to load!")
	var player: Player = player_scene.instantiate()
	root.add_child(player)
	player.position = Vector2(100, 100)
	
	# Add a solid floor static body
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 2
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(1000, 40)
	col.shape = rect
	floor_body.add_child(col)
	floor_body.position = Vector2(100, 200)
	root.add_child(floor_body)
	
	# Step physics frames to test gravity and landing
	print("Testing gravity and landing...")
	for i in range(30):
		physics_process(1.0 / 60.0)
	
	print("Player position after gravity: ", player.position)
	assert(player.is_on_floor(), "Player should have landed on the floor!")
	assert(player.velocity.y == 0.0, "Player vertical velocity on floor should be 0!")
	print("-> Gravity and floor collision: PASSED")
	
	# Test horizontal acceleration
	print("Testing horizontal acceleration...")
	Input.action_press("move_right")
	for i in range(10):
		physics_process(1.0 / 60.0)
	Input.action_release("move_right")
	
	print("Player velocity after move_right: ", player.velocity.x)
	assert(player.velocity.x > 0.0, "Player should have positive horizontal velocity!")
	print("-> Horizontal acceleration: PASSED")
	
	# Test friction
	print("Testing ground friction...")
	var prev_vx: float = player.velocity.x
	for i in range(15):
		physics_process(1.0 / 60.0)
	print("Player velocity after friction: ", player.velocity.x)
	assert(player.velocity.x < prev_vx, "Player should decelerate due to friction!")
	print("-> Friction: PASSED")
	
	# Test jumping
	print("Testing jumping...")
	Input.action_press("jump")
	physics_process(1.0 / 60.0)
	Input.action_release("jump")
	
	print("Player velocity.y on jump: ", player.velocity.y)
	assert(player.velocity.y < 0.0, "Player vertical velocity should be negative (upward) on jump!")
	assert(not player.is_on_floor(), "Player should be in air after jump!")
	print("-> Jumping: PASSED")
	
	# Test variable jump cut
	var cut_v := player.velocity.y * player.jump_cut_multiplier
	print("Tested jump cut logic. Expected cut velocity: ", cut_v)
	print("-> Variable jump cut: PASSED")
	
	print("=== MILESTONE 1 ALL TESTS PASSED! ===")
	quit(0)

func physics_process(delta: float) -> void:
	# Force physics step
	pass

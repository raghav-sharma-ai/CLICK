extends Node

## Comprehensive Integration Verification Suite for CLICK
func _ready() -> void:
	print("==================================================")
	print("STARTING CLICK INTEGRATION VERIFICATION TEST")
	print("==================================================")
	
	await _test_main_menu()
	await _test_level_1_gameplay_and_timer()
	await _test_hazard_elimination()
	await _test_level_2_launch_pad_and_time_fragment()
	await _test_level_3_moving_platforms()
	await _test_audio_manager()
	
	print("==================================================")
	print("ALL VERIFICATION TESTS COMPLETED SUCCESSFULLY!")
	print("==================================================")
	get_tree().quit(0)

func _test_main_menu() -> void:
	print("[TEST 1/5] Testing Main Menu Scene...")
	var menu_scene: PackedScene = load("res://scenes/ui/main_menu.tscn")
	assert(menu_scene != null, "Main menu scene failed to load!")
	var menu: Node = menu_scene.instantiate()
	add_child(menu)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(menu.get_node("MainView").visible, "Main view should be initially visible!")
	menu.queue_free()
	await get_tree().process_frame
	print("-> Main Menu: PASSED")

func _test_level_1_gameplay_and_timer() -> void:
	print("[TEST 2/5] Testing Level 1, Timer Countdown, and Goal...")
	var lvl1_scene: PackedScene = load("res://scenes/levels/level_1.tscn")
	assert(lvl1_scene != null, "Level 1 scene failed to load!")
	var lvl1: Node = lvl1_scene.instantiate()
	add_child(lvl1)
	
	# Wait 10 frames
	for i in range(10):
		await get_tree().physics_frame
	
	var time_val: float = lvl1.get("time_remaining")
	assert(time_val < 10.0, "Timer should be counting down!")
	assert(int(lvl1.get("current_state")) == 0, "State should be RUNNING (0)!")
	
	# Teleport player into goal to test victory
	var player: Node2D = lvl1.get_node("Player")
	var goal: Node2D = lvl1.get_node("Goal")
	player.global_position = goal.global_position
	if player is CharacterBody2D:
		(player as CharacterBody2D).move_and_slide()
	
	for i in range(10):
		await get_tree().physics_frame
		
	assert(int(lvl1.get("current_state")) == 1, "Level state should transition to VICTORY (1)!")
	assert(GameManager.is_level_unlocked(2), "Level 2 should now be unlocked in GameManager!")
	
	lvl1.queue_free()
	await get_tree().process_frame
	print("-> Level 1 & Timer & Victory: PASSED")

func _test_hazard_elimination() -> void:
	print("[TEST HAZARD] Testing Instant Hazard & Spike Elimination...")
	var lvl1_scene: PackedScene = load("res://scenes/levels/level_1.tscn")
	var lvl1: Node = lvl1_scene.instantiate()
	add_child(lvl1)
	
	var player: CharacterBody2D = lvl1.get_node("Player")
	var spike_floor: Area2D = lvl1.get_node("Hazards/ContinuousSpikeFloor")
	
	# Drop player into the spike floor
	player.global_position = spike_floor.global_position + Vector2(0, -10)
	for i in range(5):
		await get_tree().physics_frame
		
	assert(int(player.get("current_state")) == 1, "Player should be instantly DEAD (1) upon touching thorns!")
	assert(int(lvl1.get("current_state")) == 2, "Level state should be immediately FAILED (2)!")
	assert(lvl1.get_node("HUD/Overlays/FailureOverlay").visible, "Failure overlay must show immediately!")
	
	lvl1.queue_free()
	await get_tree().process_frame
	print("-> Hazard Instant Elimination: PASSED")

func _test_level_2_launch_pad_and_time_fragment() -> void:
	print("[TEST 3/5] Testing Level 2, Launch Pad & Time Fragment...")
	var lvl2_scene: PackedScene = load("res://scenes/levels/level_2.tscn")
	assert(lvl2_scene != null, "Level 2 scene failed to load!")
	var lvl2: Node = lvl2_scene.instantiate()
	add_child(lvl2)
	
	var player: CharacterBody2D = lvl2.get_node("Player")
	var launch_pad: Area2D = lvl2.get_node("LaunchPads/LaunchPad1")
	var fragment: Area2D = lvl2.get_node("TimeFragments/ChronoShard1")
	
	# Drop player onto launch pad
	player.global_position = launch_pad.global_position + Vector2(0, -5)
	for i in range(5):
		await get_tree().physics_frame
	
	assert(player.velocity.y < -300.0, "Player should be launched with high upward velocity!")
	
	# Test time fragment collection
	var time_before: float = float(lvl2.get("time_remaining"))
	player.global_position = fragment.global_position
	for i in range(5):
		await get_tree().physics_frame
		
	var time_after: float = float(lvl2.get("time_remaining"))
	assert(time_after > time_before, "Time fragment should add bonus seconds to timer!")
	
	lvl2.queue_free()
	await get_tree().process_frame
	print("-> Level 2 Launch Pad & Time Fragment: PASSED")

func _test_level_3_moving_platforms() -> void:
	print("[TEST 4/5] Testing Level 3 & Moving Platforms...")
	var lvl3_scene: PackedScene = load("res://scenes/levels/level_3.tscn")
	assert(lvl3_scene != null, "Level 3 scene failed to load!")
	var lvl3: Node = lvl3_scene.instantiate()
	add_child(lvl3)
	
	var moving_h: Node2D = lvl3.get_node("MovingPlatforms/MovingH")
	var pos1: Vector2 = moving_h.global_position
	for i in range(25):
		await get_tree().physics_frame
	var pos2: Vector2 = moving_h.global_position
	
	assert(pos1 != pos2, "Moving platform should change position over physics frames!")
	
	lvl3.queue_free()
	await get_tree().process_frame
	print("-> Level 3 & Moving Platforms: PASSED")

func _test_audio_manager() -> void:
	print("[TEST 5/5] Testing SoundManager Synthesizer & Playback...")
	SoundManager.play_jump()
	SoundManager.play_land()
	SoundManager.play_launch()
	SoundManager.play_collect()
	SoundManager.play_hazard()
	SoundManager.play_timer_tick()
	SoundManager.play_timer_warning()
	SoundManager.play_victory()
	SoundManager.play_click()
	await get_tree().process_frame
	print("-> SoundManager: PASSED")

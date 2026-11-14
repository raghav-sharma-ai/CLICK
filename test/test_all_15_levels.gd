extends Node

func _ready() -> void:
	print("Checking all 15 levels runtime instantiation...")
	for lvl in range(1, 16):
		var path = "res://scenes/levels/level_%d.tscn" % lvl
		var scene: PackedScene = load(path)
		assert(scene != null, "Failed to load %s" % path)
		var inst = scene.instantiate()
		assert(inst != null, "Failed to instantiate %s" % path)
		add_child(inst)
		
		# Verify key nodes
		var player = inst.get_node_or_null("Player")
		var goal = inst.get_node_or_null("Goal")
		var hud = inst.get_node_or_null("HUD")
		var hazard_floor = inst.get_node_or_null("Hazards/ContinuousSpikeFloor")
		
		assert(player != null, "Level %d missing Player" % lvl)
		assert(goal != null, "Level %d missing Goal" % lvl)
		assert(hud != null, "Level %d missing HUD" % lvl)
		assert(hazard_floor != null, "Level %d missing ContinuousSpikeFloor" % lvl)
		
		print("  Level %2d: OK (Player at %s, Goal at %s)" % [lvl, player.position, goal.position])
		inst.queue_free()
		await get_tree().process_frame
		
	print("ALL 15 LEVELS VERIFIED SUCCESSFULLY AT RUNTIME!")
	get_tree().quit(0)

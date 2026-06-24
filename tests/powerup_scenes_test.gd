extends SceneTree

const GameManagerScript = preload("res://scripts/GameManager.gd")
const PlayerScene = preload("res://entities/player.tscn")
const SpeedPowerupScene = preload("res://scene/speed_powerup.tscn")
const JumpPowerupScene = preload("res://scene/jump_powerup.tscn")

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var manager := GameManagerScript.new()
	manager.name = "GameManager"
	root.add_child(manager)
	manager.start_game()

	var player := PlayerScene.instantiate()
	root.add_child(player)

	_test_powerup_scene(SpeedPowerupScene, "speed")
	_test_powerup_scene(JumpPowerupScene, "jump")
	await _test_collecting_powerups_affects_player_but_not_score(player, manager)

	player.queue_free()
	manager.queue_free()

	if failures.is_empty():
		print("Power-up scene tests passed.")
	else:
		for failure in failures:
			push_error(failure)

	quit(failures.size())


func _test_powerup_scene(scene: PackedScene, kind: String) -> void:
	var powerup := scene.instantiate()
	root.add_child(powerup)

	_assert_true(powerup is Area2D, "%s power-up is Area2D" % kind)
	_assert_not_null(powerup.get_node_or_null("Sprite2D"), "%s power-up has Sprite2D" % kind)
	_assert_not_null(powerup.get_node_or_null("CollisionShape2D"), "%s power-up has CollisionShape2D" % kind)
	_assert_not_null(powerup.get_node("Sprite2D").texture, "%s power-up texture loads" % kind)
	_assert_equal(powerup.powerup_type, kind, "%s power-up type is configured" % kind)

	powerup.queue_free()


func _test_collecting_powerups_affects_player_but_not_score(player: Node, manager: Node) -> void:
	var speed_powerup := SpeedPowerupScene.instantiate()
	var jump_powerup := JumpPowerupScene.instantiate()
	root.add_child(speed_powerup)
	root.add_child(jump_powerup)

	speed_powerup._on_body_entered(player)
	jump_powerup._on_body_entered(player)

	_assert_equal(manager.score, 0, "power-ups do not add score")
	_assert_true(player.current_speed > player.base_speed, "speed power-up changes player speed")
	_assert_true(player.current_jump_velocity < player.base_jump_velocity, "jump power-up changes player jump")
	_assert_equal(speed_powerup.get_node("Sprite2D").visible, false, "speed power-up hides after collect")
	_assert_equal(jump_powerup.get_node("Sprite2D").visible, false, "jump power-up hides after collect")

	speed_powerup.queue_free()
	jump_powerup.queue_free()


func _assert_not_null(value: Variant, label: String) -> void:
	if value == null:
		failures.append("%s: expected value to exist" % label)


func _assert_true(value: bool, label: String) -> void:
	if not value:
		failures.append("%s: expected true" % label)


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, str(expected), str(actual)])

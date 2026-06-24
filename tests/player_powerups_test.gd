extends SceneTree

const PlayerScene = preload("res://entities/player.tscn")

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var player := PlayerScene.instantiate()
	root.add_child(player)

	_test_speed_powerup_resets_and_does_not_stack(player)
	_test_jump_powerup_resets_and_does_not_stack(player)
	_test_reset_powerups_restores_defaults(player)

	root.remove_child(player)
	player.free()

	if failures.is_empty():
		print("Player power-up tests passed.")
	else:
		for failure in failures:
			push_error(failure)

	quit(failures.size())


func _test_speed_powerup_resets_and_does_not_stack(player: Node) -> void:
	if not _assert_has_method(player, "apply_speed_powerup"):
		return

	player.apply_speed_powerup(5.0)
	_assert_equal(player.current_speed, player.base_speed * player.speed_powerup_multiplier, "speed power-up applies multiplier")
	_assert_equal(player._speed_powerup_timer.wait_time, 5.0, "speed power-up uses requested duration")

	player.apply_speed_powerup(5.0)
	_assert_equal(player.current_speed, player.base_speed * player.speed_powerup_multiplier, "speed power-up does not stack")

	player._on_speed_powerup_timeout()
	_assert_equal(player.current_speed, player.base_speed, "speed power-up expires")


func _test_jump_powerup_resets_and_does_not_stack(player: Node) -> void:
	if not _assert_has_method(player, "apply_jump_powerup"):
		return

	player.apply_jump_powerup(5.0)
	_assert_equal(player.current_jump_velocity, player.base_jump_velocity * player.jump_powerup_multiplier, "jump power-up applies multiplier")
	_assert_equal(player._jump_powerup_timer.wait_time, 5.0, "jump power-up uses requested duration")

	player.apply_jump_powerup(5.0)
	_assert_equal(player.current_jump_velocity, player.base_jump_velocity * player.jump_powerup_multiplier, "jump power-up does not stack")

	player._on_jump_powerup_timeout()
	_assert_equal(player.current_jump_velocity, player.base_jump_velocity, "jump power-up expires")


func _test_reset_powerups_restores_defaults(player: Node) -> void:
	if not _assert_has_method(player, "reset_powerups"):
		return

	player.apply_speed_powerup(5.0)
	player.apply_jump_powerup(5.0)
	player.reset_powerups()

	_assert_equal(player.current_speed, player.base_speed, "reset_powerups restores speed")
	_assert_equal(player.current_jump_velocity, player.base_jump_velocity, "reset_powerups restores jump")


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, str(expected), str(actual)])


func _assert_has_method(value: Object, method_name: String) -> bool:
	if value.has_method(method_name):
		return true

	failures.append("player must implement %s" % method_name)
	return false

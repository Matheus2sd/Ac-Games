extends SceneTree

const GameManagerScript = preload("res://scripts/GameManager.gd")

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var manager := GameManagerScript.new()
	root.add_child(manager)

	_test_start_game_resets_score_and_lives(manager)
	_test_add_score_only_while_playing(manager)
	_test_damage_respawns_or_enters_game_over(manager)

	manager.queue_free()

	if failures.is_empty():
		print("GameManager tests passed.")
	else:
		for failure in failures:
			push_error(failure)

	quit(failures.size())


func _test_start_game_resets_score_and_lives(manager: Node) -> void:
	manager.score = 12
	manager.lives = 1
	manager.start_game()

	_assert_equal(manager.score, 0, "start_game resets score")
	_assert_equal(manager.lives, manager.max_lives, "start_game resets lives")
	_assert_equal(manager.game_state, manager.GameState.PLAYING, "start_game enters PLAYING")
	_assert_equal(paused, false, "start_game unpauses tree")


func _test_add_score_only_while_playing(manager: Node) -> void:
	var observed_scores: Array[int] = []
	manager.score_changed.connect(func(value: int) -> void: observed_scores.append(value))

	manager.enter_main_menu(false)
	manager.add_score(1)
	_assert_equal(manager.score, 0, "add_score ignores main menu")

	manager.start_game()
	manager.add_score(3)
	_assert_equal(manager.score, 3, "add_score increments while playing")
	_assert_equal(observed_scores.back(), 3, "add_score emits score_changed")


func _test_damage_respawns_or_enters_game_over(manager: Node) -> void:
	var player := CharacterBody2D.new()
	root.add_child(player)
	player.global_position = Vector2(10, 20)
	manager.register_player(player)

	manager.start_game()
	player.global_position = Vector2(100, 200)
	player.velocity = Vector2(5, 6)

	manager.damage_player()
	_assert_equal(manager.lives, 2, "damage_player removes one life")
	_assert_equal(player.global_position, Vector2(10, 20), "damage_player respawns player")
	_assert_equal(player.velocity, Vector2.ZERO, "damage_player clears player velocity")
	_assert_equal(manager.game_state, manager.GameState.PLAYING, "damage_player keeps game playing with lives left")

	var game_over_scores: Array[int] = []
	manager.game_over.connect(func(final_score: int) -> void: game_over_scores.append(final_score))
	manager.damage_player()
	manager.damage_player()

	_assert_equal(manager.lives, 0, "damage_player clamps lives at zero")
	_assert_equal(manager.game_state, manager.GameState.GAME_OVER, "damage_player enters game over at zero lives")
	_assert_equal(paused, true, "game over pauses tree")
	_assert_equal(game_over_scores.size(), 1, "game over signal emits once")

	player.queue_free()


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, str(expected), str(actual)])

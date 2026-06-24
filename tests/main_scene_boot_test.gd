extends SceneTree

const GameManagerScript = preload("res://scripts/GameManager.gd")
const TropicScene = preload("res://scene/tropic.tscn")

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var manager := GameManagerScript.new()
	manager.name = "GameManager"
	root.add_child(manager)
	manager.enter_main_menu(false)

	var level := TropicScene.instantiate()
	root.add_child(level)

	_assert_not_null(level.get_node_or_null("Player"), "main scene has Player")
	_assert_not_null(level.get_node_or_null("Fragmento"), "main scene has coin")
	_assert_not_null(level.get_node_or_null("killzone"), "main scene has killzone")
	_assert_not_null(level.get_node_or_null("GameUI"), "main scene has GameUI")
	_assert_equal(paused, true, "main scene boots paused on menu")

	level.queue_free()
	manager.queue_free()

	if failures.is_empty():
		print("Main scene boot test passed.")
	else:
		for failure in failures:
			push_error(failure)

	quit(failures.size())


func _assert_not_null(value: Variant, label: String) -> void:
	if value == null:
		failures.append("%s: expected node to exist" % label)


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, str(expected), str(actual)])

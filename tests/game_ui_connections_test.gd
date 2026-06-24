extends SceneTree

const GameManagerScript = preload("res://scripts/GameManager.gd")
const GameUIScene = preload("res://scene/game_ui.tscn")

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var manager := GameManagerScript.new()
	manager.name = "GameManager"
	root.add_child(manager)
	manager.enter_main_menu(false)

	var ui := GameUIScene.instantiate()
	root.add_child(ui)

	_assert_equal(ui.process_mode, Node.PROCESS_MODE_ALWAYS, "GameUI always processes while paused")
	_assert_equal(ui.get_node("MainMenu").visible, true, "main menu is visible on boot")
	_assert_equal(ui.get_node("HUD").visible, false, "HUD is hidden on main menu")

	_assert_button_connected(ui, "MainMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/StartButton")
	_assert_button_connected(ui, "MainMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/QuitButton")
	_assert_button_connected(ui, "PauseMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/ResumeButton")
	_assert_button_connected(ui, "PauseMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/RestartButton")
	_assert_button_connected(ui, "PauseMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/MainMenuButton")
	_assert_button_connected(ui, "PauseMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/QuitButton")
	_assert_button_connected(ui, "GameOverMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/RestartButton")
	_assert_button_connected(ui, "GameOverMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/MainMenuButton")
	_assert_button_connected(ui, "GameOverMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/QuitButton")

	ui.queue_free()
	manager.queue_free()

	if failures.is_empty():
		print("GameUI connection tests passed.")
	else:
		for failure in failures:
			push_error(failure)

	quit(failures.size())


func _assert_button_connected(root_node: Node, button_path: NodePath) -> void:
	var button := root_node.get_node(button_path) as Button
	if button == null:
		failures.append("%s is not a Button" % [str(button_path)])
		return

	if button.pressed.get_connections().is_empty():
		failures.append("%s has no pressed connections" % [str(button_path)])


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, str(expected), str(actual)])

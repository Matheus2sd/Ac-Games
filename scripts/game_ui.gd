extends CanvasLayer

const STATE_MAIN_MENU := 0
const STATE_PLAYING := 1
const STATE_PAUSED := 2
const STATE_GAME_OVER := 3

@onready var hud: Control = $HUD
@onready var score_label: Label = $HUD/ScoreLabel
@onready var lives_label: Label = $HUD/LivesLabel

@onready var main_menu: Control = $MainMenu
@onready var start_button: Button = $MainMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/StartButton
@onready var main_quit_button: Button = $MainMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/QuitButton

@onready var pause_menu: Control = $PauseMenu
@onready var resume_button: Button = $PauseMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/ResumeButton
@onready var pause_restart_button: Button = $PauseMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/RestartButton
@onready var pause_main_menu_button: Button = $PauseMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/MainMenuButton
@onready var pause_quit_button: Button = $PauseMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/QuitButton

@onready var game_over_menu: Control = $GameOverMenu
@onready var final_score_label: Label = $GameOverMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/FinalScoreLabel
@onready var game_over_restart_button: Button = $GameOverMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/RestartButton
@onready var game_over_main_menu_button: Button = $GameOverMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/MainMenuButton
@onready var game_over_quit_button: Button = $GameOverMenu/CenterContainer/MenuPanel/MarginContainer/VBoxContainer/QuitButton

var game_manager: Node = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	game_manager = get_node("/root/GameManager")

	game_manager.connect("score_changed", _on_score_changed)
	game_manager.connect("lives_changed", _on_lives_changed)
	game_manager.connect("state_changed", _on_state_changed)
	game_manager.connect("game_over", _on_game_over)

	start_button.pressed.connect(Callable(game_manager, "start_game"))
	main_quit_button.pressed.connect(Callable(game_manager, "quit_game"))

	resume_button.pressed.connect(Callable(game_manager, "resume_game"))
	pause_restart_button.pressed.connect(Callable(game_manager, "restart_game"))
	pause_main_menu_button.pressed.connect(Callable(game_manager, "enter_main_menu"))
	pause_quit_button.pressed.connect(Callable(game_manager, "quit_game"))

	game_over_restart_button.pressed.connect(Callable(game_manager, "restart_game"))
	game_over_main_menu_button.pressed.connect(Callable(game_manager, "enter_main_menu"))
	game_over_quit_button.pressed.connect(Callable(game_manager, "quit_game"))

	_on_score_changed(game_manager.score)
	_on_lives_changed(game_manager.lives)
	_sync_visibility()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if game_manager.game_state == STATE_PLAYING or game_manager.game_state == STATE_PAUSED:
			game_manager.toggle_pause()
			get_viewport().set_input_as_handled()


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score


func _on_lives_changed(new_lives: int) -> void:
	lives_label.text = "Lives: %d" % new_lives


func _on_state_changed(_new_state: int) -> void:
	_sync_visibility()


func _on_game_over(final_score: int) -> void:
	final_score_label.text = "Final Score: %d" % final_score
	_sync_visibility()


func _sync_visibility() -> void:
	var state: int = game_manager.game_state
	hud.visible = state != STATE_MAIN_MENU
	main_menu.visible = state == STATE_MAIN_MENU
	pause_menu.visible = state == STATE_PAUSED
	game_over_menu.visible = state == STATE_GAME_OVER
	final_score_label.text = "Final Score: %d" % game_manager.score

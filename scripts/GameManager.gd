extends Node

signal score_changed(score: int)
signal lives_changed(lives: int)
signal state_changed(game_state: int)
signal game_over(final_score: int)

enum GameState { MAIN_MENU, PLAYING, PAUSED, GAME_OVER }

@export var max_lives: int = 3

var score: int = 0
var lives: int = 3
var game_state: int = GameState.MAIN_MENU

var _player: CharacterBody2D = null
var _spawn_position: Vector2 = Vector2.ZERO
var _has_spawn_position := false
var _game_over_emitted := false


func _ready() -> void:
	enter_main_menu(false)


func register_player(player: CharacterBody2D) -> void:
	_player = player
	_spawn_position = player.global_position
	_has_spawn_position = true

	if game_state != GameState.PLAYING:
		_respawn_player()


func start_game() -> void:
	reset_run()
	_set_state(GameState.PLAYING)
	get_tree().paused = false
	_respawn_player()


func restart_game() -> void:
	reset_run()
	_set_state(GameState.PLAYING)
	get_tree().paused = false
	get_tree().reload_current_scene()


func enter_main_menu(reload_scene: bool = true) -> void:
	reset_run()
	_set_state(GameState.MAIN_MENU)

	if reload_scene and get_tree().current_scene != null:
		get_tree().paused = false
		get_tree().reload_current_scene()

	get_tree().paused = true


func pause_game() -> void:
	if game_state != GameState.PLAYING:
		return

	_set_state(GameState.PAUSED)
	get_tree().paused = true


func resume_game() -> void:
	if game_state != GameState.PAUSED:
		return

	_set_state(GameState.PLAYING)
	get_tree().paused = false


func toggle_pause() -> void:
	if game_state == GameState.PLAYING:
		pause_game()
	elif game_state == GameState.PAUSED:
		resume_game()


func quit_game() -> void:
	get_tree().quit()


func reset_run() -> void:
	_reset_player_powerups()
	score = 0
	lives = max_lives
	_game_over_emitted = false
	score_changed.emit(score)
	lives_changed.emit(lives)


func add_score(amount: int = 1) -> void:
	if game_state != GameState.PLAYING or amount <= 0:
		return

	score += amount
	score_changed.emit(score)


func damage_player(amount: int = 1) -> void:
	if game_state != GameState.PLAYING or amount <= 0:
		return

	lives = maxi(lives - amount, 0)
	lives_changed.emit(lives)

	if lives == 0:
		_reset_player_powerups()
		_enter_game_over()
	else:
		_respawn_player()


func _enter_game_over() -> void:
	if _game_over_emitted:
		return

	_game_over_emitted = true
	_set_state(GameState.GAME_OVER)
	get_tree().paused = true
	game_over.emit(score)


func _respawn_player() -> void:
	if not _has_spawn_position or not is_instance_valid(_player):
		return

	_reset_player_powerups()

	if _player.has_method("respawn_at"):
		_player.respawn_at(_spawn_position)
	else:
		_player.global_position = _spawn_position
		_player.velocity = Vector2.ZERO


func _set_state(new_state: int) -> void:
	if game_state == new_state:
		return

	game_state = new_state
	state_changed.emit(game_state)


func _reset_player_powerups() -> void:
	if is_instance_valid(_player) and _player.has_method("reset_powerups"):
		_player.reset_powerups()

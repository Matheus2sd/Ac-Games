extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 80.0
const JUMP_VELOCITY = -300.0

var base_speed := SPEED
var base_jump_velocity := JUMP_VELOCITY
var current_speed := base_speed
var current_jump_velocity := base_jump_velocity
var speed_powerup_multiplier := 2.0
var jump_powerup_multiplier := 1.5

var _speed_powerup_timer: Timer
var _jump_powerup_timer: Timer


func _ready() -> void:
	add_to_group("player")
	_setup_powerup_timers()

	var game_manager := get_node_or_null("/root/GameManager")
	if game_manager != null:
		game_manager.register_player(self)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = current_jump_velocity

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	if is_on_floor():
		if direction > 0:
			anim.flip_h = false
			anim.play("walk")
		elif direction < 0:
			anim.flip_h = true
			anim.play("walk")
		else:
			anim.play("idle")
	else:
		anim.play("jump")

	move_and_slide()


func die() -> void:
	var game_manager := get_node_or_null("/root/GameManager")
	if game_manager != null:
		game_manager.damage_player()


func respawn_at(spawn_position: Vector2) -> void:
	reset_powerups()
	global_position = spawn_position
	velocity = Vector2.ZERO


func apply_speed_powerup(duration: float = 5.0) -> void:
	_setup_powerup_timers()
	current_speed = base_speed * speed_powerup_multiplier
	_speed_powerup_timer.start(duration)


func apply_jump_powerup(duration: float = 5.0) -> void:
	_setup_powerup_timers()
	current_jump_velocity = base_jump_velocity * jump_powerup_multiplier
	_jump_powerup_timer.start(duration)


func reset_powerups() -> void:
	current_speed = base_speed
	current_jump_velocity = base_jump_velocity

	if _speed_powerup_timer != null:
		_speed_powerup_timer.stop()
	if _jump_powerup_timer != null:
		_jump_powerup_timer.stop()


func _setup_powerup_timers() -> void:
	if _speed_powerup_timer == null:
		_speed_powerup_timer = _create_powerup_timer(_on_speed_powerup_timeout)

	if _jump_powerup_timer == null:
		_jump_powerup_timer = _create_powerup_timer(_on_jump_powerup_timeout)


func _create_powerup_timer(timeout_callback: Callable) -> Timer:
	var timer := Timer.new()
	timer.one_shot = true
	timer.timeout.connect(timeout_callback)
	add_child(timer)
	return timer


func _on_speed_powerup_timeout() -> void:
	current_speed = base_speed


func _on_jump_powerup_timeout() -> void:
	current_jump_velocity = base_jump_velocity

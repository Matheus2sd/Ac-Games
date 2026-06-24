extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 80.0
const JUMP_VELOCITY = -300.0


func _ready() -> void:
	add_to_group("player")
	var game_manager := get_node_or_null("/root/GameManager")
	if game_manager != null:
		game_manager.register_player(self)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

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
	global_position = spawn_position
	velocity = Vector2.ZERO

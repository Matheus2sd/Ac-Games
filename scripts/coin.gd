extends Area2D

signal collected

@export var value: int = 1

@onready var particles: GPUParticles2D = $Particles
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var _collected := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group("player"):
		return

	_collected = true
	var game_manager := get_node_or_null("/root/GameManager")
	if game_manager != null:
		game_manager.add_score(value)
	collected.emit()

	sprite_2d.visible = false
	collision_shape_2d.set_deferred("disabled", true)
	particles.emitting = true

	await particles.finished
	queue_free()

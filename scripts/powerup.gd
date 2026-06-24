extends Area2D

signal collected(powerup_type: String)

@export_enum("speed", "jump") var powerup_type := "speed"
@export var duration := 5.0
@export var texture_path := ""

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var _collected := false


func _ready() -> void:
	_load_texture()
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group("player"):
		return

	_collected = true

	if powerup_type == "speed" and body.has_method("apply_speed_powerup"):
		body.apply_speed_powerup(duration)
	elif powerup_type == "jump" and body.has_method("apply_jump_powerup"):
		body.apply_jump_powerup(duration)

	collected.emit(powerup_type)
	sprite_2d.visible = false
	collision_shape_2d.set_deferred("disabled", true)
	queue_free()


func _load_texture() -> void:
	if sprite_2d.texture != null or texture_path.is_empty():
		return

	var image := Image.new()
	if image.load(texture_path) != OK:
		push_warning("Could not load power-up texture: %s" % texture_path)
		return

	sprite_2d.texture = ImageTexture.create_from_image(image)

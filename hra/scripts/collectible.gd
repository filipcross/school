extends Area2D
class_name Collectible

signal collected(value: int)

var value: int = 150
var bob_time: float = 0.0
var base_y: float = 0.0

@onready var collision_shape: CollisionShape2D = CollisionShape2D.new()
@onready var sprite: Sprite2D = Sprite2D.new()

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)

	collision_shape.shape = CircleShape2D.new()
	(collision_shape.shape as CircleShape2D).radius = 12.0
	add_child(collision_shape)

	sprite.texture = preload("res://assets/sprites/spark.png")
	sprite.scale = Vector2(3.0, 3.0)
	add_child(sprite)

	base_y = position.y

func _process(delta: float) -> void:
	bob_time += delta
	position.y = base_y + sin(bob_time * 3.2) * 3.0
	sprite.rotation = sin(bob_time * 2.4) * 0.12
	var pulse: float = 1.0 + sin(bob_time * 5.0) * 0.08
	sprite.scale = Vector2(3.0, 3.0) * pulse

func _on_body_entered(body: Node) -> void:
	if body != null and body.is_in_group("player"):
		emit_signal("collected", value)
		queue_free()

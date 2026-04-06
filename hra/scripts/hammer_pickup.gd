extends Area2D
class_name HammerPickup

signal picked(duration: float)

var duration: float = 8.0
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
	(collision_shape.shape as CircleShape2D).radius = 14.0
	add_child(collision_shape)

	sprite.texture = preload("res://assets/sprites/spark.png")
	sprite.scale = Vector2(2.8, 2.8)
	sprite.modulate = Color(1.0, 0.82, 0.20)
	add_child(sprite)

	base_y = position.y

func _process(delta: float) -> void:
	bob_time += delta
	position.y = base_y + sin(bob_time * 3.8) * 4.0
	sprite.rotation = sin(bob_time * 4.4) * 0.18
	var pulse: float = 1.0 + sin(bob_time * 6.2) * 0.10
	sprite.scale = Vector2(2.8, 2.8) * pulse

func _on_body_entered(body: Node) -> void:
	if body != null and body.is_in_group("player"):
		if body.has_method("activate_hammer"):
			body.call("activate_hammer", duration)
		emit_signal("picked", duration)
		queue_free()

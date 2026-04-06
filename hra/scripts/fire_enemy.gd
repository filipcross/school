extends CharacterBody2D
class_name FireEnemy

const GRAVITY: float = 1400.0

var speed: float = 90.0
var direction: int = 1
var patrol_min_x: float = 0.0
var patrol_max_x: float = 0.0
var anim_time: float = 0.0

@onready var body_shape: CollisionShape2D = CollisionShape2D.new()
@onready var hitbox: Area2D = Area2D.new()
@onready var sprite: Sprite2D = Sprite2D.new()

func setup(min_x: float, max_x: float, move_speed: float = 90.0) -> void:
	patrol_min_x = min_x
	patrol_max_x = max_x
	speed = move_speed

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	add_to_group("fire_enemy")

	body_shape.shape = RectangleShape2D.new()
	(body_shape.shape as RectangleShape2D).size = Vector2(18.0, 22.0)
	add_child(body_shape)

	hitbox.collision_layer = 2
	hitbox.collision_mask = 4
	hitbox.add_to_group("danger")
	var hb_shape: CollisionShape2D = CollisionShape2D.new()
	hb_shape.shape = RectangleShape2D.new()
	(hb_shape.shape as RectangleShape2D).size = Vector2(20.0, 24.0)
	hitbox.add_child(hb_shape)
	add_child(hitbox)

	sprite.texture = preload("res://assets/sprites/spark.png")
	sprite.scale = Vector2(2.3, 2.3)
	sprite.modulate = Color(1.0, 0.48, 0.12)
	sprite.position = Vector2(0.0, -2.0)
	add_child(sprite)

func _physics_process(delta: float) -> void:
	anim_time += delta
	velocity.x = float(direction) * speed
	velocity.y += GRAVITY * delta
	move_and_slide()

	if global_position.x <= patrol_min_x:
		global_position.x = patrol_min_x
		direction = 1
	elif global_position.x >= patrol_max_x:
		global_position.x = patrol_max_x
		direction = -1

	if is_on_wall():
		direction *= -1

	var pulse: float = 1.0 + sin(anim_time * 10.0) * 0.10
	sprite.scale = Vector2(2.3, 2.3) * pulse
	sprite.rotation = sin(anim_time * 7.0) * 0.12
	sprite.flip_h = direction < 0

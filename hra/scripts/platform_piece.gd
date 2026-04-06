extends StaticBody2D
class_name PlatformPiece

func setup(width: float) -> void:
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(width, 16)
	shape.shape = rect
	add_child(shape)

	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = preload("res://assets/sprites/platform.png")
	sprite.centered = false
	sprite.position = Vector2(-width / 2.0, -8.0)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0.0, 0.0, width, 16.0)
	add_child(sprite)

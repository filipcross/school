extends Area2D
class_name LadderArea

const PLATFORM_HALF_HEIGHT: float = 8.0
const PLAYER_STANDING_OFFSET: float = 26.0
const BARREL_STANDING_OFFSET: float = 19.0
const LADDER_REGION: Rect2 = Rect2(4.0, 0.0, 40.0, 68.0)
const PLAYER_ATTACH_HALF_WIDTH: float = 10.0
const BARREL_ALIGN_HALF_WIDTH: float = 12.0
const CLIMB_VERTICAL_MARGIN: float = 6.0
const VISUAL_TOP_OVERLAP: float = 2.0
const VISUAL_BOTTOM_OVERLAP: float = 2.0

var center_x: float = 0.0
var top_floor_y: float = 0.0
var bottom_floor_y: float = 0.0
var visual_top_y: float = 0.0
var visual_bottom_y: float = 0.0
var climb_top_y: float = 0.0
var climb_bottom_y: float = 0.0

func setup(bottom_y: float, top_y: float) -> void:
	collision_layer = 0
	collision_mask = 0
	monitoring = false
	monitorable = false
	add_to_group("ladder")

	center_x = position.x
	bottom_floor_y = bottom_y
	top_floor_y = top_y
	visual_top_y = top_floor_y + PLATFORM_HALF_HEIGHT - VISUAL_TOP_OVERLAP
	visual_bottom_y = bottom_floor_y - PLATFORM_HALF_HEIGHT + VISUAL_BOTTOM_OVERLAP
	climb_top_y = get_top_snap_y()
	climb_bottom_y = get_bottom_snap_y()

	var base_texture: Texture2D = preload("res://assets/sprites/ladder.png")
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = base_texture
	atlas.region = LADDER_REGION

	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = atlas
	sprite.centered = false
	sprite.position = Vector2(-LADDER_REGION.size.x * 0.5, visual_top_y - position.y)
	var visual_height: float = max(8.0, visual_bottom_y - visual_top_y)
	sprite.scale = Vector2(1.0, visual_height / LADDER_REGION.size.y)
	add_child(sprite)

func get_top_snap_y() -> float:
	return top_floor_y - PLAYER_STANDING_OFFSET

func get_bottom_snap_y() -> float:
	return bottom_floor_y - PLAYER_STANDING_OFFSET

func is_player_attachable(pos: Vector2, max_x_distance: float, vertical_padding: float = 28.0) -> bool:
	var allowed_x: float = min(max_x_distance, PLAYER_ATTACH_HALF_WIDTH)
	if abs(pos.x - center_x) > allowed_x:
		return false

	var allowed_top: float = climb_top_y - min(vertical_padding, CLIMB_VERTICAL_MARGIN)
	var allowed_bottom: float = climb_bottom_y + min(vertical_padding, CLIMB_VERTICAL_MARGIN)
	if pos.y < allowed_top:
		return false
	if pos.y > allowed_bottom:
		return false
	return true

func is_barrel_drop_candidate(pos: Vector2, direction: int) -> bool:
	var barrel_top_floor_y: float = top_floor_y - BARREL_STANDING_OFFSET
	if abs(pos.y - barrel_top_floor_y) > 12.0:
		return false

	var dx: float = center_x - pos.x
	if direction > 0:
		if dx < -4.0 or dx > BARREL_ALIGN_HALF_WIDTH:
			return false
	elif direction < 0:
		if dx > 4.0 or dx < -BARREL_ALIGN_HALF_WIDTH:
			return false
	elif abs(dx) > BARREL_ALIGN_HALF_WIDTH:
		return false

	return true

func is_near_exit(pos: Vector2, tolerance_y: float = 18.0) -> bool:
	if abs(pos.y - get_top_snap_y()) <= tolerance_y:
		return true
	if abs(pos.y - get_bottom_snap_y()) <= tolerance_y:
		return true
	return false

func is_near_top_exit(pos: Vector2, tolerance_y: float = 18.0) -> bool:
	return abs(pos.y - get_top_snap_y()) <= tolerance_y

func is_near_bottom_exit(pos: Vector2, tolerance_y: float = 18.0) -> bool:
	return abs(pos.y - get_bottom_snap_y()) <= tolerance_y

func get_exit_snap_y(pos: Vector2) -> float:
	if abs(pos.y - get_top_snap_y()) <= abs(pos.y - get_bottom_snap_y()):
		return get_top_snap_y()
	return get_bottom_snap_y()

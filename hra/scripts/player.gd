extends CharacterBody2D
class_name Player

signal died

const SPEED: float = 220.0
const JUMP_VELOCITY: float = -500.0
const GRAVITY: float = 1400.0
const CLIMB_SPEED: float = 165.0
const LADDER_ATTACH_DISTANCE: float = 10.0
const LADDER_VERTICAL_PADDING: float = 28.0
const LADDER_X_LOCK_SPEED: float = 320.0
const LADDER_EXIT_TOLERANCE: float = 20.0
const LADDER_EXIT_NUDGE: float = 18.0

var respawn_position: Vector2 = Vector2.ZERO
var is_climbing: bool = false
var is_dead: bool = false
var anim_timer: float = 0.0
var game_ref: Node = null
var active_ladder = null
var hammer_time_left: float = 0.0

@onready var collision: CollisionShape2D = CollisionShape2D.new()
@onready var sprite: Sprite2D = Sprite2D.new()

func _ready() -> void:
	add_to_group("player")
	collision.shape = RectangleShape2D.new()
	(collision.shape as RectangleShape2D).size = Vector2(22, 36)
	add_child(collision)

	var hurtbox: Area2D = Area2D.new()
	hurtbox.monitoring = true
	hurtbox.monitorable = true
	hurtbox.collision_layer = 4
	hurtbox.collision_mask = 2
	var hb_shape: CollisionShape2D = CollisionShape2D.new()
	hb_shape.shape = RectangleShape2D.new()
	(hb_shape.shape as RectangleShape2D).size = Vector2(24, 38)
	hurtbox.add_child(hb_shape)
	hurtbox.area_entered.connect(_on_area_entered)
	add_child(hurtbox)

	sprite.texture = preload("res://assets/sprites/player_sheet.png")
	sprite.hframes = 6
	sprite.frame = 0
	sprite.position = Vector2(0, -4)
	add_child(sprite)

func set_game(value: Node) -> void:
	game_ref = value

func _physics_process(delta: float) -> void:
	if hammer_time_left > 0.0:
		hammer_time_left = max(0.0, hammer_time_left - delta)
		if game_ref != null and game_ref.has_method("update_player_power"):
			game_ref.call("update_player_power", hammer_time_left)

	if is_dead:
		velocity = Vector2.ZERO
		_update_animation(delta)
		return

	var input_x: float = _horizontal_input()
	var up: bool = _up_pressed()
	var down: bool = _down_pressed()
	var nearest_ladder = null

	if game_ref != null and game_ref.has_method("get_nearest_ladder_for_climb"):
		nearest_ladder = game_ref.call("get_nearest_ladder_for_climb", global_position, LADDER_ATTACH_DISTANCE, LADDER_VERTICAL_PADDING)

	if not is_climbing and nearest_ladder != null and (up or down):
		is_climbing = true
		active_ladder = nearest_ladder
		velocity = Vector2.ZERO

	if is_climbing:
		_process_climbing(delta, input_x, up, down, nearest_ladder)
	else:
		_process_ground(delta, input_x)

	_update_animation(delta)

func _process_climbing(delta: float, input_x: float, up: bool, down: bool, nearest_ladder) -> void:
	if active_ladder == null:
		active_ladder = nearest_ladder
	if active_ladder == null:
		is_climbing = false
		_process_ground(delta, input_x)
		return

	var still_valid: bool = bool(active_ladder.call("is_player_attachable", global_position, LADDER_ATTACH_DISTANCE + 10.0, LADDER_VERTICAL_PADDING + 24.0))
	if not still_valid:
		if nearest_ladder != null:
			active_ladder = nearest_ladder
		else:
			is_climbing = false
			active_ladder = null
			_process_ground(delta, input_x)
			return

	var target_x: float = float(active_ladder.get("center_x"))
	global_position.x = move_toward(global_position.x, target_x, LADDER_X_LOCK_SPEED * delta)
	velocity.x = 0.0
	velocity.y = 0.0

	if up and not down:
		velocity.y = -CLIMB_SPEED
	elif down and not up:
		velocity.y = CLIMB_SPEED

	move_and_slide()
	global_position.x = target_x

	if input_x != 0.0:
		var can_exit: bool = bool(active_ladder.call("is_near_exit", global_position, LADDER_EXIT_TOLERANCE))
		if can_exit:
			var exit_y: float = float(active_ladder.call("get_exit_snap_y", global_position))
			is_climbing = false
			active_ladder = null
			global_position.y = exit_y
			global_position.x += sign(input_x) * LADDER_EXIT_NUDGE
			velocity.x = input_x * SPEED
			return

	if not up and not down:
		var still_attachable: bool = bool(active_ladder.call("is_player_attachable", global_position, LADDER_ATTACH_DISTANCE + 6.0, LADDER_VERTICAL_PADDING + 24.0))
		if not still_attachable:
			is_climbing = false
			active_ladder = null

func _process_ground(delta: float, input_x: float) -> void:
	active_ladder = null
	velocity.y += GRAVITY * delta
	velocity.x = input_x * SPEED

	if is_on_floor() and _jump_just_pressed():
		velocity.y = JUMP_VELOCITY
		if game_ref != null:
			game_ref.call("play_sfx", "jump")

	move_and_slide()

func _update_animation(delta: float) -> void:
	anim_timer += delta
	if is_dead:
		sprite.frame = 3
		return

	if is_climbing:
		if int(anim_timer * 8.0) % 2 == 0:
			sprite.frame = 4
		else:
			sprite.frame = 5
	else:
		if not is_on_floor():
			sprite.frame = 3
		elif abs(velocity.x) > 8.0:
			if int(anim_timer * 12.0) % 2 == 0:
				sprite.frame = 1
			else:
				sprite.frame = 2
			sprite.flip_h = velocity.x < 0.0
		else:
			sprite.frame = 0

	if abs(velocity.x) > 8.0:
		sprite.flip_h = velocity.x < 0.0

	if hammer_time_left > 0.0:
		var pulse: float = 0.84 + abs(sin(anim_timer * 10.0)) * 0.16
		sprite.modulate = Color(1.0, 0.78 + pulse * 0.18, 0.28 + pulse * 0.22)
	else:
		sprite.modulate = Color.WHITE

func _on_area_entered(area: Area2D) -> void:
	if area == null or not area.is_in_group("danger") or is_dead:
		return

	if has_hammer():
		var owner_node: Node = area.get_parent()
		if owner_node != null and owner_node.is_in_group("barrel"):
			if owner_node.has_method("smashed_by_player"):
				owner_node.call("smashed_by_player")
			if game_ref != null and game_ref.has_method("on_barrel_smashed"):
				game_ref.call("on_barrel_smashed")
			return

	hurt()

func activate_hammer(duration: float) -> void:
	hammer_time_left = max(hammer_time_left, duration)
	if game_ref != null and game_ref.has_method("update_player_power"):
		game_ref.call("update_player_power", hammer_time_left)

func has_hammer() -> bool:
	return hammer_time_left > 0.05

func hurt() -> void:
	if is_dead:
		return
	is_dead = true
	sprite.modulate = Color(1.0, 0.5, 0.5)
	emit_signal("died")

func respawn() -> void:
	global_position = respawn_position
	velocity = Vector2.ZERO
	is_dead = false
	is_climbing = false
	active_ladder = null
	hammer_time_left = 0.0
	sprite.modulate = Color.WHITE
	if game_ref != null and game_ref.has_method("update_player_power"):
		game_ref.call("update_player_power", hammer_time_left)

func _horizontal_input() -> float:
	return float(_right_pressed()) - float(_left_pressed())

func _left_pressed() -> bool:
	return Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left")

func _right_pressed() -> bool:
	return Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right")

func _up_pressed() -> bool:
	return Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up")

func _down_pressed() -> bool:
	return Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down")

func _jump_just_pressed() -> bool:
	return Input.is_key_pressed(KEY_SPACE) or Input.is_action_just_pressed("ui_accept")

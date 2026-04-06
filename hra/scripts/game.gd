extends Node2D

const PlatformPiece = preload("res://scripts/platform_piece.gd")
const LadderArea = preload("res://scripts/ladder_area.gd")
const PlayerScript = preload("res://scripts/player.gd")
const BarrelScript = preload("res://scripts/barrel.gd")
const HUDScript = preload("res://scripts/hud.gd")
const CollectibleScript = preload("res://scripts/collectible.gd")
const HammerPickupScript = preload("res://scripts/hammer_pickup.gd")
const FireEnemyScript = preload("res://scripts/fire_enemy.gd")

const FLOOR_Y = [604.0, 492.0, 380.0, 268.0, 156.0]
const FLOOR_START_X: float = 96.0
const FLOOR_WIDTH: float = 960.0
const FLOOR_END_X: float = FLOOR_START_X + FLOOR_WIDTH
const LADDER_GAP_WIDTH: float = 56.0
const LADDER_LANES = [260.0, 420.0, 580.0, 740.0, 900.0]
const BASE_STAGE_TIME: int = 95
const MIN_STAGE_TIME: int = 52
const SAVE_PATH: String = "user://retro_rampage_save.json"
const VOID_KILL_Y: float = 700.0

var player = null
var donkey = null
var goal = null
var hud = null
var level_root = null
var barrels_root = null
var collectibles_root = null
var pickups_root = null
var enemies_root = null
var barrel_timer = null
var second_timer = null
var camera = null

var score: int = 0
var best_score: int = 0
var lives: int = 3
var level_index: int = 1
var time_left: int = BASE_STAGE_TIME
var stage_time_limit: int = BASE_STAGE_TIME
var barrels_smashed: int = 0
var collectibles_collected: int = 0
var collectibles_total: int = 0
var finished: bool = false
var paused: bool = false
var stage_transition: bool = false
var message_lock: bool = false
var shake_strength: float = 0.0

var ladders: Array = []
var floor_segments: Array = []
var current_ladder_data: Array = []
var current_fire_data: Array = []
var random: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	random.randomize()
	best_score = _load_best_score()
	_build_background()
	_build_ui()
	_setup_audio()
	_start_music()
	_setup_clock()
	_create_player_once()
	_start_new_run()

func _process(delta: float) -> void:
	if shake_strength > 0.01:
		shake_strength = lerpf(shake_strength, 0.0, delta * 8.0)
		camera.offset = Vector2(
			random.randf_range(-shake_strength, shake_strength),
			random.randf_range(-shake_strength, shake_strength)
		)
	else:
		camera.offset = Vector2.ZERO

	_check_player_void_fall()

func _build_background() -> void:
	var bg: TextureRect = TextureRect.new()
	bg.texture = preload("res://assets/sprites/background.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.size = Vector2(1152.0, 648.0)
	add_child(bg)

	camera = Camera2D.new()
	camera.position = Vector2(576.0, 324.0)
	camera.enabled = true
	add_child(camera)

func _build_ui() -> void:
	hud = HUDScript.new()
	add_child(hud)
	hud.update_score(score)
	hud.update_lives(lives)
	hud.update_time(time_left)
	hud.update_collectibles(collectibles_collected, collectibles_total)
	hud.update_best(best_score)
	hud.update_power(0.0)
	hud.update_stage(level_index)

func _setup_audio() -> void:
	for sfx_name in ["jump", "hit", "spawn", "win", "coin"]:
		var sfx: AudioStreamPlayer = AudioStreamPlayer.new()
		sfx.name = "%s_player" % sfx_name
		sfx.stream = load("res://assets/audio/%s.wav" % sfx_name)
		add_child(sfx)

	var music: AudioStreamPlayer = AudioStreamPlayer.new()
	music.name = "music"
	music.stream = load("res://assets/audio/music_loop.wav")
	music.bus = "Master"
	add_child(music)

func _start_music() -> void:
	var music: AudioStreamPlayer = get_node_or_null("music") as AudioStreamPlayer
	if music != null:
		music.volume_db = -8.0
		music.play()

func _setup_clock() -> void:
	second_timer = Timer.new()
	second_timer.wait_time = 1.0
	second_timer.one_shot = false
	second_timer.autostart = false
	second_timer.timeout.connect(_on_second_tick)
	add_child(second_timer)

func _create_player_once() -> void:
	player = PlayerScript.new()
	player.position = Vector2(136.0, 560.0)
	player.respawn_position = player.position
	player.set_game(self)
	player.died.connect(_on_player_died)
	add_child(player)

func _start_new_run() -> void:
	finished = false
	paused = false
	stage_transition = false
	message_lock = false
	score = 0
	lives = 3
	level_index = 1
	barrels_smashed = 0
	shake_strength = 0.0
	_build_stage(true)
	_show_temp_message("NEKONEČNÁ VĚŽ! DOJDI CO NEJVÝŠ.", Color(1.0, 0.86, 0.25), 1.0)

func _destroy_stage() -> void:
	ladders.clear()
	floor_segments.clear()
	current_ladder_data.clear()
	current_fire_data.clear()
	if level_root != null and is_instance_valid(level_root):
		remove_child(level_root)
		level_root.queue_free()
	level_root = Node2D.new()
	add_child(level_root)
	if player != null:
		move_child(level_root, player.get_index())

func _build_stage(reset_timer: bool) -> void:
	_destroy_stage()
	_generate_stage_layout()
	_build_stage_geometry()
	_build_stage_entities()
	_reset_player_to_spawn()
	if reset_timer:
		time_left = stage_time_limit
	hud.update_score(score)
	hud.update_lives(lives)
	hud.update_time(time_left)
	hud.update_collectibles(collectibles_collected, collectibles_total)
	hud.update_best(best_score)
	hud.update_stage(level_index)
	hud.update_power(0.0)
	hud.clear_message()
	if barrel_timer == null:
		barrel_timer = Timer.new()
		barrel_timer.timeout.connect(_spawn_barrel)
		barrel_timer.one_shot = false
		add_child(barrel_timer)
	barrel_timer.wait_time = _get_stage_barrel_interval()
	barrel_timer.start()
	if second_timer != null:
		second_timer.start()

func _generate_stage_layout() -> void:
	collectibles_collected = 0
	collectibles_total = 0
	stage_time_limit = max(MIN_STAGE_TIME, BASE_STAGE_TIME - (level_index - 1) * 3)
	current_ladder_data = _generate_ladders()
	floor_segments.clear()
	for floor_index in range(FLOOR_Y.size()):
		floor_segments.append(_compute_segments_for_floor(floor_index))

func _generate_ladders() -> Array:
	var generated: Array = []
	var lane_index: int = 0
	for top_index in range(FLOOR_Y.size() - 1):
		var min_lane: int = maxi(0, lane_index - 1)
		var max_lane: int = mini(LADDER_LANES.size() - 1, lane_index + 2)
		lane_index = random.randi_range(min_lane, max_lane)
		generated.append({"x": float(LADDER_LANES[lane_index]), "top_index": top_index})

		var extra_chance: float = min(0.20 + float(level_index - 1) * 0.06, 0.75)
		if random.randf() < extra_chance:
			var extra_lane: int = lane_index
			var tries: int = 0
			while extra_lane == lane_index and tries < 12:
				extra_lane = random.randi_range(0, LADDER_LANES.size() - 1)
				tries += 1
			if extra_lane != lane_index:
				generated.append({"x": float(LADDER_LANES[extra_lane]), "top_index": top_index})
	return generated

func _compute_segments_for_floor(floor_index: int) -> Array:
	var gaps: Array = []
	for ladder_info in current_ladder_data:
		var top_index: int = int(ladder_info["top_index"])
		if top_index == floor_index or top_index + 1 == floor_index:
			gaps.append(float(ladder_info["x"]))
	gaps.sort()

	var segments: Array = []
	var current_start: float = FLOOR_START_X
	for gap_center in gaps:
		var gap_left: float = max(FLOOR_START_X, float(gap_center) - LADDER_GAP_WIDTH * 0.5)
		var gap_right: float = min(FLOOR_END_X, float(gap_center) + LADDER_GAP_WIDTH * 0.5)
		if gap_left > current_start + 8.0:
			segments.append({"start": current_start, "end": gap_left})
		current_start = max(current_start, gap_right)
	if current_start < FLOOR_END_X - 8.0:
		segments.append({"start": current_start, "end": FLOOR_END_X})
	return segments

func _build_stage_geometry() -> void:
	for floor_index in range(FLOOR_Y.size()):
		var floor_y: float = float(FLOOR_Y[floor_index])
		var segments: Array = floor_segments[floor_index]
		for segment in segments:
			_add_platform_segment(float(segment["start"]), float(segment["end"]), floor_y)

		var left_wall: StaticBody2D = StaticBody2D.new()
		left_wall.position = Vector2(FLOOR_START_X - 14.0, floor_y - 18.0)
		var left_cs: CollisionShape2D = CollisionShape2D.new()
		left_cs.shape = RectangleShape2D.new()
		(left_cs.shape as RectangleShape2D).size = Vector2(16.0, 34.0)
		left_wall.add_child(left_cs)
		level_root.add_child(left_wall)

		var right_wall: StaticBody2D = StaticBody2D.new()
		right_wall.position = Vector2(FLOOR_END_X + 14.0, floor_y - 18.0)
		var right_cs: CollisionShape2D = CollisionShape2D.new()
		right_cs.shape = RectangleShape2D.new()
		(right_cs.shape as RectangleShape2D).size = Vector2(16.0, 34.0)
		right_wall.add_child(right_cs)
		level_root.add_child(right_wall)

	for ladder_info in current_ladder_data:
		var top_index: int = int(ladder_info["top_index"])
		var ladder_x: float = float(ladder_info["x"])
		var y_top: float = float(FLOOR_Y[top_index + 1])
		var y_bottom: float = float(FLOOR_Y[top_index])
		var ladder_area = LadderArea.new()
		ladder_area.position = Vector2(ladder_x, (y_top + y_bottom) * 0.5)
		ladder_area.setup(y_bottom, y_top)
		ladders.append(ladder_area)
		level_root.add_child(ladder_area)

func _build_stage_entities() -> void:
	donkey = Node2D.new()
	donkey.position = Vector2(150.0, 110.0)
	var dk_sprite: Sprite2D = Sprite2D.new()
	dk_sprite.texture = preload("res://assets/sprites/donkey.png")
	donkey.add_child(dk_sprite)
	level_root.add_child(donkey)

	goal = Area2D.new()
	goal.position = Vector2(965.0, 112.0)
	goal.collision_layer = 0
	goal.collision_mask = 1
	var goal_shape: CollisionShape2D = CollisionShape2D.new()
	goal_shape.shape = RectangleShape2D.new()
	(goal_shape.shape as RectangleShape2D).size = Vector2(40.0, 58.0)
	goal.add_child(goal_shape)
	var goal_sprite: Sprite2D = Sprite2D.new()
	goal_sprite.texture = preload("res://assets/sprites/goal.png")
	goal.add_child(goal_sprite)
	goal.body_entered.connect(_on_goal_reached)
	level_root.add_child(goal)

	collectibles_root = Node2D.new()
	level_root.add_child(collectibles_root)
	pickups_root = Node2D.new()
	level_root.add_child(pickups_root)
	enemies_root = Node2D.new()
	level_root.add_child(enemies_root)
	barrels_root = Node2D.new()
	level_root.add_child(barrels_root)

	_spawn_collectibles()
	_spawn_hammers()
	_spawn_fire_enemies()

func _reset_player_to_spawn() -> void:
	player.set_physics_process(true)
	player.set_process(true)
	player.respawn_position = Vector2(136.0, 560.0)
	player.respawn()

func _spawn_collectibles() -> void:
	var item_count: int = mini(5, 2 + int((level_index - 1) / 2))
	var used_by_floor: Dictionary = {}
	for floor_index in range(FLOOR_Y.size()):
		used_by_floor[floor_index] = []

	collectibles_total = 0
	for i in range(item_count):
		var floor_index: int = random.randi_range(0, FLOOR_Y.size() - 2)
		var used_positions: Array = used_by_floor[floor_index]
		var item_x: float = _pick_spawn_x_on_floor(floor_index, 28.0, used_positions)
		used_positions.append(item_x)
		var item = CollectibleScript.new()
		item.position = Vector2(item_x, float(FLOOR_Y[floor_index]) - 30.0)
		item.value = 120 + level_index * 18
		item.collected.connect(_on_collectible_collected)
		collectibles_root.add_child(item)
		collectibles_total += 1

func _spawn_hammers() -> void:
	var hammer_count: int = 1
	if level_index >= 6 and random.randf() < 0.4:
		hammer_count = 2
	for i in range(hammer_count):
		var floor_index: int = random.randi_range(1, FLOOR_Y.size() - 2)
		var item_x: float = _pick_spawn_x_on_floor(floor_index, 30.0, [])
		var pickup = HammerPickupScript.new()
		pickup.position = Vector2(item_x, float(FLOOR_Y[floor_index]) - 30.0)
		pickup.duration = 6.0 + min(4.0, float(level_index) * 0.4)
		pickup.picked.connect(_on_hammer_picked)
		pickups_root.add_child(pickup)

func _spawn_fire_enemies() -> void:
	var enemy_count: int = mini(4, 1 + int((level_index - 1) / 3))
	var used_floors: Array = []
	for i in range(enemy_count):
		var floor_index: int = random.randi_range(0, FLOOR_Y.size() - 2)
		var tries: int = 0
		while used_floors.has(floor_index) and tries < 10:
			floor_index = random.randi_range(0, FLOOR_Y.size() - 2)
			tries += 1
		used_floors.append(floor_index)
		var patrol: Dictionary = _pick_enemy_patrol(floor_index)
		if patrol.is_empty():
			continue
		var fire_enemy = FireEnemyScript.new()
		var min_x: float = float(patrol["min_x"])
		var max_x: float = float(patrol["max_x"])
		var center_x: float = (min_x + max_x) * 0.5
		fire_enemy.position = Vector2(center_x, float(FLOOR_Y[floor_index]) - 20.0)
		fire_enemy.setup(min_x, max_x, 86.0 + float(level_index - 1) * 7.0 + float(i) * 6.0)
		enemies_root.add_child(fire_enemy)

func _pick_enemy_patrol(floor_index: int) -> Dictionary:
	var segments: Array = floor_segments[floor_index]
	var candidates: Array = []
	for segment in segments:
		var start_x: float = float(segment["start"])
		var end_x: float = float(segment["end"])
		if end_x - start_x >= 180.0:
			candidates.append(segment)
	if candidates.is_empty():
		return {}
	var picked: Dictionary = candidates[random.randi_range(0, candidates.size() - 1)]
	return {"min_x": float(picked["start"]) + 18.0, "max_x": float(picked["end"]) - 18.0}

func _pick_spawn_x_on_floor(floor_index: int, margin: float, avoid_positions: Array) -> float:
	var segments: Array = floor_segments[floor_index]
	var shuffled: Array = segments.duplicate()
	_shuffle_array(shuffled)
	for segment in shuffled:
		var start_x: float = float(segment["start"]) + margin
		var end_x: float = float(segment["end"]) - margin
		if end_x <= start_x:
			continue
		var candidate_x: float = random.randf_range(start_x, end_x)
		var valid: bool = true
		for used_x in avoid_positions:
			if abs(candidate_x - float(used_x)) < 72.0:
				valid = false
				break
		if valid:
			return candidate_x
	if segments.is_empty():
		return FLOOR_START_X + 48.0
	var fallback: Dictionary = segments[0]
	return (float(fallback["start"]) + float(fallback["end"])) * 0.5

func _shuffle_array(values: Array) -> void:
	for i in range(values.size() - 1, 0, -1):
		var j: int = random.randi_range(0, i)
		var tmp = values[i]
		values[i] = values[j]
		values[j] = tmp

func _add_platform_segment(start_x: float, end_x: float, floor_y: float) -> void:
	var width: float = end_x - start_x
	if width <= 8.0:
		return
	var platform = PlatformPiece.new()
	platform.position = Vector2((start_x + end_x) * 0.5, floor_y)
	platform.setup(width)
	level_root.add_child(platform)

func _get_stage_barrel_interval() -> float:
	return max(0.78, 2.20 - float(level_index - 1) * 0.11)

func play_sfx(sfx_name: String) -> void:
	var p: AudioStreamPlayer = get_node_or_null("%s_player" % sfx_name) as AudioStreamPlayer
	if p != null:
		p.play()

func _check_player_void_fall() -> void:
	if player == null or finished or stage_transition:
		return
	if not is_instance_valid(player):
		return
	if not player.is_physics_processing():
		return
	if bool(player.get("is_dead")):
		return
	if float(player.global_position.y) > VOID_KILL_Y:
		player.call("hurt")

func add_score(value: int) -> void:
	score += value
	hud.update_score(score)

func update_player_power(seconds: float) -> void:
	if hud != null:
		hud.update_power(seconds)

func get_nearest_ladder_for_climb(pos: Vector2, max_x_distance: float, vertical_padding: float = 28.0):
	var nearest = null
	var best_distance: float = 999999.0
	for ladder in ladders:
		if ladder != null and is_instance_valid(ladder):
			var can_attach: bool = bool(ladder.call("is_player_attachable", pos, max_x_distance, vertical_padding))
			if can_attach:
				var distance: float = abs(pos.x - float(ladder.get("center_x")))
				if distance < best_distance:
					best_distance = distance
					nearest = ladder
	return nearest

func get_barrel_drop_ladder(pos: Vector2, direction: int):
	var nearest = null
	var best_distance: float = 999999.0
	for ladder in ladders:
		if ladder != null and is_instance_valid(ladder):
			var can_drop: bool = bool(ladder.call("is_barrel_drop_candidate", pos, direction))
			if can_drop:
				var distance: float = abs(pos.x - float(ladder.get("center_x")))
				if distance < best_distance:
					best_distance = distance
					nearest = ladder
	return nearest

func _spawn_barrel() -> void:
	if finished or stage_transition:
		return
	_spawn_single_barrel(56.0)
	if level_index >= 4 and random.randf() < min(0.18 + float(level_index - 4) * 0.04, 0.55):
		_spawn_single_barrel(84.0)

func _spawn_single_barrel(offset_x: float) -> void:
	var barrel = BarrelScript.new()
	barrel.position = donkey.position + Vector2(offset_x, 8.0)
	barrel.direction = 1
	barrel.set_game(self)
	barrels_root.add_child(barrel)
	play_sfx("spawn")
	shake_strength = max(shake_strength, 2.5)

func _on_collectible_collected(value: int) -> void:
	if finished or stage_transition:
		return
	collectibles_collected += 1
	add_score(value)
	play_sfx("coin")
	shake_strength = max(shake_strength, 3.0)
	hud.update_collectibles(collectibles_collected, collectibles_total)
	if barrel_timer != null:
		barrel_timer.wait_time = max(0.60, barrel_timer.wait_time - 0.05)
	_show_temp_message("BONUS +%d" % value, Color(1.0, 0.92, 0.45), 0.45)

func _on_hammer_picked(duration: float) -> void:
	if finished or stage_transition:
		return
	play_sfx("coin")
	shake_strength = max(shake_strength, 2.0)
	_show_temp_message("KLADIVO %.0fs" % duration, Color(1.0, 0.84, 0.20), 0.7)

func on_barrel_smashed() -> void:
	if finished or stage_transition:
		return
	barrels_smashed += 1
	add_score(120 + level_index * 8)
	play_sfx("coin")
	shake_strength = max(shake_strength, 4.0)

func _freeze_hazards(active: bool) -> void:
	for barrel in barrels_root.get_children():
		barrel.set_physics_process(active)
	for enemy in enemies_root.get_children():
		enemy.set_physics_process(active)

func _on_goal_reached(body: Node) -> void:
	if body != player or finished or stage_transition:
		return
	stage_transition = true
	barrel_timer.stop()
	if second_timer != null:
		second_timer.stop()
	player.set_physics_process(false)
	_freeze_hazards(false)
	var time_bonus: int = time_left * (4 + mini(level_index, 6))
	var stage_bonus: int = 350 + level_index * 120
	var pickup_bonus: int = collectibles_collected * 40
	add_score(stage_bonus + time_bonus + pickup_bonus)
	play_sfx("win")
	shake_strength = 8.0
	var bonus_life: bool = false
	if level_index % 5 == 0 and lives < 5:
		lives += 1
		bonus_life = true
		hud.update_lives(lives)
	var message: String = "LEVEL %d HOTOVO!\n+%d clear  |  +%d čas" % [level_index, stage_bonus + pickup_bonus, time_bonus]
	if bonus_life:
		message += "\nBONUS ŽIVOT!"
	hud.flash_message(message, Color(0.70, 1.0, 0.72), 0.45)
	await get_tree().create_timer(1.4).timeout
	if finished:
		return
	level_index += 1
	stage_transition = false
	_build_stage(true)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			get_tree().paused = false
			get_tree().reload_current_scene()
			return
		if event.keycode == KEY_P and not finished:
			paused = not paused
			get_tree().paused = paused
			if paused:
				hud.flash_message("PAUZA", Color(1.0, 1.0, 1.0), 0.45)
			else:
				hud.clear_message()
			return
		if finished and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE):
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_player_died() -> void:
	if finished or stage_transition:
		return
	play_sfx("hit")
	shake_strength = 12.0
	lives -= 1
	time_left = max(0, time_left - 8)
	hud.update_lives(lives)
	hud.update_time(time_left)
	hud.flash_message("AU! -1 ŽIVOT", Color(1.0, 0.45, 0.45), 0.35)
	barrel_timer.stop()
	await get_tree().create_timer(1.0).timeout
	if lives <= 0:
		_game_over("GAME OVER")
		return
	for barrel in barrels_root.get_children():
		barrel.queue_free()
	player.respawn()
	barrel_timer.start()
	hud.clear_message()

func _on_second_tick() -> void:
	if finished or stage_transition:
		return
	time_left = max(0, time_left - 1)
	hud.update_time(time_left)
	if time_left <= 0:
		_on_time_expired()

func _on_time_expired() -> void:
	if finished or stage_transition:
		return
	stage_transition = true
	lives -= 1
	hud.update_lives(lives)
	barrel_timer.stop()
	if second_timer != null:
		second_timer.stop()
	player.set_physics_process(false)
	_freeze_hazards(false)
	hud.flash_message("DOŠEL ČAS! -1 ŽIVOT", Color(1.0, 0.56, 0.42), 0.40)
	await get_tree().create_timer(1.1).timeout
	if lives <= 0:
		_game_over("GAME OVER")
		return
	stage_transition = false
	_build_stage(true)

func _game_over(title: String) -> void:
	if finished:
		return
	finished = true
	stage_transition = false
	if barrel_timer != null:
		barrel_timer.stop()
	if second_timer != null:
		second_timer.stop()
	player.set_physics_process(false)
	_freeze_hazards(false)
	var is_new_record: bool = _maybe_save_best_score()
	var message: String = "%s\nLevel: %d\nSkóre: %d\nRozbité sudy: %d\nBest: %d" % [title, level_index, score, barrels_smashed, best_score]
	if is_new_record:
		message += "\nNOVÝ REKORD!"
	message += "\nR = restart  |  ENTER = menu"
	hud.flash_message(message, Color(1.0, 0.55, 0.55), 0.55)
	hud.update_best(best_score)

func _show_temp_message(text: String, color: Color, duration: float) -> void:
	if hud == null:
		return
	message_lock = true
	hud.flash_message(text, color, 0.22)
	await get_tree().create_timer(duration).timeout
	message_lock = false
	if not finished and not paused and not stage_transition:
		hud.clear_message()

func _load_best_score() -> int:
	if not FileAccess.file_exists(SAVE_PATH):
		return 0
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return 0
	var raw_text: String = file.get_as_text()
	var parsed = JSON.parse_string(raw_text)
	if typeof(parsed) == TYPE_DICTIONARY:
		var data: Dictionary = parsed
		if data.has("best_score"):
			return int(data["best_score"])
	return 0

func _maybe_save_best_score() -> bool:
	if score <= best_score:
		return false
	best_score = score
	var data: Dictionary = {"best_score": best_score}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))
	return true

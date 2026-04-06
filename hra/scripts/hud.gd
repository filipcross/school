extends CanvasLayer
class_name HUD

var score_label: Label
var lives_label: Label
var time_label: Label
var objective_label: Label
var best_label: Label
var power_label: Label
var message_label: Label
var help_label: Label
var overlay: ColorRect
var current_stage: int = 1
var current_found: int = 0
var current_total: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	_build()

func _build() -> void:
	var top_bar: ColorRect = ColorRect.new()
	top_bar.color = Color(0.0, 0.0, 0.0, 0.45)
	top_bar.anchor_right = 1.0
	top_bar.offset_bottom = 64.0
	add_child(top_bar)

	score_label = Label.new()
	score_label.position = Vector2(18.0, 12.0)
	score_label.add_theme_font_size_override("font_size", 28)
	score_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.45))
	add_child(score_label)

	lives_label = Label.new()
	lives_label.position = Vector2(280.0, 12.0)
	lives_label.add_theme_font_size_override("font_size", 28)
	lives_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	add_child(lives_label)

	time_label = Label.new()
	time_label.position = Vector2(470.0, 12.0)
	time_label.add_theme_font_size_override("font_size", 28)
	time_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.75))
	add_child(time_label)

	objective_label = Label.new()
	objective_label.position = Vector2(680.0, 14.0)
	objective_label.add_theme_font_size_override("font_size", 22)
	objective_label.add_theme_color_override("font_color", Color(0.75, 0.95, 1.0))
	add_child(objective_label)

	best_label = Label.new()
	best_label.position = Vector2(930.0, 16.0)
	best_label.add_theme_font_size_override("font_size", 18)
	best_label.add_theme_color_override("font_color", Color(0.86, 0.86, 0.92))
	add_child(best_label)

	help_label = Label.new()
	help_label.position = Vector2(18.0, 602.0)
	help_label.text = "A/D = pohyb  |  W/S = žebřík  |  Space = skok  |  R = restart  |  P = pauza"
	help_label.add_theme_font_size_override("font_size", 18)
	help_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	add_child(help_label)

	power_label = Label.new()
	power_label.position = Vector2(790.0, 602.0)
	power_label.add_theme_font_size_override("font_size", 18)
	power_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.28))
	add_child(power_label)

	overlay = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	add_child(overlay)

	message_label = Label.new()
	message_label.anchor_left = 0.5
	message_label.anchor_top = 0.5
	message_label.anchor_right = 0.5
	message_label.anchor_bottom = 0.5
	message_label.offset_left = -360.0
	message_label.offset_top = -96.0
	message_label.offset_right = 360.0
	message_label.offset_bottom = 96.0
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 40)
	add_child(message_label)
	_refresh_objective()

func update_score(value: int) -> void:
	score_label.text = "SKÓRE: %04d" % value

func update_lives(value: int) -> void:
	lives_label.text = "ŽIVOTY: %d" % value

func update_time(value: int) -> void:
	time_label.text = "ČAS: %03d" % value

func update_collectibles(found: int, total: int) -> void:
	current_found = found
	current_total = total
	_refresh_objective()

func update_stage(value: int) -> void:
	current_stage = value
	_refresh_objective()

func _refresh_objective() -> void:
	objective_label.text = "LEVEL %02d  |  BONUSY: %d/%d" % [current_stage, current_found, current_total]

func update_best(value: int) -> void:
	best_label.text = "BEST: %04d" % value

func update_power(seconds: float) -> void:
	if seconds > 0.05:
		power_label.text = "KLADIVO: %.1fs" % seconds
	else:
		power_label.text = ""

func flash_message(text: String, color: Color = Color(1.0, 1.0, 1.0), dim: float = 0.25) -> void:
	message_label.text = text
	message_label.add_theme_color_override("font_color", color)
	overlay.color = Color(0.0, 0.0, 0.0, dim)

func clear_message() -> void:
	message_label.text = ""
	overlay.color = Color(0.0, 0.0, 0.0, 0.0)

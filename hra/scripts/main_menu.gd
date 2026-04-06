extends Control

func _ready() -> void:
	_build_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE:
			_start_game()
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _start_game() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _load_best_score() -> int:
	var save_path: String = "user://retro_rampage_save.json"
	if not FileAccess.file_exists(save_path):
		return 0
	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return 0
	var raw_text: String = file.get_as_text()
	var parsed = JSON.parse_string(raw_text)
	if typeof(parsed) == TYPE_DICTIONARY:
		var data: Dictionary = parsed
		if data.has("best_score"):
			return int(data["best_score"])
	return 0

func _build_ui() -> void:
	var bg: TextureRect = TextureRect.new()
	bg.texture = preload("res://assets/sprites/background.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	var tint: ColorRect = ColorRect.new()
	tint.color = Color(0.0, 0.0, 0.0, 0.45)
	tint.anchor_right = 1.0
	tint.anchor_bottom = 1.0
	add_child(tint)

	var root: VBoxContainer = VBoxContainer.new()
	root.anchor_left = 0.5
	root.anchor_top = 0.5
	root.anchor_right = 0.5
	root.anchor_bottom = 0.5
	root.offset_left = -320.0
	root.offset_top = -220.0
	root.offset_right = 320.0
	root.offset_bottom = 220.0
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 14)
	add_child(root)

	var title: Label = Label.new()
	title.text = """DONKEY KONG:
RETRO RAMPAGE"""
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.20))
	root.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = """ENDLESS MODE v14
Autoři: Filip Kříž a Dominik Urban"""
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92))
	root.add_child(subtitle)

	var best_label: Label = Label.new()
	best_label.text = "Nejlepší skóre: %04d" % _load_best_score()
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	best_label.add_theme_font_size_override("font_size", 20)
	best_label.add_theme_color_override("font_color", Color(0.82, 0.92, 1.0))
	root.add_child(best_label)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(620.0, 280.0)
	root.add_child(panel)

	var panel_box: VBoxContainer = VBoxContainer.new()
	panel_box.add_theme_constant_override("separation", 10)
	panel.add_child(panel_box)

	var info: Label = Label.new()
	info.text = """Cíl hry:
Každý level má nově poskládanou mapu. Vylez nahoru ke goalu, posbírej bonusy po cestě a přežij co nejvíc pater.

Co je nového:
- random skládání žebříků a mezer
- nekonečné levely se zvyšující obtížností
- rychlejší barely a víc nepřátel ve vyšších levelech
- skóre se sčítá přes celé hraní
- bonus život každých 5 levelů

Ovládání:
A/D nebo šipky = pohyb
W/S nebo šipky = lezení po žebříku
Space = skok
R = restart hry
P = pauza"""
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_size_override("font_size", 18)
	panel_box.add_child(info)

	var start_hint: Label = Label.new()
	start_hint.text = "ENTER nebo tlačítko níž = spustit hru"
	start_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_hint.add_theme_font_size_override("font_size", 18)
	start_hint.add_theme_color_override("font_color", Color(1.0, 0.82, 0.20))
	panel_box.add_child(start_hint)

	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 16)
	root.add_child(buttons)

	var start_button: Button = Button.new()
	start_button.text = "Spustit hru"
	start_button.custom_minimum_size = Vector2(200.0, 56.0)
	start_button.add_theme_font_size_override("font_size", 24)
	buttons.add_child(start_button)
	start_button.grab_focus()
	start_button.pressed.connect(_start_game)

	var quit_button: Button = Button.new()
	quit_button.text = "Konec"
	quit_button.custom_minimum_size = Vector2(160.0, 56.0)
	quit_button.add_theme_font_size_override("font_size", 24)
	buttons.add_child(quit_button)
	quit_button.pressed.connect(func() -> void:
		get_tree().quit()
	)

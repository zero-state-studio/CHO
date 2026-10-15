class_name DebugPanel
extends CanvasLayer
## Pannello di debug del livello demo, solo nelle build di debug. Tutto si usa con
## un clic: niente scorciatoie da tastiera. I controlli si costruiscono da codice
## perché è uno strumento interno che cambierà spesso.

signal zoom_requested(zoom_size: float)
signal reset_requested
signal character_requested(role: StringName)
signal test_hit_requested

## Ruoli giocabili nel pannello: chiave di traduzione del nome per ogni ruolo.
const ROLE_LABELS: Dictionary[StringName, String] = {&"junior": "ROLE_JUNIOR", &"manager": "ROLE_MANAGER"}

## Ogni quanto si aggiornano fps e draw call, in secondi reali.
@export var stats_refresh_seconds: float = 0.25
@export var panel_width: float = 300.0
@export var control_height: float = 36.0
## Spazio lasciato libero sotto il pannello: oltre, il contenuto scorre.
@export var bottom_margin: float = 100.0

var _fps_label: Label
var _draw_calls_label: Label
var _zoom_slider: HSlider
var _wobble_label: Label
var _role_buttons: Dictionary[StringName, Button] = {}
var _panel: PanelContainer
var _next_refresh_msec: int = 0


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	_build()


## Chiamata dal livello quando lo zoom cambia altrove (rotella, pulsanti +/−).
func show_zoom(zoom_size: float) -> void:
	if _zoom_slider:
		_zoom_slider.set_value_no_signal(zoom_size)


## Chiamata dal livello quando cambia il personaggio giocabile.
func show_role(role: StringName) -> void:
	for button_role: StringName in _role_buttons:
		_role_buttons[button_role].set_pressed_no_signal(button_role == role)


func setup_zoom(min_size: float, max_size: float, current: float) -> void:
	if _zoom_slider == null:
		return
	_zoom_slider.min_value = min_size
	_zoom_slider.max_value = max_size
	_zoom_slider.set_value_no_signal(current)


func _process(_delta: float) -> void:
	if _panel == null or not _panel.visible:
		return
	var now: int = Time.get_ticks_msec()
	if now < _next_refresh_msec:
		return
	_next_refresh_msec = now + int(stats_refresh_seconds * 1000.0)
	_fps_label.text = tr("UI_DEBUG_FPS").format({"value": Engine.get_frames_per_second()})
	var draw_calls: int = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	_draw_calls_label.text = tr("UI_DEBUG_DRAW_CALLS").format({"value": draw_calls})


func _build() -> void:
	var toggle := Button.new()
	toggle.text = "UI_DEBUG_TOGGLE"
	toggle.toggle_mode = true
	toggle.button_pressed = true
	toggle.focus_mode = Control.FOCUS_NONE
	toggle.custom_minimum_size = Vector2(120.0, 44.0)
	toggle.position = Vector2(16.0, 16.0)
	add_child(toggle)

	_panel = PanelContainer.new()
	_panel.position = Vector2(16.0, 68.0)
	_panel.custom_minimum_size = Vector2(panel_width, 0.0)
	add_child(_panel)
	toggle.toggled.connect(_panel.set_visible)

	var margin := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	# Il pannello scorre se non sta nella finestra (trascinando o con la rotella).
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(panel_width, _panel_max_height())
	_panel.add_child(scroll)
	scroll.add_child(margin)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)
	get_viewport().size_changed.connect(func() -> void:
		scroll.custom_minimum_size.y = _panel_max_height())

	_fps_label = _add_stat_label(column)
	_draw_calls_label = _add_stat_label(column)

	var role_title := Label.new()
	role_title.text = "UI_DEBUG_CHARACTER"
	column.add_child(role_title)
	var role_row := HBoxContainer.new()
	column.add_child(role_row)
	var role_group := ButtonGroup.new()
	for role: StringName in ROLE_LABELS:
		var role_button := Button.new()
		role_button.text = ROLE_LABELS[role]
		role_button.toggle_mode = true
		role_button.button_group = role_group
		role_button.focus_mode = Control.FOCUS_NONE
		role_button.custom_minimum_size.y = control_height + 8.0
		role_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		role_button.pressed.connect(character_requested.emit.bind(role))
		role_row.add_child(role_button)
		_role_buttons[role] = role_button

	_wobble_label = _add_stat_label(column)
	var wobble_slider := HSlider.new()
	wobble_slider.min_value = DebugSettings.WOBBLE_MIN
	wobble_slider.max_value = DebugSettings.WOBBLE_MAX
	wobble_slider.step = 0.05
	wobble_slider.value = DebugSettings.wobble
	wobble_slider.focus_mode = Control.FOCUS_NONE
	wobble_slider.custom_minimum_size.y = control_height
	wobble_slider.value_changed.connect(_on_wobble_changed)
	column.add_child(wobble_slider)
	_on_wobble_changed(DebugSettings.wobble)

	var hit_button := Button.new()
	hit_button.text = "UI_DEBUG_TEST_HIT"
	hit_button.focus_mode = Control.FOCUS_NONE
	hit_button.custom_minimum_size.y = control_height + 8.0
	hit_button.pressed.connect(test_hit_requested.emit)
	column.add_child(hit_button)

	_zoom_slider = _add_slider(column, "UI_DEBUG_ZOOM", 6.0, 26.0, 0.5, 14.0)
	_zoom_slider.value_changed.connect(zoom_requested.emit)

	var time_slider := _add_slider(column, "UI_DEBUG_TIME_SCALE",
			DebugSettings.TIME_SCALE_MIN, DebugSettings.TIME_SCALE_MAX, 0.05, DebugSettings.time_scale)
	time_slider.value_changed.connect(func(value: float) -> void: DebugSettings.time_scale = value)

	# Volumi separati per musica, effetti e versi (bus audio).
	for bus_name: StringName in [&"Music", &"SFX", &"Voices"]:
		var bus_index: int = AudioServer.get_bus_index(bus_name)
		if bus_index < 0:
			continue
		var volume_slider := _add_slider(column, "UI_DEBUG_VOLUME_" + String(bus_name).to_upper(), 0.0, 1.0, 0.05,
				db_to_linear(AudioServer.get_bus_volume_db(bus_index)))
		volume_slider.value_changed.connect(func(value: float) -> void:
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(value, 0.0001))))

	var fade_toggle := CheckButton.new()
	fade_toggle.text = "UI_DEBUG_WALL_FADE"
	fade_toggle.button_pressed = DebugSettings.wall_fade_enabled
	fade_toggle.focus_mode = Control.FOCUS_NONE
	fade_toggle.custom_minimum_size.y = control_height
	fade_toggle.toggled.connect(func(enabled: bool) -> void: DebugSettings.wall_fade_enabled = enabled)
	column.add_child(fade_toggle)

	var reset_button := Button.new()
	reset_button.text = "UI_DEBUG_RESET"
	reset_button.focus_mode = Control.FOCUS_NONE
	reset_button.custom_minimum_size.y = control_height + 8.0
	reset_button.pressed.connect(reset_requested.emit)
	column.add_child(reset_button)


func _panel_max_height() -> float:
	return maxf(get_viewport().get_visible_rect().size.y - _panel.position.y - bottom_margin, 200.0)


func _on_wobble_changed(value: float) -> void:
	DebugSettings.wobble = value
	_wobble_label.text = tr("UI_DEBUG_WOBBLE").format({"value": "%.2f" % value})


func _add_stat_label(parent: Control) -> Label:
	var label := Label.new()
	# Il testo è già tradotto e formattato da _process.
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	parent.add_child(label)
	return label


func _add_slider(parent: Control, title_key: String, min_value: float, max_value: float,
		step: float, value: float) -> HSlider:
	var title := Label.new()
	title.text = title_key
	parent.add_child(title)
	var slider := HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = value
	slider.focus_mode = Control.FOCUS_NONE
	slider.custom_minimum_size.y = control_height
	parent.add_child(slider)
	return slider

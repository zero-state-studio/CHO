extends Node3D
## Livello demo: scena di prova per movimento, personaggi gommosi, interazioni,
## fisica, asset e suoni. Collega tra loro telecamera, clic, personaggio, HUD e
## pannello di debug (chiamate verso il basso, segnali verso l'alto).

## Scene dei personaggi giocabili, scambiabili dal pannello di debug.
@export var junior_scene: PackedScene
@export var manager_scene: PackedScene
## Ruolo con cui parte la scena.
@export var starting_role: StringName = &"junior"
## Dimensioni delle celle della navigazione: devono coincidere con quelle della
## NavigationMesh della scena.
@export var navigation_cell_size: float = 0.1
@export var navigation_cell_height: float = 0.05

var character: RubberCharacter
var role: StringName

@onready var _navigation_region: NavigationRegion3D = $NavigationRegion3D
@onready var _spawn_point: Marker3D = $SpawnPoint
@onready var _camera_rig: IsoCamera = $IsoCamera
@onready var _occluder_fader: OccluderFader = $OccluderFader
@onready var _click_router: ClickRouter = $ClickRouter
@onready var _click_marker: ClickMarker = $ClickMarker
@onready var _zoom_buttons: ZoomButtons = $Hud/ZoomButtons
@onready var _debug_panel: DebugPanel = $DebugPanel


func _enter_tree() -> void:
	# La mappa di navigazione va configurata prima che la regione si registri.
	var navigation_map: RID = get_world_3d().navigation_map
	NavigationServer3D.map_set_cell_size(navigation_map, navigation_cell_size)
	NavigationServer3D.map_set_cell_height(navigation_map, navigation_cell_height)


func _ready() -> void:
	# Navmesh calcolata all'avvio: si aggiorna da sola quando cambia la scena.
	_navigation_region.bake_navigation_mesh(false)

	_occluder_fader.camera = _camera_rig.camera
	_click_router.camera = _camera_rig.camera
	_click_router.destination_chosen.connect(_click_marker.show_at)
	_spawn_character(starting_role, _spawn_point.global_transform)
	_camera_rig.snap_to_target()

	_zoom_buttons.zoom_in_pressed.connect(_camera_rig.zoom_in)
	_zoom_buttons.zoom_out_pressed.connect(_camera_rig.zoom_out)

	if is_instance_valid(_debug_panel):
		_debug_panel.setup_zoom(_camera_rig.zoom_min, _camera_rig.zoom_max, _camera_rig.zoom_size)
		_debug_panel.zoom_requested.connect(_camera_rig.set_zoom)
		_debug_panel.reset_requested.connect(_on_reset_requested)
		_debug_panel.character_requested.connect(_on_character_requested)
		_debug_panel.test_hit_requested.connect(_on_test_hit_requested)
		_debug_panel.show_role(role)
		_camera_rig.zoom_changed.connect(_debug_panel.show_zoom)

	if Benchmark.is_requested():
		var benchmark := Benchmark.new()
		benchmark.character = character
		add_child(benchmark)


## Mette in scena il personaggio del ruolo indicato, al posto di quello attuale.
func _spawn_character(new_role: StringName, spawn_transform: Transform3D) -> void:
	var scene: PackedScene = manager_scene if new_role == &"manager" else junior_scene
	if character:
		character.queue_free()
	role = new_role
	character = scene.instantiate() as RubberCharacter
	# Il gruppo "player" lo usano gli oggetti che cercano il personaggio giocabile.
	character.add_to_group(&"player")
	add_child(character)
	character.global_transform = spawn_transform
	_camera_rig.target = character
	_occluder_fader.target = character
	_click_router.character = character


func _on_character_requested(new_role: StringName) -> void:
	if new_role != role:
		_spawn_character(new_role, character.global_transform)


func _on_test_hit_requested() -> void:
	# Urto dal davanti: il personaggio viene spinto all'indietro.
	character.react(RubberBody.REACTION_HIT, -character.global_basis.z, 1.0)


func _on_reset_requested() -> void:
	get_tree().reload_current_scene()

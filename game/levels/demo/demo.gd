extends Node3D
## Livello demo: scena di prova per movimento, personaggi gommosi, interazioni,
## fisica, asset e suoni. Collega tra loro telecamera, clic, personaggio, HUD e
## pannello di debug (chiamate verso il basso, segnali verso l'alto).

## Scena del personaggio giocabile.
@export var character_scene: PackedScene
## Dimensioni delle celle della navigazione: devono coincidere con quelle della
## NavigationMesh della scena.
@export var navigation_cell_size: float = 0.1
@export var navigation_cell_height: float = 0.05

var character: RubberCharacter

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

	character = character_scene.instantiate() as RubberCharacter
	add_child(character)
	character.global_transform = _spawn_point.global_transform

	_camera_rig.target = character
	_camera_rig.snap_to_target()
	_occluder_fader.camera = _camera_rig.camera
	_occluder_fader.target = character
	_click_router.camera = _camera_rig.camera
	_click_router.character = character
	_click_router.destination_chosen.connect(_click_marker.show_at)

	_zoom_buttons.zoom_in_pressed.connect(_camera_rig.zoom_in)
	_zoom_buttons.zoom_out_pressed.connect(_camera_rig.zoom_out)

	if is_instance_valid(_debug_panel):
		_debug_panel.setup_zoom(_camera_rig.zoom_min, _camera_rig.zoom_max, _camera_rig.zoom_size)
		_debug_panel.zoom_requested.connect(_camera_rig.set_zoom)
		_debug_panel.reset_requested.connect(_on_reset_requested)
		_camera_rig.zoom_changed.connect(_debug_panel.show_zoom)


func _on_reset_requested() -> void:
	get_tree().reload_current_scene()

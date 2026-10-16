class_name AudioPad
extends StaticBody3D
## Tasto della zona audio: al clic fa partire il suono e, finché suona, mostra il
## suo segnale visivo (il tasto pulsa ed emette onde ad anelli). Il personaggio non
## si muove. La musica invece si accende e si spegne.

signal sound_started(pad: AudioPad)

const PAD_HEIGHT: float = 0.18

@export var stream: AudioStream
@export var bus: StringName = &"SFX"
## Per la musica: il tasto accende e spegne un brano in loop.
@export var toggles: bool = false
@export var color: Color = Color(0.7, 0.7, 0.75)
@export var radius: float = 0.45
## Ogni quanti secondi parte un'onda mentre il suono è in corso.
@export var wave_interval: float = 0.35
@export var wave_color: Color = Color(1.0, 0.85, 0.2, 0.9)

static var _shared_meshes: Dictionary[float, CylinderMesh] = {}
static var _shared_materials: Dictionary[Color, StandardMaterial3D] = {}

var _player: AudioStreamPlayer
var _top: MeshInstance3D
## Materiale condiviso dai tasti dello stesso colore, finché il tasto è fermo.
var _idle_material: StandardMaterial3D
## Materiale del tasto mentre suona (si illumina): solo suo.
var _material: StandardMaterial3D
var _batcher: MeshBatcher
var _wave_timer: float = 0.0
var _pulse_time: float = 0.0


func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var cylinder_shape := CylinderShape3D.new()
	cylinder_shape.radius = radius
	cylinder_shape.height = PAD_HEIGHT
	shape.shape = cylinder_shape
	shape.position.y = PAD_HEIGHT * 0.5
	add_child(shape)

	_top = MeshInstance3D.new()
	_top.mesh = _shared_mesh(radius)
	_top.position.y = PAD_HEIGHT * 0.5
	_idle_material = _shared_material(color)
	_material = _idle_material.duplicate() as StandardMaterial3D
	_top.material_override = _idle_material
	add_child(_top)
	add_to_group(MeshBatcher.BATCHABLE_GROUP)

	_player = AudioStreamPlayer.new()
	_player.stream = stream
	_player.bus = bus
	add_child(_player)
	set_process(false)


## Chiamata dal MeshBatcher: da fermi, i tasti dello stesso colore si disegnano
## insieme.
func batch_meshes(batcher: MeshBatcher) -> void:
	_batcher = batcher
	batcher.add(_top)


## Chiamata dal ClickRouter. Restituisce null: il personaggio resta dov'è.
func handle_click() -> Variant:
	if toggles and _player.playing:
		_player.stop()
	else:
		_player.play()
		_wave_timer = 0.0
		_pulse_time = 0.0
		# Mentre suona il tasto pulsa e si illumina: si disegna da solo.
		_top.material_override = _material
		if _batcher:
			_batcher.detach(_top)
		set_process(true)
		sound_started.emit(self)
	return null


func _process(delta: float) -> void:
	if not _player.playing:
		_top.scale = Vector3.ONE
		_material.emission_enabled = false
		_top.material_override = _idle_material
		if _batcher:
			_batcher.attach(_top)
		set_process(false)
		return
	# Segnale visivo: il tasto pulsa e si illumina, e manda onde ad anelli.
	_pulse_time += delta
	var pulse: float = 1.0 + 0.12 * absf(sin(_pulse_time * 10.0))
	_top.scale = Vector3(pulse, 1.0 + (pulse - 1.0) * 2.0, pulse)
	_material.emission_enabled = true
	_material.emission = wave_color
	_material.emission_energy_multiplier = 0.6
	_wave_timer -= delta
	if _wave_timer <= 0.0:
		_wave_timer = wave_interval
		_spawn_wave()


static func _shared_mesh(pad_radius: float) -> CylinderMesh:
	var cylinder: CylinderMesh = _shared_meshes.get(pad_radius)
	if cylinder == null:
		cylinder = CylinderMesh.new()
		cylinder.top_radius = pad_radius
		cylinder.bottom_radius = pad_radius * 1.1
		cylinder.height = PAD_HEIGHT
		cylinder.radial_segments = 20
		cylinder.rings = 1
		_shared_meshes[pad_radius] = cylinder
	return cylinder


static func _shared_material(pad_color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = _shared_materials.get(pad_color)
	if material == null:
		material = StandardMaterial3D.new()
		material.albedo_color = pad_color
		_shared_materials[pad_color] = material
	return material


func _spawn_wave() -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius * 0.95
	torus.outer_radius = radius * 1.1
	torus.rings = 24
	torus.ring_segments = 4
	ring.mesh = torus
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = wave_color
	ring.material_override = material
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.position.y = PAD_HEIGHT + 0.02
	add_child(ring)
	var tween: Tween = ring.create_tween().set_parallel()
	tween.tween_property(ring, "scale", Vector3(3.0, 1.0, 3.0), 0.8)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.8)
	tween.chain().tween_callback(ring.queue_free)

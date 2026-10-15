class_name ClickMarker
extends MeshInstance3D
## Anello che compare dove si è cliccato e si dissolve: conferma visiva del clic.

@export var marker_color: Color = Color(1.0, 1.0, 1.0, 0.9)
## Durata dell'animazione, in secondi.
@export var duration: float = 0.5
@export var start_scale: float = 1.4

var _material: StandardMaterial3D
var _tween: Tween


func _ready() -> void:
	var ring := TorusMesh.new()
	ring.inner_radius = 0.22
	ring.outer_radius = 0.3
	ring.rings = 16
	ring.ring_segments = 6
	mesh = ring
	_material = StandardMaterial3D.new()
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.albedo_color = marker_color
	material_override = _material
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visible = false


func show_at(point: Vector3) -> void:
	global_position = point + Vector3.UP * 0.05
	scale = Vector3.ONE * start_scale
	_material.albedo_color = marker_color
	visible = true
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(self, "scale", Vector3.ONE * 0.6, duration)
	_tween.tween_property(_material, "albedo_color:a", 0.0, duration)
	_tween.chain().tween_callback(hide)

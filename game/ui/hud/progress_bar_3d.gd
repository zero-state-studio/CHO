class_name ProgressBar3D
extends MeshInstance3D
## Barra di avanzamento sopra il personaggio durante un'azione (stampare, fare il
## caffè...). Un solo quad con shader: sempre leggibile e rivolta alla telecamera.

## Dimensioni della barra, in metri.
@export var bar_size: Vector2 = Vector2(0.8, 0.2)
@export var fill_color: Color = Color(0.3, 0.85, 0.4)

var _material: ShaderMaterial


func _ready() -> void:
	var quad := QuadMesh.new()
	quad.size = bar_size
	mesh = quad
	_material = ShaderMaterial.new()
	_material.shader = preload("res://assets/shaders/shd_progress_bar.gdshader")
	_material.set_shader_parameter("fill_color", fill_color)
	_material.render_priority = 10
	material_override = _material
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visible = false


func set_progress(value: float) -> void:
	_material.set_shader_parameter("progress", clampf(value, 0.0, 1.0))
	visible = true

class_name FeedbackPop
extends MeshInstance3D
## Piccola icona 3D che sale e sparisce: conferma visiva di un'azione (caffè bevuto,
## pratica consegnata). Ogni suono importante avrà anche questo segnale.

## Altezza della salita, in metri, e durata, in secondi.
const RISE: float = 0.7
const DURATION: float = 1.0


## Crea l'icona, la aggiunge a parent nella posizione indicata e la fa partire.
static func spawn(parent: Node, at: Vector3, icon_mesh: Mesh, color: Color) -> FeedbackPop:
	var pop := FeedbackPop.new()
	pop.mesh = icon_mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	pop.material_override = material
	pop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(pop)
	pop.global_position = at
	pop._play(material)
	return pop


func _play(material: StandardMaterial3D) -> void:
	scale = Vector3.ONE * 0.4
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(self, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:y", global_position.y + RISE, DURATION)
	tween.tween_property(material, "albedo_color:a", 0.0, DURATION * 0.4).set_delay(DURATION * 0.6)
	tween.chain().tween_callback(queue_free)

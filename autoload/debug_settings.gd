extends Node
## Impostazioni di debug condivise dal livello demo: gommosità, velocità del tempo,
## dissolvenza delle pareti. Le cambia il pannello di debug, le leggono gli altri nodi.

signal wobble_changed(value: float)
signal time_scale_changed(value: float)
signal wall_fade_changed(enabled: bool)

const WOBBLE_MIN: float = 0.0
const WOBBLE_MAX: float = 2.0
const TIME_SCALE_MIN: float = 0.1
const TIME_SCALE_MAX: float = 3.0

## 0 = rigido, 1 = oscillazioni e schiacciamento, 2 = ragdoll parziale sulle reazioni.
var wobble: float = 1.0:
	set(value):
		wobble = clampf(value, WOBBLE_MIN, WOBBLE_MAX)
		wobble_changed.emit(wobble)

var time_scale: float = 1.0:
	set(value):
		time_scale = clampf(value, TIME_SCALE_MIN, TIME_SCALE_MAX)
		Engine.time_scale = time_scale
		time_scale_changed.emit(time_scale)

var wall_fade_enabled: bool = true:
	set(value):
		wall_fade_enabled = value
		wall_fade_changed.emit(wall_fade_enabled)

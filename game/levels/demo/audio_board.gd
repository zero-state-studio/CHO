class_name AudioBoard
extends Node3D
## Zona audio del livello demo: un tasto per ogni suono di assets/audio/, creato
## leggendo le cartelle (come la vetrina). Versi, effetti e musica vanno sui loro
## bus, così si regolano separatamente.

## Cartella -> [bus, colore del tasto, tasto che accende/spegne].
@export var folders: Dictionary[String, Array] = {
	"res://assets/audio/voices": [&"Voices", Color(0.35, 0.6, 0.95), false],
	"res://assets/audio/sfx": [&"SFX", Color(0.75, 0.75, 0.8), false],
	"res://assets/audio/music": [&"Music", Color(0.4, 0.8, 0.45), true],
}
@export var extensions: PackedStringArray = PackedStringArray(["wav", "ogg", "mp3"])
## Distanza tra i tasti, in metri, e tasti per fila.
@export var spacing: float = 1.8
@export var pads_per_row: int = 6
@export var row_gap: float = 2.6
@export var label_color: Color = Color(0.1, 0.1, 0.14)

var pads: Array[AudioPad] = []


func _ready() -> void:
	var row: int = 0
	for folder: String in folders:
		var settings: Array = folders[folder]
		var files: PackedStringArray = _list_files(folder)
		for index: int in files.size():
			if index > 0 and index % pads_per_row == 0:
				row += 1
			var column: int = index % pads_per_row
			_add_pad(folder.path_join(files[index]), settings, Vector3(column * spacing, 0.0, row * row_gap))
		if not files.is_empty():
			row += 1


func _add_pad(path: String, settings: Array, at: Vector3) -> void:
	var stream := load(path) as AudioStream
	if stream == null:
		push_warning("Zona audio: non riesco a caricare %s" % path)
		return
	var ogg := stream as AudioStreamOggVorbis
	if ogg:
		ogg.loop = true
	var pad := AudioPad.new()
	pad.name = path.get_file().get_basename()
	pad.stream = stream
	pad.bus = settings[0]
	pad.color = settings[1]
	pad.toggles = settings[2]
	pad.position = at
	add_child(pad)
	pads.append(pad)

	var label := Label3D.new()
	# Il nome del file è un dato, non un testo da tradurre.
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.text = pad.name.trim_prefix("vox_").trim_prefix("sfx_").trim_prefix("mus_")
	label.modulate = label_color
	label.outline_modulate = Color.WHITE
	label.outline_size = 10
	label.font_size = 36
	label.pixel_size = 0.006
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = at + Vector3(0.0, 0.75, 0.0)
	add_child(label)


func _list_files(folder: String) -> PackedStringArray:
	var found := PackedStringArray()
	if not DirAccess.dir_exists_absolute(folder):
		return found
	var names: PackedStringArray = ResourceLoader.list_directory(folder)
	names.sort()
	for entry: String in names:
		if not entry.ends_with("/") and extensions.has(entry.get_extension().to_lower()):
			found.append(entry)
	return found

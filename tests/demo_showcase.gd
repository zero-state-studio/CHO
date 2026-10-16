extends SceneTree
## Test della vetrina del livello demo: i personaggi ci sono, con i triangoli nel
## budget; una vetrina su modelli finti (tests/fixtures/models) conta i triangoli
## giusti e segnala quello fuori budget.
##
## Uso: godot --headless --path . --fixed-fps 60 -s res://tests/demo_showcase.gd
##
## Le variabili sono Variant: questo script si compila prima degli autoload, quindi
## non può nominare classi che usano DebugSettings.

const DEMO_SCENE: String = "res://game/levels/demo/demo.tscn"
const SHOWCASE_SCRIPT: String = "res://game/levels/demo/showcase.gd"
const EXPECTED_CHARACTERS: PackedStringArray = ["colleague", "junior", "manager"]

var _failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	change_scene_to_file(DEMO_SCENE)
	await process_frame
	await process_frame
	var demo: Variant = current_scene
	var showcase: Variant = demo.get_node("NavigationRegion3D/Showcase")
	var by_name: Dictionary = {}
	for entry: Dictionary in showcase.entries:
		by_name[entry["name"]] = entry
		print("        vetrina: %-24s %5d triangoli%s" % [entry["name"], entry["triangles"],
				"  FUORI BUDGET" if entry["over_budget"] else ""])
	for character_name: String in EXPECTED_CHARACTERS:
		_check("in vetrina: " + character_name, by_name.has(character_name))
		if by_name.has(character_name):
			var triangles: int = by_name[character_name]["triangles"]
			_check(character_name + " tra 1.500 e 3.000 triangoli", triangles >= 1500 and triangles <= 3000)

	# Vetrina di prova su modelli finti.
	var fixture: Variant = (load(SHOWCASE_SCRIPT) as GDScript).new()
	fixture.set("models_root", "res://tests/fixtures/models")
	fixture.set("characters_root", "res://tests/fixtures/none")
	demo.add_child(fixture)
	await process_frame
	var fixture_entries: Dictionary = {}
	for entry: Dictionary in fixture.entries:
		fixture_entries[entry["name"]] = entry
	_check("modelli finti trovati", fixture_entries.size() == 2)
	_check("scatola: 12 triangoli", fixture_entries.get("fixture_box", {}).get("triangles", -1) == 12)
	_check("scatola nel budget", fixture_entries.get("fixture_box", {}).get("over_budget", true) == false)
	_check("sfera densa fuori budget", fixture_entries.get("fixture_dense_sphere", {}).get("over_budget", false) == true)

	print("Risultato: %d controlli falliti" % _failures)
	quit(1 if _failures > 0 else 0)


func _check(label: String, passed: bool) -> void:
	print(("OK      " if passed else "FALLITO ") + label)
	if not passed:
		_failures += 1

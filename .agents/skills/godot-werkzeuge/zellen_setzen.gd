extends SceneTree

## Setzt oder löscht Zellen einer TileMapLayer in einer gespeicherten Szene, ohne Editor.
##
## Aufruf aus dem Repo-Hauptverzeichnis:
##   godot --headless --path godot-project \
##     --script ../.agents/skills/godot-werkzeuge/zellen_setzen.gd -- \
##     --szene res://level/palermo/palermo.tscn --ebene Gelaende --zellen /pfad/zellen.json
##
## Aufbau von zellen.json (alle optional; Reihenfolge: alles_loeschen, rechtecke, setzen, loeschen):
##   {
##     "alles_loeschen": true,
##     "rechtecke":  [[x1, y1, x2, y2, quelle, atlas_x, atlas_y], ...],   (x2/y2 inklusive)
##     "setzen":     [[x, y, quelle, atlas_x, atlas_y], ...],
##     "loeschen":   [[x, y], ...]   (kommt zuletzt, schneidet Löcher)
##   }


func _initialize() -> void:
	var argumente: Dictionary = _argumente_lesen()
	for pflicht: String in ["szene", "ebene", "zellen"]:
		if not argumente.has(pflicht):
			_abbrechen("Argument --%s fehlt." % pflicht)
			return

	var szenen_pfad: String = argumente["szene"]
	var szene: PackedScene = load(szenen_pfad) as PackedScene
	if szene == null:
		_abbrechen("Szene nicht ladbar: %s" % szenen_pfad)
		return

	var wurzel: Node = szene.instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
	var ebene: TileMapLayer = wurzel.get_node_or_null(NodePath(argumente["ebene"])) as TileMapLayer
	if ebene == null:
		_abbrechen("Keine TileMapLayer unter '%s' gefunden." % argumente["ebene"])
		return

	var text: String = FileAccess.get_file_as_string(argumente["zellen"])
	var daten: Dictionary = JSON.parse_string(text) as Dictionary
	if daten == null:
		_abbrechen("zellen.json ist kein gültiges JSON-Objekt.")
		return

	var anzahl: int = 0
	if daten.get("alles_loeschen", false):
		ebene.clear()
	for eintrag: Array in daten.get("rechtecke", []):
		var quelle: int = int(eintrag[4])
		var atlas: Vector2i = Vector2i(int(eintrag[5]), int(eintrag[6]))
		for y: int in range(int(eintrag[1]), int(eintrag[3]) + 1):
			for x: int in range(int(eintrag[0]), int(eintrag[2]) + 1):
				ebene.set_cell(Vector2i(x, y), quelle, atlas)
				anzahl += 1
	for eintrag: Array in daten.get("setzen", []):
		var zelle: Vector2i = Vector2i(int(eintrag[0]), int(eintrag[1]))
		ebene.set_cell(zelle, int(eintrag[2]), Vector2i(int(eintrag[3]), int(eintrag[4])))
		anzahl += 1
	for eintrag: Array in daten.get("loeschen", []):
		ebene.erase_cell(Vector2i(int(eintrag[0]), int(eintrag[1])))
		anzahl += 1

	var neue_szene: PackedScene = PackedScene.new()
	var fehler: Error = neue_szene.pack(wurzel)
	if fehler == OK:
		fehler = ResourceSaver.save(neue_szene, szenen_pfad)
	wurzel.free()
	if fehler != OK:
		_abbrechen("Speichern fehlgeschlagen: %s" % error_string(fehler))
		return
	print("%d Zellen geändert in %s" % [anzahl, szenen_pfad])
	quit(0)


func _argumente_lesen() -> Dictionary:
	var ergebnis: Dictionary = {}
	var liste: PackedStringArray = OS.get_cmdline_user_args()
	var i: int = 0
	while i < liste.size() - 1:
		if liste[i].begins_with("--"):
			ergebnis[liste[i].trim_prefix("--")] = liste[i + 1]
			i += 2
		else:
			i += 1
	return ergebnis


func _abbrechen(meldung: String) -> void:
	push_error(meldung)
	quit(1)

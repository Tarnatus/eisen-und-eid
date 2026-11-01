extends Node2D
## PROTOTYP – Wegwerf-Code für „Bewegung zum Anfassen“.
## Testraum, Wertesätze und Anzeige. Wird nach dem Ticket weggeworfen;
## nur die Erkenntnisse aus prototyp_ritter_bewegung.gd wandern in den echten Ritter.
## Starten: godot --path godot-project res://ritter/prototyp_bewegung/prototyp_bewegung.tscn

const Raster := preload("res://ritter/prototyp_bewegung/prototyp_raster.gd")
const RitterBewegung := preload("res://ritter/prototyp_bewegung/prototyp_ritter_bewegung.gd")

const FRAGE: String = "PROTOTYP Bewegung zum Anfassen: Wie muss sich der Ritter bewegen?"
const RAUM_BREITE: int = 90
const RAUM_HOEHE: int = 24
const START_ZELLE: Vector2i = Vector2i(3, 20)
const SPUR_LAENGE: int = 90
const SCHRIFT_GROESSE: int = 8

## Wertesätze, umschaltbar mit F1–F3. Bewusst weit auseinander: erst die Richtung finden.
const WERTESAETZE: Array[Dictionary] = [
	{
		"name": "Broforce",
		"lauf_tempo": 110.0,
		"anschub": 25.0,
		"beschleunigung": 220.0,
		"extra_beschleunigung_langsam": 286.0,
		"sprint_faktor": 1.5,
		"bremsen_boden": 20.0,
		"bremsen_luft": 0.0,
		"schwerkraft": 1100.0,
		"sprung_tempo": 260.0,
		"halte_zeit": 0.123,
		"max_fall": 400.0,
		"coyote_zeit": 0.08,
		"wand_rutschen": 40.0,
		"wand_hopser_tempo": 260.0,
	},
	{
		"name": "Schwerer Ritter",
		"lauf_tempo": 95.0,
		"anschub": 10.0,
		"beschleunigung": 160.0,
		"extra_beschleunigung_langsam": 200.0,
		"sprint_faktor": 1.4,
		"bremsen_boden": 12.0,
		"bremsen_luft": 0.0,
		"schwerkraft": 1300.0,
		"sprung_tempo": 250.0,
		"halte_zeit": 0.11,
		"max_fall": 450.0,
		"coyote_zeit": 0.08,
		"wand_rutschen": 60.0,
		"wand_hopser_tempo": 240.0,
	},
	{
		"name": "Leicht und schnell",
		"lauf_tempo": 140.0,
		"anschub": 60.0,
		"beschleunigung": 500.0,
		"extra_beschleunigung_langsam": 400.0,
		"sprint_faktor": 1.5,
		"bremsen_boden": 30.0,
		"bremsen_luft": 2.0,
		"schwerkraft": 950.0,
		"sprung_tempo": 280.0,
		"halte_zeit": 0.16,
		"max_fall": 380.0,
		"coyote_zeit": 0.12,
		"wand_rutschen": 30.0,
		"wand_hopser_tempo": 280.0,
	},
]

## Beschriftete Bereiche, damit man beim Rückmelden darauf zeigen kann.
const BEREICHE: Dictionary[String, Vector2i] = {
	"A Laufen + Plattformen": Vector2i(2, 11),
	"B Säulen 1-5 Blöcke": Vector2i(22, 12),
	"C Gruben 3/5/7 breit": Vector2i(42, 15),
	"D Kletterwand": Vector2i(60, 6),
	"E Schacht": Vector2i(66, 6),
	"F niedriger Gang": Vector2i(72, 15),
	"G Plattform-Turm": Vector2i(82, 6),
}

var _wertesatz: int = 0
var _spur: PackedVector2Array = PackedVector2Array()
var _hinweis: String = ""
var _rest_hinweis: float = 0.0

@onready var _raster: Raster = $Raster as Raster
@onready var _ritter: RitterBewegung = $Ritter as RitterBewegung
@onready var _kamera: Camera2D = $Kamera
@onready var _text: Label = $Anzeige/Text


func _ready() -> void:
	_raum_bauen()
	_ritter.raster = _raster
	_wertesatz_anwenden(0)
	_neustart()

	_kamera.limit_left = 0
	_kamera.limit_top = 0
	_kamera.limit_right = RAUM_BREITE * Raster.BLOCK
	_kamera.limit_bottom = RAUM_HOEHE * Raster.BLOCK

	_text.add_theme_font_size_override("font_size", SCHRIFT_GROESSE)
	_text.add_theme_constant_override("outline_size", 2)
	_text.add_theme_color_override("font_outline_color", Color.BLACK)
	_text.add_theme_constant_override("line_spacing", -2)


func _raum_bauen() -> void:
	var fest := Raster.Art.FEST
	var leer := Raster.Art.LEER
	var plattform := Raster.Art.PLATTFORM
	_raster.anlegen(RAUM_BREITE, RAUM_HOEHE)
	_raster.setzen(0, 0, RAUM_BREITE, 1, fest)
	_raster.setzen(0, 0, 1, RAUM_HOEHE, fest)
	_raster.setzen(RAUM_BREITE - 1, 0, 1, RAUM_HOEHE, fest)
	_raster.setzen(0, 20, RAUM_BREITE, 4, fest)
	# A: Plattformen über der Laufstrecke.
	_raster.setzen(7, 17, 5, 1, plattform)
	_raster.setzen(11, 14, 5, 1, plattform)
	# B: Säulen 1 bis 5 Blöcke hoch: wie hoch kommt man mit kurzem und vollem Sprung?
	for i: int in range(5):
		_raster.setzen(22 + i * 4, 19 - i, 2, i + 1, fest)
	# C: Gruben 3, 5 und 7 Blöcke breit, 3 tief: wie weit kommt man mit und ohne Sprint?
	_raster.setzen(42, 20, 3, 3, leer)
	_raster.setzen(48, 20, 5, 3, leer)
	_raster.setzen(56, 20, 7, 3, leer)
	# D: Kletterwand 12 Blöcke hoch. E: Schacht 1 Block breit, unten von rechts begehbar.
	_raster.setzen(64, 8, 3, 12, fest)
	_raster.setzen(68, 8, 3, 10, fest)
	# F: niedriger Gang, 2 Blöcke hoch.
	_raster.setzen(73, 17, 8, 1, fest)
	# G: Plattform-Turm zum Durchspringen und Durchfallen.
	for i: int in range(4):
		_raster.setzen(82, 17 - i * 3, 6, 1, plattform)


func _wertesatz_anwenden(nummer: int) -> void:
	_wertesatz = nummer
	var werte: Dictionary = WERTESAETZE[nummer]
	for schluessel: String in werte:
		if schluessel != "name":
			_ritter.set(schluessel, werte[schluessel])
	_hinweis_zeigen("Wertesatz: %s" % werte["name"])


func _neustart() -> void:
	_ritter.zuruecksetzen(Vector2(START_ZELLE) * Raster.BLOCK + Vector2(8.0, 0.0))
	_spur.clear()
	_kamera.position = _ritter.position.round()
	_kamera.reset_physics_interpolation()


## Gibt alle Einstellwerte als fertige GDScript-Zeilen aus, zum Einfügen ins Ticket.
func _werte_ausgeben() -> void:
	print("# Bewegung zum Anfassen, ausgehend von Wertesatz „%s“" % WERTESAETZE[_wertesatz]["name"])
	for eigenschaft: Dictionary in _ritter.get_property_list():
		var nutzung: int = eigenschaft["usage"]
		var ist_einstellwert := (
			nutzung & PROPERTY_USAGE_SCRIPT_VARIABLE != 0 and nutzung & PROPERTY_USAGE_EDITOR != 0
		)
		if ist_einstellwert:
			var eigenschafts_name: String = eigenschaft["name"]
			print("%s = %s" % [eigenschafts_name, _ritter.get(eigenschafts_name)])
	_hinweis_zeigen("Werte ausgegeben (Ausgabe-Fenster)")


func _hinweis_zeigen(text: String) -> void:
	_hinweis = text
	_rest_hinweis = 2.0


func _unhandled_input(event: InputEvent) -> void:
	var taste := event as InputEventKey
	if taste != null and taste.pressed and not taste.echo:
		match taste.keycode:
			KEY_F1:
				_wertesatz_anwenden(0)
			KEY_F2:
				_wertesatz_anwenden(1)
			KEY_F3:
				_wertesatz_anwenden(2)
			KEY_F9:
				_werte_ausgeben()
			KEY_F10:
				_text.visible = not _text.visible
			KEY_R:
				_neustart()
	var knopf := event as InputEventJoypadButton
	if knopf != null and knopf.pressed and knopf.button_index == JOY_BUTTON_BACK:
		_neustart()


func _physics_process(_delta: float) -> void:
	# Kamera im Physik-Takt auf ganze Pixel; die Interpolation glättet sie wie den Ritter.
	_kamera.position = _ritter.position.round()
	_spur.append(_ritter.position + Vector2(0.0, -RitterBewegung.HOEHE / 2.0))
	if _spur.size() > SPUR_LAENGE:
		_spur.remove_at(0)
	queue_redraw()


func _process(delta: float) -> void:
	_rest_hinweis = maxf(_rest_hinweis - delta, 0.0)

	var r := _ritter
	var wand := "-"
	if r.wand_seite > 0:
		wand = "rechts"
	elif r.wand_seite < 0:
		wand = "links"
	var zeilen: PackedStringArray = [
		FRAGE,
		"F1 Broforce  F2 Schwerer Ritter  F3 Leicht+schnell  F9 Werte ausgeben  R Neustart  F10 Text",
		(
			"Wertesatz: %s    %s"
			% [WERTESAETZE[_wertesatz]["name"], _hinweis if _rest_hinweis > 0.0 else ""]
		),
		(
			"Zustand: %-11s  Tempo x %4d  y %4d px/s   Wand: %s  Decke: %s"
			% [
				r.zustand,
				roundi(r.geschwindigkeit.x),
				roundi(r.geschwindigkeit.y),
				wand,
				"ja" if r.an_decke else "-"
			]
		),
		(
			"Coyote %.2f  Buffer %.2f  Halten %.3f  Kleben %.2f  Durchfallen %.2f"
			% [r.rest_coyote, r.rest_buffer, r.rest_halten, r.rest_wand_kleben, r.rest_durchfallen]
		),
		(
			"Letzter Flug: Höhe %d px (%.1f Bl.)  Weite %d px (%.1f Bl.)"
			% [
				roundi(r.letzte_flughoehe),
				r.letzte_flughoehe / Raster.BLOCK,
				roundi(r.letzte_flugweite),
				r.letzte_flugweite / Raster.BLOCK,
			]
		),
	]
	_text.text = "\n".join(zeilen)


func _draw() -> void:
	var schrift := ThemeDB.fallback_font
	for bereich: String in BEREICHE:
		var ort := Vector2(BEREICHE[bereich] * Raster.BLOCK)
		draw_string(
			schrift,
			ort,
			bereich,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			SCHRIFT_GROESSE,
			Color(1, 1, 1, 0.6)
		)
	# Spur der letzten anderthalb Sekunden: zeigt die Sprungkurve.
	for i: int in range(_spur.size()):
		var alpha := float(i) / SPUR_LAENGE
		draw_rect(Rect2(_spur[i] - Vector2.ONE * 0.5, Vector2.ONE), Color(1, 1, 1, alpha * 0.8))

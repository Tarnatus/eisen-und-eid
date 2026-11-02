class_name Ritter
extends Koerper
## Die Spielfigur. Steuerung mit den Broforce-Werten aus „Bewegung zum Anfassen“,
## Kampf nach „Moveset im Kampf“. Kasten, Schwerkraft und Kollision kommen von Koerper.

## Nach dem Tod; der Ritter bleibt liegen, bis ihn jemand zurücksetzt.
signal gestorben
## Bitte an die Kamera; Stärke 0 bis 1.
signal wackeln(staerke: float)
signal ladungen_geaendert(anzahl: int)

enum Zustand { BODEN, STEIGEN, FALLEN, WAND, KANTEN_FLIP }

## Kollisionsebenen „Ritter“ und „Gegner“ (project.godot).
const EBENEN_ALLE: int = 0b11
const BUMERANGAXT_SZENE: PackedScene = preload("res://ritter/bumerangaxt/bumerangaxt.tscn")

@export_group("Laufen")
## Höchstgeschwindigkeit beim Laufen in px/s.
@export_range(40.0, 300.0, 1.0) var lauf_tempo: float = 110.0
## Geschwindigkeit, auf die ein Tastendruck sofort springt, in px/s.
@export_range(0.0, 150.0, 1.0) var anschub: float = 25.0
## Beschleunigung bis zur Höchstgeschwindigkeit in px/s².
@export_range(0.0, 2000.0, 10.0) var beschleunigung: float = 220.0
## Zusätzliche Beschleunigung unter 50 px/s in px/s².
@export_range(0.0, 2000.0, 10.0) var extra_beschleunigung_langsam: float = 286.0
## Faktor auf die Höchstgeschwindigkeit beim Sprinten.
@export_range(1.0, 3.0, 0.05) var sprint_faktor: float = 1.5
## Bremsen am Boden ohne Eingabe, pro Sekunde (v *= 1 − Wert × dt).
@export_range(0.0, 60.0, 0.5) var bremsen_boden: float = 20.0
## Bremsen in der Luft ohne Eingabe, pro Sekunde.
@export_range(0.0, 60.0, 0.5) var bremsen_luft: float = 0.0

@export_group("Sprung")
## Steiggeschwindigkeit beim Sprung in px/s, konstant während der Haltezeit.
@export_range(50.0, 600.0, 5.0) var sprung_tempo: float = 260.0
## So lange bleibt die Steiggeschwindigkeit, solange die Taste gehalten wird, in s.
@export_range(0.0, 0.5, 0.005) var halte_zeit: float = 0.123
## Ein zu früh gedrückter Sprung wird so lange gemerkt, in s.
@export_range(0.0, 0.5, 0.01) var jump_buffer: float = 0.2
## So lange nach dem Verlassen einer Kante darf man noch springen, in s.
@export_range(0.0, 0.3, 0.01) var coyote_zeit: float = 0.08
## Mindestabstand zwischen zwei Sprüngen vom Boden, in s.
@export_range(0.0, 0.5, 0.01) var sprung_abstand: float = 0.08

@export_group("Wand")
## Höchste Rutschgeschwindigkeit an der Wand in px/s.
@export_range(0.0, 400.0, 5.0) var wand_rutschen: float = 40.0
## So lange klebt man nach dem Loslassen der Richtung noch an der Wand, in s.
@export_range(0.0, 1.0, 0.01) var wand_klebezeit: float = 0.2
## Senkrechter Hüpfer an der Wand in px/s, ohne Haltezeit.
@export_range(0.0, 600.0, 5.0) var wand_hopser_tempo: float = 260.0
## Mindestabstand zwischen zwei Wand-Hüpfern in s.
@export_range(0.0, 0.5, 0.01) var wand_hopser_abstand: float = 0.2
## Kanten-Flip: Erreicht der Kopf beim Hochklettern die Oberkante, schwingt sich der Ritter hinauf.
@export var kanten_flip: bool = true
## Schwung nach oben beim Kanten-Flip in px/s.
@export_range(0.0, 500.0, 5.0) var kanten_flip_hoch: float = 220.0
## Schwung zur Seite beim Kanten-Flip in px/s.
@export_range(0.0, 300.0, 5.0) var kanten_flip_seitlich: float = 100.0
## Dauer des Kanten-Flips in s.
@export_range(0.0, 0.5, 0.01) var kanten_flip_dauer: float = 0.18

@export_group("Plattform")
## So lange fällt man nach „unten + Sprung“ durch Plattform-Blöcke, in s.
@export_range(0.0, 0.5, 0.01) var durchfallen_zeit: float = 0.15

@export_group("Schlag")
## Antippen schlägt sofort; halten und loslassen nach der Ladezeit gibt den Powerschlag.
@export_range(0.05, 1.0, 0.01) var powerschlag_ladezeit: float = 0.35
## Reichweite des Schlags vom Kasten aus, in px.
@export_range(4.0, 64.0, 1.0) var schlag_reichweite: float = 16.0
## Reichweite des Powerschlags vom Kasten aus, in px.
@export_range(4.0, 64.0, 1.0) var powerschlag_reichweite: float = 28.0
## Mindestabstand zwischen zwei Schlägen, in s.
@export_range(0.0, 0.5, 0.01) var schlag_abstand: float = 0.12
## Rückstoß, den ein getroffenes Ziel beim Schlag bekommt, in px/s.
@export_range(0.0, 600.0, 10.0) var schlag_rueckstoss: float = 80.0
## Rückstoß beim Powerschlag, in px/s; dazu ein Stück nach oben.
@export_range(0.0, 600.0, 10.0) var powerschlag_rueckstoss: float = 240.0

@export_group("Treffer-Effekte")
## So lange friert das Spiel beim Schlag ein, wenn er etwas trifft, in s.
@export_range(0.0, 0.3, 0.005) var einfrieren_schlag: float = 0.03
## So lange beim Powerschlag, in s.
@export_range(0.0, 0.3, 0.005) var einfrieren_powerschlag: float = 0.08
## Wackeln beim Schlag, 0 bis 1.
@export_range(0.0, 1.0, 0.05) var wackeln_schlag: float = 0.15
## Wackeln beim Powerschlag, 0 bis 1.
@export_range(0.0, 1.0, 0.05) var wackeln_powerschlag: float = 0.4

@export_group("Schild")
## Faktor auf das Lauftempo, solange der Schild gehalten wird.
@export_range(0.0, 1.0, 0.05) var schild_tempo_faktor: float = 0.4

@export_group("Bumerangaxt")
## Ladungen beim Start und nach jedem Zurücksetzen.
@export_range(0, 9, 1) var ladungen_start: int = 3

## 1 = schaut nach rechts, -1 = nach links.
var blick: int = 1
var zustand: Zustand = Zustand.BODEN
var tot: bool = false
var schild_aktiv: bool = false
var ladungen: int = 3

var _rest_halten: float = 0.0
var _rest_coyote: float = 0.0
var _rest_buffer: float = 0.0
var _rest_wand_kleben: float = 0.0
var _rest_flip: float = 0.0
var _rest_sprung_abstand: float = 0.0
var _rest_wand_abstand: float = 0.0
var _flip_richtung: int = 0
var _rest_rueckstoss: float = 0.0
var _rest_schlag_abstand: float = 0.0
## Wie lange „angreifen“ schon gehalten wird, in s; -1 = lädt nicht.
var _laden: float = -1.0
var _axt: Bumerangaxt = null
## Für die Platzhalter-Zeichnung: zuletzt getroffene Fläche (relativ zu den Füßen).
var _schlag_flaeche: Rect2 = Rect2()
var _schlag_art: Treffer.Art = Treffer.Art.SCHLAG
var _rest_schlag_anzeige: float = 0.0

@onready var _trefferzone: Trefferzone = $Trefferzone


func _ready() -> void:
	_trefferzone.getroffen.connect(_getroffen)
	ladungen = ladungen_start


## Setzt den Ritter mit den Füßen an diese Stelle und hält ihn an.
func zuruecksetzen(fuesse: Vector2) -> void:
	position = fuesse
	geschwindigkeit = Vector2.ZERO
	_rest_halten = 0.0
	_rest_buffer = 0.0
	_rest_flip = 0.0
	_rest_rueckstoss = 0.0
	_laden = -1.0
	tot = false
	_trefferzone.set_deferred("monitorable", true)
	ladungen = ladungen_start
	ladungen_geaendert.emit(ladungen)
	if is_instance_valid(_axt):
		_axt.queue_free()
	reset_physics_interpolation()


## Der Ritter stirbt mit einem Treffer (1 Treffer = tot).
func sterben(rueckstoss: Vector2 = Vector2.ZERO) -> void:
	if tot:
		return
	tot = true
	schild_aktiv = false
	_trefferzone.schild_richtung = Vector2.ZERO
	_trefferzone.set_deferred("monitorable", false)
	_laden = -1.0
	geschwindigkeit = rueckstoss + Vector2(0.0, -150.0)
	auf_boden = false
	wackeln.emit(0.5)
	_einfrieren(einfrieren_powerschlag)
	gestorben.emit()


func _physics_process(delta: float) -> void:
	_rest_schlag_anzeige = maxf(_rest_schlag_anzeige - delta, 0.0)
	if tot:
		# Leiche: fällt, rutscht aus, sonst nichts.
		geschwindigkeit.x *= maxf(1.0 - (bremsen_boden if auf_boden else 1.0) * delta, 0.0)
		schwerkraft_anwenden(delta)
		bewegen(delta)
		queue_redraw()
		return

	var achse := Input.get_axis("links", "rechts")
	richtung = 0 if absf(achse) < 0.5 else int(signf(achse))
	if richtung != 0:
		blick = richtung
	var sprint := Input.is_action_pressed("sprinten")
	var sprung_gedrueckt := Input.is_action_just_pressed("springen")
	var sprung_gehalten := Input.is_action_pressed("springen")
	var unten_gehalten := Input.is_action_pressed("unten")
	var oben_gehalten := Input.is_action_pressed("oben")

	_rest_halten = maxf(_rest_halten - delta, 0.0)
	_rest_coyote = maxf(_rest_coyote - delta, 0.0)
	_rest_buffer = maxf(_rest_buffer - delta, 0.0)
	_rest_wand_kleben = maxf(_rest_wand_kleben - delta, 0.0)
	_rest_flip = maxf(_rest_flip - delta, 0.0)
	_rest_sprung_abstand = maxf(_rest_sprung_abstand - delta, 0.0)
	_rest_wand_abstand = maxf(_rest_wand_abstand - delta, 0.0)
	_rest_rueckstoss = maxf(_rest_rueckstoss - delta, 0.0)
	_rest_schlag_abstand = maxf(_rest_schlag_abstand - delta, 0.0)

	# Kampf: Schild schließt Angriffe aus. Schlag sofort beim Drücken, Powerschlag beim
	# Loslassen nach der Ladezeit. Angriffe halten die Bewegung nicht an.
	schild_aktiv = Input.is_action_pressed("schild")
	if schild_aktiv:
		_laden = -1.0
		_trefferzone.schild_richtung = Vector2.UP if oben_gehalten else Vector2(blick, 0.0)
	else:
		_trefferzone.schild_richtung = Vector2.ZERO
		if Input.is_action_just_pressed("angreifen"):
			_laden = 0.0
			if _rest_schlag_abstand <= 0.0:
				_schlagen(Treffer.Art.SCHLAG, oben_gehalten, unten_gehalten)
		elif _laden >= 0.0 and Input.is_action_pressed("angreifen"):
			_laden += delta
		elif _laden >= 0.0:
			if _laden >= powerschlag_ladezeit:
				_schlagen(Treffer.Art.POWERSCHLAG, oben_gehalten, unten_gehalten)
			_laden = -1.0
		if Input.is_action_just_pressed("bumerangaxt"):
			_bumerangaxt_werfen()

	if sprung_gedrueckt:
		_rest_buffer = jump_buffer
	if auf_boden:
		_rest_coyote = coyote_zeit
	if wand_seite != 0 and richtung == wand_seite:
		_rest_wand_kleben = wand_klebezeit
	var klebt_an_wand := not auf_boden and wand_seite != 0 and _rest_wand_kleben > 0.0

	# Waagerecht: sofortiger Anschub, dann Beschleunigung; ohne Eingabe bremsen.
	if _rest_rueckstoss > 0.0:
		pass  # Zurückgeworfen: Schwung bleibt, keine Steuerung.
	elif _rest_flip > 0.0:
		geschwindigkeit.x = _flip_richtung * kanten_flip_seitlich
	elif richtung != 0:
		var hoechst := lauf_tempo * (sprint_faktor if sprint else 1.0)
		if schild_aktiv:
			hoechst = lauf_tempo * schild_tempo_faktor
		if signf(geschwindigkeit.x) != richtung or absf(geschwindigkeit.x) < anschub:
			geschwindigkeit.x = richtung * anschub
		var beschl := beschleunigung
		if absf(geschwindigkeit.x) < 50.0:
			beschl += extra_beschleunigung_langsam
		if absf(geschwindigkeit.x) < hoechst:
			geschwindigkeit.x = move_toward(geschwindigkeit.x, richtung * hoechst, beschl * delta)
		elif auf_boden:
			# Schneller als erlaubt (z. B. Sprint losgelassen): sanft auf Laufgeschwindigkeit.
			var gebremst := absf(geschwindigkeit.x) * maxf(1.0 - bremsen_boden * delta, 0.0)
			geschwindigkeit.x = richtung * maxf(hoechst, gebremst)
	else:
		var rate := bremsen_boden if auf_boden else bremsen_luft
		geschwindigkeit.x *= maxf(1.0 - rate * delta, 0.0)
		if absf(geschwindigkeit.x) < 2.0:
			geschwindigkeit.x = 0.0

	# Senkrecht: durch Plattform fallen, Sprung, Wand-Hüpfer, Halten, Schwerkraft.
	if auf_boden and unten_gehalten and _rest_buffer > 0.0 and steht_nur_auf_plattform():
		durch_plattformen_fallen(durchfallen_zeit)
		_rest_buffer = 0.0
		_rest_coyote = 0.0
	elif _rest_buffer > 0.0 and _rest_coyote > 0.0 and _rest_sprung_abstand <= 0.0:
		geschwindigkeit.y = -sprung_tempo
		_rest_halten = halte_zeit
		_rest_buffer = 0.0
		_rest_coyote = 0.0
		_rest_sprung_abstand = sprung_abstand
		auf_boden = false
	elif (
		sprung_gedrueckt
		and klebt_an_wand
		and geschwindigkeit.y > -25.0
		and _rest_wand_abstand <= 0.0
	):
		geschwindigkeit.y = -wand_hopser_tempo
		geschwindigkeit.x = 0.0
		_rest_halten = 0.0
		_rest_buffer = 0.0
		_rest_wand_abstand = wand_hopser_abstand

	if _rest_halten > 0.0:
		if sprung_gehalten:
			geschwindigkeit.y = -sprung_tempo
		else:
			_rest_halten = 0.0
	if _rest_halten <= 0.0:
		schwerkraft_anwenden(delta)
	if klebt_an_wand and geschwindigkeit.y > wand_rutschen:
		geschwindigkeit.y = wand_rutschen

	if (
		kanten_flip
		and _rest_flip <= 0.0
		and not auf_boden
		and wand_seite != 0
		and richtung == wand_seite
		and geschwindigkeit.y < 0.0
		and kante_erreicht(wand_seite)
	):
		_rest_flip = kanten_flip_dauer
		_flip_richtung = wand_seite
		geschwindigkeit.y = -kanten_flip_hoch
		_rest_halten = 0.0

	bewegen(delta)
	if an_decke:
		_rest_halten = 0.0

	if _rest_flip > 0.0:
		zustand = Zustand.KANTEN_FLIP
	elif auf_boden:
		zustand = Zustand.BODEN
	elif klebt_an_wand:
		zustand = Zustand.WAND
	elif geschwindigkeit.y < 0.0:
		zustand = Zustand.STEIGEN
	else:
		zustand = Zustand.FALLEN
	queue_redraw()


func _schlagen(art: Treffer.Art, oben: bool, unten: bool) -> void:
	var power := art == Treffer.Art.POWERSCHLAG
	var reichweite := powerschlag_reichweite if power else schlag_reichweite
	var richtung_vektor := Vector2(blick, 0.0)
	var flaeche := Rect2(
		breite / 2.0 if blick > 0 else -breite / 2.0 - reichweite, -hoehe, reichweite, hoehe
	)
	if oben:
		richtung_vektor = Vector2.UP
		flaeche = Rect2(-breite / 2.0 - 2.0, -hoehe - reichweite, breite + 4.0, reichweite)
	elif unten and not auf_boden:
		richtung_vektor = Vector2.DOWN
		flaeche = Rect2(-breite / 2.0 - 2.0, 0.0, breite + 4.0, reichweite)
	var rueckstoss := richtung_vektor * (powerschlag_rueckstoss if power else schlag_rueckstoss)
	if power:
		rueckstoss.y -= 100.0

	var etwas_getroffen := false
	var global := Rect2(flaeche.position + global_position, flaeche.size)
	var eigene: Array[RID] = [_trefferzone.get_rid()]
	for zone: Trefferzone in Trefferzone.finden(get_world_2d(), global, EBENEN_ALLE, eigene):
		zone.treffen(Treffer.new(art, richtung_vektor, rueckstoss, self))
		etwas_getroffen = true
	var bricht_bis := Gelaende.Haerte.HART if power else Gelaende.Haerte.WEICH
	if (
		gelaende.bloecke_zerstoeren(Rect2(flaeche.position + position, flaeche.size), bricht_bis)
		> 0
	):
		etwas_getroffen = true
	if etwas_getroffen:
		wackeln.emit(wackeln_powerschlag if power else wackeln_schlag)
		_einfrieren(einfrieren_powerschlag if power else einfrieren_schlag)

	_rest_schlag_abstand = schlag_abstand
	_schlag_flaeche = flaeche
	_schlag_art = art
	_rest_schlag_anzeige = 0.08


## Immer nur eine Bumerangaxt gleichzeitig unterwegs.
func _bumerangaxt_werfen() -> void:
	if ladungen <= 0 or is_instance_valid(_axt):
		return
	ladungen -= 1
	ladungen_geaendert.emit(ladungen)
	_axt = BUMERANGAXT_SZENE.instantiate()
	_axt.werfer = self
	_axt.gelaende = gelaende
	_axt.richtung = Vector2(blick, 0.0)
	_axt.position = position + Vector2(blick * 8.0, -hoehe / 2.0)
	_axt.wackeln.connect(wackeln.emit)
	get_parent().add_child(_axt)


func _getroffen(treffer: Treffer) -> void:
	if tot:
		return
	# Mitspieler: kein Schaden, nur der Powerschlag stößt zurück.
	if treffer.verursacher is Ritter:
		if treffer.art == Treffer.Art.POWERSCHLAG:
			geschwindigkeit = treffer.rueckstoss
			auf_boden = false
			_rest_rueckstoss = 0.25
		return
	sterben(treffer.rueckstoss)


## Kurzes Einfrieren des ganzen Spiels; der Timer läuft in Echtzeit weiter.
func _einfrieren(dauer: float) -> void:
	if dauer <= 0.0:
		return
	Engine.time_scale = 0.0
	await get_tree().create_timer(dauer, true, false, true).timeout
	Engine.time_scale = 1.0


## Platzhalter, bis „Platzhalter-Grafiken zum Anschauen“ ein Sprite liefert.
## Die Farbe zeigt den Zustand, das Visier die Blickrichtung.
func _draw() -> void:
	if tot:
		draw_rect(Rect2(-hoehe / 2.0, -6.0, hoehe, 6.0), Color(0.7, 0.15, 0.15))
		return
	var farbe := Color(0.75, 0.78, 0.85)
	match zustand:
		Zustand.STEIGEN:
			farbe = Color(0.55, 0.8, 1.0)
		Zustand.FALLEN:
			farbe = Color(0.4, 0.55, 0.95)
		Zustand.WAND:
			farbe = Color(1.0, 0.75, 0.3)
		Zustand.KANTEN_FLIP:
			farbe = Color(1.0, 0.4, 0.8)
	draw_rect(Rect2(-breite / 2.0, -hoehe, breite, hoehe), farbe)
	draw_rect(Rect2(1.0 if blick > 0 else -5.0, -15.0, 4.0, 2.0), Color(0.1, 0.1, 0.15))

	# Laden: Balken über dem Kopf, gelber Rand, sobald der Powerschlag bereit ist.
	if _laden >= 0.0:
		var anteil := minf(_laden / powerschlag_ladezeit, 1.0)
		draw_rect(Rect2(-breite / 2.0, -hoehe - 4.0, breite * anteil, 2.0), Color(1.0, 0.85, 0.2))
		if anteil >= 1.0:
			draw_rect(
				Rect2(-breite / 2.0, -hoehe, breite, hoehe), Color(1.0, 0.85, 0.2), false, 1.0
			)

	if schild_aktiv:
		var schild_farbe := Color(0.55, 0.35, 0.2)
		if _trefferzone.schild_richtung == Vector2.UP:
			draw_rect(Rect2(-breite / 2.0 - 2.0, -hoehe - 3.0, breite + 4.0, 3.0), schild_farbe)
		else:
			var x := breite / 2.0 if blick > 0 else -breite / 2.0 - 3.0
			draw_rect(Rect2(x, -hoehe + 2.0, 3.0, hoehe - 4.0), schild_farbe)

	if _rest_schlag_anzeige > 0.0:
		var power := _schlag_art == Treffer.Art.POWERSCHLAG
		draw_rect(_schlag_flaeche, Color(1.0, 0.55, 0.2, 0.8) if power else Color(1, 1, 1, 0.7))

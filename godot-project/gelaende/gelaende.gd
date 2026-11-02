class_name Gelaende
extends Node2D
## Das Block-Raster: die einzige Wahrheit für Kollision und Zerstörung (siehe ADR 0001).
## Beim Start liest es alle gemalten Zellen der TileMapLayer „Bloecke“ ein.
## Art und Härte einer Zelle stehen als Custom Data „art“ und „haerte“ am Tile im TileSet.
## Die TileMapLayer zeigt nur an und hat keinen Physics Layer.

signal block_zerstoert(zelle: Vector2i)

enum Art { LEER, FEST, PLATTFORM }
enum Haerte { WEICH, HART, UNZERSTOERBAR }

const BLOCK: int = 16

## Zellkoordinate der linken oberen Ecke des Rasters.
var ursprung: Vector2i = Vector2i.ZERO
var breite: int = 0
var hoehe: int = 0

var _zellen: PackedByteArray = PackedByteArray()
var _haerten: PackedByteArray = PackedByteArray()
## Die gemalten Zellen beim Start, damit wiederherstellen() zerstörte Blöcke zurückholt.
var _gemalt: PackedByteArray = PackedByteArray()

@onready var _bloecke: TileMapLayer = $Bloecke


func _ready() -> void:
	_gemalt = _bloecke.tile_map_data
	einlesen()


## Liest alle Zellen der TileMapLayer neu ins Raster.
func einlesen() -> void:
	var flaeche := _bloecke.get_used_rect()
	ursprung = flaeche.position
	breite = flaeche.size.x
	hoehe = flaeche.size.y
	_zellen.resize(breite * hoehe)
	_zellen.fill(Art.LEER)
	_haerten.resize(breite * hoehe)
	_haerten.fill(Haerte.WEICH)
	for zelle: Vector2i in _bloecke.get_used_cells():
		var daten := _bloecke.get_cell_tile_data(zelle)
		if daten == null:
			continue
		var stelle := zelle - ursprung
		_zellen[stelle.y * breite + stelle.x] = daten.get_custom_data("art") as int
		_haerten[stelle.y * breite + stelle.x] = daten.get_custom_data("haerte") as int


## Holt alle Blöcke zurück, wie sie beim Start gemalt waren.
func wiederherstellen() -> void:
	_bloecke.tile_map_data = _gemalt
	einlesen()


## Über dem Raster ist Himmel (leer). Links, rechts und unten gilt alles als fest,
## damit niemand aus dem Gelände fällt.
func art_bei(spalte: int, zeile: int) -> Art:
	var x := spalte - ursprung.x
	var y := zeile - ursprung.y
	if y < 0:
		return Art.LEER
	if x < 0 or x >= breite or y >= hoehe:
		return Art.FEST
	return _zellen[y * breite + x] as Art


## Außerhalb des Rasters ist alles unzerstörbar.
func haerte_bei(spalte: int, zeile: int) -> Haerte:
	var x := spalte - ursprung.x
	var y := zeile - ursprung.y
	if x < 0 or x >= breite or y < 0 or y >= hoehe:
		return Haerte.UNZERSTOERBAR
	return _haerten[y * breite + x] as Haerte


## Zerstört den Block, wenn seine Härte höchstens bricht_bis ist. Gibt zurück, ob er brach.
func block_zerstoeren(zelle: Vector2i, bricht_bis: Haerte) -> bool:
	if art_bei(zelle.x, zelle.y) == Art.LEER:
		return false
	var haerte := haerte_bei(zelle.x, zelle.y)
	if haerte == Haerte.UNZERSTOERBAR or haerte > bricht_bis:
		return false
	var stelle := zelle - ursprung
	_zellen[stelle.y * breite + stelle.x] = Art.LEER
	_bloecke.erase_cell(zelle)
	block_zerstoert.emit(zelle)
	return true


## Zerstört alle Blöcke, die das Rechteck (in px) berührt. Gibt die Anzahl zurück.
func bloecke_zerstoeren(flaeche: Rect2, bricht_bis: Haerte) -> int:
	var anzahl := 0
	for zeile: int in range(floori(flaeche.position.y / BLOCK), ceili(flaeche.end.y / BLOCK)):
		for spalte: int in range(floori(flaeche.position.x / BLOCK), ceili(flaeche.end.x / BLOCK)):
			if block_zerstoeren(Vector2i(spalte, zeile), bricht_bis):
				anzahl += 1
	return anzahl


## Ob im Rechteck (in px) ein Block liegt, der dem Schlag standhält (Art fest, zu hart).
func haelt_stand(flaeche: Rect2, bricht_bis: Haerte) -> bool:
	for zeile: int in range(floori(flaeche.position.y / BLOCK), ceili(flaeche.end.y / BLOCK)):
		for spalte: int in range(floori(flaeche.position.x / BLOCK), ceili(flaeche.end.x / BLOCK)):
			if art_bei(spalte, zeile) != Art.FEST:
				continue
			var haerte := haerte_bei(spalte, zeile)
			if haerte == Haerte.UNZERSTOERBAR or haerte > bricht_bis:
				return true
	return false

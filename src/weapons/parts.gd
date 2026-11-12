class_name Parts
## Weapon parts (plan 7.1): a weapon is chassis + barrel + core + chip.
## Chassis set the base values, the other parts modify them. Keys a part can use:
##   damage_mul, fire_rate_mul, speed_mul      multiplied
##   projectiles_add, radius_add                added
##   spread, burst, wave, pierce, bounce, homing, crit, slow, chain, leech, split   largest value wins
## Every chassis has roughly 40 damage per second, the other parts trade it for behaviour (plan 7.6).
# ponytail: constants in a script like LevelData. Move to .tres resources when parts get models and an editor.

const SLOTS := ["chassis", "barrel", "core", "chip"]
const SLOT_NAMES := {"chassis": "Gehäuse", "barrel": "Lauf", "core": "Kern", "chip": "Chip"}
const DEFAULT_LOADOUT := {"chassis": "rifle", "barrel": "single", "core": "kinetic", "chip": "none"}

const CHASSIS := {
	"rifle": {"name": "Sturmgewehr", "desc": "Ausgewogen, mittlere Reichweite.",
		"damage": 10.0, "fire_rate": 4.0, "projectiles": 1, "range": 45.0},
	"smg": {"name": "Maschinenpistole", "desc": "Schnelle schwache Schüsse, kürzere Reichweite.",
		"damage": 5.0, "fire_rate": 8.0, "projectiles": 1, "range": 36.0},
	"cannon": {"name": "Kanone", "desc": "Langsam, schwere Treffer, große Reichweite.",
		"damage": 26.0, "fire_rate": 1.6, "projectiles": 1, "range": 50.0, "radius_add": 0.1},
	"shotgun": {"name": "Schrotflinte", "desc": "Drei Kugeln im Fächer, kurze Reichweite.",
		"damage": 7.0, "fire_rate": 2.2, "projectiles": 3, "range": 26.0, "spread": 9.0},
}

const BARRELS := {
	"single": {"name": "Einzellauf", "desc": "Gerade Schüsse nebeneinander."},
	"fan": {"name": "Fächer", "desc": "Zwei Projektile mehr, gefächert, weniger Schaden je Treffer.",
		"projectiles_add": 2, "damage_mul": 0.7, "spread": 8.0},
	"burst": {"name": "Salve", "desc": "Drei Schüsse kurz hintereinander, dann Pause.",
		"burst": 3, "fire_rate_mul": 0.4, "damage_mul": 0.9},
	"wave": {"name": "Wellenlauf", "desc": "Projektile schlängeln sich und treffen breiter.",
		"wave": 1.2, "damage_mul": 0.9},
}

const CORES := {
	"kinetic": {"name": "Kinetik", "desc": "Schnelle Projektile ohne Zusatzwirkung.", "color": "22e1ff"},
	"plasma": {"name": "Plasma", "desc": "Große langsame Kugeln, mehr Schaden.",
		"color": "b47cff", "damage_mul": 1.15, "speed_mul": 0.7, "radius_add": 0.3},
	"cryo": {"name": "Kryo", "desc": "Treffer verlangsamen Gegner.",
		"color": "a8f0ff", "damage_mul": 0.9, "slow": 0.5},
	"shock": {"name": "Schock", "desc": "Treffer springen auf einen nahen Gegner über.",
		"color": "fff27a", "damage_mul": 0.9, "chain": 0.5},
}

const CHIPS := {
	"none": {"name": "Kein Chip", "desc": "Freier Platz."},
	"pierce": {"name": "Durchschlag", "desc": "Projektile durchdringen einen Gegner.", "pierce": 1, "damage_mul": 0.9},
	"ricochet": {"name": "Abpraller", "desc": "Nach einem Treffer prallt das Projektil zum nächsten Gegner.", "bounce": 1},
	"split": {"name": "Teilung", "desc": "Treffer teilen sich in zwei kleine Splitter.", "split": 1},
	"homing": {"name": "Zielsuche", "desc": "Projektile lenken leicht zum nächsten Gegner.", "homing": 3.0},
	"crit": {"name": "Präzision", "desc": "15 % Chance auf 2,5-fachen Schaden.", "crit": 0.15},
	"overdrive": {"name": "Überdruck", "desc": "Feuerrate +20 %, Schaden −10 %.", "fire_rate_mul": 1.2, "damage_mul": 0.9},
	"heavy": {"name": "Schwerkaliber", "desc": "Schaden +25 %, Feuerrate −15 %.", "damage_mul": 1.25, "fire_rate_mul": 0.85},
	"leech": {"name": "Schildraub", "desc": "Alle 40 Abschüsse +1 Schild.", "leech": 40},
}


static func table(slot: String) -> Dictionary:
	match slot:
		"chassis":
			return CHASSIS
		"barrel":
			return BARRELS
		"core":
			return CORES
		_:
			return CHIPS


## Copy of the loadout with every unknown or missing id replaced by the default (plan 15.3: no crash on removed parts).
static func sanitize(loadout: Variant) -> Dictionary:
	var source: Dictionary = loadout if loadout is Dictionary else {}
	var result := {}
	for slot: String in SLOTS:
		var id: String = str(source.get(slot, ""))
		result[slot] = id if table(slot).has(id) else DEFAULT_LOADOUT[slot]
	return result

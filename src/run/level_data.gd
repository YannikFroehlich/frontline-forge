class_name LevelData
## Content of the M1 prototype: enemy values and one hand-written level.
## Effects use the WeaponStats format [stat, op, value].
# ponytail: constants in a script. Move to data/*.tres with M2 content once the core loop is confirmed.

const ENEMIES := {
	# Swarm: many weak drones.
	"drone": {"hp": 20.0, "speed": 3.0, "radius": 0.6, "damage": 1, "coins": 1},
	# Tank: slow, lots of health, two shield points on contact.
	"tank": {"hp": 320.0, "speed": 1.0, "radius": 1.1, "damage": 2, "coins": 8},
	# Jumper: hops between the three lanes.
	"jumper": {"hp": 70.0, "speed": 2.0, "radius": 0.7, "damage": 1, "coins": 3},
}

const BOSS_HP := 6000.0
const BOSS_COINS := 60
## Bonus for clearing the level, on top of everything destroyed (plan 6.3: about 80 per level).
const WIN_COINS := 80

## Events sorted by "at" (metres along the track). Kinds:
##   {"enemy": kind, "count": n, "x": centre}
##   {"left": side, "right": side}  gate, side = {"effects": [...]}
##     shootable side adds "grow", "per_hits", "max": every per_hits hits the first effect grows by grow
##   {"boss": true}  must be the last event
const LEVEL_1 := {
	"id": "w1_l01",
	"name": "Sektor 1",
	"length": 700.0,
	"events": [
		{"at": 40.0, "enemy": "drone", "count": 3, "x": 0.0},
		{"at": 70.0, "left": {"effects": [["damage", "add", 5.0]]}, "right": {"effects": [["fire_rate", "add", 2.0]]}},
		{"at": 100.0, "enemy": "drone", "count": 5, "x": -1.2},
		{"at": 120.0, "enemy": "drone", "count": 5, "x": 1.2},
		{"at": 150.0, "enemy": "jumper", "count": 1, "x": 0.0},
		{"at": 180.0, "left": {"effects": [["projectiles", "add", 1.0]]}, "right": {"effects": [["damage", "mul", 1.5]]}},
		{"at": 210.0, "enemy": "drone", "count": 6, "x": 0.0},
		{"at": 240.0, "enemy": "tank", "count": 1, "x": 0.0},
		{"at": 275.0,
			"left": {"effects": [["projectiles", "add", 0.0]], "grow": 1.0, "per_hits": 20, "max": 3.0},
			"right": {"effects": [["fire_rate", "add", 1.0]]}},
		{"at": 310.0, "enemy": "jumper", "count": 2, "x": 0.0},
		{"at": 340.0, "enemy": "drone", "count": 8, "x": 0.0},
		{"at": 375.0,
			"left": {"effects": [["damage", "mul", 2.0], ["fire_rate", "mul", 0.6]]},
			"right": {"effects": [["fire_rate", "add", 3.0]]}},
		{"at": 410.0, "enemy": "tank", "count": 1, "x": -1.3},
		{"at": 415.0, "enemy": "drone", "count": 4, "x": 1.3},
		{"at": 450.0, "left": {"effects": [["fire_rate", "mul", 1.5]]}, "right": {"effects": [["projectiles", "add", 2.0]]}},
		{"at": 490.0, "enemy": "jumper", "count": 3, "x": 0.0},
		{"at": 520.0, "enemy": "drone", "count": 10, "x": 0.0},
		{"at": 555.0, "enemy": "tank", "count": 2, "x": 0.0},
		{"at": 595.0,
			"left": {"effects": [["projectiles", "add", 3.0], ["damage", "mul", 0.6]]},
			"right": {"effects": [["damage", "add", 10.0]]}},
		{"at": 630.0, "enemy": "drone", "count": 6, "x": 0.0},
		{"at": 640.0, "enemy": "jumper", "count": 1, "x": 0.0},
		{"at": 700.0, "boss": true},
	],
}

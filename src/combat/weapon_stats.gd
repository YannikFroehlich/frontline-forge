class_name WeaponStats
extends RefCounted
## Weapon values during a run and how gates change them. Pure logic, no scene tree.
## An effect is [stat, op, value], for example ["damage", "add", 5.0] or ["fire_rate", "mul", 1.5].

const MAX_PROJECTILES := 7
const MAX_FIRE_RATE := 15.0
const NAMES := {"damage": "SCHADEN", "fire_rate": "FEUERRATE", "projectiles": "PROJEKTILE"}
const OPS := ["add", "mul"]

const MUL_KEYS := ["damage_mul", "fire_rate_mul", "speed_mul"]
const ADD_KEYS := ["projectiles_add", "radius_add"]
const MAX_KEYS := ["spread", "burst", "wave", "pierce", "bounce", "homing", "crit", "slow", "chain", "leech", "split"]

var damage := 10.0
var fire_rate := 4.0
var projectiles := 1
## Behaviour from the weapon parts (see Parts). Gates only change the three values above.
var range_m := 45.0
var speed := 40.0
var radius := 0.0
var spread := 0.0
var burst := 1
var wave := 0.0
var pierce := 0
var bounce := 0
var homing := 0.0
var crit := 0.0
var slow := 0.0
var chain := 0.0
var leech := 0
var split := false
var color := Color(0.133, 0.882, 1.0)


## Weapon built from a loadout {chassis, barrel, core, chip}. Unknown ids fall back to defaults.
static func from_loadout(loadout: Dictionary) -> WeaponStats:
	var ids := Parts.sanitize(loadout)
	var chassis: Dictionary = Parts.CHASSIS[ids["chassis"]]
	var stats := WeaponStats.new()
	stats.damage = chassis["damage"]
	stats.fire_rate = chassis["fire_rate"]
	stats.projectiles = chassis["projectiles"]
	stats.range_m = chassis["range"]
	var mul := {"damage_mul": 1.0, "fire_rate_mul": 1.0, "speed_mul": 1.0}
	var add := {"projectiles_add": 0.0, "radius_add": 0.0}
	var best := {}
	for slot: String in Parts.SLOTS:
		var part: Dictionary = Parts.table(slot)[ids[slot]]
		for key: String in part:
			if key in MUL_KEYS:
				mul[key] *= float(part[key])
			elif key in ADD_KEYS:
				add[key] += float(part[key])
			elif key in MAX_KEYS:
				best[key] = maxf(float(best.get(key, 0.0)), float(part[key]))
			elif key == "color":
				stats.color = Color(str(part[key]))
	stats.damage *= mul["damage_mul"]
	stats.fire_rate *= mul["fire_rate_mul"]
	stats.speed *= mul["speed_mul"]
	stats.projectiles += int(add["projectiles_add"])
	stats.radius = add["radius_add"]
	stats.spread = best.get("spread", 0.0)
	stats.burst = maxi(int(best.get("burst", 1.0)), 1)
	stats.wave = best.get("wave", 0.0)
	stats.pierce = int(best.get("pierce", 0.0))
	stats.bounce = int(best.get("bounce", 0.0))
	stats.homing = best.get("homing", 0.0)
	stats.crit = best.get("crit", 0.0)
	stats.slow = best.get("slow", 0.0)
	stats.chain = best.get("chain", 0.0)
	stats.leech = int(best.get("leech", 0.0))
	stats.split = best.get("split", 0.0) > 0.0
	return stats


## Short labels for every behaviour the weapon has, shown under the numbers.
func traits() -> PackedStringArray:
	var result: PackedStringArray = []
	if spread > 0.0:
		result.append("Fächer")
	if wave > 0.0:
		result.append("Welle")
	if radius > 0.2:
		result.append("Große Projektile")
	if slow > 0.0:
		result.append("Verlangsamt")
	if chain > 0.0:
		result.append("Kettenblitz")
	if pierce > 0:
		result.append("Durchschlag")
	if bounce > 0:
		result.append("Abpraller")
	if split:
		result.append("Teilung")
	if homing > 0.0:
		result.append("Zielsuche")
	if crit > 0.0:
		result.append("Kritisch %d %%" % roundi(crit * 100.0))
	if leech > 0:
		result.append("Schildraub")
	return result


## Expected damage per second without behaviour effects (crit counted as average).
func dps() -> float:
	return damage * fire_rate * projectiles * burst * (1.0 + crit * 1.5)


## Applies one effect. Values never drop below 1. Fire rate and projectile count are capped,
## the excess is converted into damage so a strong gate is never wasted (plan 14.3).
func apply(effect: Array) -> void:
	var stat: String = effect[0]
	var value: float = effect[2]
	var current := float(get(stat))
	var result := current + value if effect[1] == "add" else current * value
	match stat:
		"damage":
			damage = maxf(result, 1.0)
		"fire_rate":
			fire_rate = maxf(result, 1.0)
			if fire_rate > MAX_FIRE_RATE:
				damage *= fire_rate / MAX_FIRE_RATE
				fire_rate = MAX_FIRE_RATE
		"projectiles":
			var count := maxi(roundi(result), 1)
			if count > MAX_PROJECTILES:
				damage *= float(count) / MAX_PROJECTILES
				count = MAX_PROJECTILES
			projectiles = count


## Gate label text, for example "SCHADEN +5" or "FEUERRATE ×1,5".
static func describe(effect: Array) -> String:
	var value: float = effect[2]
	var amount := ""
	if effect[1] == "add":
		amount = ("+" if value >= 0.0 else "−") + format_number(absf(value))
	else:
		amount = "×" + format_number(value)
	return "%s %s" % [NAMES[effect[0]], amount]


static func is_good(effect: Array) -> bool:
	var value: float = effect[2]
	return value > 0.0 if effect[1] == "add" else value > 1.0


## German decimal comma, no trailing ",0".
static func format_number(value: float) -> String:
	value = snappedf(value, 0.1)
	if is_equal_approx(value, roundf(value)):
		return str(roundi(value))
	return ("%.1f" % value).replace(".", ",")

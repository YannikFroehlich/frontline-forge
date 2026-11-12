class_name WeaponStats
extends RefCounted
## Weapon values during a run and how gates change them. Pure logic, no scene tree.
## An effect is [stat, op, value], for example ["damage", "add", 5.0] or ["fire_rate", "mul", 1.5].

const MAX_PROJECTILES := 7
const MAX_FIRE_RATE := 15.0
const NAMES := {"damage": "SCHADEN", "fire_rate": "FEUERRATE", "projectiles": "PROJEKTILE"}
const OPS := ["add", "mul"]

var damage := 10.0
var fire_rate := 4.0
var projectiles := 1


func dps() -> float:
	return damage * fire_rate * projectiles


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
	if is_equal_approx(value, roundf(value)):
		return str(roundi(value))
	return ("%.1f" % value).replace(".", ",")

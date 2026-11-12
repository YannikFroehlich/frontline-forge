class_name Arsenal
## What the player owns and has upgraded, and the weapon that results. Pure logic on the save data.
## Parts are unlocked with coins (price in Parts). Each chassis has its own upgrade levels for
## damage and fire rate: cost Basis × 1.15^level, effect +8 % per level, 20 levels (plan 6.3, 14.5).
# ponytail: no catch-up discount (plan 6.4) and no refunds yet. Add both with the forge.

const MAX_LEVEL := 20
const UPGRADE_GAIN := 1.08
const UPGRADE_GROWTH := 1.15
const UPGRADE_BASE := {"damage": 50.0, "fire_rate": 60.0}
const UPGRADE_NAMES := {"damage": "Schaden", "fire_rate": "Feuerrate"}


## Starter parts: everything with price 0.
static func starter_owned() -> Dictionary:
	var owned := {}
	for slot: String in Parts.SLOTS:
		var ids: Array[String] = []
		for id: String in Parts.table(slot):
			if int(Parts.table(slot)[id]["price"]) == 0:
				ids.append(id)
		owned[slot] = ids
	return owned


static func is_owned(data: Dictionary, slot: String, id: String) -> bool:
	if int(Parts.table(slot).get(id, {}).get("price", -1)) == 0:
		return true
	var owned: Dictionary = data.get("owned", {})
	return id in (owned.get(slot, []) as Array)


static func part_price(slot: String, id: String) -> int:
	return int(Parts.table(slot)[id]["price"])


## Deducts the price and adds the part. False if already owned, unknown or too expensive.
static func buy_part(data: Dictionary, slot: String, id: String) -> bool:
	if not Parts.table(slot).has(id) or is_owned(data, slot, id):
		return false
	var price := part_price(slot, id)
	if int(data["coins"]) < price:
		return false
	data["coins"] = int(data["coins"]) - price
	var owned: Dictionary = data.get_or_add("owned", {})
	(owned.get_or_add(slot, []) as Array).append(id)
	return true


static func upgrade_level(data: Dictionary, chassis: String, stat: String) -> int:
	var upgrades: Dictionary = data.get("upgrades", {})
	return int((upgrades.get(chassis, {}) as Dictionary).get(stat, 0))


## Price of the next level, rounded to whole coins.
static func upgrade_cost(stat: String, level: int) -> int:
	return roundi(float(UPGRADE_BASE[stat]) * pow(UPGRADE_GROWTH, level))


static func buy_upgrade(data: Dictionary, chassis: String, stat: String) -> bool:
	var level := upgrade_level(data, chassis, stat)
	if level >= MAX_LEVEL:
		return false
	var cost := upgrade_cost(stat, level)
	if int(data["coins"]) < cost:
		return false
	data["coins"] = int(data["coins"]) - cost
	var upgrades: Dictionary = data.get_or_add("upgrades", {})
	(upgrades.get_or_add(chassis, {}) as Dictionary)[stat] = level + 1
	return true


## The loadout with every part the player does not own replaced by the default.
static func owned_loadout(data: Dictionary) -> Dictionary:
	var loadout := Parts.sanitize(data.get("loadout", {}))
	for slot: String in Parts.SLOTS:
		if not is_owned(data, slot, loadout[slot]):
			loadout[slot] = Parts.DEFAULT_LOADOUT[slot]
	return loadout


## The weapon the run uses: equipped parts plus the upgrades of its chassis.
static func equipped_stats(data: Dictionary) -> WeaponStats:
	return stats_for(data, owned_loadout(data))


## Any loadout with the upgrades of its chassis, for previews of parts not owned yet.
static func stats_for(data: Dictionary, loadout: Dictionary) -> WeaponStats:
	var stats := WeaponStats.from_loadout(loadout)
	stats.damage *= pow(UPGRADE_GAIN, upgrade_level(data, loadout["chassis"], "damage"))
	stats.fire_rate *= pow(UPGRADE_GAIN, upgrade_level(data, loadout["chassis"], "fire_rate"))
	return stats

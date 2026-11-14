class_name LevelData
## Enemy and boss values. The levels themselves are data files, see Campaign and data/.
# ponytail: enemy values stay constants until more enemy families arrive with world 2.

const ENEMIES := {
	# Swarm: many weak drones.
	"drone": {"hp": 20.0, "speed": 3.0, "radius": 0.6, "damage": 1, "coins": 1},
	# Tank: slow, lots of health, two shield points on contact.
	"tank": {"hp": 320.0, "speed": 1.0, "radius": 1.1, "damage": 2, "coins": 8},
	# Jumper: hops between the three lanes.
	"jumper": {"hp": 70.0, "speed": 2.0, "radius": 0.7, "damage": 1, "coins": 3},
}

## The boss does not scale with the level; it only appears in the last level of the world.
const BOSS_HP := 6000.0
const BOSS_COINS := 60

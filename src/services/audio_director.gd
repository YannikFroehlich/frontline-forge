extends Node
## Autoload "Audio": all sound effects of the game (plan 11.3, 11.4).
## Sounds are synthesized once at start (see Synth). Each category has its own bus and a small pool
## of players, so rapid fire can never stack hundreds of voices. A limiter on the master bus prevents clipping.
## Every sound gets a small random pitch change so repeats do not tire the ear.
# ponytail: pitch variation instead of three recorded variants per sound, no music and no volume settings yet.
# Music comes next in M2, the sliders with the settings screen.

const BUSES := {"Weapons": -8.0, "Sfx": -5.0, "Ui": -10.0}
const VOICES := {"Weapons": 6, "Sfx": 10, "Ui": 3}
## Shortest gap between two plays of the same sound, in seconds. Keeps dense fire and hits readable.
const MIN_GAP := 0.045
const PITCH_SPREAD := 0.06

const SOUNDS := {
	# Weapons: one signature per chassis (plan 11.3).
	"shot_rifle": {"bus": "Weapons", "wave": "saw", "notes": [[760.0, 170.0, 0.09]], "noise": 0.25, "lowpass": 0.6},
	"shot_smg": {"bus": "Weapons", "wave": "square", "notes": [[1150.0, 380.0, 0.05]], "noise": 0.15, "volume": 0.45},
	"shot_cannon": {"bus": "Weapons", "wave": "saw", "notes": [[260.0, 45.0, 0.32]], "noise": 0.5, "lowpass": 0.25, "volume": 0.8},
	"shot_shotgun": {"bus": "Weapons", "wave": "saw", "notes": [[340.0, 70.0, 0.18]], "noise": 0.7, "lowpass": 0.45, "volume": 0.7},
	# Hits and destruction.
	"hit": {"bus": "Sfx", "wave": "tri", "notes": [[520.0, 260.0, 0.035]], "noise": 0.5, "volume": 0.35},
	"crit": {"bus": "Sfx", "wave": "sine", "notes": [[1700.0, 2300.0, 0.09]], "volume": 0.45},
	"enemy_down": {"bus": "Sfx", "wave": "tri", "notes": [[420.0, 60.0, 0.22]], "noise": 0.55, "lowpass": 0.35},
	"explosion": {"bus": "Sfx", "wave": "sine", "notes": [[140.0, 28.0, 0.7]], "noise": 0.75, "lowpass": 0.12, "volume": 0.9, "curve": 1.5},
	"hurt": {"bus": "Sfx", "wave": "saw", "notes": [[240.0, 70.0, 0.28]], "noise": 0.4, "lowpass": 0.3, "volume": 0.8},
	"shield": {"bus": "Sfx", "wave": "sine", "notes": [[520.0, 780.0, 0.1], [780.0, 1040.0, 0.16]], "volume": 0.5},
	# Gates.
	"gate_good": {"bus": "Sfx", "wave": "tri", "notes": [[660.0, 660.0, 0.07], [990.0, 990.0, 0.14]], "volume": 0.5},
	"gate_bad": {"bus": "Sfx", "wave": "saw", "notes": [[330.0, 150.0, 0.22]], "volume": 0.5},
	"gate_grow": {"bus": "Sfx", "wave": "sine", "notes": [[880.0, 1320.0, 0.08]], "volume": 0.4},
	# Boss.
	"boss_warn": {"bus": "Sfx", "wave": "square", "notes": [[440.0, 440.0, 0.09], [330.0, 330.0, 0.12]], "volume": 0.4},
	"boss_shot": {"bus": "Sfx", "wave": "saw", "notes": [[180.0, 90.0, 0.2]], "noise": 0.3, "lowpass": 0.3, "volume": 0.6},
	"phase": {"bus": "Sfx", "wave": "saw", "notes": [[90.0, 620.0, 0.6]], "noise": 0.2, "lowpass": 0.4, "curve": 0.6, "volume": 0.7},
	# Run results.
	"win": {"bus": "Sfx", "wave": "tri", "curve": 1.0, "volume": 0.6,
		"notes": [[523.0, 523.0, 0.14], [659.0, 659.0, 0.14], [784.0, 784.0, 0.14], [1047.0, 1047.0, 0.5]]},
	"lose": {"bus": "Sfx", "wave": "saw", "curve": 1.0, "volume": 0.5,
		"notes": [[392.0, 392.0, 0.2], [311.0, 311.0, 0.2], [196.0, 150.0, 0.6]]},
	# Menu: quiet, short, soft (plan 11.3).
	"ui_tap": {"bus": "Ui", "wave": "sine", "notes": [[820.0, 700.0, 0.04]], "volume": 0.4},
	"ui_buy": {"bus": "Ui", "wave": "tri", "notes": [[700.0, 700.0, 0.06], [1050.0, 1050.0, 0.06], [1400.0, 1400.0, 0.16]], "volume": 0.5},
}

var _streams: Dictionary = {}
var _players: Dictionary = {}
var _next: Dictionary = {}
var _last_played: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	AudioServer.add_bus_effect(0, AudioEffectHardLimiter.new())
	for bus: String in BUSES:
		AudioServer.add_bus()
		var index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, bus)
		AudioServer.set_bus_volume_db(index, BUSES[bus])
		var pool: Array[AudioStreamPlayer] = []
		for i in int(VOICES[bus]):
			var player := AudioStreamPlayer.new()
			player.bus = bus
			add_child(player)
			pool.append(player)
		_players[bus] = pool
		_next[bus] = 0
	for id: String in SOUNDS:
		_streams[id] = Synth.make(SOUNDS[id])
	# Every button in the game gets the tap sound without each screen wiring it up.
	get_tree().node_added.connect(_on_node_added)


## Plays a sound with slight random pitch. pitch scales it further, for example per weapon core.
func play(id: String, pitch: float = 1.0) -> void:
	var now := Time.get_ticks_msec() * 0.001
	if now - float(_last_played.get(id, -1.0)) < MIN_GAP:
		return
	_last_played[id] = now
	var bus: String = SOUNDS[id]["bus"]
	var pool: Array = _players[bus]
	var player: AudioStreamPlayer = pool[_next[bus]]
	_next[bus] = (int(_next[bus]) + 1) % pool.size()
	player.stream = _streams[id]
	player.pitch_scale = pitch * randf_range(1.0 - PITCH_SPREAD, 1.0 + PITCH_SPREAD)
	player.play()


## Shot of the given chassis, coloured by the core: cryo glassy and high, plasma deep, shock sharp.
func shot(chassis: String, core: String) -> void:
	var pitch := 1.0
	match core:
		"cryo":
			pitch = 1.35
		"plasma":
			pitch = 0.75
		"shock":
			pitch = 1.15
	var id := "shot_" + chassis
	play(id if SOUNDS.has(id) else "shot_rifle", pitch)


func _on_node_added(node: Node) -> void:
	var button := node as BaseButton
	if button != null:
		button.pressed.connect(play.bind("ui_tap"))

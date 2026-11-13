extends Node3D
## M1 core-loop prototype: drive one level, steer, auto-fire, pick gates, survive three enemy types, beat the boss.
## The platform stays at z = 0. Everything on the track moves towards it (+z). Collisions are simple distance checks.
# ponytail: one controller script for the whole run. Split into director, combat and enemy behaviours
# when M2 adds more content than fits here.

enum State { RUNNING, BOSS, WON, LOST }

const SPEED := 8.0
const SPAWN_DISTANCE := 60.0
const TRACK_HALF := 2.2
const DRAG_SCALE := 0.011
const KEY_SPEED := 7.0
const STEER_SPEED := 18.0
const PLAYER_RADIUS := 0.7
const MAX_SHIELD := 3
const INVULNERABLE_TIME := 1.0
const BULLET_SPACING := 0.35
const BULLET_HEIGHT := 0.65
const BULLET_HIT_RADIUS := 0.12
const MAX_BULLETS := 320
const BURST_INTERVAL := 0.07
const CRIT_MULTIPLIER := 2.5
const CHAIN_RANGE := 3.5
const BOUNCE_RANGE := 12.0
const SLOW_TIME := 1.5
const SPLIT_ANGLE := 0.5
const SPLIT_DAMAGE := 0.4
const MUZZLE_Z := -2.0
const BOSS_STOP_Z := -22.0
const BOSS_HALF_WIDTH := 2.4
const ORB_SPEED := 11.0
const TELEGRAPH_TIME := 0.9
const LANES := [-2.0, 0.0, 2.0]

const BULLET_BASIS := Basis(Vector3.RIGHT, PI / 2.0)


class Enemy:
	var node: Node3D
	var kind := ""
	var hp := 0.0
	var speed := 0.0
	var radius := 0.0
	var damage := 0
	var coins := 0
	var pulse := 0.0
	var timer := 0.0
	var target_x := 0.0
	var slow_time := 0.0
	## Emissive material of the model's shell and its resting glow, for hit flashes.
	var shell: StandardMaterial3D
	var glow := 0.0


class Bullet:
	var pos := Vector3.ZERO
	var vel := Vector3.ZERO
	var damage := 0.0
	var radius := 0.0
	var age := 0.0
	var travelled := 0.0
	var pierce := 0
	var bounce := 0
	var split := false
	## Enemy hit last. Skipped so a piercing or bouncing projectile does not hit it twice.
	var last_hit: Enemy


class Gate:
	var node: Node3D
	var sides: Array[Dictionary] = []
	var labels: Array[Label3D] = []
	var hits: Array[int] = [0, 0]
	var passed := false


class Telegraph:
	var node: Node3D
	var x := 0.0
	var time_left := TELEGRAPH_TIME


var _level: Dictionary = LevelData.LEVEL_1
var _events: Array = _level["events"]
var _length: float = _level["length"]
var _next_event := 0
var _distance := 0.0
var _scroll := SPEED
var _state := State.RUNNING
var _time := 0.0
var _loadout := Arsenal.owned_loadout(Save.data)
var _stats := Arsenal.stats_for(Save.data, _loadout)
var _shield := MAX_SHIELD
var _invulnerable := 0.0
var _kills := 0
var _coins := 0
var _target_x := 0.0
var _fire_cooldown := 0.0
var _burst_left := 0
var _burst_timer := 0.0
var _leech_count := 0

var _bullets: Array[Bullet] = []
var _enemies: Array[Enemy] = []
var _gates: Array[Gate] = []
var _orbs: Array[Node3D] = []
var _telegraphs: Array[Telegraph] = []
var _boss: Node3D
var _boss_hp := 0.0
var _boss_pulse := 0.0
var _boss_shell: StandardMaterial3D
var _enraged := false
var _boss_attack := 1.5
var _boss_spawn := 4.0

var _floor_mat: ShaderMaterial
var _pillars: Array[Node3D] = []
var _far_pillars: Array[Node3D] = []
var _camera: Camera3D
var _shake := 0.0
var _sparks: Array[CPUParticles3D] = []
var _next_spark := 0
var _platform: Node3D
var _flash: OmniLight3D
var _core_mat: StandardMaterial3D
var _bullet_mesh: MultiMeshInstance3D
var _explosions: Array[CPUParticles3D] = []
var _next_explosion := 0
var _hud: RunHud


func _ready() -> void:
	get_tree().quit_on_go_back = false
	_camera = RunArt.environment(self)
	_floor_mat = RunArt.track(self)
	_pillars = RunArt.pillars(self, 26, 5.5, 13.0, 12.0)
	_far_pillars = RunArt.pillars(self, 16, 18.0, 34.0, 30.0)
	_platform = RunArt.platform(_loadout, _stats.color)
	_platform.position.y = 0.6
	add_child(_platform)
	_flash = _platform.get_node("Muzzle/Flash") as OmniLight3D
	_core_mat = (_platform.get_node("Core") as MeshInstance3D).material_override as StandardMaterial3D
	_bullet_mesh = RunArt.bullets(MAX_BULLETS, _stats.color)
	add_child(_bullet_mesh)
	for color: Color in [RunArt.MAGENTA, RunArt.MAGENTA, RunArt.MAGENTA, RunArt.AMBER, RunArt.LIME,
			RunArt.MAGENTA, RunArt.MAGENTA, RunArt.CYAN]:
		var particles := RunArt.explosion(color)
		add_child(particles)
		_explosions.append(particles)
	for i in 10:
		var spark := RunArt.spark(_stats.color)
		add_child(spark)
		_sparks.append(spark)

	_hud = RunHud.new()
	add_child(_hud)
	_hud.back_pressed.connect(_go_back)
	_hud.pause_pressed.connect(_set_paused.bind(true))
	_hud.resume_pressed.connect(_set_paused.bind(false))
	_hud.restart_pressed.connect(_restart)
	_hud.arsenal_pressed.connect(_open_arsenal)
	_hud.set_shield(_shield, MAX_SHIELD)
	_hud.set_stats(_stats)
	_hud.set_coins(_coins)
	Audio.music("level")


func _exit_tree() -> void:
	get_tree().quit_on_go_back = true
	Engine.time_scale = 1.0


## Android back toggles the pause menu. Leaving the app pauses the run (plan 4.1).
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			if _playing():
				_set_paused(not get_tree().paused)
			else:
				_go_back()
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			if _playing():
				_set_paused(true)


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused and _playing()
	_hud.show_pause(get_tree().paused)


func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


## Relative drag: finger anywhere on screen, platform follows the movement (plan 4.2).
## Touch arrives as emulated mouse events on Android, so this one handler covers both.
func _unhandled_input(event: InputEvent) -> void:
	var motion := event as InputEventMouseMotion
	if motion and motion.button_mask & MOUSE_BUTTON_MASK_LEFT and _playing():
		_target_x = clampf(_target_x + motion.relative.x * DRAG_SCALE, -TRACK_HALF, TRACK_HALF)


func _process(delta: float) -> void:
	_time += delta
	if _playing():
		_update_player(delta)
		_spawn_events()
		_update_fire(delta)
		if _state == State.RUNNING:
			_hud.set_progress(_distance / _length)
	_distance += _scroll * delta
	_update_bullets(delta)
	_update_enemies(delta)
	_update_gates(delta)
	_update_boss(delta)
	_update_orbs(delta)
	_update_scenery(delta)


func _playing() -> bool:
	return _state == State.RUNNING or _state == State.BOSS


# --- Player -----------------------------------------------------------------

func _update_player(delta: float) -> void:
	var key_dir := Input.get_axis("ui_left", "ui_right")
	_target_x = clampf(_target_x + key_dir * KEY_SPEED * delta, -TRACK_HALF, TRACK_HALF)
	var x := move_toward(_platform.position.x, _target_x, STEER_SPEED * delta)
	_platform.rotation.z = clampf((_platform.position.x - x) / maxf(delta, 0.001) * 0.02, -0.35, 0.35)
	_platform.position.x = x
	_platform.position.y = 0.6 + sin(_time * 3.0) * 0.05
	_invulnerable = maxf(_invulnerable - delta, 0.0)
	_platform.visible = _invulnerable == 0.0 or fmod(_time, 0.16) < 0.1


func _update_fire(delta: float) -> void:
	if _burst_left > 0:
		_burst_timer -= delta
		if _burst_timer <= 0.0:
			_burst_timer = BURST_INTERVAL
			_burst_left -= 1
			_fire_volley()
	_fire_cooldown -= delta
	if _fire_cooldown > 0.0:
		return
	_fire_cooldown = maxf(_fire_cooldown + 1.0 / _stats.fire_rate, 0.0)
	_fire_volley()
	_burst_left = _stats.burst - 1
	_burst_timer = BURST_INTERVAL


## One trigger pull: projectiles side by side, or fanned out when the weapon has spread.
func _fire_volley() -> void:
	var count := _stats.projectiles
	var origin := Vector3(_platform.position.x, BULLET_HEIGHT, MUZZLE_Z)
	for i in count:
		var offset := i - (count - 1) * 0.5
		if _stats.spread > 0.0:
			_spawn_bullet(origin, deg_to_rad(offset * _stats.spread), _stats.damage, _stats.split)
		else:
			_spawn_bullet(origin + Vector3(offset * BULLET_SPACING, 0.0, 0.0), 0.0, _stats.damage, _stats.split)
	_flash.light_energy = 5.0
	Audio.shot(_loadout["chassis"], _loadout["core"])


## angle in radians from straight ahead, positive to the right. Returns null when the pool is full.
func _spawn_bullet(pos: Vector3, angle: float, damage: float, split: bool) -> Bullet:
	if _bullets.size() >= MAX_BULLETS:
		return null
	var bullet := Bullet.new()
	bullet.pos = pos
	bullet.vel = Vector3(sin(angle), 0.0, -cos(angle)) * _stats.speed
	bullet.damage = damage
	bullet.radius = BULLET_HIT_RADIUS + _stats.radius
	bullet.pierce = _stats.pierce
	bullet.bounce = _stats.bounce
	bullet.split = split
	_bullets.append(bullet)
	return bullet


func _hurt(amount: int) -> void:
	if _invulnerable > 0.0 or not _playing():
		return
	_shield -= amount
	_invulnerable = INVULNERABLE_TIME
	_shake = 0.5
	Audio.play("hurt")
	_hud.set_shield(_shield, MAX_SHIELD)
	if _shield <= 0:
		_lose()


# --- Bullets ----------------------------------------------------------------

func _update_bullets(delta: float) -> void:
	for i in range(_bullets.size() - 1, -1, -1):
		var bullet := _bullets[i]
		bullet.age += delta
		if _stats.homing > 0.0:
			_steer_homing(bullet, delta)
		var prev_z := bullet.pos.z
		bullet.pos += bullet.vel * delta
		if _stats.wave > 0.0:
			bullet.pos.x += cos(bullet.age * 12.0) * _stats.wave * 12.0 * delta
		bullet.travelled += _stats.speed * delta
		if bullet.travelled > _stats.range_m or absf(bullet.pos.x) > 6.0 or not _bullet_survives(bullet, prev_z):
			_bullets[i] = _bullets[_bullets.size() - 1]
			_bullets.resize(_bullets.size() - 1)
	var multi := _bullet_mesh.multimesh
	var basis := BULLET_BASIS.scaled(Vector3.ONE * (1.0 + _stats.radius * 3.0))
	multi.visible_instance_count = _bullets.size()
	for j in _bullets.size():
		multi.set_instance_transform(j, Transform3D(basis, _bullets[j].pos))


## Swept check between last and current z, so fast projectiles cannot skip a thin target.
## Returns false when the projectile is used up.
func _bullet_survives(bullet: Bullet, prev_z: float) -> bool:
	if not _playing():
		return true
	var near_z := maxf(prev_z, bullet.pos.z)
	var far_z := minf(prev_z, bullet.pos.z)
	for enemy in _enemies:
		if enemy == bullet.last_hit:
			continue
		var pos := enemy.node.position
		var reach := enemy.radius + bullet.radius
		if absf(pos.x - bullet.pos.x) < reach and far_z < pos.z + reach and near_z > pos.z - reach:
			return _bullet_hit_enemy(bullet, enemy)
	if _state == State.BOSS and absf(bullet.pos.x - _boss.position.x) < BOSS_HALF_WIDTH + bullet.radius \
			and far_z < _boss.position.z + 1.0:
		_spark(bullet.pos)
		_damage_boss(_roll_damage(bullet.damage))
		return false
	for gate in _gates:
		var z := gate.node.position.z
		if far_z <= z and near_z > z:
			var side := 0 if bullet.pos.x < 0.0 else 1
			if gate.sides[side].has("grow"):
				_grow_gate(gate, side)
				return false
	return true


## Applies hit, crit, chain, slow and split. Returns true if the projectile flies on (pierce, bounce).
func _bullet_hit_enemy(bullet: Bullet, enemy: Enemy) -> bool:
	var pos := enemy.node.position
	var damage := _roll_damage(bullet.damage)
	_spark(bullet.pos)
	var chained: Enemy = _nearest_enemy(pos, enemy, CHAIN_RANGE, false) if _stats.chain > 0.0 else null
	if _stats.slow > 0.0:
		enemy.slow_time = SLOW_TIME
	_damage_enemy(enemy, damage)
	if chained != null:
		_explode(chained.node.position)
		_damage_enemy(chained, damage * _stats.chain)
	if bullet.split:
		for side: float in [-1.0, 1.0]:
			var shard := _spawn_bullet(bullet.pos, side * SPLIT_ANGLE, bullet.damage * SPLIT_DAMAGE, false)
			if shard != null:
				shard.last_hit = enemy
				shard.pierce = 0
				shard.bounce = 0
	bullet.last_hit = enemy
	if bullet.pierce > 0:
		bullet.pierce -= 1
		return true
	if bullet.bounce > 0:
		var target := _nearest_enemy(pos, enemy, BOUNCE_RANGE, false)
		if target != null:
			bullet.bounce -= 1
			var direction := target.node.position - bullet.pos
			direction.y = 0.0
			bullet.vel = direction.normalized() * _stats.speed
			return true
	return false


func _roll_damage(base: float) -> float:
	if _stats.crit > 0.0 and randf() < _stats.crit:
		Audio.play("crit")
		return base * CRIT_MULTIPLIER
	return base


func _steer_homing(bullet: Bullet, delta: float) -> void:
	var target := _nearest_enemy(bullet.pos, bullet.last_hit, 20.0, true)
	if target == null:
		return
	var direction := target.node.position - bullet.pos
	direction.y = 0.0
	bullet.vel = bullet.vel.move_toward(direction.normalized() * _stats.speed, _stats.homing * _stats.speed * delta)


## Closest enemy within max_distance, ignoring exclude. ahead_only: only enemies further down the track.
func _nearest_enemy(pos: Vector3, exclude: Enemy, max_distance: float, ahead_only: bool) -> Enemy:
	var best: Enemy = null
	var best_distance := max_distance
	for enemy in _enemies:
		if enemy == exclude or (ahead_only and enemy.node.position.z > pos.z):
			continue
		var distance := pos.distance_to(enemy.node.position)
		if distance < best_distance:
			best = enemy
			best_distance = distance
	return best


# --- Enemies ----------------------------------------------------------------

func _spawn_events() -> void:
	while _next_event < _events.size():
		var event: Dictionary = _events[_next_event]
		var at: float = event["at"]
		if at > _distance + SPAWN_DISTANCE:
			return
		var z := _distance - at
		if event.has("enemy"):
			_spawn_enemies(event, z)
		elif event.has("boss"):
			_spawn_boss(z)
		else:
			_spawn_gate(event, z)
		_next_event += 1


## Groups spawn in rows of up to four, centred on event "x".
func _spawn_enemies(event: Dictionary, z: float) -> void:
	var kind: String = event["enemy"]
	var count: int = event["count"]
	var centre: float = event["x"]
	var def: Dictionary = LevelData.ENEMIES[kind]
	var columns := mini(count, 4)
	var spacing: float = def["radius"] * 2.0 + 0.2
	for i in count:
		var enemy := Enemy.new()
		enemy.kind = kind
		enemy.hp = def["hp"]
		enemy.speed = def["speed"]
		enemy.radius = def["radius"]
		enemy.damage = def["damage"]
		enemy.coins = def["coins"]
		enemy.timer = randf_range(0.5, 1.5)
		enemy.node = RunArt.enemy(kind)
		enemy.shell = (enemy.node.get_node("Shell") as MeshInstance3D).material_override as StandardMaterial3D
		enemy.glow = enemy.shell.emission_energy_multiplier
		var column := i % columns
		var x := clampf(centre + (column - (columns - 1) * 0.5) * spacing, -TRACK_HALF, TRACK_HALF)
		enemy.target_x = x
		enemy.node.position = Vector3(x, enemy.radius + 0.3, z - floorf(float(i) / columns) * spacing * 1.2)
		add_child(enemy.node)
		_enemies.append(enemy)


func _spawn_minions(z: float) -> void:
	_spawn_enemies({"enemy": "drone", "count": 3, "x": randf_range(-1.5, 1.5)}, z)


func _update_enemies(delta: float) -> void:
	for i in range(_enemies.size() - 1, -1, -1):
		var enemy := _enemies[i]
		var pos := enemy.node.position
		enemy.slow_time = maxf(enemy.slow_time - delta, 0.0)
		var slow := 1.0 - _stats.slow if enemy.slow_time > 0.0 else 1.0
		pos.z += (_scroll + enemy.speed) * slow * delta
		match enemy.kind:
			"drone":
				pos.y = enemy.radius + 0.3 + sin(_time * 2.5 + pos.x) * 0.15
			"jumper":
				enemy.timer -= delta
				if enemy.timer <= 0.0:
					enemy.timer = 1.3
					enemy.target_x = _other_lane(pos.x)
				pos.x = move_toward(pos.x, enemy.target_x, 5.0 * delta)
				pos.y = enemy.radius + 0.3 + absf(pos.x - enemy.target_x) * 0.6
		enemy.pulse = maxf(enemy.pulse - delta * 6.0, 0.0)
		enemy.node.scale = Vector3.ONE * (1.0 + 0.2 * enemy.pulse)
		enemy.shell.emission_energy_multiplier = enemy.glow + enemy.pulse * 4.0
		enemy.node.position = pos
		if _playing() and absf(pos.z) < enemy.radius + 0.5 and absf(pos.x - _platform.position.x) < enemy.radius + PLAYER_RADIUS:
			_hurt(enemy.damage)
			_explode(pos)
			_remove_enemy(enemy)
		elif pos.z > 3.0:
			_remove_enemy(enemy)


func _other_lane(x: float) -> float:
	var options: Array[float] = []
	for lane: float in LANES:
		if absf(lane - x) > 0.5:
			options.append(lane)
	return options.pick_random()


func _damage_enemy(enemy: Enemy, amount: float) -> void:
	enemy.hp -= amount
	enemy.pulse = 1.0
	if enemy.hp <= 0.0 and enemy in _enemies:
		_kills += 1
		Audio.play("enemy_down")
		_add_coins(enemy.coins)
		_explode(enemy.node.position)
		_remove_enemy(enemy)
		_count_leech()


## Chip "Schildraub": every n kills restore one shield point.
func _count_leech() -> void:
	if _stats.leech <= 0:
		return
	_leech_count += 1
	if _leech_count >= _stats.leech:
		_leech_count = 0
		if _shield < MAX_SHIELD:
			_shield += 1
			_hud.set_shield(_shield, MAX_SHIELD)
			_hud.toast("+1 SCHILD", RunArt.CYAN)
			Audio.play("shield")


func _remove_enemy(enemy: Enemy) -> void:
	enemy.node.queue_free()
	_enemies.erase(enemy)


# --- Gates ------------------------------------------------------------------

func _spawn_gate(event: Dictionary, z: float) -> void:
	var gate := Gate.new()
	gate.node = Node3D.new()
	gate.node.position.z = z
	RunArt.gate_posts(gate.node)
	for side in 2:
		var source: Dictionary = event["left"] if side == 0 else event["right"]
		var data := source.duplicate(true)
		gate.sides.append(data)
		var panel := RunArt.gate_panel(-1.5 if side == 0 else 1.5, _side_color(data), _side_text(data))
		gate.node.add_child(panel)
		gate.labels.append(panel.get_node("Label") as Label3D)
	add_child(gate.node)
	_gates.append(gate)


func _update_gates(delta: float) -> void:
	for i in range(_gates.size() - 1, -1, -1):
		var gate := _gates[i]
		gate.node.position.z += _scroll * delta
		if not gate.passed and gate.node.position.z >= 0.0 and _playing():
			gate.passed = true
			_pass_gate(gate.sides[0 if _platform.position.x < 0.0 else 1])
		if gate.node.position.z > 4.0:
			gate.node.queue_free()
			_gates.remove_at(i)


func _pass_gate(side: Dictionary) -> void:
	var lines: PackedStringArray = []
	for effect: Array in side["effects"]:
		_stats.apply(effect)
		lines.append(WeaponStats.describe(effect))
	_hud.set_stats(_stats)
	_hud.toast("\n".join(lines), _side_color(side))
	Audio.play("gate_bad" if _side_color(side) == RunArt.RED else "gate_good")


func _grow_gate(gate: Gate, side: int) -> void:
	gate.hits[side] += 1
	var data := gate.sides[side]
	if gate.hits[side] % int(data["per_hits"]) != 0:
		return
	var effect: Array = data["effects"][0]
	effect[2] = minf(float(effect[2]) + float(data["grow"]), float(data["max"]))
	gate.labels[side].text = _side_text(data)
	Audio.play("gate_grow")


func _side_text(side: Dictionary) -> String:
	var lines: PackedStringArray = []
	for effect: Array in side["effects"]:
		lines.append(WeaponStats.describe(effect))
	if side.has("grow"):
		lines.append("▲ BESCHIESSEN")
	return "\n".join(lines)


## Green = only good, red = only bad, amber = trade-off, cyan = shootable.
func _side_color(side: Dictionary) -> Color:
	if side.has("grow"):
		return RunArt.CYAN
	var good := 0
	var effects: Array = side["effects"]
	for effect: Array in effects:
		if WeaponStats.is_good(effect):
			good += 1
	if good == effects.size():
		return RunArt.GREEN
	return RunArt.RED if good == 0 else RunArt.AMBER


# --- Boss -------------------------------------------------------------------

func _spawn_boss(z: float) -> void:
	_boss = RunArt.boss()
	_boss_shell = (_boss.get_node("Shell") as MeshInstance3D).material_override as StandardMaterial3D
	_boss.position = Vector3(0.0, 1.6, z)
	_boss_hp = LevelData.BOSS_HP
	add_child(_boss)


## Phase 1: one telegraphed lane shot every 2.2 s. Phase 2 below half health: two lanes every 1.4 s plus drones.
func _update_boss(delta: float) -> void:
	for i in range(_telegraphs.size() - 1, -1, -1):
		var telegraph := _telegraphs[i]
		telegraph.time_left -= delta
		telegraph.node.visible = fmod(telegraph.time_left, 0.2) > 0.07
		if telegraph.time_left <= 0.0:
			if _state == State.BOSS:
				var orb := RunArt.orb()
				orb.position = Vector3(telegraph.x, 0.7, _boss.position.z + 1.5)
				Audio.play("boss_shot")
				add_child(orb)
				_orbs.append(orb)
			telegraph.node.queue_free()
			_telegraphs.remove_at(i)

	if _boss == null:
		return
	if _state == State.RUNNING:
		_boss.position.z += _scroll * delta
		if _boss.position.z >= BOSS_STOP_Z:
			_boss.position.z = BOSS_STOP_Z
			_scroll = 0.0
			_state = State.BOSS
			_hud.set_boss(1.0)
			_hud.toast("WÄCHTER", RunArt.MAGENTA)
			Audio.music("boss")
		return
	if _state != State.BOSS:
		return

	_boss.position.x = sin(_time * 0.6) * 1.0
	_boss_pulse = maxf(_boss_pulse - delta * 8.0, 0.0)
	_boss.scale = Vector3.ONE * (1.0 + 0.03 * _boss_pulse)
	_boss_shell.emission_energy_multiplier = 0.05 + _boss_pulse * 3.0
	var enraged := _boss_hp < LevelData.BOSS_HP * 0.5
	if enraged and not _enraged:
		_enraged = true
		_shake = 0.6
		_hud.toast("PHASE 2", RunArt.RED)
		Audio.play("phase")
		_slow_motion(0.35, 0.6)
	_boss_attack -= delta
	if _boss_attack <= 0.0:
		_boss_attack = 1.4 if enraged else 2.2
		var lanes := LANES.duplicate()
		lanes.shuffle()
		for lane: float in lanes.slice(0, 2 if enraged else 1):
			_telegraph(lane)
	if enraged:
		_boss_spawn -= delta
		if _boss_spawn <= 0.0:
			_boss_spawn = 5.0
			_spawn_minions(_boss.position.z + 2.0)


func _telegraph(lane: float) -> void:
	Audio.play("boss_warn")
	var telegraph := Telegraph.new()
	telegraph.x = lane
	telegraph.node = RunArt.lane_marker(-BOSS_STOP_Z)
	telegraph.node.position = Vector3(lane, 0.02, BOSS_STOP_Z * 0.5)
	add_child(telegraph.node)
	_telegraphs.append(telegraph)


func _damage_boss(amount: float) -> void:
	_boss_hp -= amount
	_boss_pulse = 1.0
	_hud.set_boss(maxf(_boss_hp, 0.0) / LevelData.BOSS_HP)
	if _boss_hp <= 0.0:
		_win()


func _update_orbs(delta: float) -> void:
	for i in range(_orbs.size() - 1, -1, -1):
		var orb := _orbs[i]
		orb.position.z += (ORB_SPEED + _scroll) * delta
		if _playing() and absf(orb.position.z) < 0.8 and absf(orb.position.x - _platform.position.x) < PLAYER_RADIUS + 0.4:
			_hurt(1)
			_explode(orb.position)
			orb.position.z = 99.0
		if orb.position.z > 3.0:
			orb.queue_free()
			_orbs.remove_at(i)


# --- End of run -------------------------------------------------------------

func _win() -> void:
	_state = State.WON
	_shake = 1.0
	Audio.play("explosion")
	Audio.music("")
	_slow_motion(0.25, 0.9)
	_add_coins(LevelData.BOSS_COINS + LevelData.WIN_COINS)
	for offset: Vector3 in [Vector3.ZERO, Vector3(-1.5, 0.5, 0.0), Vector3(1.5, -0.3, 0.0), Vector3(0.0, 1.0, 0.5)]:
		_explode(_boss.position + offset)
	_boss.queue_free()
	_boss = null
	for enemy: Enemy in _enemies.duplicate():
		_explode(enemy.node.position)
		_remove_enemy(enemy)
	for orb in _orbs:
		orb.queue_free()
	_orbs.clear()
	_scroll = SPEED
	_show_result_later(true)


func _lose() -> void:
	_state = State.LOST
	Audio.play("explosion")
	Audio.music("")
	_explode(_platform.position)
	_platform.hide()
	_scroll = 0.0
	_show_result_later(false)


func _add_coins(amount: int) -> void:
	_coins += amount
	_hud.set_coins(_coins)


## Books the run into the save before the result appears, so closing the app then loses nothing.
## Aborting with the back button gives nothing.
func _show_result_later(won: bool) -> void:
	var new_best: bool = Save.record_run(Save.data, _level["id"], won, _coins, _kills, _time)
	Save.save()
	var lines: PackedStringArray = [
		"Zeit %s%s" % [_format_time(_time), "  · neue Bestzeit" if new_best else ""],
		"Zerstört %d · Schild %d/%d" % [_kills, maxi(_shield, 0), MAX_SHIELD],
		"Schaden pro Sekunde %s" % WeaponStats.format_number(roundf(_stats.dps())),
	]
	await get_tree().create_timer(1.2).timeout
	Audio.play("win" if won else "lose")
	_hud.show_result(won, _coins, int(Save.data["coins"]), "\n".join(lines))


static func _format_time(seconds: float) -> String:
	return "%d:%02d" % [floori(seconds / 60.0), int(seconds) % 60]


# --- Scenery ----------------------------------------------------------------

func _update_scenery(delta: float) -> void:
	_floor_mat.set_shader_parameter("scroll", _distance)
	_core_mat.emission_energy_multiplier = 1.6 + 0.6 * sin(_time * 6.0)
	_flash.light_energy = move_toward(_flash.light_energy, 0.0, 60.0 * delta)
	for pillar in _pillars:
		pillar.position.z += _scroll * delta
		if pillar.position.z > 8.0:
			pillar.position.z -= 110.0
	for pillar in _far_pillars:
		pillar.position.z += _scroll * 0.5 * delta
		if pillar.position.z > 8.0:
			pillar.position.z -= 110.0
	_shake = maxf(_shake - delta * 2.5, 0.0)
	_camera.h_offset = randf_range(-1.0, 1.0) * _shake * 0.2
	_camera.v_offset = randf_range(-1.0, 1.0) * _shake * 0.2


## Short slow motion for boss moments (plan 11.1). The timer ignores the time scale.
func _slow_motion(factor: float, seconds: float) -> void:
	Engine.time_scale = factor
	await get_tree().create_timer(seconds, true, false, true).timeout
	Engine.time_scale = 1.0


func _spark(pos: Vector3) -> void:
	Audio.play("hit")
	var particles := _sparks[_next_spark]
	_next_spark = (_next_spark + 1) % _sparks.size()
	particles.global_position = pos
	particles.restart()


func _explode(pos: Vector3) -> void:
	var particles := _explosions[_next_explosion]
	_next_explosion = (_next_explosion + 1) % _explosions.size()
	particles.global_position = pos
	particles.restart()


func _go_back() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _open_arsenal() -> void:
	MainMenu.start_tab = "arsenal"
	_go_back()

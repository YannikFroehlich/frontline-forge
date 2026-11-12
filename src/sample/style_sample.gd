extends Node3D
## Style sample (M0 step 7): one weapon, one enemy, one gate on a scrolling track. Not gameplay.
# ponytail: throwaway scene built from primitives in code. Replaced by real scenes and models in M1/M2.

const SPEED := 10.0
const CYAN := Color(0.133, 0.882, 1.0)
const MAGENTA := Color(1.0, 0.24, 0.506)
const AMBER := Color(1.0, 0.69, 0.125)
const GREEN := Color(0.3, 1.0, 0.55)
const RED := Color(1.0, 0.3, 0.3)
const ENEMY_HP := 14

const FLOOR_SHADER := """
shader_type spatial;
uniform vec3 base_color : source_color = vec3(0.025, 0.035, 0.075);
uniform vec3 line_color : source_color = vec3(0.133, 0.882, 1.0);
uniform float scroll = 0.0;
uniform float cell = 2.5;
varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = vec2(world_pos.x, world_pos.z - scroll) / cell;
	vec2 g = abs(fract(p - 0.5) - 0.5) / fwidth(p);
	float line = 1.0 - min(min(g.x, g.y), 1.0);
	ALBEDO = base_color;
	METALLIC = 0.7;
	ROUGHNESS = 0.35;
	EMISSION = line_color * line * 0.9;
}
"""

var _time := 0.0
var _floor_mat: ShaderMaterial
var _platform: Node3D
var _muzzle: Node3D
var _flash: OmniLight3D
var _core_mat: StandardMaterial3D
var _bullet_mat: StandardMaterial3D
var _bullets: Array[MeshInstance3D] = []
var _fire_cooldown := 0.0
var _boost_time := 0.0
var _enemy: Node3D
var _enemy_ring: Node3D
var _enemy_shell: StandardMaterial3D
var _enemy_hp := ENEMY_HP
var _enemy_flash := 0.0
var _explosion: CPUParticles3D
var _gate: Node3D
var _gate_passed := false
var _pillars: Array[Node3D] = []
var _fps_label: Label
var _status_label: Label


func _ready() -> void:
	get_tree().quit_on_go_back = false
	_build_environment()
	_build_track()
	_build_platform()
	_build_enemy()
	_build_gate()
	_build_pillars()
	_build_ui()
	_respawn_enemy()


func _exit_tree() -> void:
	get_tree().quit_on_go_back = true


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_go_back()


func _process(delta: float) -> void:
	_time += delta
	_floor_mat.set_shader_parameter("scroll", _time * SPEED)

	var target_x := _enemy.position.x
	_platform.position.x = move_toward(_platform.position.x, target_x, 2.5 * delta)
	_platform.position.y = 0.6 + sin(_time * 3.0) * 0.05
	_platform.rotation.z = clampf((_platform.position.x - target_x) * 0.25, -0.3, 0.3)
	_core_mat.emission_energy_multiplier = 1.6 + 0.6 * sin(_time * 6.0)
	_flash.light_energy = move_toward(_flash.light_energy, 0.0, 60.0 * delta)

	_update_fire(delta)
	_update_bullets(delta)
	_update_enemy(delta)
	_update_gate(delta)
	_update_pillars(delta)
	_fps_label.text = "%d FPS" % Engine.get_frames_per_second()


# --- Update ---------------------------------------------------------------

func _update_fire(delta: float) -> void:
	_boost_time = maxf(_boost_time - delta, 0.0)
	_status_label.visible = _boost_time > 0.0
	_fire_cooldown -= delta
	if _fire_cooldown > 0.0:
		return
	_fire_cooldown = 0.07 if _boost_time > 0.0 else 0.13
	for bullet in _bullets:
		if not bullet.visible:
			bullet.global_position = _muzzle.global_position
			bullet.visible = true
			_flash.light_energy = 5.0
			return


func _update_bullets(delta: float) -> void:
	for bullet in _bullets:
		if not bullet.visible:
			continue
		bullet.position.z -= 45.0 * delta
		if bullet.position.z < -70.0:
			bullet.visible = false
		elif _enemy.visible and bullet.position.distance_to(_enemy.position) < 0.9:
			bullet.visible = false
			_hit_enemy()


func _update_enemy(delta: float) -> void:
	_enemy.position.z += SPEED * 0.45 * delta
	_enemy.position.y = 1.0 + sin(_time * 2.5) * 0.25
	_enemy_ring.rotate_y(delta * 3.0)
	_enemy_flash = maxf(_enemy_flash - delta * 6.0, 0.0)
	_enemy_shell.emission = MAGENTA.lerp(Color.WHITE, _enemy_flash)
	_enemy_shell.emission_energy_multiplier = 0.5 + _enemy_flash * 4.0
	if _enemy.position.z > 1.5:
		_respawn_enemy()


func _hit_enemy() -> void:
	_enemy_hp -= 1
	_enemy_flash = 1.0
	if _enemy_hp <= 0:
		_explosion.global_position = _enemy.global_position
		_explosion.restart()
		_respawn_enemy()


func _respawn_enemy() -> void:
	_enemy.position = Vector3(randf_range(-2.0, 2.0), 1.0, -55.0)
	_enemy_hp = ENEMY_HP


func _update_gate(delta: float) -> void:
	_gate.position.z += SPEED * delta
	if not _gate_passed and _gate.position.z > _platform.position.z:
		_gate_passed = true
		if _platform.position.x < 0.0:
			_boost_time = 3.0
	if _gate.position.z > 4.0:
		_gate.position.z = -70.0
		_gate_passed = false


func _update_pillars(delta: float) -> void:
	for pillar in _pillars:
		pillar.position.z += SPEED * delta
		if pillar.position.z > 8.0:
			pillar.position.z -= 110.0


# --- Build ----------------------------------------------------------------

func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.03, 0.07)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.3, 0.35, 0.5)
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.9
	env.glow_bloom = 0.05
	env.glow_hdr_threshold = 0.9
	env.fog_enabled = true
	env.fog_light_color = Color(0.05, 0.07, 0.16)
	env.fog_density = 0.025
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, 25.0, 0.0)
	sun.light_color = Color(0.75, 0.82, 1.0)
	sun.light_energy = 0.7
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 30.0
	add_child(sun)

	var camera := Camera3D.new()
	camera.fov = 68.0
	camera.position = Vector3(0.0, 4.4, 6.8)
	add_child(camera)
	camera.look_at(Vector3(0.0, 0.6, -10.0))


func _build_track() -> void:
	var shader := Shader.new()
	shader.code = FLOOR_SHADER
	_floor_mat = ShaderMaterial.new()
	_floor_mat.shader = shader
	var plane := PlaneMesh.new()
	plane.size = Vector2(6.0, 200.0)
	var track := _mesh(plane, _floor_mat, Vector3(0.0, 0.0, -90.0))
	add_child(track)

	var rail_mesh := BoxMesh.new()
	rail_mesh.size = Vector3(0.12, 0.12, 200.0)
	var rail_mat := _mat(CYAN, 3.0)
	for side: float in [-1.0, 1.0]:
		add_child(_mesh(rail_mesh, rail_mat, Vector3(3.06 * side, 0.06, -90.0)))


func _build_platform() -> void:
	_platform = Node3D.new()
	add_child(_platform)
	var metal := _mat(Color(0.16, 0.18, 0.24), 0.0, 0.8, 0.35)
	var dark := _mat(Color(0.08, 0.09, 0.12), 0.0, 0.6, 0.5)

	var base := CylinderMesh.new()
	base.top_radius = 0.9
	base.bottom_radius = 1.0
	base.height = 0.22
	base.radial_segments = 8
	_platform.add_child(_mesh(base, dark, Vector3(0.0, -0.3, 0.0)))
	var ring := TorusMesh.new()
	ring.inner_radius = 0.95
	ring.outer_radius = 1.05
	ring.rings = 24
	ring.ring_segments = 6
	_platform.add_child(_mesh(ring, _mat(CYAN, 4.0), Vector3(0.0, -0.42, 0.0)))

	var body := BoxMesh.new()
	body.size = Vector3(0.55, 0.42, 1.5)
	_platform.add_child(_mesh(body, metal, Vector3.ZERO))
	var stripe := BoxMesh.new()
	stripe.size = Vector3(0.57, 0.06, 1.0)
	_platform.add_child(_mesh(stripe, _mat(AMBER, 2.5), Vector3(0.0, 0.05, 0.1)))
	var fin := BoxMesh.new()
	fin.size = Vector3(0.9, 0.05, 0.5)
	for side: float in [-1.0, 1.0]:
		_platform.add_child(_mesh(fin, metal, Vector3(0.55 * side, -0.12, 0.35)))

	var barrel := CylinderMesh.new()
	barrel.top_radius = 0.11
	barrel.bottom_radius = 0.14
	barrel.height = 1.3
	barrel.radial_segments = 10
	var barrel_node := _mesh(barrel, dark, Vector3(0.0, 0.05, -1.25))
	barrel_node.rotation_degrees.x = -90.0
	_platform.add_child(barrel_node)
	var muzzle_ring := TorusMesh.new()
	muzzle_ring.inner_radius = 0.13
	muzzle_ring.outer_radius = 0.2
	var muzzle_node := _mesh(muzzle_ring, _mat(CYAN, 5.0), Vector3(0.0, 0.05, -1.88))
	muzzle_node.rotation_degrees.x = 90.0
	_platform.add_child(muzzle_node)

	_core_mat = _mat(Color(0.7, 0.95, 1.0), 3.0)
	var core := SphereMesh.new()
	core.radius = 0.12
	core.height = 0.24
	_platform.add_child(_mesh(core, _core_mat, Vector3(0.0, 0.3, 0.25)))

	_muzzle = Node3D.new()
	_muzzle.position = Vector3(0.0, 0.05, -2.0)
	_platform.add_child(_muzzle)
	_flash = OmniLight3D.new()
	_flash.light_color = CYAN
	_flash.omni_range = 5.0
	_flash.light_energy = 0.0
	_muzzle.add_child(_flash)

	var bullet_mesh := CapsuleMesh.new()
	bullet_mesh.radius = 0.06
	bullet_mesh.height = 0.6
	bullet_mesh.radial_segments = 6
	bullet_mesh.rings = 2
	_bullet_mat = _mat(CYAN, 6.0)
	for i in 40:
		var bullet := _mesh(bullet_mesh, _bullet_mat, Vector3.ZERO)
		bullet.rotation_degrees.x = 90.0
		bullet.visible = false
		bullet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(bullet)
		_bullets.append(bullet)


func _build_enemy() -> void:
	_enemy = Node3D.new()
	add_child(_enemy)
	_enemy_shell = _mat(Color(0.12, 0.05, 0.1), 0.5, 0.6, 0.4)
	_enemy_shell.emission = MAGENTA
	var shell := SphereMesh.new()
	shell.radius = 0.6
	shell.height = 1.0
	shell.radial_segments = 6
	shell.rings = 3
	_enemy.add_child(_mesh(shell, _enemy_shell, Vector3.ZERO))
	var eye := SphereMesh.new()
	eye.radius = 0.2
	eye.height = 0.4
	_enemy.add_child(_mesh(eye, _mat(MAGENTA, 5.0), Vector3(0.0, 0.0, 0.5)))
	_enemy_ring = Node3D.new()
	_enemy.add_child(_enemy_ring)
	var ring := TorusMesh.new()
	ring.inner_radius = 0.85
	ring.outer_radius = 0.95
	ring.ring_segments = 4
	var ring_node := _mesh(ring, _mat(MAGENTA, 3.0), Vector3.ZERO)
	ring_node.rotation_degrees.x = 20.0
	_enemy_ring.add_child(ring_node)

	_explosion = CPUParticles3D.new()
	_explosion.emitting = false
	_explosion.one_shot = true
	_explosion.amount = 48
	_explosion.lifetime = 0.9
	_explosion.explosiveness = 1.0
	_explosion.direction = Vector3.UP
	_explosion.spread = 180.0
	_explosion.initial_velocity_min = 3.0
	_explosion.initial_velocity_max = 9.0
	_explosion.gravity = Vector3(0.0, -9.0, 0.0)
	var shrink := Curve.new()
	shrink.add_point(Vector2(0.0, 1.0))
	shrink.add_point(Vector2(1.0, 0.0))
	_explosion.scale_amount_curve = shrink
	var shard := BoxMesh.new()
	shard.size = Vector3.ONE * 0.14
	shard.material = _mat(MAGENTA, 6.0)
	_explosion.mesh = shard
	add_child(_explosion)


func _build_gate() -> void:
	_gate = Node3D.new()
	_gate.position.z = -40.0
	add_child(_gate)
	var post := BoxMesh.new()
	post.size = Vector3(0.12, 2.2, 0.12)
	var post_mat := _mat(Color(0.8, 0.85, 1.0), 2.0)
	for x: float in [-3.0, 0.0, 3.0]:
		_gate.add_child(_mesh(post, post_mat, Vector3(x, 1.1, 0.0)))
	_gate.add_child(_gate_panel(-1.5, GREEN, "FEUERRATE\n+100 %"))
	_gate.add_child(_gate_panel(1.5, RED, "SCHADEN\n−20 %"))


func _gate_panel(x: float, color: Color, text: String) -> Node3D:
	var panel := Node3D.new()
	panel.position = Vector3(x, 1.1, 0.0)
	var mat := _mat(color, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(color, 0.25)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var box := BoxMesh.new()
	box.size = Vector3(2.85, 2.0, 0.04)
	var glass := _mesh(box, mat, Vector3.ZERO)
	glass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	panel.add_child(glass)
	var label := Label3D.new()
	label.text = text
	label.font_size = 72
	label.outline_size = 12
	label.pixel_size = 0.006
	label.position.z = 0.05
	label.modulate = Color.WHITE
	label.outline_modulate = Color(color.darkened(0.6), 1.0)
	panel.add_child(label)
	return panel


func _build_pillars() -> void:
	var body_mat := _mat(Color(0.06, 0.07, 0.11), 0.0, 0.5, 0.6)
	var cap_mats: Array[StandardMaterial3D] = [_mat(CYAN, 3.0), _mat(MAGENTA, 3.0), _mat(AMBER, 2.5)]
	for i in 26:
		var pillar := Node3D.new()
		var side := -1.0 if i % 2 == 0 else 1.0
		var height := randf_range(2.0, 12.0)
		var width := randf_range(1.0, 2.5)
		pillar.position = Vector3(side * randf_range(5.5, 13.0), 0.0, -100.0 + i * 4.2)
		var body := BoxMesh.new()
		body.size = Vector3(width, height, width)
		pillar.add_child(_mesh(body, body_mat, Vector3(0.0, height * 0.5, 0.0)))
		var cap := BoxMesh.new()
		cap.size = Vector3(width + 0.06, 0.1, width + 0.06)
		pillar.add_child(_mesh(cap, cap_mats[i % cap_mats.size()], Vector3(0.0, height, 0.0)))
		add_child(pillar)
		_pillars.append(pillar)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var back := Button.new()
	back.text = "← Zurück"
	back.add_theme_font_size_override("font_size", 28)
	back.position = Vector2(24.0, 56.0)
	back.custom_minimum_size = Vector2(200.0, 72.0)
	back.pressed.connect(_go_back)
	layer.add_child(back)

	_fps_label = Label.new()
	_fps_label.add_theme_font_size_override("font_size", 24)
	_fps_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
	_fps_label.anchor_left = 1.0
	_fps_label.anchor_right = 1.0
	_fps_label.offset_left = -160.0
	_fps_label.offset_right = -24.0
	_fps_label.offset_top = 70.0
	_fps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	layer.add_child(_fps_label)

	_status_label = Label.new()
	_status_label.text = "FEUERRATE +100 %"
	_status_label.add_theme_font_size_override("font_size", 36)
	_status_label.add_theme_color_override("font_color", GREEN)
	_status_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_status_label.offset_left = -300.0
	_status_label.offset_right = 300.0
	_status_label.offset_top = 170.0
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.visible = false
	layer.add_child(_status_label)

	var caption := Label.new()
	caption.text = "Stilprobe · kein Gameplay"
	caption.add_theme_font_size_override("font_size", 22)
	caption.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 0.8))
	caption.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	caption.offset_left = -300.0
	caption.offset_right = 300.0
	caption.offset_top = -80.0
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layer.add_child(caption)


func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/boot.tscn")


# --- Helpers --------------------------------------------------------------

func _mat(color: Color, emission: float = 0.0, metallic: float = 0.2, roughness: float = 0.5) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = roughness
	if emission > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission
	return mat


func _mesh(mesh: Mesh, material: Material, pos: Vector3) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = material
	node.position = pos
	return node

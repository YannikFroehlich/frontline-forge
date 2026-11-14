class_name RunArt
## Meshes, materials and effects of the run, built from primitives in code (plan 11.1):
## clear shapes carried by light, glowing edges and particles instead of texture detail.
## The weapon model is assembled from the equipped parts.
# ponytail: new materials per spawn. Share them if the enemy count per level grows a lot.

const CYAN := Color(0.133, 0.882, 1.0)
const MAGENTA := Color(1.0, 0.24, 0.506)
const AMBER := Color(1.0, 0.69, 0.125)
const GREEN := Color(0.3, 1.0, 0.55)
const RED := Color(1.0, 0.3, 0.3)
const LIME := Color(0.7, 1.0, 0.2)

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


const SKY_SHADER := """
shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled;
uniform vec3 top_color : source_color = vec3(0.01, 0.015, 0.05);
uniform vec3 horizon_color : source_color = vec3(0.35, 0.08, 0.3);
uniform vec3 sun_color : source_color = vec3(1.0, 0.45, 0.25);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float height = 1.0 - uv.y;
	vec3 color = mix(horizon_color, top_color, smoothstep(0.0, 0.55, height));
	// Low sun with horizontal cuts.
	vec2 sun_uv = (uv - vec2(0.5, 0.92)) * vec2(2.6, 1.0);
	float sun = smoothstep(0.17, 0.165, length(sun_uv));
	float cuts = step(0.35, fract(height * 60.0 - TIME * 0.05)) + smoothstep(0.1, 0.16, height);
	color = mix(color, sun_color * 1.6, sun * clamp(cuts, 0.0, 1.0));
	// Sparse twinkling stars in the upper part.
	vec2 cell = floor(uv * vec2(1100.0, 420.0));
	float star = step(0.9975, hash(cell)) * smoothstep(0.2, 0.5, height);
	color += vec3(star) * (0.6 + 0.4 * sin(TIME * 2.0 + hash(cell + 1.0) * 6.28));
	ALBEDO = color;
}
"""


## Builds light, fog, glow, sky and camera. Returns the camera for screen shake.
static func environment(parent: Node) -> Camera3D:
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
	env.fog_density = 0.02
	var world := WorldEnvironment.new()
	world.environment = env
	parent.add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, 25.0, 0.0)
	sun.light_color = Color(0.75, 0.82, 1.0)
	sun.light_energy = 0.7
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 30.0
	parent.add_child(sun)

	var camera := Camera3D.new()
	# Fixed horizontal view: tall phones show more sky instead of cutting off the track edges.
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.fov = 48.0
	camera.position = Vector3(0.0, 5.2, 7.2)
	parent.add_child(camera)
	camera.look_at(Vector3(0.0, 0.4, -12.0))

	var sky_shader := Shader.new()
	sky_shader.code = SKY_SHADER
	var sky_mat := ShaderMaterial.new()
	sky_mat.shader = sky_shader
	var sky := QuadMesh.new()
	sky.size = Vector2(520.0, 200.0)
	var sky_node := mesh(sky, sky_mat, Vector3(0.0, 86.0, -230.0))
	sky_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(sky_node)
	return camera


## Returns the floor material, its "scroll" parameter moves the grid.
static func track(parent: Node) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = FLOOR_SHADER
	var floor_mat := ShaderMaterial.new()
	floor_mat.shader = shader
	var plane := PlaneMesh.new()
	plane.size = Vector2(6.0, 200.0)
	parent.add_child(mesh(plane, floor_mat, Vector3(0.0, 0.0, -90.0)))
	var rail_mesh := BoxMesh.new()
	rail_mesh.size = Vector3(0.12, 0.12, 200.0)
	var rail_mat := mat(CYAN, 3.0)
	for side: float in [-1.0, 1.0]:
		parent.add_child(mesh(rail_mesh, rail_mat, Vector3(3.06 * side, 0.06, -90.0)))
	return floor_mat


## Row of towers on both sides. near/far = distance from the track centre. The run moves the far,
## taller layer slower for depth.
static func pillars(parent: Node, count: int, near: float, far: float, max_height: float) -> Array[Node3D]:
	var result: Array[Node3D] = []
	var body_mat := mat(Color(0.06, 0.07, 0.11), 0.0, 0.5, 0.6)
	var cap_mats: Array[StandardMaterial3D] = [mat(CYAN, 3.0), mat(MAGENTA, 3.0), mat(AMBER, 2.5)]
	for i in count:
		var pillar := Node3D.new()
		var side := -1.0 if i % 2 == 0 else 1.0
		var height := randf_range(max_height * 0.2, max_height)
		var width := randf_range(1.0, 2.5) * (far / 13.0)
		pillar.position = Vector3(side * randf_range(near, far), 0.0, -100.0 + i * (110.0 / count))
		var body := BoxMesh.new()
		body.size = Vector3(width, height, width)
		pillar.add_child(mesh(body, body_mat, Vector3(0.0, height * 0.5, 0.0)))
		var cap := BoxMesh.new()
		cap.size = Vector3(width + 0.06, 0.1, width + 0.06)
		pillar.add_child(mesh(cap, cap_mats[i % cap_mats.size()], Vector3(0.0, height, 0.0)))
		parent.add_child(pillar)
		result.append(pillar)
	return result


## Weapon platform assembled from the loadout: chassis shape, barrel layout, core colour, chip light.
## Children used by the run: "Muzzle" (with "Flash"), "Core".
static func platform(loadout: Dictionary, core_color: Color) -> Node3D:
	var root := Node3D.new()
	var metal := mat(Color(0.16, 0.18, 0.24), 0.0, 0.8, 0.35)
	var dark := mat(Color(0.08, 0.09, 0.12), 0.0, 0.6, 0.5)
	var glow := mat(core_color, 4.0)

	var base := CylinderMesh.new()
	base.top_radius = 0.9
	base.bottom_radius = 1.0
	base.height = 0.22
	base.radial_segments = 8
	root.add_child(mesh(base, dark, Vector3(0.0, -0.3, 0.0)))
	var ring := TorusMesh.new()
	ring.inner_radius = 0.95
	ring.outer_radius = 1.05
	ring.rings = 24
	ring.ring_segments = 6
	root.add_child(mesh(ring, mat(CYAN, 4.0), Vector3(0.0, -0.42, 0.0)))

	# Chassis: body size, barrel thickness and extra blocks.
	var body_size := Vector3(0.55, 0.42, 1.5)
	var barrel_scale := 1.0
	match loadout["chassis"]:
		"smg":
			body_size = Vector3(0.5, 0.36, 1.0)
			barrel_scale = 0.75
			for side: float in [-1.0, 1.0]:
				root.add_child(_box(Vector3(0.16, 0.2, 0.7), metal, Vector3(0.36 * side, -0.02, 0.0)))
		"cannon":
			body_size = Vector3(0.8, 0.62, 1.3)
			barrel_scale = 1.6
			root.add_child(_box(Vector3(1.0, 0.3, 0.5), dark, Vector3(0.0, -0.1, 0.55)))
		"shotgun":
			body_size = Vector3(0.9, 0.4, 1.1)
			barrel_scale = 1.15
			root.add_child(_box(Vector3(1.1, 0.46, 0.3), dark, Vector3(0.0, 0.0, -0.6)))
	root.add_child(_box(body_size, metal, Vector3.ZERO))
	root.add_child(_box(Vector3(body_size.x + 0.02, 0.06, body_size.z * 0.65), mat(AMBER, 2.5), Vector3(0.0, 0.05, 0.1)))
	for side: float in [-1.0, 1.0]:
		root.add_child(_box(Vector3(0.9, 0.05, 0.5), metal, Vector3((body_size.x * 0.5 + 0.3) * side, -0.12, 0.35)))

	# Barrel: one tube, a fan of three, a tight bundle of three, or a tube with glowing coils.
	var front := -body_size.z * 0.5
	match loadout["barrel"]:
		"fan":
			for angle: float in [-0.22, 0.0, 0.22]:
				root.add_child(_barrel(0.09 * barrel_scale, 0.9, dark, Vector3(0.0, 0.05, front), angle))
		"burst":
			for offset: Vector2 in [Vector2(0.0, 0.12), Vector2(-0.11, -0.06), Vector2(0.11, -0.06)]:
				root.add_child(_barrel(0.07 * barrel_scale, 1.2, dark,
						Vector3(offset.x * barrel_scale, 0.05 + offset.y * barrel_scale, front), 0.0))
		"wave":
			root.add_child(_barrel(0.1 * barrel_scale, 1.2, dark, Vector3(0.0, 0.05, front), 0.0))
			var coil := TorusMesh.new()
			coil.inner_radius = 0.13 * barrel_scale
			coil.outer_radius = 0.19 * barrel_scale
			for i in 3:
				var coil_node := mesh(coil, glow, Vector3(0.0, 0.05, front - 0.3 - i * 0.35))
				coil_node.rotation_degrees.x = 90.0
				root.add_child(coil_node)
		_:
			root.add_child(_barrel(0.12 * barrel_scale, 1.3, dark, Vector3(0.0, 0.05, front), 0.0))
	var muzzle_ring := TorusMesh.new()
	muzzle_ring.inner_radius = 0.13 * barrel_scale
	muzzle_ring.outer_radius = 0.2 * barrel_scale
	var muzzle_node := mesh(muzzle_ring, glow, Vector3(0.0, 0.05, front - 1.2))
	muzzle_node.rotation_degrees.x = 90.0
	root.add_child(muzzle_node)

	var core := SphereMesh.new()
	core.radius = 0.13
	core.height = 0.26
	var core_node := mesh(core, mat(core_color.lerp(Color.WHITE, 0.5), 3.0, 0.2, 0.5, core_color),
			Vector3(0.0, body_size.y * 0.5 + 0.08, 0.25))
	core_node.name = "Core"
	root.add_child(core_node)

	# Chip: small amber antenna, only when a chip is installed.
	if loadout["chip"] != "none":
		var chip_x := body_size.x * 0.5 - 0.06
		root.add_child(_box(Vector3(0.05, 0.3, 0.05), dark, Vector3(chip_x, body_size.y * 0.5 + 0.15, 0.5)))
		root.add_child(_box(Vector3(0.1, 0.1, 0.1), mat(AMBER, 5.0), Vector3(chip_x, body_size.y * 0.5 + 0.34, 0.5)))

	var muzzle := Node3D.new()
	muzzle.name = "Muzzle"
	muzzle.position = Vector3(0.0, 0.05, -2.0)
	root.add_child(muzzle)
	var flash := OmniLight3D.new()
	flash.name = "Flash"
	flash.light_color = core_color
	flash.omni_range = 5.0
	flash.light_energy = 0.0
	muzzle.add_child(flash)
	return root


static func _box(size: Vector3, material: Material, pos: Vector3) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size
	return mesh(box, material, pos)


## Tube pointing forward (-z) from start, turned by angle (radians) around the vertical axis.
static func _barrel(radius: float, length: float, material: Material, start: Vector3, angle: float) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = start
	pivot.rotation.y = -angle
	var tube := CylinderMesh.new()
	tube.top_radius = radius
	tube.bottom_radius = radius * 1.25
	tube.height = length
	tube.radial_segments = 10
	var node := mesh(tube, material, Vector3(0.0, 0.0, -length * 0.5))
	node.rotation_degrees.x = -90.0
	pivot.add_child(node)
	return pivot


## Enemy model. The child named "Shell" has its own emissive material, the run flashes it on hits.
static func enemy(kind: String) -> Node3D:
	var root := Node3D.new()
	match kind:
		"drone":
			var shell := SphereMesh.new()
			shell.radius = 0.5
			shell.height = 0.8
			shell.radial_segments = 6
			shell.rings = 3
			root.add_child(_shell(shell, mat(Color(0.12, 0.05, 0.1), 0.6, 0.6, 0.4, MAGENTA)))
			var eye := SphereMesh.new()
			eye.radius = 0.16
			eye.height = 0.32
			root.add_child(mesh(eye, mat(MAGENTA, 5.0), Vector3(0.0, 0.0, 0.42)))
			var ring := TorusMesh.new()
			ring.inner_radius = 0.65
			ring.outer_radius = 0.73
			ring.ring_segments = 4
			var ring_node := mesh(ring, mat(MAGENTA, 3.0), Vector3.ZERO)
			ring_node.rotation_degrees.x = 20.0
			root.add_child(ring_node)
		"tank":
			var hull := BoxMesh.new()
			hull.size = Vector3(2.0, 1.1, 1.8)
			root.add_child(_shell(hull, mat(Color(0.14, 0.12, 0.08), 0.05, 0.7, 0.4, AMBER)))
			var armor := BoxMesh.new()
			armor.size = Vector3(2.2, 0.9, 0.2)
			root.add_child(mesh(armor, mat(Color(0.25, 0.2, 0.1), 0.4, 0.7, 0.4, AMBER), Vector3(0.0, 0.0, 1.0)))
			var visor := BoxMesh.new()
			visor.size = Vector3(1.4, 0.12, 0.05)
			root.add_child(mesh(visor, mat(AMBER, 5.0), Vector3(0.0, 0.2, 1.12)))
		"jumper":
			var body := SphereMesh.new()
			body.radius = 0.6
			body.height = 1.2
			body.radial_segments = 4
			body.rings = 2
			root.add_child(_shell(body, mat(Color(0.08, 0.12, 0.04), 0.6, 0.6, 0.4, LIME)))
			var eye := SphereMesh.new()
			eye.radius = 0.15
			eye.height = 0.3
			root.add_child(mesh(eye, mat(LIME, 5.0), Vector3(0.0, 0.1, 0.5)))
	return root


static func _shell(shape: Mesh, material: Material) -> MeshInstance3D:
	var node := mesh(shape, material, Vector3.ZERO)
	node.name = "Shell"
	return node


## Boss model, also with a "Shell" child for hit flashes.
static func boss() -> Node3D:
	var root := Node3D.new()
	var hull := BoxMesh.new()
	hull.size = Vector3(4.4, 2.4, 2.0)
	root.add_child(_shell(hull, mat(Color(0.1, 0.05, 0.1), 0.05, 0.8, 0.35, MAGENTA)))
	var band := BoxMesh.new()
	band.size = Vector3(4.5, 0.15, 2.05)
	root.add_child(mesh(band, mat(MAGENTA, 3.0), Vector3(0.0, 0.6, 0.0)))
	var core := SphereMesh.new()
	core.radius = 0.55
	core.height = 1.1
	var core_node := mesh(core, mat(MAGENTA, 4.0), Vector3(0.0, -0.1, 1.0))
	core_node.name = "Core"
	root.add_child(core_node)
	var arm := BoxMesh.new()
	arm.size = Vector3(0.8, 0.8, 2.6)
	for side: float in [-1.0, 1.0]:
		root.add_child(mesh(arm, mat(Color(0.14, 0.07, 0.14), 0.0, 0.8, 0.35), Vector3(2.6 * side, -0.4, 0.4)))
	return root


## Gate side panel. The text label is the child named "Label".
static func gate_panel(x: float, color: Color, text: String) -> Node3D:
	var panel := Node3D.new()
	panel.position = Vector3(x, 1.1, 0.0)
	var glass := mat(color, 0.5)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.albedo_color = Color(color, 0.25)
	glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	var box := BoxMesh.new()
	box.size = Vector3(2.85, 2.0, 0.04)
	var pane := mesh(box, glass, Vector3.ZERO)
	pane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	panel.add_child(pane)
	var label := Label3D.new()
	label.name = "Label"
	label.text = text
	label.font_size = 72
	label.outline_size = 12
	label.pixel_size = 0.0055
	label.position.z = 0.05
	label.outline_modulate = Color(color.darkened(0.6), 1.0)
	panel.add_child(label)
	return panel


static func gate_posts(parent: Node3D) -> void:
	var post := BoxMesh.new()
	post.size = Vector3(0.12, 2.2, 0.12)
	var post_mat := mat(Color(0.8, 0.85, 1.0), 2.0)
	for x: float in [-3.0, 0.0, 3.0]:
		parent.add_child(mesh(post, post_mat, Vector3(x, 1.1, 0.0)))


## Red floor strip that announces a boss shot in one lane.
static func lane_marker(length: float) -> MeshInstance3D:
	var strip := BoxMesh.new()
	strip.size = Vector3(1.6, 0.02, length)
	var marker_mat := mat(RED, 2.0)
	marker_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	marker_mat.albedo_color = Color(RED, 0.35)
	var node := mesh(strip, marker_mat, Vector3.ZERO)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node


static func orb() -> MeshInstance3D:
	var sphere := SphereMesh.new()
	sphere.radius = 0.45
	sphere.height = 0.9
	var node := mesh(sphere, mat(RED, 4.0), Vector3.ZERO)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node


## All player bullets in one draw call.
static func bullets(count: int, color: Color) -> MultiMeshInstance3D:
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.06
	capsule.height = 0.9
	capsule.radial_segments = 6
	capsule.rings = 2
	capsule.material = mat(color, 6.0)
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = capsule
	multi.instance_count = count
	multi.visible_instance_count = 0
	var node := MultiMeshInstance3D.new()
	node.multimesh = multi
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node


static func explosion(color: Color) -> CPUParticles3D:
	var particles := CPUParticles3D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 32
	particles.lifetime = 0.8
	particles.explosiveness = 1.0
	particles.direction = Vector3.UP
	particles.spread = 180.0
	particles.initial_velocity_min = 3.0
	particles.initial_velocity_max = 9.0
	particles.gravity = Vector3(0.0, -9.0, 0.0)
	var shrink := Curve.new()
	shrink.add_point(Vector2(0.0, 1.0))
	shrink.add_point(Vector2(1.0, 0.0))
	particles.scale_amount_curve = shrink
	var shard := BoxMesh.new()
	shard.size = Vector3.ONE * 0.14
	shard.material = mat(color, 6.0)
	particles.mesh = shard
	return particles


## Short burst of a few sparks where a projectile hits.
static func spark(color: Color) -> CPUParticles3D:
	var particles := explosion(color)
	particles.amount = 6
	particles.lifetime = 0.25
	particles.initial_velocity_min = 2.0
	particles.initial_velocity_max = 5.0
	particles.direction = Vector3(0.0, 0.3, 1.0)
	particles.spread = 50.0
	return particles


static func mat(color: Color, emission: float = 0.0, metallic: float = 0.2, roughness: float = 0.5,
		emission_color: Color = Color.TRANSPARENT) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.metallic = metallic
	result.roughness = roughness
	if emission > 0.0:
		result.emission_enabled = true
		result.emission = color if emission_color.a == 0.0 else emission_color
		result.emission_energy_multiplier = emission
	return result


static func mesh(shape: Mesh, material: Material, pos: Vector3) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = shape
	node.material_override = material
	node.position = pos
	return node

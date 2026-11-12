class_name RunArt
## Gray-box meshes and materials for the M1 prototype, built from primitives in code.
## Look follows the approved style sample (M0 step 7).
# ponytail: primitives only, new materials per spawn. Real models and shared materials come with the art pass.

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


static func environment(parent: Node) -> void:
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


static func pillars(parent: Node) -> Array[Node3D]:
	var result: Array[Node3D] = []
	var body_mat := mat(Color(0.06, 0.07, 0.11), 0.0, 0.5, 0.6)
	var cap_mats: Array[StandardMaterial3D] = [mat(CYAN, 3.0), mat(MAGENTA, 3.0), mat(AMBER, 2.5)]
	for i in 26:
		var pillar := Node3D.new()
		var side := -1.0 if i % 2 == 0 else 1.0
		var height := randf_range(2.0, 12.0)
		var width := randf_range(1.0, 2.5)
		pillar.position = Vector3(side * randf_range(5.5, 13.0), 0.0, -100.0 + i * 4.2)
		var body := BoxMesh.new()
		body.size = Vector3(width, height, width)
		pillar.add_child(mesh(body, body_mat, Vector3(0.0, height * 0.5, 0.0)))
		var cap := BoxMesh.new()
		cap.size = Vector3(width + 0.06, 0.1, width + 0.06)
		pillar.add_child(mesh(cap, cap_mats[i % cap_mats.size()], Vector3(0.0, height, 0.0)))
		parent.add_child(pillar)
		result.append(pillar)
	return result


## Children used by the run: "Muzzle" (with "Flash"), "Core".
static func platform() -> Node3D:
	var root := Node3D.new()
	var metal := mat(Color(0.16, 0.18, 0.24), 0.0, 0.8, 0.35)
	var dark := mat(Color(0.08, 0.09, 0.12), 0.0, 0.6, 0.5)

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

	var body := BoxMesh.new()
	body.size = Vector3(0.55, 0.42, 1.5)
	root.add_child(mesh(body, metal, Vector3.ZERO))
	var stripe := BoxMesh.new()
	stripe.size = Vector3(0.57, 0.06, 1.0)
	root.add_child(mesh(stripe, mat(AMBER, 2.5), Vector3(0.0, 0.05, 0.1)))
	var fin := BoxMesh.new()
	fin.size = Vector3(0.9, 0.05, 0.5)
	for side: float in [-1.0, 1.0]:
		root.add_child(mesh(fin, metal, Vector3(0.55 * side, -0.12, 0.35)))

	var barrel := CylinderMesh.new()
	barrel.top_radius = 0.11
	barrel.bottom_radius = 0.14
	barrel.height = 1.3
	barrel.radial_segments = 10
	var barrel_node := mesh(barrel, dark, Vector3(0.0, 0.05, -1.25))
	barrel_node.rotation_degrees.x = -90.0
	root.add_child(barrel_node)

	var core := SphereMesh.new()
	core.radius = 0.12
	core.height = 0.24
	var core_node := mesh(core, mat(Color(0.7, 0.95, 1.0), 3.0), Vector3(0.0, 0.3, 0.25))
	core_node.name = "Core"
	root.add_child(core_node)

	var muzzle := Node3D.new()
	muzzle.name = "Muzzle"
	muzzle.position = Vector3(0.0, 0.05, -2.0)
	root.add_child(muzzle)
	var flash := OmniLight3D.new()
	flash.name = "Flash"
	flash.light_color = CYAN
	flash.omni_range = 5.0
	flash.light_energy = 0.0
	muzzle.add_child(flash)
	return root


static func enemy(kind: String) -> Node3D:
	var root := Node3D.new()
	match kind:
		"drone":
			var shell := SphereMesh.new()
			shell.radius = 0.5
			shell.height = 0.8
			shell.radial_segments = 6
			shell.rings = 3
			root.add_child(mesh(shell, mat(Color(0.12, 0.05, 0.1), 0.6, 0.6, 0.4, MAGENTA), Vector3.ZERO))
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
			root.add_child(mesh(hull, mat(Color(0.14, 0.12, 0.08), 0.0, 0.7, 0.4), Vector3.ZERO))
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
			root.add_child(mesh(body, mat(Color(0.08, 0.12, 0.04), 0.6, 0.6, 0.4, LIME), Vector3.ZERO))
			var eye := SphereMesh.new()
			eye.radius = 0.15
			eye.height = 0.3
			root.add_child(mesh(eye, mat(LIME, 5.0), Vector3(0.0, 0.1, 0.5)))
	return root


static func boss() -> Node3D:
	var root := Node3D.new()
	var hull := BoxMesh.new()
	hull.size = Vector3(4.4, 2.4, 2.0)
	root.add_child(mesh(hull, mat(Color(0.1, 0.05, 0.1), 0.0, 0.8, 0.35), Vector3.ZERO))
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
static func bullets(count: int) -> MultiMeshInstance3D:
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.06
	capsule.height = 0.6
	capsule.radial_segments = 6
	capsule.rings = 2
	capsule.material = mat(CYAN, 6.0)
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

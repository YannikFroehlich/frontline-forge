class_name WeaponPreview
extends SubViewportContainer
## Rotating 3D model of a loadout for the arsenal (plan 11.1: weapon preview on a turntable).
## Renders in its own small world so it does not depend on a running level.

const BACKGROUND := Color(0.102, 0.133, 0.22)

var _pivot: Node3D
var _model: Node3D
var _key := ""


func _ready() -> void:
	stretch = true
	custom_minimum_size = Vector2(0.0, 260.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var viewport := SubViewport.new()
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_2X
	add_child(viewport)

	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = BACKGROUND
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.4, 0.45, 0.6)
	env.ambient_light_energy = 2.0
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.8
	env.glow_hdr_threshold = 0.9
	var world := WorldEnvironment.new()
	world.environment = env
	viewport.add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45.0, 30.0, 0.0)
	light.light_energy = 2.5
	viewport.add_child(light)
	var camera := Camera3D.new()
	camera.fov = 34.0
	camera.position = Vector3(0.0, 1.5, 3.6)
	viewport.add_child(camera)
	camera.look_at(Vector3(0.0, -0.1, 0.0))
	_pivot = Node3D.new()
	viewport.add_child(_pivot)


func _process(delta: float) -> void:
	_pivot.rotate_y(delta * 0.7)


## Rebuilds the model only when the loadout or colour actually changed.
func show_loadout(loadout: Dictionary, core_color: Color) -> void:
	var key := str(loadout) + core_color.to_html()
	if key == _key:
		return
	_key = key
	if _model != null:
		_model.queue_free()
	_model = RunArt.platform(loadout, core_color)
	# The barrel reaches further forward than the body goes back; shift so it turns around its middle.
	_model.position.z = 0.6
	_pivot.add_child(_model)

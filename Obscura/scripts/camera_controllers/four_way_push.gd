class_name FourWayPushBox
extends CameraControllerBase

@export var push_ratio: float = 0.5
@export var pushbox_top_left: Vector2 = Vector2(-10.0, -6.0)
@export var pushbox_bottom_right: Vector2 = Vector2(10.0, 6.0)
@export var speedup_zone_top_left: Vector2 = Vector2(-5.0, -3.0)
@export var speedup_zone_bottom_right: Vector2 = Vector2(5.0, 3.0)

func _ready() -> void:
	super()
	position = target.position

func _process(delta: float) -> void:
	if !current or target == null:
		return
	
	if draw_camera_logic:
		draw_logic()
	
	var tpos = target.global_position
	var cpos = global_position
	var in_speedup_zone = (tpos.x >= cpos.x + speedup_zone_top_left.x and tpos.x <= cpos.x + speedup_zone_bottom_right.x and tpos.z >= cpos.z + speedup_zone_top_left.y and tpos.z <= cpos.z + speedup_zone_bottom_right.y)

	if !in_speedup_zone:
		global_position.x = lerp(global_position.x, tpos.x, push_ratio * delta)
		global_position.z = lerp(global_position.z, tpos.z, push_ratio * delta)

	#boundary checks
	#left
	var left_edge = cpos.x + pushbox_top_left.x
	if tpos.x < left_edge:
		global_position.x += (tpos.x - left_edge) * push_ratio
	
	#right
	var right_edge = cpos.x + pushbox_bottom_right.x
	if tpos.x > right_edge:
		global_position.x += (tpos.x - right_edge) * push_ratio
	
	#top
	var top_edge = cpos.z + pushbox_top_left.y
	if tpos.z < top_edge:
		global_position.z += (tpos.z - top_edge) * push_ratio
	
	#bottom
	var bottom_edge = cpos.z + pushbox_bottom_right.y
	if tpos.z > bottom_edge:
		global_position.z += (tpos.z - bottom_edge) * push_ratio

	super(delta)

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_top_left.y))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_top_left.y))
	immediate_mesh.surface_end()

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_top_left.y))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_top_left.y))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()

class_name HorizontalScroll
extends CameraControllerBase

@export var top_left: Vector2 = Vector2(-5, 5)  
@export var bottom_right: Vector2 = Vector2(5, -5)
@export var autoscroll_speed: Vector3 = Vector3(0.0, 0.0, 0.0)

func _ready() -> void:
	super()
	position = target.position

func _process(delta: float) -> void:
	if !current:
		return

	position.x += autoscroll_speed.x * delta
	position.z += autoscroll_speed.z * delta

	keep_player_within_bounds()

	if draw_camera_logic:
		draw_logic()

	super(delta)

func keep_player_within_bounds() -> void:
	var left_edge_x = position.x + top_left.x
	var right_edge_x = position.x + bottom_right.x
	var top_edge_z = position.z + top_left.y
	var bottom_edge_z = position.z + bottom_right.y
	
	if target.global_position.x < left_edge_x:
		target.global_position.x = left_edge_x

	if target.global_position.x > right_edge_x:
		target.global_position.x = right_edge_x

	if target.global_position.z > top_edge_z:
		target.global_position.z = top_edge_z
	elif target.global_position.z < bottom_edge_z:
		target.global_position.z = bottom_edge_z

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	# Set up the box boundaries directly from top_left and bottom_right
	var left = top_left.x
	var right = bottom_right.x
	var top = top_left.y
	var bottom = bottom_right.y

	# Begin drawing the box as a line loop
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_end()

	# Set material properties
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	# Add the mesh to the scene and position it around the target
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	# Free the mesh after one frame
	await get_tree().process_frame
	mesh_instance.queue_free()

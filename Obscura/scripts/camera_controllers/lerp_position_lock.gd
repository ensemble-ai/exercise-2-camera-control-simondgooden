class_name LerpPositionLock
extends CameraControllerBase

@export var follow_speed: float = 200.0  
@export var catchup_speed: float = 5.0  
@export var leash_distance: float = 10.0 

func _ready() -> void:
	super()
	position = target.position

func _process(delta: float) -> void:
	if !current:
		return
	
	update_camera_position(delta)
	
	if draw_camera_logic:
		draw_logic()
	
	super(delta)

func update_camera_position(delta: float) -> void:
	var dist_to_target: float = position.distance_to(target.global_position)
	position = position.lerp(target.global_position, catchup_speed * delta / dist_to_target)
	
	if dist_to_target >= leash_distance:
		print("greater than lerp")

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var half_size: float = 2.5
	var left: float = -half_size
	var right: float = half_size
	var top: float = -half_size
	var bottom: float = half_size
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(left, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, bottom))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	# Free the mesh after one frame
	await get_tree().process_frame
	mesh_instance.queue_free()

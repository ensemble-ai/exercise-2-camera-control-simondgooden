class_name TargetLerpCamera
extends CameraControllerBase

@export var lead_speed: float = 250.0  
@export var catchup_speed: float = 5.0  
@export var leash_distance: float = 10.0 
@export var catchup_delay_duration: float = 0.5 

var catchup_timer: float = 0.0  
var target_last_position: Vector3 
var is_moving: bool = false 

func _ready() -> void:
	position = target.global_position
	target_last_position = target.global_position
	super()

func _process(delta: float) -> void:
	if !current:
		return
	
	update_camera_position(delta)
	
	if draw_camera_logic:
		draw_logic()
	
	super(delta)

func update_camera_position(delta: float) -> void:
	var target_direction = (target.global_position - target_last_position).normalized()
	var target_xz: Vector2 = Vector2(target.global_position.x, target.global_position.z)
	var camera_xz: Vector2 = Vector2(position.x, position.z)
	var dist_to_target: float = camera_xz.distance_to(target_xz)

	if target.global_position.distance_to(target_last_position) > 0.01:
		is_moving = true
		catchup_timer = 0.0 
	else:
		is_moving = false
		catchup_timer += delta

	target_last_position = target.global_position

	if is_moving and dist_to_target < leash_distance:
		var lead_position = target.global_position + target_direction * leash_distance
		position = position.move_toward(Vector3(lead_position.x, position.y, lead_position.z), lead_speed * delta)
	elif catchup_timer >= catchup_delay_duration:
		position = position.move_toward(Vector3(target.global_position.x, position.y, target.global_position.z), catchup_speed * delta)
	else:
		var speed_multiplier: float
		if target.velocity.length() > 100.0:
			speed_multiplier = 500.0
		else:
			speed_multiplier = 50.0
		position = position.lerp(Vector3(target.global_position.x, position.y, target.global_position.z), speed_multiplier * delta / max(dist_to_target, 1.0))


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
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()

extends CharacterBody3D

var speed = 7
const ACCEL_DEFAULT = 10
const ACCEL_AIR = 1
@onready var accel = ACCEL_DEFAULT
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump = 5

var cam_accel = 40
var mouse_sense = 0.1

var angular_velocity = 30

var direction = Vector3.ZERO
var gravity_vec = Vector3()

@onready var head = $Head
@onready var campivot = $Head/CamPivot
@onready var mesh = $MeshInstance


func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#mesh no longer inherits rotation of parent, allowing it to rotate freely
	mesh.top_level = true
	
func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _process(delta):
	#physics interpolation to reduce jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
		campivot.top_level = true
		campivot.global_transform.origin = campivot.global_transform.origin.lerp(head.global_transform.origin, cam_accel * delta)
		campivot.rotation.y = rotation.y
		campivot.rotation.x = head.rotation.x
		mesh.global_transform.origin = mesh.global_transform.origin.lerp(global_transform.origin, cam_accel * delta)
	else:
		campivot.top_level = false
		campivot.global_transform = head.global_transform
		mesh.global_transform.origin = global_transform.origin

	#turns body in the direction of movement
	if direction != Vector3.ZERO:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), angular_velocity * delta)

func _physics_process(delta):
	#get keyboard input
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = (transform.basis * Vector3(direction.x, 0, direction.y)).normalized()
	
	#jumping and gravity
	if is_on_floor():
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
		if Input.is_action_just_pressed("ui_accept"):
			gravity_vec = Vector3.UP * jump
	else:
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
	
	#make it move
	velocity = velocity.lerp(direction * speed, accel * delta)
	velocity += gravity_vec
	
	move_and_slide()

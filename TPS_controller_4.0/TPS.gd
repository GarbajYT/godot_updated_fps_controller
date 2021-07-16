extends KinematicBody

var speed = 7
const ACCEL_DEFAULT = 10
const ACCEL_AIR = 1
@onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 5

var cam_accel = 40
var mouse_sense = 0.1
var snap

var angular_velocity = 30

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

@onready var head = $Head
@onready var campivot = $Head/CamPivot
@onready var mesh = $MeshInstance

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#mesh no longer inherits rotation of parent, allowing it to rotate freely
	mesh.set_as_toplevel(true)
	
func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _process(delta):
	#physics interpolation to reduce jitter on high refresh-rate monitors
	var fps = Engine.get_frames_per_second()
	if fps > Engine.iterations_per_second:
		campivot.set_as_toplevel(true)
		campivot.global_transform.origin = campivot.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		campivot.rotation.y = rotation.y
		campivot.rotation.x = head.rotation.x
		mesh.global_transform.origin = mesh.global_transform.origin.linear_interpolate(global_transform.origin, cam_accel * delta)
	else:
		campivot.set_as_toplevel(false)
		campivot.global_transform = head.global_transform
		mesh.global_transform.origin = global_transform.origin

	#turns body in the direction of movement
	if direction != Vector3.ZERO:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), angular_velocity * delta)

func _physics_process(delta):
	#get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
	
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)
	
	
	

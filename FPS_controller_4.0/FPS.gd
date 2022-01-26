extends CharacterBody3D

var speed = 17
const ACCEL_DEFAULT = 14
const ACCEL_AIR = 12

@onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 5

var cam_accel = 40
var mouse_sense = 0.1

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()

@onready var head = $Head
@onready var camera = $Head/Camera

func _ready():
	# hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _process(delta):
	camera.global_transform = head.global_transform
		
func _physics_process(delta):
	# get keyboard input
	var h_rot = transform.basis.get_euler().y
	var f_input = Input.get_axis("move_forward", "move_backward")
	var h_input = Input.get_axis("move_left", "move_right")

	direction = Vector3(h_input, 0, f_input).rotated(up_direction, h_rot).normalized()
	
	# jumping and gravity
	if is_on_floor():
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		gravity_vec = up_direction * jump
	
	# make it move
	motion_velocity = velocity.lerp(direction * speed, accel * delta) + gravity_vec
	
	move_and_slide()


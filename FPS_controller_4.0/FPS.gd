extends CharacterBody3D

var speed = 7
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
@onready var accel = ACCEL_DEFAULT
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump = 5

var cam_accel = 40
var mouse_sense = 0.1

var gravity_vec = Vector3()

@onready var head = $Head
@onready var camera = $Head/Camera

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
		camera.top_level = true
		camera.global_transform.origin = camera.global_transform.origin.lerp(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.top_level = false
		camera.global_transform = head.global_transform
		
func _physics_process(delta):
	#get keyboard input
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
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

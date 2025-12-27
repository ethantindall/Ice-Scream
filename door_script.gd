extends Node3D  # Root of the door

@export var is_open: bool = false
@export var open_angle: float = 90.0  # how much it rotates when opened
@export var open_speed: float = 6.0   # rotation speed

var target_rotation: float = 0.0
var closed_rotation: float = 0.0

func _ready():
	# Store the original rotation as "closed"
	closed_rotation = rotation_degrees.y
	target_rotation = closed_rotation

func toggle():
	if is_open:
		# Close the door
		is_open = false
		target_rotation = closed_rotation
		print("closing")
	else:
		# Open the door
		is_open = true
		target_rotation = closed_rotation + open_angle
		print("opening")

func _physics_process(delta: float):
	# Smoothly rotate door toward target
	rotation_degrees.y = lerp(rotation_degrees.y, target_rotation, delta * open_speed)

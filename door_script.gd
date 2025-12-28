extends Node3D  # Root of the door

@export var is_open: bool = false
@export var open_angle: float = 90.0
@export var open_speed: float = 6.0
@export var item_name: String = "Door"
@export var locked: bool = false  # door can be locked

var target_rotation: float = 0.0
var closed_rotation: float = 0.0

func _ready():
	closed_rotation = rotation_degrees.y
	target_rotation = closed_rotation
		

func toggle():
	if locked:
		print(item_name + " is locked!")
		return

	if is_open:
		is_open = false
		target_rotation = closed_rotation
		print("closing")
	else:
		is_open = true
		target_rotation = closed_rotation + open_angle
		print("opening")

func _physics_process(delta: float):
	rotation_degrees.y = lerp(rotation_degrees.y, target_rotation, delta * open_speed)

# Optional helper to get display text
func get_display_text() -> String:
	var status := "Unlocked"
	if locked:
		status = "Locked"
	return "%s - %s" % [item_name, status]

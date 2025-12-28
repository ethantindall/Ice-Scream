extends Node3D

@export var screen_surface_index := 2
@export var powered_on: bool = false  # exported for UI or inspector

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var viewport: SubViewport = $SubViewport
@onready var video: VideoStreamPlayer = $SubViewport/VideoStreamPlayer

const BLACK_TEXTURE := preload("res://Assets/texture/black.png")

var is_on := false

func _ready():
	_setup_screen_material()
	turn_off() # force correct startup state

func toggle():
	if is_on:
		turn_off()
	else:
		turn_on()

func turn_on():
	is_on = true
	powered_on = true  # sync powered state

	var mat := _get_screen_material()
	if not mat:
		return

	var tex := viewport.get_texture()
	mat.albedo_texture = tex
	mat.emission_texture = tex
	mat.emission_energy = 2.0

	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	video.play()

func turn_off():
	is_on = false
	powered_on = false  # sync powered state

	var mat := _get_screen_material()
	if not mat:
		return

	video.stop()
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

	mat.albedo_texture = BLACK_TEXTURE
	mat.emission_texture = null
	mat.emission_energy = 0.0

func _setup_screen_material():
	var mat := mesh.get_active_material(screen_surface_index)
	mat = mat.duplicate()
	mesh.set_surface_override_material(screen_surface_index, mat)

	if mat is StandardMaterial3D:
		mat.albedo_texture = BLACK_TEXTURE
		mat.emission_enabled = true
		mat.emission_energy = 0.0

func _get_screen_material() -> StandardMaterial3D:
	var mat := mesh.get_surface_override_material(screen_surface_index)
	if mat is StandardMaterial3D:
		return mat
	return null

# ------------------------------
# New method for UI display
func get_display_text() -> String:
	return "TV - " + ("On" if powered_on else "Off")

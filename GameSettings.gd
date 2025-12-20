extends Node

# =====================
# VIDEO SETTINGS
# =====================
var max_fps: int = 120
var vsync_enabled: bool = true

# =====================
# CAMERA SETTINGS
# =====================
var base_fov: float = 60.0
var sprint_fov_bonus: float = 10.0

# Mouse sensitivity (degrees per pixel)
var mouse_sensitivity: float = 0.1
signal mouse_sensitivity_changed(value)

# Render distance (in meters / world units)
var render_distance: float = 400.0

signal fov_changed(value)

func _ready():
	apply_video_settings()
	apply_render_distance()
	apply_fov()

# ---------------------
# VIDEO
# ---------------------
func apply_video_settings():
	Engine.max_fps = 45
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

# ---------------------
# CAMERA
# ---------------------
func apply_fov():
	for camera in get_tree().get_nodes_in_group("cameras"):
		camera.fov = base_fov
	fov_changed.emit(base_fov)

func set_base_fov(value: float):
	base_fov = clamp(value, 30.0, 120.0)
	apply_fov()

# ---------------------
# INPUT
# ---------------------
func set_mouse_sensitivity(value: float):
	mouse_sensitivity = clamp(value, 0.01, 1.0)
	mouse_sensitivity_changed.emit(mouse_sensitivity)

# ---------------------
# RENDER DISTANCE
# ---------------------
func apply_render_distance():
	for camera in get_tree().get_nodes_in_group("cameras"):
		camera.far = render_distance

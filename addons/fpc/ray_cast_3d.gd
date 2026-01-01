# ray_cast_3d.gd
extends RayCast3D

@onready var interaction_label = get_parent().get_parent().get_node("CanvasLayer/Control/InteractionLabel")

var interactable_node: Node = null
var pickup_node: Node3D = null
var held_item: Node = null
var is_hidden = false

# --- THROW SETTINGS ---
@export var max_throw_charge := 1.2
@export var min_throw_charge := 0.25
@export var throw_force := 14.0

var _throw_charge := 0.0
var _charging_throw := false

@export var drop_height: float = 0.2
@export var drop_forward_offset: float = 0.5

func _physics_process(delta: float):
	if is_hidden:
		return

	# -------- THROW CHARGING --------
	if held_item and Input.is_action_pressed("ui_drop"):
		_charging_throw = true
		_throw_charge = min(_throw_charge + delta, max_throw_charge)

	# -------- RAYCAST LOGIC --------
	if is_colliding():
		var collider = get_collider()

		# INTERACTABLES
		if collider.is_in_group("interactable"):
			interactable_node = collider
			if collider.get_parent() != null and not collider.is_in_group("pickup"):
				interactable_node = collider.get_parent()

			if interactable_node.has_method("get_display_text"):
				interaction_label.text = interactable_node.get_display_text()
			else:
				interaction_label.text = interactable_node.name
		else:
			interactable_node = null

		# PICKUPS
		if collider.is_in_group("pickup") and held_item == null:
			pickup_node = collider as Node3D
			if pickup_node.has_method("get_display_text"):
				interaction_label.text = pickup_node.get_display_text()
		else:
			pickup_node = null
	else:
		interaction_label.text = ""
		interactable_node = null
		pickup_node = null


func _input(event):
	# LEFT CLICK — interact / pickup
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if interactable_node and interactable_node.has_method("toggle"):
			interactable_node.toggle()

		if interactable_node and interactable_node.has_method("hide_enter"):
			interactable_node.hide_enter()
			is_hidden = true
			interaction_label.text = "Press E to exit"

		if interactable_node and interactable_node.has_method("climb"):
			interactable_node.climb()
			print("climb")
		
		if interactable_node and interactable_node.has_method("do_homework"):
			interactable_node.do_homework()
			
			
		if pickup_node and pickup_node.has_method("pickup"):
			pickup_node.pickup()
			held_item = pickup_node
			pickup_node = null
			interaction_label.text = "Hold E to throw"
	
	# E — release to drop or throw
	if event.is_action_released("ui_drop") and held_item:
		if _throw_charge >= min_throw_charge:
			_throw_held_item(_throw_charge / max_throw_charge)
		else:
			_drop_held_item()

		_throw_charge = 0.0
		_charging_throw = false


func _drop_held_item():
	if not held_item:
		return

	var player: Node3D = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var drop_position: Vector3
	var raycast: RayCast3D = player.get_node_or_null("Head/RayCast3D")
	var head_transform: Transform3D = player.get_node("Head").global_transform

	if not raycast:
		var forward: Vector3 = -player.global_transform.basis.z.normalized()
		drop_position = player.global_transform.origin + forward * 2 + Vector3.UP * drop_height
	else:
		if raycast.is_colliding():
			drop_position = raycast.get_collision_point() + Vector3.UP * drop_height
		else:
			var ray_end: Vector3 = raycast.to_global(raycast.target_position)
			var ray_dir: Vector3 = (ray_end - raycast.global_transform.origin).normalized()
			drop_position = ray_end + ray_dir * drop_forward_offset

	# Prevent downward clipping
	var head_forward: Vector3 = -head_transform.basis.z.normalized()
	if head_forward.y < 0 and head_forward.y > -0.8:
		drop_position.y += 0.5

	held_item.drop(drop_position)
	held_item = null
	interaction_label.text = ""


func _throw_held_item(strength: float):
	if not held_item:
		return

	var player: Node3D = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var head: Node3D = player.get_node("Head")
	var forward := -head.global_transform.basis.z.normalized()
	var start_pos := head.global_transform.origin + forward * 0.8

	var item := held_item
	held_item = null
	interaction_label.text = ""

	item.drop(start_pos)

	# Apply throw AFTER physics is enabled
	item.call_deferred("_apply_throw", forward, throw_force * strength)

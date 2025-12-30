#ray_cast_3d.gd
extends RayCast3D

@onready var interaction_label = get_parent().get_parent().get_node("CanvasLayer/Control/InteractionLabel")

var interactable_node: Node = null
var pickup_node: Node3D = null
var held_item: Node = null
var is_hidden = false

func _physics_process(delta: float):
	if is_hidden:
		return
		
	if is_colliding():
		var collider = get_collider()

		# INTERACTABLES (doors, etc.)
		if collider.is_in_group("interactable"):
			# Doors etc. usually have a child collider
			interactable_node = collider
			if collider.get_parent() != null and not collider.is_in_group("pickup"):
				interactable_node = collider.get_parent()

			if interactable_node.has_method("get_display_text"):
				interaction_label.text = interactable_node.get_display_text()
			else:
				interaction_label.text = interactable_node.name
		else:
			interactable_node = null

		# PICKUPS (RigidBody3D root)
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
	print(interactable_node)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if interactable_node and interactable_node.has_method("toggle"):
			interactable_node.toggle()

		if interactable_node and interactable_node.has_method("hide_enter"):
			interactable_node.hide_enter()
			is_hidden = true
			interaction_label.text = "Press E to exit"
			
		if pickup_node and pickup_node.has_method("pickup"):
			pickup_node.pickup()
			held_item = pickup_node
			pickup_node = null
			interaction_label.text = "Press E to drop"

	# E — drop held item
	if event.is_action_pressed("ui_drop") and held_item:
		_drop_held_item()

@export var drop_height: float = 0.2         # vertical offset above hit point
@export var drop_forward_offset: float = 0.5 # used only when ray hits nothing


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
		print("RayCast3D not found! Dropping in front of player.")
		var forward: Vector3 = -player.global_transform.basis.z.normalized()
		drop_position = player.global_transform.origin + forward * 2 + Vector3.UP * drop_height
	else:
		if raycast.is_colliding():
			# Drop at collision point + vertical offset (no forward push)
			drop_position = raycast.get_collision_point() + Vector3.UP * drop_height
		else:
			# Drop at end of ray + optional forward offset
			var ray_end: Vector3 = raycast.to_global(raycast.target_position)
			var ray_dir: Vector3 = (ray_end - raycast.global_transform.origin).normalized()
			drop_position = ray_end + ray_dir * drop_forward_offset

	# --- CHECK HEAD ANGLE ---
	var head_forward: Vector3 = -head_transform.basis.z.normalized()
	var angle_x = rad_to_deg(asin(head_forward.y))  # Up/down angle in degrees

	#THIS IS SOPPOSED TO KEEP STUFF FROM GLITCHING THROUGH THE MAP
	# If looking down (x < 0), add extra drop height
	if head_forward.y < 0 and head_forward.y >-45:
		drop_position.y += 0.5  # adjust this value as needed

	held_item.drop(drop_position)
	held_item = null
	interaction_label.text = ""

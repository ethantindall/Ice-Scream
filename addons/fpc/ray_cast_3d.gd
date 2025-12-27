extends RayCast3D

@onready var interaction_label = get_parent().get_parent().get_node("CanvasLayer/Control/InteractionLabel")

var interactable_node: Node = null

func _physics_process(delta: float):
	if is_colliding():
		var collider = get_collider()
		if collider.is_in_group("interactable"):
			interaction_label.text = collider.name
			interactable_node = collider.get_parent()  # store for _input
		else:
			interaction_label.text = ""
			interactable_node = null
	else:
		interaction_label.text = ""
		interactable_node = null

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		if interactable_node != null:
			if interactable_node.has_method("toggle"):
				interactable_node.toggle()
			elif interactable_node.has_method("open"):
				interactable_node.open()

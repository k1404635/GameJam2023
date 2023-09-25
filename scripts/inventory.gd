extends Control

var can_use_item = false
signal item_used()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#put_inventory_item("gun")


func _process(delta):
	if Input.is_action_just_pressed("use_item"):
		_on_action_pressed()

func put_inventory_item(id):
	# Assign Texture
	var texture_path = get_texture_path(id)
	var texture = load("res://" + texture_path)
	$ItemGraphicContainer/ItemGraphic.texture = texture

	# Move in
	$Animation.play("in")

func swap_inventory_item(id):
	# Assign Texture
	var texture_path = get_texture_path(id)
	var texture = load("res://" + texture_path)
	$ItemGraphicContainer/ItemGraphic.texture = texture

func discard_items():
	$Animation.play("out")

func get_texture_path(id):
	match id:
		"gun":
			return "assets/items/gun.png"
		_:
			return "assets/items/gun_TEMP.png"

func enable_item():
	can_use_item = true
	
	var tween = get_tree().create_tween()
	tween.tween_property($ItemGraphicContainer/UsableOverlay, "self_modulate", Color("#ffffffff"), 1.0)

func disable_item():
	can_use_item = false
	
	var tween = get_tree().create_tween()
	tween.tween_property($ItemGraphicContainer/UsableOverlay, "self_modulate", Color(Color("#ffffff"), 0.0), 1.0)


func _on_action_pressed():
	if (can_use_item):
		print("Using Item")
		item_used.emit()

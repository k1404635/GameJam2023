extends Node2D

@onready var GLOBAL = get_node("/root/Global")

@export var PLAYER_VELOCITY = 10

const SCREEN_WIDTH = 1920
const SCREEN_HEIGHT = 1080

var no_pause = false
var current_item = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	add_player_interactives()


func _process(delta):
	# Handles Scrolling
	if ($Player.scroll_velocity != Vector2.ZERO):
		$Scroll.position -= $Player.scroll_velocity * delta
		if $Scroll.position.y > 0:
			$Scroll.position.y = 0
			$Player.scroll_up_limit = 540
		elif $Scroll.position.y < -3240:
			$Scroll.position.y = -3240
			$Player.scroll_down_limit = 540
		else:
			$Player.scroll_up_limit = 540/2
			$Player.scroll_down_limit = 540/2
		
		if $Scroll.position.x > 0:
			$Scroll.position.x = 0
			$Player.scroll_left_limit = 960
		elif $Scroll.position.x < -1920:
			$Scroll.position.x = -1920
			$Player.scroll_right_limit = 960
		else:
			$Player.scroll_left_limit = 960/2
			$Player.scroll_right_limit = 960/2
	
	# Layering
	for npc in $Scroll/NPCs.get_children():
		var npc_real_y = npc.get_node("NPCFollow").position.y + $Scroll.position.y + npc.sprite_down_point
		if npc_real_y < $Player.position.y + 130:
			npc.z_index = -1
		if npc_real_y >= $Player.position.y + 130:
			npc.z_index = 1
	
	for environment_obj in $Scroll/Environment.get_children():
		var real_y = environment_obj.position.y + $Scroll.position.y + environment_obj.down_point
		if real_y < $Player.position.y + 130:
			environment_obj.get_node("OnLayer").z_index = -1
		if real_y >= $Player.position.y + 130:
			environment_obj.get_node("OnLayer").z_index = 1
	
	# Pausing
	if Input.is_action_just_pressed("pause") and not(no_pause):
		if ($UILayer/PauseMenu.visible):
			$UILayer/PauseMenu.unpause()
			$UILayer/PauseMenu.visible = false
		else:
			$UILayer/PauseMenu.pause()
			$UILayer/PauseMenu.visible = true

func reset():
	$Scroll.position = Vector2(-960, -2700)
	$Player.position = Vector2(960, 540)
	
	$Player.scroll_left_limit = 960/2
	$Player.scroll_right_limit = 960/2
	$Player.scroll_up_limit = 540/2
	$Player.scroll_down_limit = 540/2
	
	current_item = ""
	
	freeze()
	match GLOBAL.loops:
		0:
			
			$UILayer/DialogueEngine.play_dialogue_file("dialogues/intro_0_0.json")
			await $UILayer/DialogueEngine.dialogue_finished
			$UILayer/DialogueEngine.play_dialogue_file("dialogues/intro_0_1.json")
			await $UILayer/DialogueEngine.dialogue_finished
			$UILayer/DialogueEngine.play_dialogue_file("dialogues/intro_0_2.json")
	
	await $UILayer/DialogueEngine.dialogue_finished
	unfreeze()
	
	if (GLOBAL.loops > 0):
		await get_tree().create_timer(2).timeout
		$UILayer/IncidentTimer.go()


func _on_incident_timer_time_up():
	var tween = get_tree().create_tween()
	tween.tween_property($UILayer/ColorOverlay, "color", Color("#000000ff"), 0.5)
	
	await get_tree().create_timer(0.5).timeout
	freeze()
	
	await get_tree().create_timer(1.5).timeout
	tween = get_tree().create_tween()
	tween.tween_property($UILayer/Failure, "self_modulate", Color("#ffffffff"), 5)

func add_player_interactives():
	# Interactive Objects
	for item in $Scroll/Items.get_children():
		var interactive = item.get_node("Interactable")
		interactive.area_entered.connect(interactive_player_enter_check.bind(interactive))
		interactive.area_exited.connect(interactive_player_exit_check.bind(interactive))
		item.picked_up.connect(on_item_pickup)
	
	# NPCs
	for npc in $Scroll/NPCs.get_children():
		var interactive = npc.get_node("NPCFollow/Interactable")
		interactive.area_entered.connect(interactive_player_enter_check.bind(interactive))
		interactive.area_exited.connect(interactive_player_exit_check.bind(interactive))
	
	# Environment Overlays
	for environment_obj in $Scroll/Environment.get_children():
		if (environment_obj.has_node("Overlay") and environment_obj.has_node("OverlayChecker")):
			environment_obj.get_node("OverlayChecker").area_entered.connect(overlay_player_enter_check.bind(environment_obj))
			environment_obj.get_node("OverlayChecker").area_exited.connect(overlay_player_exit_check.bind(environment_obj))

func interactive_player_enter_check(area, interactive):
	# If body is the player, add to list of interactives
	if (area == $Player/PlayerInteraction):
		$Player.on_interaction_area_entered(interactive)

func interactive_player_exit_check(area, interactive):
	# If body is the player, remove from list of interactives
	if (area == $Player/PlayerInteraction):
		$Player.on_interaction_area_exited(interactive)

func overlay_player_enter_check(area, environment_obj):
	# If body is the player, add to list of interactives
	if (area == $Player/PlayerBox):
		environment_obj.on_overlay_active()

func overlay_player_exit_check(area, environment_obj):
	# If body is the player, add to list of interactives
	if (area == $Player/PlayerBox):
		environment_obj.on_overlay_inactive()

func on_item_pickup(id):
	print("Picked up a(n) ", id)
	if (current_item == ""):
		$UILayer/Inventory.put_inventory_item(id)
	else:
		$UILayer/Inventory.swap_inventory_item(id)
	
	current_item = id

func freeze():
	no_pause = true
	$Player.frozen = true
	for npc in $Scroll/NPCs.get_children():
		npc.frozen = true

func unfreeze():
	no_pause = false
	$Player.frozen = false
	for npc in $Scroll/NPCs.get_children():
		npc.frozen = false



func _on_dialogue_engine_dialogue_finished(type, id):
	for item in $Scroll/Items.get_children():
		if ("on_dialogue_finished" in item):
			_on_dialogue_engine_item_not_usable()
			item.on_dialogue_finished(type, id)


func _on_dialogue_engine_item_usable():
	$UILayer/Inventory.enable_item()

func _on_dialogue_engine_item_not_usable():
	$UILayer/Inventory.disable_item()



func _on_inventory_item_used():
	# Sanity Check
	if $UILayer/DialogueEngine.active:
		if (current_item == "gun"):
			$UILayer/DialogueEngine.override_upper("I'm sorry I had to do this.", 1)
			await $UILayer/DialogueEngine.continued_dialogue
			
			# BANG
			$UILayer/ColorOverlay.color = Color("#000000ff")
			
			GLOBAL.loops += 1
			$UILayer/DialogueEngine.end_dialogue()
			$UILayer/Inventory.discard_items()
			
			await get_tree().create_timer(3).timeout
			
			print("AGAIN")
			$UILayer/AGAIN.self_modulate = Color("#ffffffff")
			
			var tween = get_tree().create_tween()
			tween.tween_property($UILayer/AGAIN, "self_modulate", Color(1, 1, 1, 0), 1.0)
			
			await get_tree().create_timer(2).timeout
			
			reset()
			
			tween = get_tree().create_tween()
			tween.tween_property($UILayer/ColorOverlay, "color", Color(0, 0, 0, 0), 1.0)

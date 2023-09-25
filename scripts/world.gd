extends Node2D

@onready var GLOBAL = get_node("/root/Global")

@export var PLAYER_VELOCITY = 10
@export var gun: PackedScene

const SCREEN_WIDTH = 1920
const SCREEN_HEIGHT = 1080

var current_talk_npc = -1

var FINAL_WIN = false

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
	
	for item in $Scroll/Items.get_children():
		var real_y = item.position.y + $Scroll.position.y + 50
		if real_y < $Player.position.y + 130:
			item.get_node("Sprite").z_index = -1
		if real_y >= $Player.position.y + 130:
			item.get_node("Sprite").z_index = 1
	
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
	
	if (GLOBAL.loops > 0):
		randomize_gun()
	
	print("Stopping for init")
	freeze()
	$UILayer/DialogueEngine.clear_dialogue()
	await get_tree().create_timer(2).timeout
	
	current_item = ""
	match GLOBAL.loops:
		0:
			$UILayer/DialogueEngine.play_dialogue_file("dialogues/intro_0_0.json")
			await $UILayer/DialogueEngine.dialogue_finished
			
			$Cutscene.play("girl_in")
			await $Cutscene.animation_finished
			
			$UILayer/DialogueEngine.play_dialogue_file("dialogues/intro_0_1.json")
			await $UILayer/DialogueEngine.dialogue_finished
			
			$Cutscene.play("girl_out")
			await $Cutscene.animation_finished
			
			$UILayer/DialogueEngine.play_dialogue_file("dialogues/intro_0_2.json")
		1:
			$UILayer/DialogueEngine.play_dialogue_file("dialogues/intro_1_0.json")
		2:
			$UILayer/DialogueEngine.play_dialogue_file("dialogues/intro_2_0.json")
		3:
			$UILayer/DialogueEngine.play_dialogue_file("dialogues/intro_3_0.json")
		4:
			$UILayer/DialogueEngine.play_dialogue_file("dialogues/intro_4_0.json")
	
	print("And now we wait")
	await $UILayer/DialogueEngine.dialogue_finished
	
	print("Unstopping for init")
	unfreeze()
	
	if (GLOBAL.loops > 0):
		var tween = get_tree().create_tween()
		tween.tween_property($MusicPlayer, "volume_db", -10, 1.0)
		$MusicPlayer.play()
		await get_tree().create_timer(1).timeout
		$UILayer/IncidentTimer.go()
		
	if (GLOBAL.loops == 0):
		end_loop()

func randomize_gun():
	var gun_positions = [
		Vector2(3540, 300),
		Vector2(300, 500),
		Vector2(2020, 1800),
		Vector2(400, 3930)
	]
	
	var gun_scene = gun.instantiate()
	gun_scene.position = gun_positions[randi() % len(gun_positions)]
	print("Gun at ", gun_scene.position)
	
	var sprite = load("res://assets/items/gun.png")
	var pickup_quip = "This might be useful."
	var pickup_name = "gun"
	gun_scene.init_with_vals(sprite, pickup_quip, pickup_name)
	
	if (GLOBAL.loops > 0):
		var interactive = gun_scene.get_node("Interactable")
		interactive.area_entered.connect(interactive_player_enter_check.bind(interactive))
		interactive.area_exited.connect(interactive_player_exit_check.bind(interactive))
		gun_scene.picked_up.connect(on_item_pickup)
	
	$Scroll/Items.add_child(gun_scene)



func _on_incident_timer_time_up():
	var tween = get_tree().create_tween()
	tween.tween_property($UILayer/ColorOverlay, "color", Color("#000000ff"), 0.5)
	
	await get_tree().create_timer(0.5).timeout
	freeze()
	
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/fail_screen.tscn")

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
	
	if (id == "gun" and GLOBAL.loops == 4):
		$UILayer/IncidentTimer.end()
		
		var tween = get_tree().create_tween()
		tween.tween_property($MusicPlayer, "volume_db", -50, 1.0)
		await get_tree().create_timer(1).timeout
		$MusicPlayer.stop()
		
		freeze()
		$UILayer/DialogueEngine.play_dialogue_file("dialogues/player.json")
		await $UILayer/DialogueEngine.dialogue_finished
		
		if (not(FINAL_WIN)):
			$UILayer/ColorOverlay.color = Color("#000000ff")
			GLOBAL.worst_end = true
			
			await get_tree().create_timer(2).timeout
			
			get_tree().change_scene_to_file("res://scenes/fail_screen.tscn")

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
			var can_kill_index = 0
			match ($UILayer/DialogueEngine.dialogue_id):
				"mother":
					can_kill_index = 0
				"shopkeeper":
					can_kill_index = 1
				"criminal":
					can_kill_index = 2
				"player":
					can_kill_index = 3
			
			$UILayer/Inventory.can_use_item = false
			if (can_kill_index == 3):
				$UILayer/DialogueEngine.override_upper("I have no other choice.", 0.75)
				FINAL_WIN = true
				await $UILayer/DialogueEngine.continued_dialogue
				$Shot.play()
				end_loop(can_kill_index)
			elif (not(GLOBAL.suspects_killed[can_kill_index])):
				$UILayer/DialogueEngine.override_upper("I'm sorry I had to do this.", 1)
				await $UILayer/DialogueEngine.continued_dialogue
				$Shot.play()
				GLOBAL.suspects_killed[can_kill_index] = true
				end_loop(can_kill_index)
			else:
				$UILayer/DialogueEngine.override_upper("(No, they weren't the killer.)", 1)
				$UILayer/Inventory.can_use_item = true

func end_loop(just_killed: int = -1):
	# BANG
	$UILayer/ColorOverlay.color = Color("#000000ff")
	$UILayer/IncidentTimer.stop()
	freeze()
	
	GLOBAL.loops += 1
	$UILayer/DialogueEngine.end_dialogue()
	$UILayer/Inventory.discard_items()
	
	$UILayer/Inventory.can_use_item = true
	
	$MusicPlayer.volume_db = -50
	$MusicPlayer.stop()
	
	await get_tree().create_timer(3).timeout
	
	if (GLOBAL.loops == 5):
		await get_tree().create_timer(5).timeout
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
	elif (GLOBAL.loops > 1):
		var slide = get_tree().create_tween()
		slide.tween_property($UILayer.get_node("Suspect" + str(just_killed + 1)), "position", Vector2(0, 0), 1.5).set_trans(Tween.TRANS_ELASTIC)
		var blood = get_tree().create_tween()
		$UILayer/Blood.self_modulate = Color(1, 1, 1, 1)
		blood.tween_property($UILayer/Blood, "position", Vector2(0, 0), 1.5).set_trans(Tween.TRANS_ELASTIC)
		await get_tree().create_timer(1.5).timeout
		
		var idname = ""
		match just_killed:
			0:
				idname = "Mother"
			1:
				idname = "Shopkeeper"
			2:
				idname = "Random Guy"
		var msg = "The " + idname + " was not the killer."
		$UILayer/SuspectLabel.text = msg
		$UILayer/SuspectLabel.visible = true
		$UILayer/SuspectLabel.self_modulate = Color(1, 1, 1, 1)
		await get_tree().create_timer(3).timeout
		
		var fadeout = get_tree().create_tween()
		fadeout.tween_property($UILayer.get_node("Suspect" + str(just_killed + 1)), "self_modulate", Color(0, 0, 0, 0), 1.5)
		fadeout.tween_property($UILayer/SuspectLabel, "self_modulate", Color(0, 0, 0, 0), 1.5)
		var bloodout = get_tree().create_tween()
		bloodout.tween_property($UILayer/Blood, "self_modulate", Color(1, 1, 1, 0), 1.5)
		$UILayer/SuspectLabel.visible = false
	
	await get_tree().create_timer(2).timeout
	$UILayer/Blood.position = Vector2(-1920, 0)
	
	reset()
	
	var tween = get_tree().create_tween()
	tween.tween_property($UILayer/ColorOverlay, "color", Color(0, 0, 0, 0), 1.0)

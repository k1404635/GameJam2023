extends Node2D

@export var PLAYER_VELOCITY = 10

const SCREEN_WIDTH = 1920
const SCREEN_HEIGHT = 1080

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
		var npc_real_y = npc.get_node("NPCFollow").position.y + $Scroll.position.y + 50
		if npc_real_y < $Player.position.y + 130:
			npc.z_index = -1
		if npc_real_y >= $Player.position.y + 130:
			npc.z_index = 1

func reset():
	$Scroll.position = Vector2(-960, -2700)
	$Player.position = Vector2(960, 540)
	
	$Player.scroll_left_limit = 960/2
	$Player.scroll_right_limit = 960/2
	$Player.scroll_up_limit = 540/2
	$Player.scroll_down_limit = 540/2
	
	#await get_tree().create_timer(2).timeout
	#$UILayer/IncidentTimer.go()


func _on_incident_timer_time_up():
	var tween = get_tree().create_tween()
	tween.tween_property($UILayer/Bleak, "color", Color("#171d29a0"), 2.0)

func add_player_interactives():
	for interactive in $Scroll/Items.get_children():
		interactive.area_entered.connect(interactive_player_enter_check.bind(interactive))
		interactive.area_exited.connect(interactive_player_exit_check.bind(interactive))
	
	for npc in $Scroll/NPCs.get_children():
		var interactive = npc.get_node("NPCFollow/Interactable")
		interactive.area_entered.connect(interactive_player_enter_check.bind(interactive))
		interactive.area_exited.connect(interactive_player_exit_check.bind(interactive))

func interactive_player_enter_check(area, interactive):
	# If body is the player, add to list of interactives
	if (area == $Player/PlayerInteraction):
		$Player.on_interaction_area_entered(interactive)

func interactive_player_exit_check(area, interactive):
	# If body is the player, remove from list of interactives
	if (area == $Player/PlayerInteraction):
		$Player.on_interaction_area_exited(interactive)

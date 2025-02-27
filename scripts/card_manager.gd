extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

var card_being_dragged
var screen_size
var is_hovering_on_card = false

@onready var player_hand_reference = $"../PlayerHand"
@onready var input_manager_reference = $"../InputManager"


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	input_manager_reference.connect("left_mouse_button_released", on_left_click_released)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if card_being_dragged:
		var mouse_position = get_global_mouse_position()
		
		card_being_dragged.position = Vector2(
										clamp(mouse_position.x,0 ,screen_size.x),
			 							clamp(mouse_position.y,0,screen_size.y))


			
func start_drag(card:Card):
	card_being_dragged = card	
	card.scale = Vector2(1.05,1.05)
	
func finish_drag():
	card_being_dragged.scale = Vector2(1,1)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		#Card dropped in card slot
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot_found.card_in_slot = true
	else :
		player_hand_reference.add_card_to_hand(card_being_dragged)
	card_being_dragged = null
	

func connect_card_signals(card:Card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	
func on_left_click_released():
	if card_being_dragged:
		finish_drag()

func on_hovered_over_card(card:Card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card,true)
	
	
func on_hovered_off_card(card:Card):	
	if !card_being_dragged:
		highlight_card(card,false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
				highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false
	
	
func highlight_card(card:Card, hovered:bool):
		if hovered:
			card.scale = Vector2(1.05,1.05)
			card.z_index = 2
		else:
			card.scale = Vector2(1,1)
			card.z_index = 1
			

func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cardList):
	var highest_z_card = cardList[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1,cardList.size()):
		var current_card = cardList[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
		

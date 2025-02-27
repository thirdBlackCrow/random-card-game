extends Node2D

class_name PlayerHand


const CARD_WIDTH = 200
const HAND_Y_POSITION = 890

const DEAULT_CARD_SPEED = 0.2


var player_hand  = []
var center_screen_x




# Called when the node enters the scene tree for the first time.
func _ready():
	center_screen_x = get_viewport().size.x /2

		
		

func add_card_to_hand(card:Card,card_draw_speed:float):
	if card not in player_hand:
		player_hand.insert(0,card)
		update_hand_positions(card_draw_speed)
	else :
		animate_card_to_position(card,card.starting_position,card_draw_speed)
	
func update_hand_positions(card_draw_speed:float):
	for i in range(player_hand.size()):
		# Get new card position based on index
		var new_position = Vector2(calculate_card_position(i),HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position,card_draw_speed)
		

func  calculate_card_position(index):
	var total_width = (player_hand.size() -1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset
	

func animate_card_to_position(card: Card, new_position:Vector2, card_draw_speed:float):
	var tween = get_tree().create_tween()
	tween.tween_property(card,"position", new_position,card_draw_speed)
	
func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEAULT_CARD_SPEED)
	
	

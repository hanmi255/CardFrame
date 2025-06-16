extends Node2D

@export var deck1: Node
@export var deck2: Node
@export var deck3: Node

@export var max_random_item_num: int
@export var min_random_item_num: int

@export var site_items: Dictionary

func getSomeCard():
	var num_cards = randi() % (max_random_item_num - min_random_item_num + 1) + min_random_item_num
	var total_weight = getTotalWeight(site_items)
	var selected_cards = []

	for i in range(num_cards):
		var random_weight = randi() % total_weight
		var current_weight = 0
		for card_name in site_items.keys():
			current_weight += site_items[card_name]
			if current_weight >= random_weight:
				selected_cards.append(card_name)
				break

	for card_name in selected_cards:
		var random_deck = get_tree().get_nodes_in_group("cardDeck")[randi_range(0, 1)]
		await get_tree().create_timer(0.1).timeout

		Infos.generateNewCard(card_name, random_deck, $Button)

func getTotalWeight(card_dict):
	var total_weight = 0
	for weight in card_dict.values():
		total_weight += weight
	return total_weight

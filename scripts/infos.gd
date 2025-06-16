extends CanvasLayer

# 保存所有存档
var saves: Dictionary

var save: PlayerInfo

var player_info_path: String

@onready var hand_deck: Control = $HandDeck

func generateNewCard(card_name, card_deck, caller = get_tree().get_first_node_in_group("cardDeck")) -> Node:
	print("开始创建卡牌：" + str(card_name))
	var card_class = ReadCardInfo.info_dic[card_name]["base_cardClass"]
	print("卡牌类型：" + str(card_class))
	var card_to_add = preload("res://scenes/card.tscn").instantiate() as Card

	card_to_add.initCard(card_name)

	card_to_add.global_position = caller.global_position
	card_to_add.z_index = 100

	card_deck.addCard(card_to_add)

	return card_to_add

func savePlayerInfo(new_save_path: String):
	for deck in get_tree().get_nodes_in_group("saveableDecks"):
		deck.storeCard()
	var path = save.folder_path + new_save_path + ".tres"
	ResourceSaver.save(save, path)
	print("保存成功！")

func loadPlayerInfo(save_path: String = "auto_save"):
	var path = "user://save/" + save_path + ".tres"
	player_info_path = path
	save = load(player_info_path) as PlayerInfo

	$HandDeck.max_weight = save.hand_max

	get_tree().change_scene_to_file(save.location)
	hand_deck.loadCards()
	visible = true

extends Panel

@onready var card_deck: Control = $CardDeck
@onready var card_pos_deck: HBoxContainer = $ScrollContainer/CardPosDeck

var current_weight = 0
@export var max_weight = 100

func _ready():
	if is_in_group("saveableDecks"):
		loadCards()
	else:
		for i in default_cards:
			Infos.now_scene.generateNewCard(i, self)
	$ProgressBar.max_value = max_weight
		

func _process(_delta: float) -> void:
	if card_deck.get_child_count() != 0:
		var children = card_deck.get_children()
		sortNodesByPosition(children)

func sortNodesByPosition(children):
	children.sort_custom(sortByPosition)
	for i in range(children.size()):
		if children[i].current_card_state:
			children[i].z_index = i
			card_deck.move_child(children[i], i)

func sortByPosition(a, b):
	return a.position.x < b.position.x

func addCard(card_to_add) -> void:
	if current_weight + card_to_add.card_weight <= max_weight:
		if isStacked(card_to_add):
			return

	var index = card_to_add.z_index
	var card_background = preload("res://scenes/card_background.tscn").instantiate()
	card_pos_deck.add_child(card_background)

	if index <= card_pos_deck.get_child_count():
		card_pos_deck.move_child(card_background, index)
	else:
		card_pos_deck.move_child(card_background, -1)
	
	var global_pos = card_to_add.global_position # 获取节点的全局坐标

	if card_to_add.get_parent():
		card_to_add.get_parent().remove_child(card_to_add)

	card_deck.add_child(card_to_add)
	card_to_add.global_position = global_pos
	card_to_add.follow_target = card_background
	card_to_add.pre_deck = self
	card_to_add.current_card_state = card_to_add.card_state.FOLLOWING

	updateWeight()

func updateWeight():
	var now_weight = 0
	for card in card_deck.get_children():
		if card.current_card_state == card.card_state.FOLLOWING:
			now_weight += card.card_weight * card.num
	current_weight = now_weight
	var weight_text = str(current_weight) + "/" + str(max_weight)
	$WeightLabel.text = weight_text
	$ProgressBar.value = current_weight

func isStacked(card_to_stack) -> bool:
	for card in card_deck.get_children():
		if card_to_stack.card_name == card.card_name \
			&& card.current_card_state == card.card_state.FOLLOWING:
			if card.cardStack(card_to_stack):
				fakeCardMove(card)
				card_to_stack.queue_free()
				updateWeight()
				return true
	return false

func fakeCardMove(card_to_fake):
	var fake_card = card_to_fake.duplicate()
	fake_card.initCard(card_to_fake.card_name)
	fake_card.z_index = 1000
	fake_card.current_card_state = fake_card.card_state.FAKE
	VFSLayer.add_child(fake_card)
	fake_card.global_position = get_global_mouse_position() - Vector2(125, 100)
	var tween = create_tween()
	await tween.tween_property(fake_card, "global_position", card_to_fake.global_position, 0.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).finished
	fake_card.queue_free()

@export var card_saved: Array[PackedScene]
func storeCard():
	card_saved = []
	if card_deck.get_children().size() > 0:
		for card in card_deck.get_children():
			var packed_scene = PackedScene.new()
			var result = packed_scene.pack(card)
			print("保存" + card.card_name + "成功", "保存结果为:", result)
			card_saved.append(packed_scene)
	
	var saver = DeckSavedCards.new()
	saver.cards = card_saved
	var path = str(get_path())
	var save_path = path
	Infos.save.decks[save_path] = saver

@export var default_cards: Array[String]
func loadCards():
	clearChildren($ScrollContainer/CardPosDeck)
	clearChildren($CardDeck)

	var path = str(get_path())
	var save_path = path

	if Infos.save.decks.has(save_path):
		var saver = Infos.save.decks[save_path]
		if saver.cards.size() > 0:
			for card in saver.cards:
				var pack = card.instantiate()
				addCard(pack)
	else:
		for i in default_cards:
			Infos.now_scene.generateNewCard(i, self)

func clearChildren(node: Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
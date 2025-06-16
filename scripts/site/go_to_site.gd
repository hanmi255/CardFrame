extends Button

@export var site: String

func _on_go_to_site_button_down():
	for deck in get_tree().get_nodes_in_group("saveableDecks"):
		deck.storeCard()
	get_tree().change_scene_to_file(site)

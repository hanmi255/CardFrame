extends Control

func _on_new_game_button_down()->void:
	get_tree().change_scene_to_file("res://scenes/name_screen.tscn")

# func _on_continue_game_button_down()->void:
# 	Infos.loadPlayerInfo()

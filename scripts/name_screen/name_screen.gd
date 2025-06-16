extends Control

@onready var name_box = $LineEdit

func _on_ensure_button_down() -> void:
	var new_player_info = PlayerInfo.new()
	playerInit(new_player_info)

func playerInit(new_player: PlayerInfo):
	new_player.player_name = name_box.text
	new_player.location = "res://scenes/site/site1.tscn"
	new_player.hand_max = 50
	
	var folder_path = "user://save/"
	var save_path = folder_path + "auto_save.tres"
	createFolder(folder_path)

	new_player.folder_path = folder_path
	ResourceSaver.save(new_player, save_path)

	Infos.loadPlayerInfo()

func createFolder(path: String):
	var dir = DirAccess.open(path)
	if dir != null:
		print("Folder already exists:" + path)
	else:
		var result = DirAccess.make_dir_absolute(path)
		if result:
			print("Folder created:" + path)
		else:
			print("Folder creation failed:" + path)
extends Panel

var save_data: PlayerInfo
var save_name: String
var pure_name: String

func _ready():
	var save_info = save_data.player_name
	pure_name = save_name.split(".")[0]
	$VBoxContainer/PlayerNameLabel.text = pure_name
	$VBoxContainer/OtherInfoLabel.text = save_info

func _on_load_button_down():
	Infos.loadPlayerInfo(pure_name)
	PauseMenu.hideMenu()

func _on_delete_button_down():
	var file_path: String = "user://save/" + save_name

	var dir_access = DirAccess.open(file_path.get_base_dir())
	if dir_access and dir_access.file_exists(file_path):
		if dir_access.remove(file_path) == OK:
			print("File deleted successfully!")
		else:
			print("Error deleting file.")
	else:
		print("File does not exist.")

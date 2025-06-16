extends CanvasLayer


func showMenu():
	get_tree().paused = true
	visible = true
	loadSaveList()

func hideMenu():
	get_tree().paused = false
	visible = false
	_on_save_back_button_down()

func _on_save_back_button_down() -> void:
	var tween := create_tween()
	await tween.tween_property($SavePanel, "size", Vector2(500, 1), 0.2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).finished
	$SavePanel.visible = false

func _on_save_new_button_down() -> void:
	var time = Time.get_time_dict_from_system()
	var save_name = ("%02d-%02d-%02d" % [time.hour, time.minute, time.second])
	Infos.savePlayerInfo(save_name)
	loadSaveList()

func _on_back_button_down() -> void:
	hideMenu()

func _on_quick_save_button_down() -> void:
	Infos.savePlayerInfo("auto_save")
	loadSaveList()

func _on_save_list_button_down() -> void:
	$SavePanel.visible = true
	var tween := create_tween()
	await tween.tween_property($SavePanel, "size", Vector2(500, 700), 0.2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).finished
	loadSaveList()

func _on_exit_button_down():
	get_tree().quit()

func loadSaveList():
	var container = $SavePanel/ScrollContainer/VBoxContainer.get_children()
	for c in container:
		c.queue_free()

	var dir = DirAccess.open("user://save/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var save = load("user://save/" + file_name)
			var save_line = load("res://scenes/pause_menu/save_panel.tscn").instantiate()
			save_line.save_data = save
			save_line.save_name = file_name
			$SavePanel/ScrollContainer/VBoxContainer.add_child(save_line)
			file_name = dir.get_next()

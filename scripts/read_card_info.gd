extends Node
var file_path = "res://assets/files/card_infos/card_info.csv"
var info_dic: Dictionary

func _init() -> void:
	info_dic = readCSVAsNestedDictionary(file_path)

# 读取CSV文件并转换为嵌套字典
func readCSVAsNestedDictionary(path: String) -> Dictionary:
	var data = {}
	var file = FileAccess.open(path, FileAccess.READ)
	var headers = []
	var first_line = true
	while not file.eof_reached():
		var values = file.get_csv_line()
		if first_line:
			headers = values
			first_line = false
		elif values.size() >= 2:
			var key = values[0]
			var row_dict = {}
			for i in range(0, headers.size()):
				row_dict[headers[i]] = values[i]
			data[key] = row_dict

	file.close()
	return data

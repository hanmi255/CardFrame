extends "./deck.gd"

func _ready() -> void:
	$ProgressBar.max_value = max_weight
	updateWeight()

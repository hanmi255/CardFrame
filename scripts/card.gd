##
# @class card.gd
# @brief 卡片控制类，实现拖拽跟随效果
# @extends Control
#
# 提供基于物理模拟的卡片拖拽和跟随功能，包含两种状态：
# - 拖拽状态：跟随鼠标位置
# - 跟随状态：基于弹簧物理模型跟随目标节点

extends Control

class_name Card

## @brief 当前运动速度（像素/秒）
var velocity = Vector2.ZERO
## @brief 阻尼系数（0-1）
var damping = 0.35
## @brief 刚度系数（弹簧强度）
var stiffness = 500
## @brief 牌桌节点
var pre_deck

@export var card_info: Dictionary
@export var card_name: String
@export var card_class: String
@export var card_max_stack: int
@export var card_weight: float

var pick_button: Node
var dup
var num = 1

## @brief 卡片状态枚举
enum card_state {FOLLOWING, DRAGGING, VFS, FAKE}
## @brief 当前卡片状态（默认：FOLLOWING）
@export var current_card_state = card_state.FOLLOWING

## @brief 要跟随的目标节点
@export var follow_target: Node

var which_deck_mouse_in

## @brief 处理物理模拟和状态更新
## @param delta 帧时间间隔（秒）
func _process(delta: float) -> void:
	match current_card_state:
		card_state.DRAGGING:
			## @brief 拖拽状态：跟随鼠标位置
			var target_position = get_global_mouse_position() - size / 2
			global_position = lerp(global_position, target_position, 0.4)

			var mouse_position = get_global_mouse_position()
			var nodes = get_tree().get_nodes_in_group("cardDropable")
			for node in nodes:
				if node.get_global_rect().has_point(mouse_position) && node.visible == true:
					which_deck_mouse_in = node
					break

		card_state.FOLLOWING:
			## @brief 跟随状态：基于弹簧物理模型
			if follow_target != null:
				var target_position = follow_target.global_position
				var displacement = target_position - global_position
				var force = displacement * stiffness
				velocity += force * delta
				velocity *= (1.0 - damping)
				global_position += velocity * delta

func cardStack(card_to_stack):
	var stack_num = card_to_stack.num
	if num + stack_num > card_max_stack:
		return false
	else:
		num += stack_num
		drawCard()
		return true

## @brief 鼠标按下事件处理
## @note 触发DRAGGING状态切换
func _on_button_button_down() -> void:
	if current_card_state == card_state.FOLLOWING:
		var num_cache = num
		num = 1
		drawCard()

		dup = self.duplicate()
		VFSLayer.add_child(dup)
		dup.global_position = global_position
		dup.current_card_state = card_state.VFS

		current_card_state = card_state.DRAGGING

		get_parent().get_parent().updateWeight()

		if num_cache != 1 && num_cache != null:
				var card: Card = Infos.generateNewCard(card_name, get_parent().get_parent(), self)
				card.follow_target.queue_free()
				card.follow_target = follow_target
				card.global_position = global_position
				card.num = num_cache - 1
				card.drawCard()
		elif follow_target != null:
			follow_target.queue_free()

		get_parent().get_parent().updateWeight()

func _on_all_button_button_down() -> void:
	if current_card_state == card_state.FOLLOWING:
		dup = self.duplicate()
		VFSLayer.add_child(dup)
		dup.global_position = global_position
		dup.current_card_state = card_state.VFS

		current_card_state = card_state.DRAGGING

		if follow_target != null:
			follow_target.queue_free()

## @brief 鼠标释放事件处理
## @note 触发FOLLOWING状态切换
func _on_button_button_up() -> void:
	if dup != null:
		dup.queue_free()

	if which_deck_mouse_in != null:
		which_deck_mouse_in.addCard(self)
	else:
		if pre_deck != null:
			pre_deck.addCard(self)

	current_card_state = card_state.FOLLOWING

func initCard(index) -> void:
	card_info = ReadCardInfo.info_dic[index]
	card_name = card_info["base_cardName"]
	card_class = card_info["base_cardClass"]
	card_max_stack = int(card_info["base_maxStack"])
	card_weight = float(card_info["base_cardWeight"])
	current_card_state = card_state.FOLLOWING
	drawCard()

func drawCard() -> void:
	pick_button = $Button
	var image_path = "res://assets/images/cards/" + str(card_name) + ".jpg"
	$Control/ColorRect/ItemImg.texture = load(image_path)
	$Control/ColorRect/name.text = card_info["base_displayName"]
	$allButton.text = "x" + str(num)

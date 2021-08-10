extends Control


var player_nums : Array = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_just_pressed("p1_left") or Input.is_action_just_pressed("p1_right"):
		if !player_nums.has(1):
			player_nums.append(1)
			$VBoxContainer/BlueContainer/CheckMark.visible = true
	if Input.is_action_just_pressed("p2_left") or Input.is_action_just_pressed("p2_right"):
		if !player_nums.has(2):
			player_nums.append(2)
			$VBoxContainer/OrangeContainer/CheckMark.visible = true
	if Input.is_action_just_pressed("p3_left") or Input.is_action_just_pressed("p3_right"):
		if !player_nums.has(3):
			player_nums.append(3)
			$VBoxContainer/GreenContainer/CheckMark.visible = true
	if Input.is_action_just_pressed("p4_left") or Input.is_action_just_pressed("p4_right"):
		if !player_nums.has(4):
			player_nums.append(4)
			$VBoxContainer/PurpleContainer/CheckMark.visible = true
	
	if player_nums.size() >= 1:
		$LabelStart.visible = true
		if Input.is_action_just_pressed("ui_accept"):
				GlobalData.player_nums = player_nums
				get_tree().change_scene("res://game.tscn")

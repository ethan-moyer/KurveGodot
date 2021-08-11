extends Node2D


export(PackedScene) var player_packed : PackedScene
export var spawn_bounds_x : Vector2 = Vector2.ZERO
export var spawn_bounds_y : Vector2 = Vector2.ZERO

var players : Dictionary = {}
var trails : Array = []
var remaining_players : int


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for n in GlobalData.player_nums:
		var new_player = player_packed.instance()
		new_player.connect("spawn_trail", self, "_on_spawn_trail")
		call_deferred("add_child", new_player)
		new_player.player_num = n
		players[n] = [new_player, 0] #[player_node, score]
		
		if n == 1:
			$UI/Control/VBoxContainer/LabelBlue.visible = true
		elif n == 2:
			$UI/Control/VBoxContainer/LabelOrange.visible = true
		elif n == 3:
			$UI/Control/VBoxContainer/LabelGreen.visible = true
		elif n == 4:
			$UI/Control/VBoxContainer/LabelPurple.visible = true
	
	call_deferred("start_round")


func start_round():
	#Clear previous trails
	for t in trails:
		t.queue_free()
	trails = []
	
	#Reset Players
	for p in players:
		players[p][0].position = Vector2(rand_range(spawn_bounds_x.x, spawn_bounds_x.y),rand_range(spawn_bounds_y.x, spawn_bounds_y.y))
		players[p][0].start()
	remaining_players = players.size()
	
	$RoundStartTimer.start()


func _process(delta):
	#Collision
	for p in players:
		if player_collision(players[p][0]):
			players[p][0].set_process(false)
			remaining_players -= 1
			if remaining_players <= 1:
				round_over()
	
	$UI/Control/FPSCounter.text = str(Engine.get_frames_per_second())

func round_over():
	$RoundOverTimer.start()
	if remaining_players == 1:
		for p in players:
			if players[p][0].is_processing():
				#Update Score
				players[p][0].set_process(false)
				players[p][1] += 1
				
				#Update UI
				if p == 1:
					$UI/Control/VBoxContainer/LabelBlue.text = "BLUE: %s" % players[p][1]
					$UI/Control/LabelRoundOver.text = "BLUE WINS!"
				elif p == 2:
					$UI/Control/VBoxContainer/LabelOrange.text = "ORANGE: %s" % players[p][1]
					$UI/Control/LabelRoundOver.text = "ORANGE WINS!"
				elif p == 3:
					$UI/Control/VBoxContainer/LabelGreen.text = "GREEN: %s" % players[p][1]
					$UI/Control/LabelRoundOver.text = "GREEN WINS!"
				elif p == 4:
					$UI/Control/VBoxContainer/LabelPurple.text = "PURPLE: %s" % players[p][1]
					$UI/Control/LabelRoundOver.text = "PURPLE WINS!"
				return
	else:
		$UI/Control/LabelRoundOver.text = "IT'S A DRAW!"


func player_collision(player):
	#Checks if a player is currently colliding with any of the trails.
	#Iterate through every line segment and check if the closest point to the player is within the player's radius.
	if player.is_processing():
		for t in trails:
			for i in range(t.points.size() - 1):
				var closest_point : Vector2 = Geometry.get_closest_point_to_segment_2d(player.position, t.points[i], t.points[i+1])
				if closest_point.distance_squared_to(player.position) <= player.radius_squared:
					return true
		return false
	else:
		return false


func _on_spawn_trail(new_trail):
	trails.append(new_trail)


func _on_RoundStartTimer_timeout():
	for p in players:
		players[p][0].set_process(true)
		players[p][0].get_node("Arrow").visible = false


func _on_RoundOverTimer_timeout():
	$UI/Control/LabelRoundOver.text = ""
	start_round()


func _on_Walls_area_exited(area):
	#Collision for player hitting the walls.
	if area.is_in_group("Player"):
		area.set_process(false)
		remaining_players -= 1
		if remaining_players <= 1:
			round_over()

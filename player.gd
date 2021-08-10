extends Area2D


signal spawn_trail(new_trail)


export var player_num : int = 1
export var speed : float = 20.0
export var rotate_speed : float = 10.0
export var place_point_distance : float = 5.0
export var line_time_limit : float = 10
export var gap_time_limit : float = 0.5
export(PackedScene) var trail_packed : PackedScene

onready var sprite : Sprite = $Sprite
onready var radius_squared = pow($CollisionShape2D.shape.radius, 2)
var line_timer : float = 0
var gap_timer : float = 0
var forward : Vector2 = Vector2.UP
var drawing_line : bool = true
var trail : Line2D


func start():
	line_timer = 0
	gap_timer = 0
	drawing_line = true
	
	var angle = rand_range(0, 2*PI)
	forward = Vector2(cos(angle), sin(angle))
	$Arrow.visible = true
	$Arrow.rotation = angle + PI / 2
	add_new_trail()
	set_process(false)


func _ready():
	randomize()
	$Arrow.modulate = get_player_color()


func _process(delta):
	#Rotation & Movement
	if Input.is_action_pressed("p%s_left" % player_num):
		forward = forward.rotated(-rotate_speed * delta)
	if Input.is_action_pressed("p%s_right" % player_num):
		forward = forward.rotated(rotate_speed * delta)
	position += forward * speed * delta
	
	#Check if a new point should be added to trail
	if drawing_line:
		line_timer += delta
		if position.distance_to(trail.points[-1]) > place_point_distance:
			add_new_point()
		if line_timer >= line_time_limit:
			line_timer = 0
			drawing_line = false
	else:
		gap_timer += delta
		if gap_timer >= gap_time_limit:
			gap_timer = 0
			drawing_line = true
			add_new_trail()


func add_new_trail():
	trail = trail_packed.instance()
	get_tree().current_scene.call_deferred("add_child", trail)
	trail.default_color = get_player_color()
	emit_signal("spawn_trail", trail)
	add_new_point()


func add_new_point():
	var spawn_pos : Vector2 = position - forward * 7
	var temp_array : PoolVector2Array = trail.points
	temp_array.append(spawn_pos)
	trail.points = temp_array


func get_player_color():
	if player_num == 1:
		return Color.deepskyblue
	elif player_num == 2:
		return  Color.coral
	elif player_num == 3:
		return Color.greenyellow
	elif player_num == 4:
		return Color.mediumorchid

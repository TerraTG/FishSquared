extends Control

#imported nodes
@onready var bar_background: ColorRect = $BarBackground
@onready var control_bar: ColorRect = $ControlBar
@onready var fish_icon: ColorRect = $FishIcon
@onready var progress_bar: ProgressBar = $ProgressBar

#movement variables
var gravity = 0.098
var frame = 1
var velocity
var can_fish_move = true;
var begin = false

#stat values
var resistance: float
var speed
var min_move
var max_move

func _ready() -> void:
	progress_bar.value = Global.catch_meter
	await get_tree().create_timer(1.5).timeout;
	begin = true

func _process(delta: float) -> void:
	if begin:
		if Global.catch_meter >= 100:
			begin = false
			Global.reeling = "Win";
			$"../".queue_free()
		elif Global.catch_meter <= 0:
			begin = false
			Global.reeling = "Lose";
			$"../".queue_free()
		progress_bar.value = Global.catch_meter
		if fish_icon.position.x >= control_bar.position.x && fish_icon.position.x <= control_bar.position.x + control_bar.size.x:
			Global.catch_meter += delta * (12 * speed)
		else:
			Global.catch_meter -= delta * 12
		if can_fish_move:
			handle_ai();
		if Input.is_action_just_pressed("Click") || Input.is_action_just_released("Click"):
			frame = 0;
		if Input.is_action_pressed("Click"):
			if (control_bar.position.x + control_bar.size.x < bar_background.position.x + bar_background.size.x):
				input_handler();
			
		else:
			if (control_bar.position.x > bar_background.position.x):
				gravity_handler();

func input_handler():
	frame += 1
	velocity = gravity * frame
	control_bar.position.x += velocity

func gravity_handler():
	frame += 1
	velocity = gravity * frame
	control_bar.position.x -= velocity

func handle_ai():
	var move_left = randi_range(-max_move, -min_move)
	var move_right = randi_range(min_move, max_move)
	can_fish_move = false
	
	
	var wall_hit = check_if_hit_edge()
	if wall_hit != "None":
		match wall_hit:
			"Left":
				var tween = create_tween()
				tween.tween_property(fish_icon, "position", Vector2(fish_icon.position.x + move_right, fish_icon.position.y), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);
			"Right":
				var tween = create_tween()
				tween.tween_property(fish_icon, "position", Vector2(fish_icon.position.x + move_left, fish_icon.position.y), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);
	else:
		var direction = randi_range(0, 1);
		match direction:
			0:
				if fish_icon.position.x + move_left <= bar_background.position.x:
					var tween = get_tree().create_tween()
					tween.tween_property(fish_icon, "position", Vector2(bar_background.position.x, fish_icon.position.y), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);
				else:
					var tween = create_tween()
					tween.tween_property(fish_icon, "position", Vector2(fish_icon.position.x + move_left, fish_icon.position.y), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);
			1:
				if (fish_icon.position.x + move_right) + fish_icon.size.x >= bar_background.position.x + bar_background.size.x:
					var tween = create_tween()
					tween.tween_property(fish_icon, "position", Vector2(bar_background.position.x + (bar_background.size.x - fish_icon.size.x), fish_icon.position.y), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);
				else:
					var tween = create_tween()
					tween.tween_property(fish_icon, "position", Vector2(fish_icon.position.x + move_right, fish_icon.position.y), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);
		
	await get_tree().create_timer(resistance).timeout
	can_fish_move = true

func check_if_hit_edge() -> String:
	if (fish_icon.position.x > bar_background.position.x):
		if fish_icon.position.x + fish_icon.size.x < (bar_background.position.x + bar_background.size.x) - 10:
			return "None"
		else:
			return "Right"
	else:
		return "Left"
	

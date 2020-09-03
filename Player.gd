extends KinematicBody2D

var velocity = Vector2(0, 0);
var speed = 165;
var dash_charged = true;
var jump_count = 0;
var just_hit_ground = false;
var dashing = false;
onready var main_sprite = get_node("Sprite");

func _physics_process(_delta):
	
	if (Input.is_action_pressed("move_right")):
		main_sprite.set_flip_h(false); #flips sprite to direction
		velocity.x = speed;
	elif (Input.is_action_pressed("move_left")):
		main_sprite.set_flip_h(true);
		velocity.x = -speed;
	
	if (Input.is_action_just_pressed("dash") and dash_charged):
		dash();
	
	if (Input.is_action_just_pressed("jump") and jump_count < 2):
		velocity.y = -290;
		jump_count += 1;
	
	if (is_on_floor()):
		if (not just_hit_ground):
			$GroundSound.play();
			just_hit_ground = true;
		dash_charged = true;
		jump_count = 0;
	
	if (not is_on_floor() and not dashing):
		velocity.y += (15 + (10 if (Input.is_action_pressed("crouch") and not dashing) else 0)); #gravity
		just_hit_ground = false;
	# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP, true);
	velocity.x = lerp(velocity.x, 0, 0.25);
	print(global_position.y)
	if (global_position.y > 1000):
		global_position = Vector2(0, 0);

func dash():
	var up = 1 if Input.get_action_strength("up") else 0;
	var down = 1 if Input.get_action_strength("crouch") else 0;
	var left = 1 if Input.get_action_strength("move_left") else 0;
	var right = 1 if Input.get_action_strength("move_right") else 0;
	
	var dash_vector = Vector2(right - left, down - up).normalized() * 2.2 * speed;
	if (left or right and not up and not down):
		dash_vector *= 2;
	var angle = get_angle_to(global_position + dash_vector);
	$DashSound.play();
	
	dashing = true;
	velocity.x += cos(angle) * 400;
	velocity.y += sin(angle) * 400;
	dashing = false;
	
	dash_charged = false;

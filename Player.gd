extends KinematicBody2D

var velocity = Vector2(0, 0);
var speed = 165;
var jump_height = -300;
var death_count = 0;

var dash_charged = true;
var dashing = false;

var coyote_hanging = true;
var jump_was_pressed = false;
var just_hit_ground = false;

onready var main_sprite = get_node("Sprite");

enum {IDLE = 0, WALKING = 1, DASHING = 2, FAST_FALLING = 3};
var animation_state = IDLE;

func _physics_process(_delta):
	# flips sprite/animation to direction, and moves character left and right.
	if (Input.is_action_pressed("move_right")):
		main_sprite.set_flip_h(false); 
		velocity.x = speed;
	elif (Input.is_action_pressed("move_left")):
		main_sprite.set_flip_h(true);
		velocity.x = -speed;
	
	# checks if pressing dash button, then dashes
	if (Input.is_action_just_pressed("dash") and dash_charged):
		dash();
	
	# checks if pressing dash button, then adds velocity upwards 
	# coyote hanging allows you leniency when jumping
	if (Input.is_action_just_pressed("jump")):
		jump_was_pressed = true;
		remember_jump_time();
		if (coyote_hanging):
			velocity.y = jump_height;
	
	# short hopping
	if (Input.is_action_just_released("jump") and velocity.y < 0):
		velocity.y += 150;
	
	# plays ground hit noise, and sets a couple of variables
	# dash_charged (recharges dash on ground touch)
	if (is_on_floor()):
		if (jump_was_pressed):
			velocity.y = jump_height;
		coyote_hanging = true;
		if (not just_hit_ground):
			$GroundSound.play();
			just_hit_ground = true;
		dash_charged = true;
	
	# doesn't apply gravity when on a floor (or it would build endlessly),
	if (not is_on_floor()):
		coyote_time();
		velocity.y += (15 + (10 if (Input.is_action_pressed("crouch") and not dashing) else 0)); #gravity
		just_hit_ground = false;
	
	# moves character with the provided velocity
	# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP, true);
	
	# makes character movement slowly move down to zero when not moving to
	# not suddenly stop
	animation_loop();
	velocity.x = lerp(velocity.x, 0, 0.25);
	if (global_position.y > 1000):
		global_position = Vector2(0, 0);
		death_count += 1;

# function that dashes toward a direction
func dash():
	
	# makes variables based on what directions are being pressed 
	var up = 1 if Input.get_action_strength("up") else 0;
	var down = 1 if Input.get_action_strength("crouch") else 0;
	var left = 1 if Input.get_action_strength("move_left") else 0;
	var right = 1 if Input.get_action_strength("move_right") else 0;
	
	# vector to add to velocity
	var dash_vector = Vector2(right - left, down - up).normalized() * 2.2 * speed;
	if (left or right and not up and not down):
		dash_vector *= 2;
	var angle = get_angle_to(global_position + dash_vector);
	$DashSound.play();
	
	# adds to velocity
	dashing = true;
	velocity.x += cos(angle) * 400;
	velocity.y += sin(angle) * 400;
	dashing = false;
	
	dash_charged = false;
	pass;

func animation_loop():
	$Sprite/AnimationPlayer.play(str(animation_state));
	pass;
	
# gives leniency when jumping off platforms
func coyote_time():
	yield(get_tree().create_timer(0.1), "timeout");
	coyote_hanging = false;
	pass;

# allows jumps to "buffer", so you have leeway when bhopping
func remember_jump_time():
	yield(get_tree().create_timer(0.074), "timeout");
	jump_was_pressed = false;
	pass;

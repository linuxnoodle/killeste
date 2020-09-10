extends KinematicBody2D

var velocity = Vector2();
var axis = Vector2();
var speed = 165;
var jump_height = -300;
var death_count = 0;
var last_movement = 0;

var dash_speed = 36000;
var dash_charged = true;
var is_dashing = false;
var dash_time = 0;

var coyote_hanging = true;
var jump_was_pressed = false;
var just_hit_ground = false;

var wall_sliding = false;
var is_grabbing = false;
var wall_slide_factor = 0.8;

onready var main_sprite = get_node("Sprite");

enum {IDLE = 0, WALKING = 1, DASHING = 2, FAST_FALLING = 3};
var animation_state = IDLE;

func _physics_process(_delta):
	$Camera2D.global_transform.origin.y = 50;
	# flips sprite/animation to direction, and moves character left and right.
	# 0 is no movement, -1 is left, and 1 is right
	if (Input.is_action_pressed("move_right")):
		main_sprite.set_flip_h(false); 
		velocity.x = speed;
		if (last_movement != 1):
			self.get_node("CollisionShape2D").translate(Vector2(4.5, 0));
		last_movement = 1;
	elif (Input.is_action_pressed("move_left")):
		main_sprite.set_flip_h(true);
		velocity.x = -speed;
		if (last_movement != -1):
			self.get_node("CollisionShape2D").translate(Vector2(-4.5, 0));
		last_movement = -1;
	# checks if pressing dash button, then adds velocity upwards 
	# coyote hanging allows you leniency when jumping
	if (Input.is_action_just_pressed("jump")):
		jump_was_pressed = true;
		remember_jump_time();
		if (coyote_hanging):
			velocity.y = jump_height;

	# short hopping
	if (Input.is_action_just_released("jump") and velocity.y < 0):
		velocity.y += 100;

	# plays ground hit noise, and sets a couple of variables
	# dash_charged (recharges dash on ground touch)
	if (is_on_floor()):
		if (jump_was_pressed):
			velocity.y = jump_height;
		else:
			velocity.y = 0;
		coyote_hanging = true;
		if (not just_hit_ground):
			$GroundSound.play();
			just_hit_ground = true;
		dash_charged = true;

	# doesn't apply gravity when on a floor (or it would build endlessly),
	if (not is_on_floor()):
		coyote_time();
		velocity.y += (15 + (10 if (Input.is_action_pressed("crouch") and not is_dashing) else 0)); #gravity
		just_hit_ground = false;

	# checks if pressing dash button, then dashes
	if (Input.is_action_just_pressed("dash") and dash_charged):
		dash();

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
	
	velocity = Vector2.ZERO;
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
	is_dashing = true;
	velocity.x += cos(angle) * 400;
	velocity.y += sin(angle) * 400;
	is_dashing = false;

	dash_charged = false;
	pass;

func animation_loop():
	$Sprite/AnimationPlayer.play(str(animation_state));
	pass;

# gives leniency when jumping off platforms
func coyote_time():
	yield(get_tree().create_timer(0.15), "timeout");
	coyote_hanging = false;
	pass;

# allows jumps to "buffer", so you have leeway when bhopping
func remember_jump_time():
	yield(get_tree().create_timer(0.074), "timeout");
	jump_was_pressed = false;
	pass;

# slows down when next to wall
func wallSlide(delta):
	if not is_on_floor():
		if $Rotatable/RayCast2D.is_colliding():
			wall_sliding = true;
			if Input.is_action_pressed("grab"):
				is_grabbing = true;
				if axis.y != 0:
					velocity.y = axis.y * 12000 * delta;
				else:
					velocity.y = 0;
			else:
				is_grabbing = false;
				velocity.y = velocity.y * wall_slide_factor;
		else:
			wall_sliding = false;
			is_grabbing = false;


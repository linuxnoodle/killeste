extends KinematicBody2D

const TYPE = "PLAYER";

var velocity = Vector2();
var axis = Vector2();
var DEATH_POS = Vector2(0, 0);
var speed = 150;
var jump_height = -350;
var death_count = 0;
var last_movement = 0;

var dash_speed = 350;
var dash_charged = true;

var coyote_hanging = true;
var jump_was_pressed = false;
var just_hit_ground = false;

var is_grabbing = false;
var is_jumping = false;
var is_walking = false;
var is_dashing = false;

var wall_sliding = false;
var just_reset_color = false;
var walljump_count = 0;
var wall_slide_factor = 0.865;
var player_movement_allowed = true;

onready var main_sprite = get_node("Sprite");
onready var collision = get_node("CollisionShape2D");

onready var ground_sound = get_node("GroundSound");
onready var dash_sound = get_node("DashSound");

onready var animation_player = get_node("Sprite/AnimationPlayer");
onready var Global = get_node("/root/MusicController");
onready var Networking = get_node("/root/Networking");

slave var slave_position = Vector2();
slave var slave_movement = Vector2();

func _physics_process(delta):
	
	if (is_network_master() or Global.singleplayer):
		# flips sprite/animation to direction, and moves character left and right.
		# 0 is no movement, -1 is left, and 1 is right
		if (Input.is_action_pressed("move_right") and player_movement_allowed):
			main_sprite.set_flip_h(false); 
			velocity.x = speed;
			is_walking = true;
			if (last_movement < 0):
				collision.translate(Vector2(11, 0));
			last_movement = 1;
		elif (Input.is_action_pressed("move_left") and player_movement_allowed):
			main_sprite.set_flip_h(true);
			velocity.x = -speed;
			is_walking = true;
			if (last_movement != -1):
				collision.translate(Vector2(-11, 0));
			last_movement = -1;
		else:
			is_walking = false;
		# checks if pressing dash button, then adds velocity upwards 
		# coyote hanging allows you leniency when jumping
		if (Input.is_action_just_pressed("jump")):
			jump_was_pressed = true;
			remember_jump_time();
			if (coyote_hanging):
				is_jumping = true;
				velocity.y = jump_height;
				yield(get_tree().create_timer(0.3), "timeout");
				is_jumping = false;
		
		# crouching
		# 0.65x speed
		# 1.3x dash
		if (Input.is_action_pressed("crouch") and not is_dashing and is_on_floor()):
			scale.y = 0.65;
			speed = 82.5;
			dash_speed = 195;
			player_movement_allowed = false;
		elif (Input.is_action_just_released("crouch")):
			scale.y = 1;
			speed = 165; 
			dash_speed = 150;
			player_movement_allowed = true;
		
		# short hopping
		if (Input.is_action_just_released("jump") and velocity.y < 0):
			velocity.y += 100;
		
		if (not (is_dashing or is_jumping)):
			wall_slide(delta);
		
		# plays ground hit noise, and sets a couple of variables
		# dash_charged (recharges dash on ground touch)
		if (is_on_floor()):
			if (jump_was_pressed):
				velocity.y = jump_height;
			else:
				velocity.y = 0;
			coyote_hanging = true;
			if (not just_hit_ground):
				ground_sound.play();
				just_hit_ground = true;
			dash_charged = true;
			walljump_count = 0;
			modulate = Color(1, 1, 1, 1);

		# doesn't apply gravity when on a floor (or it would build endlessly),
		if ((not is_on_floor()) and (not is_grabbing)):
			coyote_time();
			velocity.y += (20 + (10 if (Input.is_action_pressed("crouch") and not is_dashing) else 0)); #gravity
			just_hit_ground = false;

		# checks if pressing dash button, then dashes
		if (Input.is_action_just_pressed("dash") and dash_charged):
			dash();
		
		# speed capping
		if (velocity.x > 600):
			velocity.x = 600;
		elif (velocity.x < -600):
			velocity.x = -600;
		if (velocity.y > 500):
			velocity.y = 500;
		elif (velocity.y < -500):
			velocity.y = -500;
			
		# moves character with the provided velocity
		# warning-ignore:return_value_discarded
		move_and_slide(velocity, Vector2.UP, true);

		# makes character movement slowly move down to zero when not moving to
		# not suddenly stop
		animation_loop();
		velocity.x = lerp(velocity.x, 0, 0.25);
		if (global_position.y > 550):
			die();
		rset_unreliable('slave_position', position);
		rset('slave_movement', velocity);
	else:
		move_and_slide(slave_movement, Vector2.UP, true);
		position = slave_position;
		
	
	if (get_tree().is_network_server()):
		Network.update_position(int(name), position)

func die():
	global_position = DEATH_POS;
	Engine.time_scale = 0.5;
	yield(get_tree().create_timer(0.2), "timeout");
	Engine.time_scale = 1;
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
	var dash_vector = Vector2(right - left, down - up).normalized() * 3.2 * dash_speed;
	if ((left or right) and not (up or down)):
		dash_vector *= 4;
	dash_sound.play();

	# adds to velocity
	is_dashing = true;
	velocity = dash_vector;
	modulate = Color(0.35, 0.35, 0.5, 1);
	yield(get_tree().create_timer(0.2), "timeout");
	is_dashing = false;
	modulate = Color(0.5, 0.35, 0.35, 1);
	
	dash_charged = false;
	pass;

func animation_loop():
	if (is_jumping or jump_was_pressed):
		animation_player.play("Jumping");
	elif (is_dashing or is_walking):
		animation_player.play("Walking");
	else:
		animation_player.play("0");

# gives leniency when jumping off platforms
func coyote_time():
	yield(get_tree().create_timer(0.15), "timeout");
	coyote_hanging = false;
	pass;

# allows jumps to "buffer", so you have leeway when bhopping
func remember_jump_time():
	yield(get_tree().create_timer(0.1), "timeout");
	jump_was_pressed = false;
	pass;

# slows down when next to wall
func wall_slide(delta):
	if not (is_on_floor()):
		if (is_on_wall()):
			wall_sliding = true;
			if (Input.is_action_pressed("grab")):
				is_grabbing = (true and walljump_count < 4);
				if (Input.is_action_just_pressed("jump") and walljump_count < 4):
					velocity.y += -80000 * delta;
					walljump_count += 1;
				elif (Input.is_action_pressed("up") and walljump_count < 4):
					velocity.y = -8000 * delta;
					walljump_count += 0.05;
				elif (Input.is_action_pressed("crouch") and walljump_count < 4):
					velocity.y = 8000 * delta;
					walljump_count += 0.05;
				else:
					if (walljump_count >= 4):
						modulate = Color(0.7, 0.5, 0, 1)
					if (axis.y != 0 and walljump_count < 4):
						velocity.y = axis.y * 60000 * delta;
					else:
						velocity.y = 0;
			elif (Input.is_action_just_pressed("jump")):
				velocity.x *= -500 * delta;
				velocity.y *= -275 * delta;
				player_movement_allowed = false;
				main_sprite.set_flip_h(false if (last_movement == -1) else true);
				yield(get_tree().create_timer(0.35), 'timeout');
				player_movement_allowed = true;
			else:
				is_grabbing = false;
				velocity.y = velocity.y * wall_slide_factor;
		else:
			wall_sliding = false;
			is_grabbing = false;

func init(start_position, is_slave):
	global_position = start_position
	if is_slave:
		$Sprite.texture = load('res://killeste-idle-alt.piskel');

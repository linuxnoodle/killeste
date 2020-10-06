extends Area2D

onready var collision = get_node("CollisionPolygon2D");
onready var sprite = get_node("Sprite");

func _on_Area2D_body_entered(body):
	if (body.get("TYPE") == "PLAYER"):
		if (body.dash_charged):
			body.dash_charged = true;
			body.walljump_count = 0;
			body.modulate = Color(1, 1, 1, 1);
			
			collision.disabled = true;
			sprite.visible = false;
			yield(get_tree().create_timer(5), "timeout")
			collision.disabled = false;
			sprite.visible = true

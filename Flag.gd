extends Area2D

onready var collision = get_node("CollisionShape2D");
onready var sprite = get_node("Sprite");

func _on_Area2D_body_entered(body):
	if (body.get("TYPE") == "PLAYER"):
		collision.disabled = true;
		sprite.modulate = Color(0, 1, 1, 1);
		body.DEATH_POS = Vector2(global_position.x, global_position.y - 20);

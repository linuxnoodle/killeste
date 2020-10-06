extends Area2D

onready var collision = get_node("CollisionShape2D");
onready var sprite = get_node("Sprite");

func _on_Area2D_body_entered(body):
	if (body.get("TYPE") == "PLAYER"):
		collision.disabled = true;
		sprite.visible = false;
		body.get_node("CanvasLayer/Panel/MarginContainer/Label").timer_on = false;

extends Area2D

func _on_Area2D_body_entered(body):
	if (body.get("TYPE") == "PLAYER"):
		body.global_position = Vector2(0, 0);
		body.death_count += 1;

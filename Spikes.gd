extends Area2D

func _on_Area2D_body_entered(body):
	if (body.get("TYPE") == "PLAYER"):
		body.die();
		body.death_count += 1;

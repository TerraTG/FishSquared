extends Button

func _on_pressed() -> void:
	Global.shake_meter += 1;
	Global.can_spawn_button = true;
	queue_free();

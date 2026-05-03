class_name HighlightArea

extends Area2D

var twenn: Tween

func _on_character_entered(body: Node2D) -> void:
    if body is Character:
        if twenn:
            twenn.kill()
        twenn = create_tween().set_parallel(true)
        twenn.tween_property(get_parent(), "modulate:a", 0.3, 0.1)
        twenn.tween_property(body.sprite.material, "shader_parameter/outline_color", Color.WHITE, 0.1)

func _on_character_exited(body: Node2D) -> void:
    if body is Character:
        if twenn:
            twenn.kill()
        twenn = create_tween().set_parallel(true)
        twenn.tween_property(get_parent(), "modulate:a", 1.0, 0.1)
        twenn.tween_property(body.sprite.material, "shader_parameter/outline_color", Color.TRANSPARENT, 0.1)

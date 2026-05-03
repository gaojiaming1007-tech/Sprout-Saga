class_name Pickable

extends Area2D

@export var inventory: Inventory

@export var sprite: Sprite2D

@export var count: int = 1

func _ready():
    set_size()
    play_animation()

func set_size():
    var t_size = inventory["highlight_texture"].get_size()
    sprite.texture = inventory["highlight_texture"]
    sprite.scale = Vector2(12.0 / t_size.x, 12.0 / t_size.y)

func play_animation():
    var random_angle = randf_range(0, TAU)
    var random_distance = randf_range(12 * 0.8, 16 * 1.2)
    var target_position = global_position + Vector2(cos(random_angle), sin(random_angle)) * random_distance

    var tween := create_tween()
    tween.set_parallel(true)

    tween.tween_method(
        func(t):
            var sine_t = t * PI

            var current_x = lerp(global_position.x, target_position.x, t)
            var current_y = lerp(global_position.y, target_position.y, t)


            var vertical_offset = sin(sine_t) * 5

            global_position = Vector2(current_x, current_y - vertical_offset)
            ,
            0.0, 1.0, 0.4
    ).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)


func _on_character_entered(body: Node2D) -> void:
     if body is Character:
        body.on_pickable_enter(self )


func _on_character_exited(body: Node2D) -> void:
    if body is Character:
        body.on_pickable_leave(self )

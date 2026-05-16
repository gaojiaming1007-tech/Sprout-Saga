class_name TransferArea

extends Area2D

@export var timer: Timer

@export var target_level: Game.LevelType

var is_enter: bool = false

var has_finish: bool = false

func _on_character_entered(body: Node2D) -> void:
    if body is Character:
        is_enter = true

func _on_character_exited(body: Node2D) -> void:
    if body is Character:
        is_enter = false
        timer.stop()
        has_finish = false

func _process(delta: float) -> void:
    if has_finish || !is_enter: return
    if GameManager.game.character.direction.is_zero_approx():
        timer.stop()
    else:
        if timer.is_stopped():
            timer.start()

func _on_timer_timeout() -> void:
    if !has_finish:
        has_finish = true
        GameManager.game.load_level(target_level)

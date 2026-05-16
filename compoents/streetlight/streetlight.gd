class_name Streetlight

extends Node2D

@export var animtion_player: AnimationPlayer

func _enter_tree() -> void:
    GameManager.game.time_record.day.connect(on_day)
    GameManager.game.time_record.night.connect(on_night)

func on_day():
    animtion_player.play('off')

func on_night():
    animtion_player.play('on')

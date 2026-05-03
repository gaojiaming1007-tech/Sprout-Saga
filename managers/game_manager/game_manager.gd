extends Node

@export var game: Game

signal quit

func _ready() -> void:
    get_tree().set_auto_accept_quit(false)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        on_quit()

func on_quit():
    quit.emit()
    print("quit")
    get_tree().quit()
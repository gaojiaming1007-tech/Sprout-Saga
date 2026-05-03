class_name InterfaceNode

extends Control

signal click

##是否在UI之上
static var above = false

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
            on_left_click()
    elif event is InputEventMouseMotion:
        on_move()

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_MOUSE_ENTER:
            on_mouse_enter()
        NOTIFICATION_MOUSE_EXIT:
            on_mouse_exit()

func on_mouse_enter():
    above = true

func on_mouse_exit():
    above = false

func on_move():
    pass

func on_left_click():
    click.emit()

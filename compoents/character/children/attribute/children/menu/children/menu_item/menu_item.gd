class_name MenuItem

extends InterfaceNode

@export var texture_rect: TextureRect

@export var animation_player: AnimationPlayer

@export var icon: AtlasTexture

func _ready() -> void:
    texture_rect.texture = icon
    texture_rect.material = texture_rect.material.duplicate()
    texture_rect.material.set("shader_parameter/outline_color", Color.TRANSPARENT)

func on_mouse_enter():
    super.on_mouse_enter()
    texture_rect.material.set("shader_parameter/outline_color", Color.WHITE)
    animation_player.play('bounce')

func on_mouse_exit():
    super.on_mouse_exit()
    texture_rect.material.set("shader_parameter/outline_color", Color.TRANSPARENT)
    animation_player.stop()

func on_left_click():
    super.on_left_click()
    GameManager.game.character.attribute.menu.on_click_item(name)

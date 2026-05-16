class_name Message

extends CanvasLayer

@export var root: PanelContainer

@export var icon: TextureRect

@export var label: Label

func set_default(at_position: Vector2, at: AtlasTexture, content: String):
    icon.texture = at
    label.text = content
    root.reset_size()
    var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN)
    root.global_position = Vector2(at_position.x - 10, at_position.y)
    tween.tween_property(root, "global_position", Vector2(at_position.x - 10, at_position.y - 20), 0.8)
    await tween.finished
    queue_free()

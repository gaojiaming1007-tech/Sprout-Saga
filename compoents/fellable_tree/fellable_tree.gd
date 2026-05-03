class_name FellableTree

extends Node2D

## { fellable_tree:FellableTreeResource,axe_count:int,position:Vector2i }
var current: Dictionary

@export var sprite: Sprite2D

@export var highlight_are: HighlightArea

@export var animation_player: AnimationPlayer

func _ready() -> void:
    set_frame_from_sequence()

func set_frame_from_sequence():
    if current["axe_count"] >= current["fellable_tree"]["times"]:
        sprite.texture = current["fellable_tree"]["stump_atlas"]
    else:
        sprite.texture = current["fellable_tree"]["whole_atlas"]
    update_highlight_area()
    
func update_highlight_area():
    if highlight_are && current["axe_count"] >= current["fellable_tree"]["times"]:
        highlight_are.queue_free()

func to_axe():
    if animation_player.is_playing(): return
    animation_player.play("rock")
    await animation_player.animation_finished
    current["axe_count"] += 1
    set_frame_from_sequence()

    if current["axe_count"] == current["fellable_tree"]["times"]:
        await create_collapse_wood()
        UtilsManager.drop_pickable(current["fellable_tree"]["wood"], 3, global_position + Vector2(8, 8))
    elif current["axe_count"] == current["fellable_tree"]["destroy_times"]:
        UtilsManager.drop_pickable(current["fellable_tree"]["wood"], 1, global_position + Vector2(8, 8))
        GameManager.game.current_level_instance.remove_fellable_tree(self )

func create_collapse_wood():
    var collapse_wood := Sprite2D.new()
    collapse_wood.centered = false
    collapse_wood.offset = Vector2(-16, -48)
    collapse_wood.texture = current["fellable_tree"]["collapse_altas"]
    sprite.get_parent().add_child(collapse_wood)
    var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN)
    tween.tween_property(collapse_wood, "position", Vector2(0, -8), 1)
    tween.tween_property(collapse_wood, "rotation_degrees", 90 if GameManager.game.character.global_position.x < global_position.x else -90, 1)
    await tween.finished
    collapse_wood.queue_free()

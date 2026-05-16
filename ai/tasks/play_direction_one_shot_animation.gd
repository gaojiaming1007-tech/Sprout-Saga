extends Action

@export var animation_name: String

@export var enable_direction: bool

@export var direction: Character.FaceDirection

func _enter() -> void:
    super._enter()
    var current = "%s_%s" % [animation_name, Character.FACE_DIRECTION[direction if enable_direction else blackboard.get_var("face_direction")]]
    if npc.animation_sprite2d.animation != current || !npc.animation_sprite2d.is_playing():
        npc.animation_sprite2d.play(current)

func _tick(_delta: float) -> Status:
    if npc.animation_sprite2d.is_playing():
        return RUNNING
    return SUCCESS

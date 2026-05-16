extends Action

@export var visible: bool

func _enter() -> void:
    super._enter()
    npc.interact.visible = visible

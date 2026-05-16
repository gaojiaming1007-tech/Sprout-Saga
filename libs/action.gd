class_name Action

extends BTAction

var npc: NPC

func _enter() -> void:
    npc = agent as NPC

func _tick(_delta: float) -> Status:
    return SUCCESS

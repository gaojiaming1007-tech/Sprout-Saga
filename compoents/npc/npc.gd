class_name NPC

extends Node2D

enum NpcType {
    Boatman,
    Blacksmith
}

const NPC_TYPE = {
    NpcType.Boatman: 'boatman',
    NpcType.Blacksmith: 'blacksmith'
}

@export var machine: BTPlayer

@export var graphics: Node2D

@export var animation_sprite2d: AnimatedSprite2D

@export var interact: Control

@export var schedule_list_resource: ScheduleListResource

signal move_finish

func _enter_tree() -> void:
    machine.blackboard.set_var("is_range", false)
    machine.blackboard.set_var("move", false)

func _ready() -> void:
    if !schedule_list_resource: return
    GameManager.quit.connect(save)
    GameManager.game.time_record.time_update.connect(to_update_schedule)
    to_update_schedule()

func save():
    ResourceSaver.save(schedule_list_resource, schedule_list_resource.resource_path)

func to_update_schedule():
    for item in schedule_list_resource.list:
        item.update(self )

func _on_character_entered(body: Node2D) -> void:
    if body is Character:
        machine.blackboard.set_var("is_range", true)

func _on_character_exited(body: Node2D) -> void:
    if body is Character:
        machine.blackboard.set_var("is_range", false)

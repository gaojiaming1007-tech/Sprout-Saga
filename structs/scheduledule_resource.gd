class_name ScheduleResource

extends Resource

enum ScheduleType {
    Day
}

@export var type: ScheduleType = ScheduleType.Day

@export var start_place: String

@export var target_place: String

@export var level: Game.LevelType = Game.LevelType.Village

@export_group("day")

@export var hour: int = 0

@export var end_hour: int = 0

## 返回日程位置
func get_schedule_position(place: String):
    var list := GameManager.get_tree().get_nodes_in_group("schedule")
    var index = list.find_custom(func(n: Node2D): return n.name == place)
    if index == -1:
        return Vector2.ZERO
    return list[index].global_position

## 时间更新
func update(npc: NPC):
    if GameManager.game.game_resource.level != level: return
    if type == ScheduleType.Day:
        update_day_schedule(npc)

## 日更新
func update_day_schedule(npc: NPC):
    pass

## 完成
func finish(npc: NPC):
    pass

class_name BlacksmithWork

extends ScheduleResource

func update_day_schedule(npc: NPC):
    if !npc.machine.blackboard.get_var("move"):
        if GameManager.game.game_resource.hour == hour:
            handle(npc)
        else:
            if GameManager.game.game_resource.hour >= end_hour || GameManager.game.game_resource.hour < hour:
                npc.global_position = get_schedule_position(start_place)
                npc.visible = false
            else:
                finish(npc)

func handle(npc: NPC):
    npc.visible = true
    npc.global_position = get_schedule_position(start_place)
    npc.machine.blackboard.set_var("move", true)
    npc.machine.blackboard.set_var("destination", get_schedule_position(target_place))
    await npc.move_finish
    finish(npc)

## 完成
func finish(npc: NPC):
    npc.visible = true
    npc.global_position = get_schedule_position(target_place)
    npc.schedule_list_resource.list = npc.schedule_list_resource.list.filter(func(item: ScheduleResource): return item != self )
    var rest: BlacksmithRest = ResourceManager.load_resource("res://resources/schedule/blacksmith/rest.tres")
    npc.schedule_list_resource.list.push_back(rest)

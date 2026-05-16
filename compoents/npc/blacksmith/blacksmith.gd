class_name Blacksmith

extends NPC

func _process(_delta):
    ImGui.Begin("blacksmith")
    if ImGui.Button('move'):
        machine.blackboard.set_var("move", true)
        machine.blackboard.set_var("destination", Vector2(512, -568))
    ImGui.End()

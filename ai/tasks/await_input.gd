extends Action

@export var input_key: String

func _tick(_delta: float) -> Status:
    return SUCCESS if Input.is_action_just_pressed(input_key) else FAILURE

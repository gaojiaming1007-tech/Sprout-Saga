class_name StatusInfo

extends InterfaceNode

func _process(_delta: float) -> void:
    var resource = GameManager.game.character.character_resource
    %Money.text = str(resource.money)

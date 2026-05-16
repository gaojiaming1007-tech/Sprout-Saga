extends Action

@export var dialogue_name: String

func _enter() -> void:
    super._enter()
    if !GameManager.game.character.is_dialogue:
        Dialogic.start(dialogue_name)
        SoundManager.player_audio(SoundManager.AudioType.Dialogue_Start, -10.0)
        GameManager.game.character.on_dialogue_timeline_started(dialogue_name)
        await Dialogic.timeline_ended
        GameManager.game.character.on_dialogue_timeline_ended(dialogue_name)

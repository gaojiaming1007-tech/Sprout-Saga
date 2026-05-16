class_name ClassifyButton

extends InterfaceNode

@export var animation_player: AnimationPlayer

@export var type: Main.MainType = Main.MainType.Game

func _ready() -> void:
    %Label.text = Main.MAIN_TYPE[type]

func reset():
    animation_player.play('reset')

func focus():
    animation_player.play('focus')
    SoundManager.player_audio(SoundManager.AudioType.UI_Click, -3, 0.01, SoundManager.AudioGrade.UI)

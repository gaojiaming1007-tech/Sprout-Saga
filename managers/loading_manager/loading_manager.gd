extends Node

@export var loading:ColorRect

@export var animation_player:AnimationPlayer

var is_loading:bool = false

func enter_force():
    loading.material.set("shader_parameter/progress",0.0)

func leave_force():
    loading.material.set("shader_parameter/progress",1.0)

func enter(center:Vector2,invent:bool = false,callback:Callable = func():pass):
    is_loading = true
    loading.material.set("shader_parameter/is_active",invent)
    loading.material.set("shader_parameter/center_point",center)
    animation_player.play('enter')
    await animation_player.animation_finished
    callback.call()

func leave(center:Vector2,callback:Callable = func():pass):
    loading.material.set("shader_parameter/center_point",center)
    animation_player.play('leave')
    await animation_player.animation_finished
    is_loading = false
    callback.call()

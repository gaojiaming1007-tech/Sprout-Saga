class_name TaskResource

extends Resource

## 任务ID
@export var id: int

## 任务发布者
@export var promupgator: NPC.NpcType

## 任务总结
@export var summary: String

## 任务描述
@export var describe: String

## 任务是否完成
@export var done: bool = false

## 任务详情
@export var detail: Resource

## 任务奖励 { inventory:Inventory, count:int }
@export var reward: Array[Dictionary]

## 处理状态
func deal_done(npc: String):
    done = detail.deal_done(npc)

func is_own_npc(npc: String):
    if detail is CollectTaskDetailResource:
        return true

func pay():
    detail.pay()

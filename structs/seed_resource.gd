class_name SeedResource

extends Resource

## 生长序列帧
@export var sequence_frame: AtlasTexture

## 每个生长阶段到下一阶段需要的时间，长度等于sequence_frame帧数 - 1
@export var groth_time_state: Array[int]

## 成熟的果实
@export var fruit: Inventory

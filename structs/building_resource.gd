class_name BuildingResource

extends Resource

enum BuildingType {
    Wood_Fence,
    Iron_Fence,
    Chest
}

##  key:BuildingType,value:Array[Vector2i]
@export var buildings: Dictionary

##  key:Vector2i,value:Array[ChestResource]
@export var chests: Dictionary

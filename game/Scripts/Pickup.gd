@tool
extends Area2D

enum Pickups {SEEDS, STAMINA, HEALTH, WATER}
@export var item: Pickups

var seeds_texture = preload("res://Sunnyside_World_ASSET_PACK_V2.1/Sunnyside_World_Assets/Elements/Crops/beetroot_00.png")
var stamina_texture = preload("res://Assets/Icons/fruit_01b.png")
var health_texture = preload("res://Assets/Icons/potion_03c.png")
var water_texture = preload("res://Sunnyside_World_ASSET_PACK_V2.1/Sunnyside_World_Assets/UI/water.png")
# Called when the node enters the scene tree for the first time.

@onready var sprite = $Sprite2D

func _ready():
	if not Engine.is_editor_hint():
		if item == Pickups.SEEDS:
			sprite.set_texture(seeds_texture)
		elif item == Pickups.HEALTH:
			sprite.set_texture(health_texture)
		elif item == Pickups.STAMINA:
			sprite.set_texture(stamina_texture)
		elif item == Pickups.WATER:
			sprite.set_texture(water_texture)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		if item == Pickups.SEEDS:
			sprite.set_texture(seeds_texture)
		elif item == Pickups.HEALTH:
			sprite.set_texture(health_texture)
		elif item == Pickups.STAMINA:
			sprite.set_texture(stamina_texture)
		elif item == Pickups.WATER:
			sprite.set_texture(water_texture)
			


func _on_body_entered(body):
	if body.name == "Player":
		body.add_pickup(item)
		get_tree().queue_delete(self)


extends ColorRect

@onready var value = $Value
# Called when the node enters the scene tree for the first time.

func update_seeds_pickup_ui(seeds_pickup):
	value.text = str(seeds_pickup)

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

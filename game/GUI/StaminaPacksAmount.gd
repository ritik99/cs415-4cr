extends ColorRect

@onready var value = $Value
# Called when the node enters the scene tree for the first time.

func update_stamina_pickup_ui(stamina_pickup):
	value.text = str(stamina_pickup)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

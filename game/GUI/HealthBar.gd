extends ColorRect

@onready var value = $Value

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_health_ui(health, max_health):
	value.size.x = 98 * health / max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

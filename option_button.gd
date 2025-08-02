extends OptionButton

@export var title = ""
@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = title

# Called every frame. 'delta' is the elapsed time since the previous frame.

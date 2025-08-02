extends StaticBody2D

@onready var chip_scene = preload("res://chip.tscn")
@onready var button = $Button
@export var column_number = 0
@onready var sprite_2d = $Sprite2D
@onready var chip_preview = $ChipPreview

var empty = true

func _ready():
	sprite_2d.visible = false

func _process(_delta):
	if Global.main.game_state[column_number][5] == -1 && not Global.main.input_disabled:
		sprite_2d.modulate = Color(1,1,1,1)
		chip_preview.modulate = Color(1,1,1,0.5)
		chip_preview.set_frame(Global.main.whose_turn)
	else:
		sprite_2d.modulate = Color(1,1,1,0)
		chip_preview.modulate = Color(1,1,1,0)
	if Global.main.move_auto == column_number:
		Global.main.column = column_number
		Global.main.move_auto = -1
		if Global.main.game_speed != 2:
			chip_preview.offset.y -= 64
			var chip = chip_scene.instantiate()
			add_child(chip)
		else:
			if empty:
				chip_preview.offset.y = 0
				empty = false
			var chip = chip_scene.instantiate()
			add_child(chip)
			chip.position.y = chip_preview.position.y + chip_preview.offset.y
			chip_preview.offset.y -= 64
	if Global.main.winner != -1:
		button.disabled = true
		empty = true
	else:
		button.disabled = false

func _on_button_pressed():
	if Global.main.game_state[column_number][5] == -1 && not Global.main.input_disabled:
		Global.main.column = column_number
		if empty:
				chip_preview.offset.y = 0
				empty = false
		if Global.main.game_speed != 2:
			chip_preview.offset.y -= 64
			var chip = chip_scene.instantiate()
			add_child(chip)
		else:
			var chip = chip_scene.instantiate()
			add_child(chip)
			chip.position.y = chip_preview.position.y + chip_preview.offset.y
			chip_preview.offset.y -= 64
			

func _on_button_mouse_entered():
	sprite_2d.visible = true
	chip_preview.visible = true

func _on_button_mouse_exited():
	sprite_2d.visible = false
	chip_preview.visible = false

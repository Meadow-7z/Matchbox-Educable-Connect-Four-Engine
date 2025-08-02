extends CharacterBody2D

var gravities = [60, 400, 0]
var gravity = gravities[Global.main.game_speed]
var falling = true
@onready var sprite_2d = $Sprite2D

func _ready():
	Global.main.input_disabled = true
	sprite_2d.set_frame(Global.main.whose_turn)
	if gravity == 0:
		falling = false
		Global.main.place_chip(sprite_2d.frame)

func _physics_process(_delta):
	if Global.main.game_speed != 2 && not is_on_floor():
		velocity.y += gravity
		move_and_slide()
	elif falling:
		falling = false
		Global.main.place_chip(sprite_2d.frame)

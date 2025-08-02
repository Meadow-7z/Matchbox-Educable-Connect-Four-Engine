extends Node2D

@onready var label = $Label
@onready var game_counter = $GameCounter
@onready var player_display = $PlayerDisplay
@onready var button = $Button
@onready var selections = [$PlayerSelect0, $PlayerSelect1, $SpeedSelect, $ContinueSelect]
@onready var columns = [$Column0, $Column1, $Column2, $Column3, $Column4, $Column5, $Column6]
@onready var timer = $Timer
@onready var save_button = $SaveButton
@onready var save_select_0 = $SaveSelect0
@onready var save_select_1 = $SaveSelect1

var input_disabled = true
var whose_turn = 0
var player_count = 2
var game_state = [[-1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1]]
var column = 0
var winner = -1
var turn = 0
var game_round = 1
var move_auto = -1
var players = ["human", "human"]
var player_list = ["human", "random", "MEC4E"]
var game_speed = 0
var game_number = 0
var wins = []
var autoplay_stopped = false
var matchboxes0 = {}
var matchboxes1 = {}
var mec4e_data0 = {}
var mec4e_data1 = {}

func _ready():
	randomize()
	player_display.visible = false

func _process(_delta):
	if game_number == 0:
		var game_ready = true
		for b in selections:
			if b.get_selected_id() == -1 && visible == true:
				game_ready = false
				break
		if game_ready:
			button.visible = true

func game_start():
	save_select_0.visible = false
	save_select_1.visible = false
	save_button.visible = false
	save_button.disabled = false
	save_button.text = "Save"
	player_display.set_frame(0)
	turn = 0
	game_round = 1
	whose_turn = 0
	game_state = [[-1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1]]
	winner = -1
	autoplay_stopped = false
	if game_number == 0:
		if FileAccess.file_exists("user://" + save_select_0.text + "a.matchbox"):
			var remember = FileAccess.open("user://" + save_select_0.text + "a.matchbox", FileAccess.READ)
			matchboxes0 = remember.get_var()
			#print(matchboxes0)
		if FileAccess.file_exists("user://" + save_select_1.text + "b.matchbox"):
			var remember = FileAccess.open("user://" + save_select_1.text + "b.matchbox", FileAccess.READ)
			matchboxes1 = remember.get_var()
			#print(matchboxes1)
	for co in columns:
		for c in co.find_children("*", "CharacterBody2D", false, false):
			c.queue_free()
		co.empty = true
		co.chip_preview.offset.y = 0
	for b in selections:
		b.visible = false
	players[0] = player_list[selections[0].get_selected_id()]
	players[1] = player_list[selections[1].get_selected_id()]
	game_speed = selections[2].get_selected_id()
	if selections[3].get_selected_id() == 0:
		button.visible = false
	else:
		button.text = "Stop Autoplay"
	game_number += 1
	game_counter.text = "Game " + str(game_number) + "\nRed wins: " + str(wins.count(0)) + "\nYellow wins: " + str(wins.count(1)) + "\nDraws: " + str(wins.count(-2))
	if players.has("human") || game_speed != 2:
		label.text = "Red player's turn"
		player_display.visible = true
	else:
		label.visible = false
	match players[0]:
		"human":
			input_disabled = false
		"random":
			move_auto = pick_random_move()
		"MEC4E":
			move_auto = mec4e_pick_move(matchboxes0, 0)
		_:
			move_auto = pick_random_move()

func next_turn():
	turn += 1
	whose_turn += 1
	if whose_turn >= player_count:
		whose_turn = 0
		game_round += 1
	if is_instance_valid(label):
		match whose_turn:
			0:
				label.text = "Red player's turn"
			1:
				label.text = "Yellow player's turn"
			_:
				label.text = "Player " + str(whose_turn + 1) + "'s turn"
	player_display.set_frame(whose_turn)
	match players[whose_turn]:
		"human":
			input_disabled = false
		"random":
			move_auto = pick_random_move()
		"MEC4E":
			match whose_turn:
				0:
					move_auto = mec4e_pick_move(matchboxes0, 0)
					#print(matchboxes0)
				1:
					move_auto = mec4e_pick_move(matchboxes1, 1)
		_:
			move_auto = pick_random_move()

func place_chip(player):
	for slot in range(0,6):
		if game_state[column][slot] == -1:
			game_state[column][slot] = player
			if check_win(slot, column):
				label.visible = true
				winner = player
				match winner:
					0:
						label.text = "Red wins!!!"
					1:
						label.text = "Yellow wins!!"
					_:
						label.text = "Player " + str(whose_turn + 1) + " wins!!!"
				game_end()
			elif turn == 41:
				label.visible = true
				label.text = "It's a draw!!!"
				player_display.visible = false
				winner = -2
				game_end()
			else:
				next_turn()
			break

func check_win(c_row, c_column):
	var player = game_state[c_column][c_row]
	var c_connected = 1
	if c_row > 2:
		if game_state[c_column][c_row - 1] == player:
			c_connected += 1
			if game_state[c_column][c_row - 2] == player:
				c_connected += 1
				if game_state[c_column][c_row - 3] == player:
					c_connected += 1
	if c_connected >= 4:
		return true
	else:
		c_connected = 1
	
	if c_column < 6:
		if game_state[c_column + 1][c_row] == player:
			c_connected += 1
			if c_column < 5:
				if game_state[c_column + 2][c_row] == player:
					c_connected += 1
					if c_column < 4:
						if game_state[c_column + 3][c_row] == player:
							c_connected += 1
	if c_column > 0:
		if game_state[c_column - 1][c_row] == player:
			c_connected += 1
			if c_column > 1:
				if game_state[c_column - 2][c_row] == player:
					c_connected += 1
					if c_column > 2:
						if game_state[c_column - 3][c_row] == player:
							c_connected += 1
	if c_connected >= 4:
		return true
	else:
		c_connected = 1
	
	if c_column < 6 && c_row < 5:
		if game_state[c_column + 1][c_row + 1] == player:
			c_connected += 1
			if c_column < 5 && c_row < 4:
				if game_state[c_column + 2][c_row + 2] == player:
					c_connected += 1
					if c_column < 4 && c_row < 3:
						if game_state[c_column + 3][c_row + 3] == player:
							c_connected += 1
	if c_column > 0 && c_row > 0:
		if game_state[c_column - 1][c_row - 1] == player:
			c_connected += 1
			if c_column > 1 && c_row > 1:
				if game_state[c_column - 2][c_row - 2] == player:
					c_connected += 1
					if c_column > 2 && c_row > 2:
						if game_state[c_column - 3][c_row - 3] == player:
							c_connected += 1
	if c_connected >= 4:
		return true
	else:
		c_connected = 1
		
	if c_column < 6 && c_row > 0:
		if game_state[c_column + 1][c_row - 1] == player:
			c_connected += 1
			if c_column < 5 && c_row > 1:
				if game_state[c_column + 2][c_row - 2] == player:
					c_connected += 1
					if c_column < 4 && c_row > 2:
						if game_state[c_column + 3][c_row - 3] == player:
							c_connected += 1
	if c_column > 0 && c_row < 5:
		if game_state[c_column - 1][c_row + 1] == player:
			c_connected += 1
			if c_column > 1 && c_row < 4:
				if game_state[c_column - 2][c_row + 2] == player:
					c_connected += 1
					if c_column > 2 && c_row < 3:
						if game_state[c_column - 3][c_row + 3] == player:
							c_connected += 1
	if c_connected >= 4:
		return true
	else:
		return false
	
func pick_random_move():
	var moves = [0, 1, 2, 3, 4, 5, 6]
	var move_select = 0
	for c in game_state:
		if c[5] != -1:
			moves.erase(move_select)
		move_select += 1
	return moves.pick_random()

func game_end():
	wins.append(winner)
	game_counter.text = "Game " + str(game_number) + "\nRed wins: " + str(wins.count(0)) + "\nYellow wins: " + str(wins.count(1)) + "\nDraws: " + str(wins.count(-2))
	if players[0] == "MEC4E":
		mec4e_learn(0)
		save_button.visible = true
	if players[1] == "MEC4E":
		mec4e_learn(1)
		save_button.visible = true
	if selections[3].get_selected_id() == 0 || autoplay_stopped:
		button.visible = true
		button.text = "New Game"
	elif selections[2].get_selected_id() == 2:
		game_start()
	else:
		timer.start()

func _on_button_pressed():
	if game_number == 0 || winner != -1:
		game_start()
	else:
		button.visible = false
		autoplay_stopped = true

func _on_timer_timeout():
	if winner != -1:
		game_start()

func mec4e_pick_move(matchboxes, player_num):
	var c_game_state = game_state.duplicate(true)
	var reversed = false
	var move_weights = []
	var danger = false
	if matchboxes.has(c_game_state):
		move_weights = matchboxes[c_game_state]
	else:
		c_game_state.reverse()
		if matchboxes.has(c_game_state):
			reversed = true
			move_weights = matchboxes[c_game_state]
		else:
			c_game_state.reverse()
			var w_default = 22 - game_round
			if c_game_state[0] == c_game_state[6] && c_game_state[1] == c_game_state[5] && c_game_state[2] == c_game_state[4]:
				move_weights = [w_default, w_default, w_default, w_default, 0, 0, 0]
			else:
				move_weights = [w_default, w_default, w_default, w_default, w_default, w_default, w_default]
			var move_select = 0
			for c in c_game_state:
				if c[5] != -1:
					move_weights[move_select] = 0
				move_select += 1
			matchboxes[c_game_state] = move_weights
			#print(move_weights)
	if move_weights == [0, 0, 0, 0, 0, 0, 0]:
		danger = true
		if c_game_state[0] == c_game_state[6] && c_game_state[1] == c_game_state[5] && c_game_state[2] == c_game_state[4]:
			move_weights = [1, 1, 1, 1, 0, 0, 0]
		else:
			move_weights = [1, 1, 1, 1, 1, 1, 1]
		var move_select = 0
		for c in c_game_state:
				if c[5] != -1:
					move_weights[move_select] = 0
				move_select += 1
		matchboxes[c_game_state] = move_weights
	var w_sum = move_weights[0] + move_weights[1] + move_weights[2] + move_weights[3] + move_weights[4] + move_weights[5] + move_weights[6]
	var choice_num = randi_range(1, w_sum)
	var choice = -1
	while choice_num > 0:
		choice+= 1
		choice_num -= move_weights[choice]
	var move_data = [choice, c_game_state, danger]
	match player_num:
		0:
			mec4e_data0[game_round] = move_data
		1:
			mec4e_data1[game_round] = move_data
	#print(matchboxes)
	if reversed:
		return (6 - choice)
	else:
		return choice
		
func mec4e_learn(player_num):
	var move_data = {}
	if player_num == 1 && winner == 0:
		game_round -= 1
	match player_num:
		0:
			move_data = mec4e_data0
			mec4e_data0 = {}
		1:
			move_data = mec4e_data1
			mec4e_data1 = {}
	var lesson = 0
	match winner:
		player_num:
			lesson = 22 - game_round
		-2:
			lesson = 1
		_:
			lesson = game_round - 22
	for m in move_data:
		var move_made = move_data[m]
		var move_state = []
		if m == game_round:
			match winner:
				player_num:
					match player_num:
						0:
							move_state = matchboxes0[move_made[1]]
							#print("Turn " + str(m) + "\nWas: " + str(move_state))
							move_state = [0, 0, 0, 0, 0, 0, 0]
							move_state[move_made[0]] = 1
							matchboxes0[move_made[1]] = move_state
							#print("Now: " + str(move_state))
						1:
							move_state = matchboxes1[move_made[1]]
							move_state = [0, 0, 0, 0, 0, 0, 0]
							move_state[move_made[0]] = 1
							matchboxes1[move_made[1]] = move_state
				-2:
					pass
				_:
					match player_num:
						0:
							move_state = matchboxes0[move_made[1]]
							#print("Turn " + str(m) + "\nWas: " + str(move_state))
							move_state[move_made[0]] = 0
							matchboxes0[move_made[1]] = move_state
							#print("Now: " + str(move_state))
						1:
							move_state = matchboxes1[move_made[1]]
							#print(move_state)
							move_state[move_made[0]] = 0
							matchboxes1[move_made[1]] = move_state
							#print(move_state)
		elif move_data[m+1][2]:
			match player_num:
				0:
					move_state = matchboxes0[move_made[1]]
					#print("Turn " + str(m) + "\nWas: " + str(move_state))
					move_state[move_made[0]] -= 6
					if move_state[move_made[0]] < 0:
						move_state[move_made[0]] = 0
					matchboxes0[move_made[1]] = move_state
					#print("Now: " + str(move_state))
				1:
					move_state = matchboxes1[move_made[1]]
					move_state[move_made[0]] -= 6
					if move_state[move_made[0]] < 0:
						move_state[move_made[0]] = 0
					matchboxes1[move_made[1]] = move_state
		else:
			match player_num:
				0:
					move_state = matchboxes0[move_made[1]]
					print("Turn " + str(m) + "\nWas: " + str(move_state))
					move_state[move_made[0]] += lesson
					if move_state[move_made[0]] < 0:
						move_state[move_made[0]] = 0
					matchboxes0[move_made[1]] = move_state
					print("Now: " + str(move_state))
				1:
					move_state = matchboxes1[move_made[1]]
					move_state[move_made[0]] += lesson
					if move_state[move_made[0]] < 0:
						move_state[move_made[0]] = 0
					matchboxes1[move_made[1]] = move_state
				
func _on_save_button_pressed():
	save_button.disabled = true
	button.disabled = true
	save_button.text = "Saving..."
	var remember0 = FileAccess.open("user://" + save_select_0.text + "a.matchbox", FileAccess.WRITE)
	remember0.store_var(matchboxes0)
	#var remember0txt = FileAccess.open("user://" + save_select_0.text + "a.txt", FileAccess.WRITE)
	#remember0txt.store_string(str(matchboxes0))
	var remember1 = FileAccess.open("user://" + save_select_1.text + "b.matchbox", FileAccess.WRITE)
	remember1.store_var(matchboxes1)
	#var remember1txt = FileAccess.open("user://" + save_select_1.text + "b.txt", FileAccess.WRITE)
	#remember1txt.store_string(str(matchboxes1))
	button.disabled = false
	save_button.text = "Saved"

func _on_player_select_0_item_selected(index):
	if index == 2:
		save_select_0.visible = true
	else:
		save_select_0.visible = false

func _on_player_select_1_item_selected(index):
	if index == 2:
		save_select_1.visible = true
	else:
		save_select_1.visible = false

func _on_save_select_0_text_changed(new_text):
	if not new_text.is_valid_filename():
		new_text = new_text.validate_filename()
		save_select_0.text = new_text
		save_select_0.caret_column = new_text.length()
	if FileAccess.file_exists("user://" + new_text + "a.matchbox"):
		save_select_0.modulate = Color(0.5,1,0.5,1)
	else:
		save_select_0.modulate = Color(1,1,1,1)

func _on_save_select_1_text_changed(new_text):
	if not new_text.is_valid_filename():
		new_text = new_text.validate_filename()
		save_select_1.text = new_text
		save_select_1.caret_column = new_text.length()
	if FileAccess.file_exists("user://" + new_text + "b.matchbox"):
		save_select_1.modulate = Color(0.5,1,0.5,1)
	else:
		save_select_1.modulate = Color(1,1,1,1)

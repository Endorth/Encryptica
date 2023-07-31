extends Control
const PLAYER = preload("res://Scenes/EncPlayer.tscn")
const CARTEL = preload("res://Scenes/Cartel.tscn")
const LEAD = preload("res://Scenes/LeadLabel.tscn")
#onready var gift = $Gift
onready var players = $Players
var is_game_start = false

var current_frase : String = ''
var current_pista : String = ''
var psph = []
class MyCustomSorter:
	static func sort_descending(a, b):
		if a[0] > b[0]:
			return true
		return false

func _sorter():
	var sort_array = []
	for pl in players.get_children():
		sort_array.append([pl.points, pl])
	sort_array.sort_custom(MyCustomSorter, "sort_descending")
	
	var i = 0
	for sorted_players in sort_array:
		players.move_child(sorted_players[1], i)
		i += 1
	
func _ready():
	$Menu.connect("was_pressed", self, 'connection')
	randomize()
	$Menu.visible = false
	$LeaderPanel.visible = false
	for player in players.get_children():
		players.remove_child(player)
	
	TwitchChat.connect("new_message", self, "send_data")

func connection(text):
	TwitchChat.channel = text
	TwitchChat._anon_connection()
	$Menu.visible = false
	$MenuButton.pressed = false

func send_data(data):
	if "username" in data:
		var user : String = data["username"]
		var msg : String = data["msg"]
		if is_new_player(user):
			add_player(user)
		if msg.begins_with("!l "):
			add_letter(user, msg, "!l ")
		elif msg.begins_with("!letter "):
			add_letter(user, msg, "!letter ")
		elif msg.begins_with("!s "):
			add_solve(user, msg, "!s ")
		elif msg.begins_with("!solve "):
			add_solve(user, msg, "!solve ")

func add_solve(plyr, msg, m):
	match m:
		"!s " : 
			msg.erase(0, 3)
		"!solve " : 
			msg.erase(0, 7)
	msg = msg.left(msg.length() - 1)
	check_solve(msg, plyr)

func check_solve(msg, plyr):
	if msg.to_upper() == current_frase:
		for box in $MainContainer.get_children():
			for c in box.get_children():
				if not c.is_solved:
					c.solve()
		if is_game_start:
			give_points_to(plyr, 10)
			check_results()

func add_letter(plyr, msg, m):
	match m:
		"!l " :
			msg.erase(0, 3)
		"!letter " : 
			msg.erase(0, 8)
	
	msg = msg.left(msg.length() - 1)
	check_letters(msg, plyr)

func is_correct_type(let, msg) -> bool:
	var b : bool = false
	if msg.length() == 1:
		if is_vocal(let):
			b = (base_letter(msg) == base_letter(let))
		else:
			b = (msg.to_upper() == let.to_upper())
	return b

func base_letter(l) -> String:
	var s : String = ''
	match l:
		"a" : s = 'A'
		"á" : s = 'A'
		"A" : s = 'A'
		"Á" : s = 'A'
		"e" : s = 'E'
		"é" : s = 'E'
		"E" : s = 'E'
		"É" : s = 'E'
		"i" : s = 'I'
		"í" : s = 'I'
		"I" : s = 'I'
		"Í" : s = 'I'
		"o" : s = 'O'
		"ó" : s = 'O'
		"O" : s = 'O'
		"Ó" : s = 'O'
		"u" : s = 'U'
		"ú" : s = 'U'
		"U" : s = 'U'
		"Ú" : s = 'U'
	return s

func is_vocal(l) -> bool:
	var b : bool = false
	match l:
		"a" : b = true
		"á" : b = true
		"A" : b = true
		"Á" : b = true
		"e" : b = true
		"é" : b = true
		"E" : b = true
		"É" : b = true
		"i" : b = true
		"í" : b = true
		"I" : b = true
		"Í" : b = true
		"o" : b = true
		"ó" : b = true
		"O" : b = true
		"Ó" : b = true
		"u" : b = true
		"ú" : b = true
		"U" : b = true
		"Ú" : b = true
	return b

func check_letters(msg, plyr):
	var i = 0
	for box in $MainContainer.get_children():
		for c in box.get_children():
			if is_correct_type(c.letter, msg):
				if not c.is_solved:
					c.solve()
					i += 1
	if is_game_start:
		give_points_to(plyr, i)
		check_results()

func check_results():
	if is_panel_completed():
		is_game_start = false
		EDB.frases[psph[0]]["solved"] = true
	_sorter()
	$RecordContainer/Label.text = players.get_children()[0].user + " -> " + str(
																							players.get_children()[0].points)
	if players.get_child_count() > 2:
		$RecordContainer/Label.text = players.get_children()[0].user + " -> " + str(
																	players.get_children()[0].points)
		$RecordContainer/Label2.text = players.get_children()[1].user + " -> " + str(
																		players.get_children()[1].points)
		$RecordContainer/Label3.text = players.get_children()[2].user + " -> " + str(
																		players.get_children()[2].points)
	update_leaderboard()
	
func is_panel_completed() -> bool:
	var b : bool = true
	for box in $MainContainer.get_children():
		for c in box.get_children():
			if not c.is_solved:
				b = false
				break
	return b
		
func give_points_to(plyr, i):
	for player in players.get_children():
		if player.user == plyr:
			player.points += i

#func enter_action(user, msg):
##	var r = randi()% 10
##	var user = 'endorth' + str(r)
#	print(players)
#	if is_new_player(user):
#		add_player(user)
#	if msg.begins_with("!l "):
#		add_letter(user, msg, "!l ")
#	elif msg.begins_with("!letter "):
#		add_letter(user, msg, "!letter ")
#	elif msg.begins_with("!s "):
#		add_solve(user, msg, "!s ")
#	elif msg.begins_with("!solve "):
#		add_solve(user, msg, "!solve ")
#	$SendButton/LineEdit.clear()

func is_new_player(user) -> bool:
	var b : bool = true
	for player in players.get_children():
		if player.user == user:
			b = false
			break
	return b

func add_player(user):
	var p = PLAYER.instance()
	p.user = user
	players.add_child(p)
	

func _on_SendButton_pressed():
	pass
#	enter_action($SendButton/LineEdit.text)

func add_cartel(l):
	var c = CARTEL.instance()
	
	c.is_special = is_special_character(l)
	c.letter = l
	c.is_in_game = true
	
	if $MainContainer/HBox.get_child_count() < 14:
		$MainContainer/HBox.add_child(c)
	elif $MainContainer/HBox2.get_child_count() < 14:
		$MainContainer/HBox2.add_child(c)
	else:
		$MainContainer/HBox3.add_child(c)

func is_special_character(l) -> bool:
	var is_sp = false
	match l:
		" " : is_sp = true
		"," : is_sp = true
		"." : is_sp = true
	return is_sp

func new_game(f):
	is_game_start = true
	for box in $MainContainer.get_children():
		for c in box.get_children():
			box.remove_child(c)
	current_frase = f["frase"]
	current_pista = f["pista"]
	
	$PistaLab.text = current_pista
	
	for l in current_frase:
		add_cartel(l)

	
func _on_AddPhrase_pressed():
	psph = []
	for ph in EDB.frases:
		if not EDB.frases[ph]["solved"]:
			psph.append(ph)
	psph.shuffle()
	new_game(EDB.frases[psph[0]])

func _on_LeaderboardButton_toggled(button_pressed):
	$LeaderPanel.visible = button_pressed
	update_leaderboard()
	
func update_leaderboard():
	for l in $LeaderPanel/ScrollContainer/VBoxContainer.get_children():
		$LeaderPanel/ScrollContainer/VBoxContainer.remove_child(l)
	_sorter()
	var i = 0
	for pl in players.get_children():
		add_leader_label(pl, i)
		i += 1
		
func add_leader_label(_pl, i):
	var l = LEAD.instance()
	$LeaderPanel/ScrollContainer/VBoxContainer.add_child(l)
	l.text = players.get_children()[i].user + " -> " + str(
																			players.get_children()[i].points)



func _on_MenuButton_toggled(button_pressed):
	$Menu.visible = button_pressed

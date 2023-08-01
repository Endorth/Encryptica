extends TextureRect


export var letter : String = ''
var is_special : bool = false
var is_in_game : bool = false
var is_solved : bool = false

func _ready():
	if is_in_game:
		set_special(is_special)
		if not is_special:
			$Label.text = ""
		else:
			$Label.text = letter
	else:
		$Label.text = letter

func set_special(bol):
	if bol:
		is_solved = true
		self_modulate = Color("#a4c9c8")
	else:
		self_modulate = Color.white

func solve():
	$Label.text = letter
	is_solved = true

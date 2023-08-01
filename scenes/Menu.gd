extends Control
onready var line = $LineEdit
signal was_pressed()

func _on_ConnecteButton_pressed():
	emit_signal("was_pressed", line.text)
	

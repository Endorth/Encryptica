extends Control

signal was_pressed()
func _on_ConnecteButton_pressed():
	emit_signal("was_pressed", $LineEdit.text)
	

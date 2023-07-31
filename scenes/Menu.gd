extends Control


func _on_ConnecteButton_pressed():
	TwitchChat.channel = $LineEdit.text
	TwitchChat._anon_connection()

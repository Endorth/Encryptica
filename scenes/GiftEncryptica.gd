extends Gift

signal new_letter()
signal new_solve()


func _ready() -> void:
	connect_to_twitch()
	yield(self, "twitch_connected")
	
	authenticate_oauth("endorth4", "oauth:uuhflmpy4jii7ems7vycqrholz6anp")
	
	if(yield(self, "login_attempt") == false):
		print("Invalid username or token.")
		return
		
	join_channel("endorth4")
	# warning-ignore: return_value_discarded
	connect("cmd_no_permission", self, "no_permission")
	# warning-ignore: return_value_discarded
	connect("chat_message", self, "infinitica_chat_message")

func infinitica_chat_message(sender_data: SenderData, msg: String):
	if msg.begins_with("!l ") or msg.begins_with("!letter "):
		emit_signal("new_letter", sender_data.user, msg)
	elif msg.begins_with("!s ") or msg.begins_with("!solve "):
		emit_signal("new_solve", sender_data.user, msg)

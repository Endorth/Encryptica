extends Node

signal print_message(message)
signal send_message(message)
signal received_message(message, user)


var channel : String = ''
var user : String = ''
var token : String = ''

# The URL we will connect to
export var websocket_url = "wss://irc-ws.chat.twitch.tv:443"

# Our WebSocketClient instance
var _client = WebSocketClient.new()
var connected:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# activate ssl
	_client.verify_ssl = true
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "closed")
	_client.connect("connection_error", self, "closed")
	_client.connect("connection_established", self, "connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "on_data")
	
	

	emit_signal("print_message", "Connecting to %s" % [websocket_url])
	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		emit_signal("print_message", "Unable to connect Twitch")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _client.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		_client.poll()


func closed(_was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	emit_signal("print_message", "Closed comunication with twich")

func connected(_proto = ""):
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	emit_signal("print_message", "Connected with Twich, waiting to join the channel...")
	
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	
	if Constants.channel != "" && Constants.user != "" && Constants.token != "":
		connect_to_channel(Constants.token, Constants.user, Constants.channel)


func on_data():
	var messages : PoolStringArray = _client.get_peer(1).get_packet().get_string_from_utf8().strip_edges(false).split("\r\n")
	for message in messages:
		#print ("raw: ", message)
		if(message.begins_with("PING")):
			sendMessage("PONG :tmi.twitch.tv")
		else:
			var msg : PoolStringArray = message.split(" ", false, 1)
			var messageRaw:String = msg[1]
			var startIndexMessage = messageRaw.find("#"+Constants.channel)+len("#"+Constants.channel)+2
			var messageCutted:String = messageRaw.substr(startIndexMessage)
			var user:String = msg[0].substr(1, msg[0].find("!")-1)
			if user != Constants.user: #maybe active the message 366?
				emit_signal("received_message", message, user)

func sendMessage(message:String):
	if connected:
		emit_signal("print_message", "sent: %s" % [message])
		_client.get_peer(1).put_packet(message.to_utf8())
	
func connect_to_channel(token, channel, user):
	# sendMessage("CAP REQ :twitch.tv/membership twitch.tv/tags twitch.tv/commands") we need this?
	if connected:
		sendMessage("PART #"+Constants.channel)
	
	connected = true
	sendMessage("PASS "+token)
	sendMessage("NICK "+user)
	sendMessage("JOIN #"+channel)

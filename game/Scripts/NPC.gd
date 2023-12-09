extends CharacterBody2D

@onready var interact_label = $NPCInteractLabel
@onready var textbox_boundary = $TextBox/TextBoxBoundary
@onready var textbox_label = $TextBox/NPCDialogue
@onready var continue_label = $TextBox/ContinueLabel
@onready var http_node = $HTTPRequest
@onready var user_input = $TextBox/UserInput
@onready var submit_input_label = $TextBox/SubmitInput
@onready var exit_label = $TextBox/ExitLabel

var continuing_interaction = false

signal interaction(availability, obj)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	http_node.request_completed.connect(self._on_HTTPRequest_request_completed)
	
func _process(delta):
	pass
	
func _physics_process(delta):
	pass

func _input(event):
	pass

func player_animations(direction: Vector2):
	pass

func returned_direction(direction: Vector2):
	pass

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		print('Player entered')
		interact_label.visible = !interact_label.visible
		body.interaction_availability = true
		body.interaction_target = self

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		print('Player exited')
		interact_label.visible = !interact_label.visible
		body.interaction_availability = false
		body.interaction_target = self
		
		textbox_boundary.visible = false
		textbox_label.visible = false
		continue_label.visible = false

func run_interaction():
	var url = "https://api.openai.com/v1/chat/completions"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer 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" # Replace with your actual API key
	]
	var body = {
		"model": "gpt-4",
		"messages": [
			{"role": "system", "content": "You are Skeletor, a game character in the world of West World. \
			West World is set in the year 2025. The main character in this game is Jimmy Neutron, a \
			college kid who has been accidentally teleported to the alternate dimension of West World. \
			West world is a 2D map. There is a Bank near the middle of the map, to the left of you, a Salon \
			to the north of you. The Sheriff and the Hotel is also to the left of you, right next to the Bank. \
			When the player talks to you give him a warm welcome and ask if they need any help. Keep your \
			messages short."},
			{"role": "user", "content": "Hello!"}
		]
	}
	
	var json_body = JSON.stringify(body)
	
	var error = http_node.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		push_error("An error occurred in the HTTP request")
		
func continue_interaction():
	textbox_label.visible = false
	continue_label.visible = false
	user_input.visible = true
	user_input.editable = true
	submit_input_label.visible = true
	continuing_interaction = true

func exit_interaction():
	submit_input_label.visible = false
	continuing_interaction = false
	exit_label.visible = false
	textbox_boundary.visible = false
	textbox_label.visible = false
	
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	textbox_label.text = str(response["choices"][0]["message"]["content"])
	print(response["choices"][0]["message"]["content"])
	textbox_boundary.visible = true
	textbox_label.visible = true
	if continuing_interaction == false:
		continue_label.visible = true
		exit_label.visible = false
	else:
		continue_label.visible = false
		exit_label.visible = true

func _on_user_input_text_submitted(new_text):
	print("User entered: ", new_text)
	user_input.visible = false
	user_input.editable = false
	submit_input_label.visible = false
	
	var url = "https://api.openai.com/v1/chat/completions"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer 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" # Replace with your actual API key
	]
	var body = {
		"model": "gpt-4",
		"messages": [
			{"role": "system", "content": "You are Skeletor, a game character in the world of West World. \
			West World is set in the year 2025. The main character in this game is Jimmy Neutron, a \
			college kid who has been accidentally teleported to the alternate dimension of West World. \
			West world is a 2D map. There is a Bank near the middle of the map, to the left of you, a Salon \
			to the north of you. The Sheriff and the Hotel is also to the left of you, right next to the Bank. \
			When the player talks to you give him a warm welcome and ask if they need any help. Keep your \
			messages short. Do not greet the player, only answer his question. Also, do not ask the player \
			if they have any more questions. Only answer their question. Also warn the player that there is a dangerous \
			goblin near the shores on the right."},
			{"role": "user", "content": new_text}
		]
	}
	
	var json_body = JSON.stringify(body)
	
	var error = http_node.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		push_error("An error occurred in the HTTP request")

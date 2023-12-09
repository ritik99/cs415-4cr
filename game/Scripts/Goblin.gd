extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var speed = 45
var direction: Vector2

var new_direction = Vector2(0, 1)
var rng = RandomNumberGenerator.new()
var timer = 0
var attacking = false
var player_in_hitzone = false
var player_dead = false
var dead = false

@onready var player = get_tree().root.get_node("Main/Player")
@onready var animation_sprite = $AnimatedSprite2D

func _ready():
	rng.randomize()
	
func returned_direction(direction: Vector2):
	var normalized_direction = direction.normalized()
	var default_return = "side"
	
	if normalized_direction.x >= 0:
		animation_sprite.flip_h = false
	else:
		animation_sprite.flip_h = true
		
	return default_return
	
func player_animations(direction: Vector2, speed):
	var player_distance = player.position - position
	if dead:
		var animation = "death"
		animation_sprite.play(animation)
		
	elif player_distance.length() <= 30 and !player_dead:
		var animation = "attack"
		returned_direction(direction)
		animation_sprite.play(animation)
		attacking = true
	elif direction != Vector2.ZERO and speed != 0:
		var animation = "walk"
		returned_direction(direction)
		animation_sprite.play(animation)
		attacking = false
	else:
		var animation = "idle"
		returned_direction(direction)
		animation_sprite.play(animation)
		attacking = false

func _physics_process(delta):
	var player_distance = player.position - position
	if player_distance.length() <= 30:
		direction = player_distance.normalized()
		speed = 0
	elif player_distance.length() <= 100 and player_distance.length() > 30:
		direction = player_distance.normalized()
		speed = 45
		
	var movement = speed * direction * delta
	var collision = move_and_collide(movement)
	player_animations(direction, speed)

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player_in_hitzone = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_in_hitzone = false

func _on_animated_sprite_2d_animation_finished():
	if attacking and player_in_hitzone and !dead:
		player.health = player.health - 20
		if player.health <= 0:
			print('deadedadeadeada')
			attacking = false
			player_dead = true
	elif dead:
		self.queue_free()
		
		
func goblin_die():
	print('AAAAHHHHH')
	if !dead:
		player_animations(direction, 0)
	dead = true



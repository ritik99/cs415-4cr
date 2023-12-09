extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animation_sprite = $AnimatedSprite2D
@onready var health_bar = $UI/HealthBar
@onready var stamina_bar = $UI/StaminaBar
@onready var healthpacks_amount = $UI/HealthPacksAmount
@onready var staminapacks_amount = $UI/StaminaPacksAmount

@export var speed = 0
var is_attacking = false
var direction: Vector2
var health = 100
var max_health = 100
var regen_health = 1
var stamina = 100
var max_stamina = 100
var regen_stamina = 5
var interaction_target
var interaction_availability = false
var is_interacting = false
var continued_interaction = false
var goblin_in_hitzone = false
var animation_finished = false

signal health_updated
signal stamina_updated
signal health_pickups_updated
signal stamina_pickups_updated
signal seeds_pickups_updated
signal water_pickups_updated

enum Pickups {SEEDS, STAMINA, HEALTH, WATER}
var seeds_pickup = 0
var stamina_pickup = 0
var health_pickup = 0
var water_pickup = 0
var successful_hit = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	health_updated.connect(health_bar.update_health_ui)
	stamina_updated.connect(stamina_bar.update_stamina_ui)
	health_pickups_updated.connect(healthpacks_amount.update_health_pickup_ui)
	stamina_pickups_updated.connect(staminapacks_amount.update_stamina_pickup_ui)
	
func restart_game():
	var current_scene = get_tree().current_scene
	get_tree().reload_current_scene()

func _process(delta):
	var updated_health = min(health + regen_health * delta, max_health)
	if health <= 0:
		player_animations(direction)
		restart_game()
	elif updated_health != health:
		health = updated_health
		health_updated.emit(health, max_health)
		
	var updated_stamina = min(stamina + regen_stamina * delta, max_stamina)
	if updated_stamina != stamina:
		stamina = updated_stamina
		stamina_updated.emit(stamina, max_stamina)
	

func _physics_process(delta):
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	if Input.is_action_pressed("ui_sprint"):
		if stamina >= 0:
			speed = 100
			stamina = stamina - 1
			stamina_updated.emit(stamina, max_stamina)
		else:
			speed = 50		
	elif Input.is_action_just_released("ui_sprint"):
		speed = 50
	else:
		speed  = 50
	
	var movement = 0
	if is_interacting == false:
		movement = speed * direction * delta
	
	if is_attacking == false and is_interacting == false:
		move_and_collide(movement)
		player_animations(direction)
	
	if !Input.is_anything_pressed():
		if is_attacking == false:
			var animation = "idle"
			returned_direction(direction)
		
func _input(event):
	if event.is_action_pressed("ui_attack") and is_interacting == false:
		is_attacking = true
		var animation = "attack"
		returned_direction(direction)
		animation_sprite.play(animation)
		if goblin_in_hitzone:
			successful_hit += 1
			get_tree().call_group("full_scene", "goblin_die")
		
	if event.is_action_pressed("ui_interact"):
		if interaction_availability and is_interacting == false:
			is_interacting = true
			interaction_target.run_interaction()
	
	if event.is_action_pressed("ui_continue_interaction"):
		if interaction_availability and continued_interaction == false:
			continued_interaction == true
			interaction_target.continue_interaction()
	if event.is_action_pressed("ui_exit_interaction"):
		interaction_target.exit_interaction()
		is_interacting = false
			
	if event.is_action_pressed("use_health_pickup"):
		use_health_pickup()
	
	if event.is_action_pressed("use_stamina_pickup"):
		use_stamina_pickup()
		
func player_animations(direction: Vector2):
	if health <= 0:
		var animation = "death"
		animation_sprite.play(animation)
	if direction != Vector2.ZERO:
		var animation = "walk"
		returned_direction(direction)
		animation_sprite.play(animation)
	else:
		var animation = "idle"
		returned_direction(direction)
		animation_sprite.play(animation)
		
func returned_direction(direction: Vector2):
	var normalized_direction = direction.normalized()
	var default_return = "side"
	
	if normalized_direction.x >= 0:
		animation_sprite.flip_h = false
	else:
		animation_sprite.flip_h = true
		
	return default_return

func use_health_pickup():
	health = health + 25
	health_pickup = health_pickup - 1
	health_pickups_updated.emit(health_pickup)

func use_stamina_pickup():
	stamina = stamina + 50
	stamina_pickup = stamina_pickup - 1
	stamina_pickups_updated.emit(stamina_pickup)

func add_pickup(item):
	if item == Pickups.HEALTH:
		health_pickup = health_pickup + 1
		health_pickups_updated.emit(health_pickup)
	elif item == Pickups.WATER:
		water_pickup = water_pickup + 1
		water_pickups_updated.emit(water_pickup)
	elif item == Pickups.SEEDS:
		seeds_pickup = seeds_pickup + 1
		seeds_pickups_updated.emit(seeds_pickup)
	elif item == Pickups.STAMINA:
		stamina_pickup = stamina_pickup + 1
		stamina_pickups_updated.emit(stamina_pickup)
		
func _on_animated_sprite_2d_animation_finished():
	is_attacking = false

func _on_area_2d_body_entered(body):
	if body.name == "Goblin":
		goblin_in_hitzone = true

func _on_area_2d_body_exited(body):
	if body.name == "Goblin":
		goblin_in_hitzone = false

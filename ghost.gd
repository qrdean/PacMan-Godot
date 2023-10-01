extends CharacterBody2D
class_name Ghost

@export var ghost_type: String
@export var ghost_starting_location: Vector2

var SPEED = 60.0
var state = PEN

@export var scatter_nav_array = []
var scatter_nav_index = 0

@onready var nav_agent_2d: NavigationAgent2D = %NavigationAgent2D
@onready var ghost_sprite = $NormalGhost
@onready var ghost_scared_sprite = $ScaredGhost
@onready var ghost_eyes_sprite = $GhostEyes

enum {
	PEN,
	CHASE,
	SCATTER,
	SCARED,
	EATEN
}

func set_pac_position(pac_position: Vector2):
	nav_agent_2d.target_position = pac_position

func _physics_process(_delta):
	if nav_agent_2d.is_navigation_finished() && (state == SCATTER || state == SCARED):
		nav_agent_2d.target_position = scatter_nav_array[scatter_nav_index]
		var current_agent_position = global_position
		var next_path_position = nav_agent_2d.get_next_path_position()
		velocity = (next_path_position - current_agent_position).normalized() * SPEED
		if scatter_nav_index >= scatter_nav_array.size() - 1:
			scatter_nav_index = 0
		else:
			scatter_nav_index += 1
		
	if not nav_agent_2d.is_navigation_finished():
		var current_agent_position = global_position
		var next_path_position = nav_agent_2d.get_next_path_position()

		if state == EATEN:
			velocity = (next_path_position - current_agent_position).normalized() * (SPEED*1.5)
		if state == SCARED:
			velocity = (next_path_position - current_agent_position).normalized() * (SPEED/2)
		else:
			velocity = (next_path_position - current_agent_position).normalized() * SPEED
		
		move_and_slide()

func set_chase():
	ghost_scared_sprite.visible = false
	ghost_sprite.visible = true
	ghost_eyes_sprite.visible = false 
	state = CHASE

func set_scared():
	ghost_scared_sprite.visible = true
	ghost_sprite.visible = false
	ghost_eyes_sprite.visible = false 
	state = SCARED

func set_scatter():
	ghost_scared_sprite.visible = false
	ghost_sprite.visible = true
	ghost_eyes_sprite.visible = false 
	state = SCATTER

func set_eaten():
	ghost_scared_sprite.visible = false
	ghost_sprite.visible = false
	ghost_eyes_sprite.visible = true 
	state = EATEN

func set_pen():
	ghost_scared_sprite.visible = false
	ghost_sprite.visible = true
	ghost_eyes_sprite.visible = false 
	state = PEN

func reset(level_ghost_starting_pos):
	velocity = Vector2.ZERO
	global_position = level_ghost_starting_pos
	ghost_scared_sprite.visible = false
	ghost_sprite.visible = true
	ghost_eyes_sprite.visible = false 
	state = PEN


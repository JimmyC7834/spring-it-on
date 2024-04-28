extends CharacterBody2D

const TEX_SPRING_EYE_LEFT = preload("res://asset/spring/spring_eye_left.png")
const TEX_SPRING_EYE_RIGHT = preload("res://asset/spring/spring_eye_right.png")
const TEX_SPRING_EYE_UP = preload("res://asset/spring/spring_eye_up.png")

const TEX_EYES = [TEX_SPRING_EYE_LEFT, TEX_SPRING_EYE_UP, TEX_SPRING_EYE_RIGHT]

@onready var visual = $Visual
@onready var sprite = $Visual/Sprite2D
@onready var sprite_eye = $Visual/Eye

@export var terminal_v_velocity: float = 750.0
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var damping: float = 0.15
@export var bounce_threshold: float = 65.0
@export var max_jump_force: float = 600.0
@export var h_jump_force: float = 150.0
@export var jump_force_acc: float = 600.0
@export var speed: float = 150.0
var dir: int = 0
var jump_force: float = 0.0
var state: Callable = state_falling

signal on_bounced
signal on_landed

func _process(delta):
    sprite_eye.texture = TEX_EYES[dir + 1]    

func _physics_process(delta):
    apply_gravity(delta)
    state.call(delta)
    move_and_slide()

func state_floor(delta):
    if not is_on_floor():
        state = state_falling
        return
    
    if Input.is_action_just_pressed("DOWN"):
        velocity.x = 0    
        state = state_jump
        return
    
    if Input.is_action_just_pressed("UP"):
        dir = 0

    var axis = Input.get_axis("LEFT", "RIGHT")
    if axis != 0:
        dir = axis
    velocity.x = speed * axis

func state_jump(delta):
    visual.scale.y = 1 - (.5 * (jump_force / max_jump_force)) 
    jump_force += jump_force_acc * delta
    jump_force = min(max_jump_force, jump_force)
    if Input.is_action_just_released("DOWN"):
        jump()
        visual.scale.y = 1 
        state = state_falling

func state_falling(delta):
    if Input.is_action_pressed("UP"):
        state = state_bouncing
        return

    align_sprite()
    var collision = move_and_collide(velocity * delta)
    
    if collision:
        velocity = velocity.slide(collision.get_normal())

    if is_on_floor():
        visual.rotation = 0
        on_landed.emit()    
        
        state = state_floor

func state_bouncing(delta):
    if Input.is_action_just_released("UP"):
        state = state_falling
        return
    
    align_sprite()
    var collision = move_and_collide(velocity * delta)       
    
    if collision:
        if abs(velocity.y) < bounce_threshold:
            visual.rotation = 0
            state = state_floor
            
        bounce(collision)
        on_bounced.emit()  

func align_sprite():
    var a = Vector2(abs(velocity.x), velocity.y).angle() * 0.5
    visual.rotation = a if abs(velocity.angle_to(Vector2.UP)) > 0.1 and abs(velocity.angle_to(Vector2.DOWN)) > 0.1 else 0

func apply_gravity(delta: float):
    velocity.y += gravity * delta
    velocity.y = min(terminal_v_velocity, velocity.y)

func jump():
    velocity = Vector2(dir * h_jump_force, -jump_force)
    jump_force = 0

func bounce(collision: KinematicCollision2D):
    if not collision: return
    velocity = velocity.bounce(collision.get_normal()) * (1 - damping)
    print("bounced: ", velocity, damping)
    if velocity.length() < bounce_threshold:
        velocity.y = 0

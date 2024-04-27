extends CharacterBody2D

@onready var sprite = $Sprite2D

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
var bouncing: bool = false
var state: Callable = state_falling

signal on_bounced
signal on_landed

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
    sprite.scale.y = 0.5 - (0.25 * (jump_force / max_jump_force))
    jump_force += jump_force_acc * delta
    jump_force = min(max_jump_force, jump_force)
    if Input.is_action_just_released("DOWN"):
        jump()
        sprite.scale.y = .5
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
        sprite.rotation = 0
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
            sprite.rotation = 0
            state = state_floor
            
        bounce(collision)
        on_bounced.emit()

func align_sprite():
    sprite.rotation = Vector2(abs(velocity.x), velocity.y).angle()    

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

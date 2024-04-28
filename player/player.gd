extends CharacterBody2D

const SFX_COLLISION_1 = preload("res://asset/audio/dialog_voice (1).ogg")
const SFX_COLLISION_2 = preload("res://asset/audio/dialog_voice (2).ogg")
const SFX_COLLISION_3 = preload("res://asset/audio/dialog_voice (3).ogg")
const SFX_COLLISION_4 = preload("res://asset/audio/dialog_voice (4).ogg")

const SFX_COLLISIONS = [SFX_COLLISION_1, SFX_COLLISION_2, SFX_COLLISION_3, SFX_COLLISION_4]

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
@export var bounce_threshold: float = 50.0
@export var max_jump_force: float = 600.0
@export var h_jump_force: float = 150.0
@export var jump_force_acc: float = 600.0
@export var speed: float = 150.0
var dir: int = 0
var jump_force: float = 0.0
var state: Callable = state_falling
var previous_collision

# juice
@export var sprite_deform_scale: Vector2 = Vector2.ONE
var hitstop_frames: int = 0
var histop_floor: int = 5

signal on_bounced
signal on_landed

func _process(delta):
    sprite_eye.texture = TEX_EYES[dir + 1]    

func _physics_process(delta):
    if hitstop_frames > 0:
        hitstop_frames -= 1
        if hitstop_frames <= 0:
            stop_hitstop()
            return
    
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
        Audio.play_sfx(SFX_COLLISIONS.pick_random())
        visual.scale.y = 1 
        state = state_falling

func state_falling(delta):
    if Input.is_action_pressed("UP"):
        state = state_bouncing
        return

    align_sprite()
    scale_sprite()
    var collision = move_and_collide(velocity * delta)
    
    if collision:
        velocity = velocity.slide(collision.get_normal())
        if previous_collision != collision.get_collider_id():
            previous_collision = collision.get_collider_id()
            Audio.play_sfx(SFX_COLLISIONS.pick_random())
    else:
        previous_collision = null

    if is_on_floor():
        visual.rotation = 0
        sprite.scale = Vector2.ONE
        #Audio.play_sfx(SFX_COLLISIONS.pick_random())
        start_hitstop(histop_floor)
        on_landed.emit()
        
        state = state_floor

func state_bouncing(delta):
    if Input.is_action_just_released("UP"):
        state = state_falling
        return
    
    align_sprite()
    scale_sprite()
    var collision = move_and_collide(velocity * delta)       
    
    if collision:
        if velocity.length() < bounce_threshold:
            visual.rotation = 0
            sprite.scale = Vector2.ONE
            state = state_floor
            
        bounce(collision)
        on_bounced.emit()  

func align_sprite():
    var a = Vector2(abs(velocity.x), velocity.y).angle() * 0.5
    visual.rotation = a if abs(velocity.angle_to(Vector2.UP)) > 0.1 and abs(velocity.angle_to(Vector2.DOWN)) > 0.1 else 0

func scale_sprite():
    sprite.scale = lerp(Vector2.ONE, Vector2.ONE * sprite_deform_scale, velocity.length() / terminal_v_velocity)

func apply_gravity(delta: float):
    velocity.y += gravity * delta
    velocity.y = min(terminal_v_velocity, velocity.y)

func jump():
    velocity = Vector2(dir * h_jump_force, -jump_force)
    jump_force = 0

func bounce(collision: KinematicCollision2D):
    if not collision: return
    Audio.play_sfx(SFX_COLLISIONS.pick_random())
    start_hitstop(histop_floor)
    velocity = velocity.bounce(collision.get_normal()) * (1 - damping)
    print("bounced: ", velocity, damping)
    if velocity.length() < bounce_threshold:
        velocity.y = 0      

func start_hitstop(frames: int) -> void:
    hitstop_frames = frames

func stop_hitstop() -> void:
    hitstop_frames = 0

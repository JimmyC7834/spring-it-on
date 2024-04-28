extends Node

const WORLD = "res://levels/world.tscn"
@onready var player = $"../Player"
var save_pt: Vector2

func _ready():
    save_pt = player.global_position

func _input(event):
    if Input.is_action_just_pressed("DEBUG_REFRESH"):
        player.global_position = save_pt
    elif Input.is_action_just_pressed("DEBUG_SET"):
        save_pt = player.global_position

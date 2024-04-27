extends Node

const WORLD = "res://levels/world.tscn"

func _input(event):
    if Input.is_action_just_pressed("DEBUG_REFRESH"):
        get_tree().reload_current_scene()

extends Node2D

@onready var progress_label = $CanvasLayer/Progress
@onready var time_label = $CanvasLayer/Time

@export var player: CharacterBody2D
@export var start: Node2D
@export var goal: Node2D

var time: float = 0.0

func _process(delta):
    time += delta
    var p = min(99, 100 * abs(player.global_position.y / (goal.global_position.y - start.global_position.y)))
    progress_label.text = "Progress: %d%%" % p
    time_label.text = time_convert(time)

func time_convert(time_in_sec):
    time_in_sec = int(time_in_sec)
    var seconds = time_in_sec % 60
    var minutes = (time_in_sec / 60) % 60
    var hours = (time_in_sec / 60) / 60

    #returns a string with the format "HH:MM:SS"
    return "%02d:%02d:%02d" % [hours, minutes, seconds]

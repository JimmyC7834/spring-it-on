extends Camera2D

@onready var cam_points: Node = $"../cam_points"

@export var player: CharacterBody2D

func _process(delta):
    global_position = cam_points.get_children().reduce(
        func(n: Node2D, pt: Node2D):
            return pt if node_dist(pt, player) < node_dist(n, player) else n).global_position

func node_dist(n1: Node2D, n2: Node2D):
    return n1.global_position.distance_to(n2.global_position)

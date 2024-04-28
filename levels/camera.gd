extends Camera2D

@onready var cam_points: Node = $"../cam_points"
@onready var canvas_modulate = $CanvasModulate
@onready var clouds = $clouds
@onready var background = $background

@export var player: CharacterBody2D
@export var modulate_gradient: Gradient
var cloud_offset: Vector2 = Vector2.ZERO

func _process(delta):
    var pt = cam_points.get_children().reduce(
        func(n: Node2D, pt: Node2D):
            return pt if node_dist(pt, player) < node_dist(n, player) else n)
    global_position = pt.global_position

    cloud_offset = (global_position - player.global_position) / 50
    background.global_position = global_position + cloud_offset / 2
    clouds.global_position = global_position + cloud_offset
    clouds.flip_h = pt.get_index() % 2 == 0
    
    var total = cam_points.get_children().back().global_position.y - cam_points.get_children()[0].global_position.y
    canvas_modulate.color = modulate_gradient.sample(global_position.y / total)

func node_dist(n1: Node2D, n2: Node2D):
    return n1.global_position.distance_to(n2.global_position)

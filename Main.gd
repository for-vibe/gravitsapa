extends Node3D

@onready var orbit_sphere: Node3D = $OrbitSphere
@export var radius: float = 2.0
var angle := 0.0

func _ready():
    var camera := $Camera3D
    camera.transform.origin = Vector3(0, 2, 6)
    camera.look_at(Vector3.ZERO, Vector3.UP)

func _process(delta):
    angle += delta
    var x = radius * cos(angle)
    var z = radius * sin(angle)
    orbit_sphere.position = Vector3(x, 0, z)

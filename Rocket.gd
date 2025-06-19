extends RigidBody3D

# Simple rocket controlled by player with gravitational influences from two bodies.

const G = 1.0

@export var start_body: Node3D
@export var target_body: Node3D
@export var mass_start: float = 1.0
@export var mass_target: float = 10.0
@export var target_radius: float = 1.0

@export var thrust_force: float = 20.0
@export var rocket_mass: float = 1.0
@export var fuel_max: float = 5.0
@export var start_offset: Vector3 = Vector3(0, 0, 1.2)

var fuel: float

func _ready():
    fuel = fuel_max
    self.mass = rocket_mass
    if start_body:
        global_transform.origin = start_body.global_transform.origin + start_offset
    if target_body:
        look_at(target_body.global_transform.origin, Vector3.UP)

func _physics_process(delta):
    var acc = Vector3.ZERO
    var pos = global_transform.origin

    if start_body:
        var dir = start_body.global_transform.origin - pos
        var dist2 = dir.length_squared()
        if dist2 > 0.0:
            acc += G * mass_start / dist2 * dir.normalized()

    if target_body:
        var dir2 = target_body.global_transform.origin - pos
        var dist22 = dir2.length_squared()
        if dist22 > 0.0:
            acc += G * mass_target / dist22 * dir2.normalized()

    if Input.is_action_pressed("ui_accept") and fuel > 0.0:
        acc += -global_transform.basis.z * (thrust_force / rocket_mass)
        fuel = max(0.0, fuel - delta)

    linear_velocity += acc * delta

    var rot_input := 0.0
    if Input.is_action_pressed("ui_left"):
        rot_input += 1.0
    if Input.is_action_pressed("ui_right"):
        rot_input -= 1.0
    if rot_input != 0.0:
        angular_velocity.y = rot_input * 1.5
    else:
        angular_velocity.y = 0.0

    if target_body and (target_body.global_transform.origin - pos).length() <= target_radius:
        print("Victory: reached target")
        set_physics_process(false)

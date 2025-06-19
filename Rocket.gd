extends RigidBody3D

# Rocket controlled by player and influenced by gravity of two bodies.

const G = 1.0

@export var start_body: Node3D
@export var target_body: Node3D
@export var mass_start: float = 1.0
@export var mass_target: float = 10.0
@export var target_radius: float = 1.0

@export var thrust_force: float = 20.0
@export var thrust_consumption: float = 1.0
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

func compute_gravity(p: Vector3, center: Vector3, mass_val: float) -> Vector3:
    var dir = center - p
    var dist_sq = dir.length_squared()
    if dist_sq == 0.0:
        return Vector3.ZERO
    return G * mass_val / dist_sq * dir.normalized()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    var acc = Vector3.ZERO
    var pos = global_transform.origin

    if start_body:
        acc += compute_gravity(pos, start_body.global_transform.origin, mass_start)
    if target_body:
        acc += compute_gravity(pos, target_body.global_transform.origin, mass_target)

    add_central_force(acc * mass)

    if Input.is_action_pressed("ui_accept") and fuel > 0.0:
        add_central_force(-global_transform.basis.z * thrust_force)
        fuel = max(0.0, fuel - thrust_consumption * state.step)

func _physics_process(delta: float) -> void:
    var rot_input := 0.0
    if Input.is_action_pressed("ui_left"):
        rot_input += 1.0
    if Input.is_action_pressed("ui_right"):
        rot_input -= 1.0
    if rot_input != 0.0:
        angular_velocity.y = rot_input * 1.5
    else:
        angular_velocity.y = 0.0

    if target_body and (target_body.global_transform.origin - global_transform.origin).length() <= target_radius:
        print("Victory: reached target")
        set_physics_process(false)

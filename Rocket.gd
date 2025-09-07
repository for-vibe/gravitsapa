extends RigidBody3D

# Rocket controlled by player and influenced by gravity of two bodies.

const G = 0.1  # Reduced for game units

@export var start_body: Node3D
@export var target_body: Node3D
@export var mass_start: float = 1.0
@export var mass_target: float = 5.0
@export var target_radius: float = 1.0

@export var thrust_force: float = 20.0
@export var thrust_consumption: float = 1.0
@export var rocket_mass: float = 1.0
@export var fuel_max: float = 5.0
@export var start_offset: Vector3 = Vector3(0, 0, 1.5)

@onready var speed_label: Label = get_node("../CanvasLayer/SpeedLabel")

var fuel: float

func _ready():
	fuel = fuel_max
	self.mass = rocket_mass
	
	# Check if speed_label exists with fallback
	if not speed_label:
		print("SpeedLabel not found at '../CanvasLayer/SpeedLabel', trying alternative paths...")
		speed_label = get_node("/root/World/CanvasLayer/SpeedLabel")
		if not speed_label:
			speed_label = get_node("../../../CanvasLayer/SpeedLabel")
			if not speed_label:
				push_error("SpeedLabel not found! Speed display will not work.")
				speed_label = null
			else:
				print("SpeedLabel found at alternative path")
		else:
			print("SpeedLabel found at /root/World/CanvasLayer/SpeedLabel")
	else:
		print("SpeedLabel found successfully at '../CanvasLayer/SpeedLabel'")
	
	print("Start body: ", start_body)
	print("Target body: ", target_body)
	
	if start_body and is_instance_valid(start_body):
		var start_pos = start_body.global_transform.origin + start_offset
		global_transform.origin = start_pos
		print("Rocket positioned at: ", global_transform.origin, " (planet at: ", start_body.global_transform.origin, ")")
	else:
		print("ERROR: start_body not valid - rocket stays at origin")
		print("Available nodes from rocket:")
		for child in get_parent().get_children():
			print("  - ", child.name)
		
	if target_body and is_instance_valid(target_body):
		look_at(target_body.global_transform.origin, Vector3.UP)
		print("Target body found: ", target_body.name, " at ", target_body.global_transform.origin)
	else:
		print("ERROR: target_body not valid")
	
	# Add initial orbital velocity
	if target_body and is_instance_valid(target_body):
		var direction_to_planet = (target_body.global_transform.origin - global_transform.origin).normalized()
		var distance_to_planet = (target_body.global_transform.origin - global_transform.origin).length()
		
		print("Distance to planet: ", distance_to_planet)
		
		# Calculate first cosmic velocity: v = sqrt(G * M / R)
		var orbital_speed = sqrt(G * mass_target / distance_to_planet)
		
		# Reduce initial speed to prevent flying away
		orbital_speed *= 0.8  # 80% of perfect orbital speed
		
		var orbital_velocity = direction_to_planet.cross(Vector3.UP).normalized() * orbital_speed
		linear_velocity = orbital_velocity
		print("Initial orbital velocity set: ", orbital_speed, " m/s (", orbital_speed * 1.25, " m/s for perfect orbit)")
	else:
		print("ERROR: Cannot set orbital velocity - target_body not valid")

func compute_gravity(p: Vector3, center: Vector3, mass_val: float) -> Vector3:
	var dir = center - p
	var dist_sq = dir.length_squared()
	if dist_sq == 0.0:
		return Vector3.ZERO
	
	var distance = sqrt(dist_sq)
	var force = G * mass_val / dist_sq  # F = G * M / r^2
	var acceleration = force / rocket_mass  # a = F / m
	
	return acceleration * dir.normalized()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var acc = Vector3.ZERO
	var pos = global_transform.origin

	# Only apply gravity from target_body (the planet we're orbiting)
	if target_body and is_instance_valid(target_body):
		acc += compute_gravity(pos, target_body.global_transform.origin, mass_target)
		# Debug: print gravity force occasionally
		if randf() < 0.002:  # Print ~0.2% of the time to avoid spam
			print("Gravity acceleration: ", acc.length(), " at distance: ", (target_body.global_transform.origin - pos).length())

	apply_central_force(acc * mass)

	if Input.is_action_pressed("ui_accept") and fuel > 0.0:
		var thrust_direction = -global_transform.basis.z
		apply_central_force(thrust_direction * thrust_force)
		fuel = max(0.0, fuel - thrust_consumption * state.step)
		print("Thrust applied, fuel remaining: ", fuel)

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

	# Update speed display - simplified
	if speed_label:
		var speed = linear_velocity.length()
		speed_label.text = "Speed: %.2f m/s" % speed
		
		# Debug info
		if target_body and is_instance_valid(target_body):
			var distance_to_planet = (target_body.global_transform.origin - global_transform.origin).length()
			var target_orbital_speed = sqrt(G * mass_target / distance_to_planet)
			speed_label.text += "\nTarget: %.2f m/s" % target_orbital_speed
			speed_label.text += "\nDistance: %.2f" % distance_to_planet
		else:
			speed_label.text += "\nTarget: INVALID"
			# Try to find target_body again
			var found_target = get_node("../OrbitSphere")
			if found_target:
				target_body = found_target
				print("Target body found dynamically: ", target_body.name)
			else:
				print("ERROR: Cannot find target body at ../OrbitSphere")

	if target_body and is_instance_valid(target_body) and (target_body.global_transform.origin - global_transform.origin).length() <= target_radius:
		print("Victory: reached target")
		set_physics_process(false)

extends Camera3D

@onready var rocket = get_parent()
@onready var planet = get_node("../../OrbitSphere")

func _ready():
	print("Camera script initialized")
	# Add safety checks
	if not rocket:
		push_error("Camera: Rocket not found!")
		return
	if not planet:
		print("Camera: Planet not found at '../../OrbitSphere', trying alternative paths...")
		planet = get_node("/root/World/OrbitSphere")
		if not planet:
			planet = get_node("../OrbitSphere")
			if not planet:
				push_error("Camera: Planet not found! Camera will not work properly.")
				return
		else:
			print("Camera: Planet found at /root/World/OrbitSphere")
	else:
		print("Camera: Planet found successfully at '../../OrbitSphere'")

func _process(delta):
	if not rocket or not planet:
		return
		
	if planet and is_instance_valid(planet) and rocket and is_instance_valid(rocket):
		# Look at the center of the planet
		look_at(planet.global_transform.origin, Vector3.UP)
		
		# Optional: Adjust camera distance based on rocket speed
		var speed = rocket.linear_velocity.length()
		var base_distance = 5.0
		var speed_factor = clamp(speed / 10.0, 0.5, 2.0)  # Adjust based on speed
		var target_distance = base_distance * speed_factor
		
		# Smooth camera positioning
		var target_position = Vector3(0, 2, target_distance)
		global_transform.origin = global_transform.origin.lerp(rocket.global_transform.origin + target_position, delta * 2.0)

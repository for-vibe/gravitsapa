extends Node3D

# Main script - simplified to avoid conflicts with rocket physics

func _ready():
	print("Main scene initialized")
	# Camera is now handled by Camera.gd script attached to the camera itself
	# OrbitSphere position is now static for gravity calculations

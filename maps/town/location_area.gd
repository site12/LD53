extends Area3D

enum Location {
	CHURCH,
	HOTEL,
	TRAIN_STATION,
	SALOON,
	WATER_TOWER,
	BANK,
	STORE,
	BLANK
}

@export var this_location = Location.BLANK

func _ready():
	print("I exist")

func _on_body_entered(body):
	print(body.name)
	if body.is_in_group("player"):
		body.current_location = this_location

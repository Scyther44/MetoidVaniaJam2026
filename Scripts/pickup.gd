extends Area3D

enum PickupType {
	LORE,
	HEALTH,
	DOWNBLAST,
	SIDEBLAST
}

@export var pickup_type : PickupType
@export_multiline var pickup_text : String
@export var pickup_title : String
@export var pickup_icon : Texture2D

const PICKUP_POPUP = preload(
	"res://Scenes/pickuppopup.tscn"
)

var collected := false

func _on_body_entered(body: Node3D) -> void:

	if collected:
		return

	if !body.is_in_group("player"):
		return

	collected = true

	# Apply upgrade
	match pickup_type:

		PickupType.DOWNBLAST:
			body.unlock_down_blast()

		PickupType.HEALTH:
			body.max_health += 1
			body.health += 1

		PickupType.SIDEBLAST:
			body.unlock_side_blast()

		PickupType.LORE:
			pass

	# Show popup
	var popup = PICKUP_POPUP.instantiate()

	get_tree().current_scene.add_child(popup)

	popup.show_pickup(
		pickup_title,
		pickup_text,
		pickup_icon
	)

	hide()

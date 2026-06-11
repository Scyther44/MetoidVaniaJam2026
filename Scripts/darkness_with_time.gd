extends WorldEnvironment

@export var duration := 1200.0 # 20 minutes

@export var max_fog_light_energy := 0.25
@export var max_fog_density := 0.5
@export var max_sky_affect := 0.5

var elapsed := 0.0

func _process(delta):

	elapsed += delta

	var t = clamp(
		elapsed / duration,
		0.0,
		1.0
	)

	environment.fog_light_energy = lerp(
		0.0,
		max_fog_light_energy,
		t
	)

	environment.fog_density = lerp(
		0.0,
		max_fog_density,
		t
	)

	environment.fog_sky_affect = lerp(
		0.0,
		max_sky_affect,
		t
	)

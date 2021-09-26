extends Control

var vis = 0.0

func display(text):
	$Description.text = text

func displayRing(progress):
	$ProgressRing.value = progress * 100

func _process(delta):
	vis = clamp((MasterScript.player.visibilityLevel * 5.263157895), 0, 1)
	vis = clamp(vis, 0.2, 1.0)
	if vis < 1.0:
		$LightGem.modulate = Color(vis,vis,vis,0.8)
	else:
		$LightGem.modulate = Color(1,0.66,0.66,0.8)

func updateHealth(newHealth):
	$HealthLabel/HealthNumber.text = str(newHealth)
	print(newHealth)

func updateAmmo(ammo):
	$AmmoLabel/AmmoNumber.text = str(ammo)

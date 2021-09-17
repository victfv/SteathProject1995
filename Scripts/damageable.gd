extends CSGBox

# This script is put on objects you want to be damagable. -1 equals tranqulizer
func damage(damageAmount):
	if damageAmount == -1: #Tranqulizer
		yield(get_tree().create_timer(2), "timeout")
		print("Asleep TODO")
	else:
		print("Damage TODO")

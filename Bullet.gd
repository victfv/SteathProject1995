extends KinematicBody

# set by emitter
var speed = 0
var damage = 0

const LIFESPAN = 10.0
var time_alive = 0.0

func _physics_process(delta):
	var collision = move_and_collide(global_transform.basis.z * speed * delta)
	if collision:
		if collision.collider.has_method("damage"):
			collision.collider.damage(damage)
		elif collision.collider.has_method("tranqulize"):
			collision.collider.tranqulize()
		queue_free()
	
	time_alive += delta
	if time_alive > LIFESPAN:
		queue_free()

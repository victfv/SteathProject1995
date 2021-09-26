tool

extends Spatial

export var upd = false setget updAll
export var size = Vector2(3,3) setget updSize
export (Mesh) var mesh
export (Material) var material setget updMat

func updSize(a):
	size = a

func updAll(a):
	upd = a
	if a:
		set_process(true)

func updFloor():
	for i in get_children():
		i.queue_free()
	var r = get_tree().edited_scene_root
	
	var nsize = size/3
	nsize.x = ceil(nsize.x)
	nsize.y = ceil(nsize.y)
	
	var xrest = (size.x/3) - floor(size.x/3)
	var yrest = (size.y/3) - floor(size.y/3)
	
	var sttc = StaticBody.new()
	sttc.transform.origin = Vector3(size.x/2,-0.1,size.y/2)
	var shp = CollisionShape.new()
	var bx = BoxShape.new()
	bx.extents = Vector3(size.x/2,0.1,size.y/2)
	shp.shape = bx
	
	add_child(sttc)
	sttc.add_child(shp)
	
	sttc.owner = r
	shp.owner = r
	
	for i in range(nsize.x):
		for j in range(nsize.y):
			var n = MeshInstance.new()
			n.use_in_baked_light = true
			n.mesh = mesh
			n.material_override = material
			add_child(n)
			n.owner = r
			n.transform.origin = Vector3(i*3, 0, j*3)
			
			if i == nsize.x - 1 and xrest > 0:
				n.scale.x = xrest
			if j == nsize.y - 1 and yrest > 0:
				n.scale.z = yrest

func _process(delta):
	if upd:
		upd = false
		updFloor()
	set_process(false)

func updMesh(a):
	mesh = a

func updMat(a):
	material = a
	for i in get_children():
		i.material_override = material

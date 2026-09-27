class_name Util
# copied from another one of my projects

static func posheight(pos: Vector2 = Vector2.ZERO, height: float = 0) -> Vector3:
	return Vector3(pos.x, height, pos.y)

static func coord(point: Vector3) -> Vector2:
	return Vector2(point.x, point.z)

static func randv3(anysign: bool, scale: float = 1) -> Vector3:
	if anysign:
		return randv3(false, scale) * 2 - Vector3.ONE * scale
	return Vector3(randf(), randf(), randf()) * scale

static func randv2(anysign: bool, scale: float = 1) -> Vector2:
	if anysign:
		return randv2(false, scale) * 2 - Vector2.ONE * scale
	return Vector2(randf(), randf()) * scale

static func randdisp(scale: float = 1) -> Vector2:
	return Vector2(randf_range(-1, 1), randf_range(-1, 1)) * scale

static func coinflip() -> bool:
	return randf() < 0.5

static func antienum(en: Dictionary) -> Dictionary[int, String]:
	var newdict: Dictionary[int, String] = {}
	for key: String in en:
		newdict[en[key]] = key
	return newdict

static func rangebedamned(minval: float, maxval: float, step: float) -> Array[float]:
	var output: Array[float] = []
	var iter := minval
	while iter <= maxval:
		output.append(iter)
		iter += step
	return output

static func vecfloor(vector: Vector3) -> Vector3:
	var vecsign := vector.sign()
	return (vector * vecsign).floor() * vecsign

extends Node
class_name Main

func newworld() -> void:
	Global.world = load("res://world.tscn").instantiate()
	add_child(Global.world)
	Global.world.create()

func stopworld() -> void:
	remove_child(Global.world)
	Global.world = null

func _ready() -> void:
	newworld()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("restart"):
		stopworld()
		newworld()
	if event.is_action_pressed("musictoggle"):
		$MusicPlayer.playing = not $MusicPlayer.playing
	if event.is_action_pressed("sfxtoggle"):
		Global.sfxon = not Global.sfxon
	if event.is_action_pressed("pause"):
		if Global.world.process_mode == Node.PROCESS_MODE_DISABLED:
			Global.world.process_mode = Node.PROCESS_MODE_PAUSABLE
		else:
			Global.world.process_mode = Node.PROCESS_MODE_DISABLED

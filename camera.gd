class_name Camera
extends Camera2D

const FADE_DURATION: float = 1.0
const SMOOTH_TRANSITION_DURATION: float = 0.5

@export var smooth_transition_curve: Curve

var is_stair_transition: bool

var _current_room: Room
var _smooth_transition_tween: Tween
var _smooth_transition_camera_start: Vector2
var _smooth_transition_camera_target: Vector2

@onready var color_rect: ColorRect = $CanvasLayer2/ColorRect

# public methods
func transition_to_room(target_room: Room):
	#if _current_room == null: # this only happens when the level is loaded, so the camera will not fade in
		#color_rect.color.a = 0.0
		#position = target_room.position
		##reset_smoothing()
	#else:
		#if is_stair_transition:
			#_fade_out()
		#else:
			#position = target_room.position
	_smooth_transition_camera_start = position
	_smooth_transition_camera_target = target_room.position
			
	if _smooth_transition_tween:
		_smooth_transition_tween.kill()
	_smooth_transition_tween = get_tree().create_tween()
	_smooth_transition_tween.tween_method(_smooth_transition, 0.0, 1.0, SMOOTH_TRANSITION_DURATION)
	_current_room = target_room

# private methods
func _smooth_transition(value: float) -> void:
	var sampled_value = smooth_transition_curve.sample(value)
	position = lerp(_smooth_transition_camera_start, _smooth_transition_camera_target, sampled_value)

#func _fade_out():
	#var tween = get_tree().create_tween()
	#tween.tween_property(color_rect, "color:a", 1.0, FADE_DURATION)
	#tween.tween_callback(_finished_fade_out)
#
#func _finished_fade_out():
	#position = _current_room.position
	#is_stair_transition = false
	##reset_smoothing()
	#_fade_in()
#
#func _fade_in():
	#var tween = get_tree().create_tween()
	#tween.tween_property(color_rect, "color:a", 0.0, FADE_DURATION)
	#tween.tween_callback(_finished_fade_in)
#
#func _finished_fade_in():
	#pass

class_name NotePlayer extends AudioStreamPlayer

var notes : Array[float] = []
var index : int = 0
var tempo : float = 0
var rnd : RandomNumberGenerator = RandomNumberGenerator.new()

@export var duration : float = 4
@export var note_name : String
@export var note_per_second : float = 2
@export var alternate_note : AudioStream = null
var primary_note : AudioStream = null

enum NoteSelectState
{
	PLAYING_MAJOR,
	PENDING_MINOR,
	PLAYING_MINOR,
	PENDING_MAJOR,
}
var note_select_state : NoteSelectState = NoteSelectState.PLAYING_MAJOR

var notes_in_span : int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rnd.seed = int(Time.get_unix_time_from_system() + note_name.hash())
	primary_note = stream
	notes_in_span = round(note_per_second * duration)
	var timings : Array
	for i : int in range(0, 3 * duration):
		timings.append([i / 3.0, rnd.randf()])
	timings.sort_custom(func(a,b): return a[1] < b[1])
	for i : int in range(0, notes_in_span):
		notes.append(timings[i][0])
	notes.sort()
	index = 0
	
func set_to_major() -> void:
	if alternate_note == null:
		return
	if note_select_state == NoteSelectState.PLAYING_MINOR:
		note_select_state = NoteSelectState.PENDING_MAJOR
	elif note_select_state == NoteSelectState.PENDING_MINOR:
		note_select_state = NoteSelectState.PLAYING_MAJOR

func set_to_minor() -> void:
	if alternate_note == null:
		return
	if note_select_state == NoteSelectState.PLAYING_MAJOR:
		note_select_state = NoteSelectState.PENDING_MINOR
	elif note_select_state == NoteSelectState.PENDING_MAJOR:
		note_select_state = NoteSelectState.PLAYING_MINOR

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tempo += delta
	if tempo > notes[index]:
		if note_select_state == NoteSelectState.PENDING_MINOR:
			note_select_state = NoteSelectState.PLAYING_MINOR
			print("Switching to MINOR")
			stream = alternate_note
		elif note_select_state == NoteSelectState.PENDING_MAJOR:
			print("Switching to MAJOR")
			note_select_state = NoteSelectState.PLAYING_MAJOR
			stream = primary_note
		play()
		index = (index + 1) % notes_in_span
		if index == 0:
			tempo -= duration

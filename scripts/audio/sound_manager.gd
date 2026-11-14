extends Node

## SoundManager
## Generates clean procedural 16-bit sound effects at runtime.
## This ensures CLICK has responsive audio feedback without relying
## on any missing external audio files or dependencies.

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
const MAX_PLAYERS: int = 8

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_audio_players()
	_generate_all_sfx()

func _create_audio_players() -> void:
	for i in range(MAX_PLAYERS):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players.append(player)

func _get_available_player() -> AudioStreamPlayer:
	for p in _players:
		if not p.playing:
			return p
	# Steal first player if all are busy
	return _players[0]

func play(sfx_name: String, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	if not GameManager.sfx_enabled:
		return
	if not _streams.has(sfx_name):
		return
	var player := _get_available_player()
	player.stream = _streams[sfx_name]
	player.pitch_scale = pitch_scale
	player.volume_db = volume_db
	player.play()

# Convenience playback helpers
func play_jump() -> void:
	play("jump", randf_range(0.96, 1.04))

func play_land() -> void:
	play("land", randf_range(0.95, 1.05))

func play_launch() -> void:
	play("launch", randf_range(0.98, 1.02))

func play_collect() -> void:
	play("collect", randf_range(0.98, 1.05))

func play_hazard() -> void:
	play("hazard", 1.0)

func play_timer_tick() -> void:
	play("tick", 1.0, -4.0)

func play_timer_warning() -> void:
	play("warning", 1.0, -2.0)

func play_victory() -> void:
	play("victory", 1.0, 1.0)

func play_click() -> void:
	play("click", randf_range(0.95, 1.05), -3.0)

# ----------------- Procedural Wave Generation -----------------

func _generate_all_sfx() -> void:
	_streams["jump"] = _build_tone_sweep(280.0, 560.0, 0.09, 0.4, false)
	_streams["land"] = _build_tone_sweep(160.0, 70.0, 0.06, 0.35, true)
	_streams["launch"] = _build_tone_sweep(240.0, 720.0, 0.16, 0.5, false)
	_streams["collect"] = _build_dual_chime(587.33, 880.0, 0.14, 0.4)
	_streams["hazard"] = _build_noise_burst(0.18, 0.5)
	_streams["tick"] = _build_click(900.0, 0.025, 0.3)
	_streams["warning"] = _build_click(1400.0, 0.04, 0.45)
	_streams["victory"] = _build_arpeggio([440.0, 554.37, 659.25, 880.0], 0.08, 0.4)
	_streams["click"] = _build_click(1200.0, 0.02, 0.25)

func _create_stream(pcm_bytes: PackedByteArray, sample_rate: int = 22050) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = pcm_bytes
	return wav

func _build_tone_sweep(start_f: float, end_f: float, duration: float, volume: float, is_low: bool) -> AudioStreamWAV:
	var rate := 22050
	var total_samples := int(duration * rate)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)
	
	var phase: float = 0.0
	for i in range(total_samples):
		var t := float(i) / float(total_samples)
		var freq := lerpf(start_f, end_f, t)
		phase += (freq * TAU) / float(rate)
		
		# Envelope: quick attack, smooth exponential decay
		var env: float = (1.0 - t) * (1.0 - t)
		if t < 0.05:
			env *= (t / 0.05)
		
		var sample_f := sin(phase)
		if is_low:
			# Add triangle/sub harmonic for low thud
			sample_f = 0.7 * sample_f + 0.3 * sin(phase * 0.5)
		
		var val := int(clampf(sample_f * env * volume, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, val)
		
	return _create_stream(bytes, rate)

func _build_dual_chime(f1: float, f2: float, duration: float, volume: float) -> AudioStreamWAV:
	var rate := 22050
	var total_samples := int(duration * rate)
	var half_samples := total_samples / 2
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)
	
	var phase1: float = 0.0
	var phase2: float = 0.0
	
	for i in range(total_samples):
		var is_second_note := i >= half_samples
		var current_freq := f2 if is_second_note else f1
		var note_t := float(i - (half_samples if is_second_note else 0)) / float(half_samples)
		
		if not is_second_note:
			phase1 += (current_freq * TAU) / float(rate)
		else:
			phase2 += (current_freq * TAU) / float(rate)
		
		var phase := phase2 if is_second_note else phase1
		var env := (1.0 - note_t) * (1.0 - note_t)
		var sample_f := sin(phase) + 0.25 * sin(phase * 2.0)
		var val := int(clampf(sample_f * env * volume * 0.7, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, val)
		
	return _create_stream(bytes, rate)

func _build_noise_burst(duration: float, volume: float) -> AudioStreamWAV:
	var rate := 22050
	var total_samples := int(duration * rate)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t := float(i) / float(total_samples)
		var env := (1.0 - t) * (1.0 - t)
		var white := randf_range(-1.0, 1.0)
		var val := int(clampf(white * env * volume, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, val)
		
	return _create_stream(bytes, rate)

func _build_click(freq: float, duration: float, volume: float) -> AudioStreamWAV:
	var rate := 22050
	var total_samples := int(duration * rate)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)
	
	var phase: float = 0.0
	for i in range(total_samples):
		var t := float(i) / float(total_samples)
		phase += (freq * TAU) / float(rate)
		var env := (1.0 - t)
		var sample_f := sin(phase)
		var val := int(clampf(sample_f * env * volume, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, val)
		
	return _create_stream(bytes, rate)

func _build_arpeggio(notes: Array, note_duration: float, volume: float) -> AudioStreamWAV:
	var rate := 22050
	var samples_per_note := int(note_duration * rate)
	var total_samples := samples_per_note * notes.size()
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)
	
	for n in range(notes.size()):
		var freq: float = notes[n]
		var phase: float = 0.0
		for i in range(samples_per_note):
			var global_idx := n * samples_per_note + i
			var t := float(i) / float(samples_per_note)
			phase += (freq * TAU) / float(rate)
			var env := (1.0 - t)
			var sample_f := sin(phase) + 0.3 * sin(phase * 2.0)
			var val := int(clampf(sample_f * env * volume * 0.7, -1.0, 1.0) * 32767.0)
			bytes.encode_s16(global_idx * 2, val)
			
	return _create_stream(bytes, rate)

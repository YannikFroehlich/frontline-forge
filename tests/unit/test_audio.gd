extends "res://tests/test_case.gd"

const AudioDirector := preload("res://src/services/audio_director.gd")


func _peak(data: PackedByteArray) -> int:
	var peak := 0
	for i in range(0, data.size(), 2):
		peak = maxi(peak, absi(data.decode_s16(i)))
	return peak


func test_length_matches_notes() -> void:
	var spec := {"notes": [[440.0, 440.0, 0.1], [880.0, 880.0, 0.05]]}
	check(is_equal_approx(Synth.duration(spec), 0.15), "Dauer")
	check_eq(Synth.samples(spec).size(), int(0.1 * Synth.RATE) * 2 + int(0.05 * Synth.RATE) * 2, "16 Bit je Abtastwert")


func test_sound_is_audible_and_fades_out() -> void:
	var data := Synth.samples({"notes": [[440.0, 220.0, 0.2]], "wave": "saw", "volume": 0.6})
	check(_peak(data) > 8000, "Hörbar: %d" % _peak(data))
	check(absi(data.decode_s16(data.size() - 2)) < 400, "Endet leise, kein Knacken")
	check(absi(data.decode_s16(0)) < 400, "Beginnt leise, kein Knacken")


func test_never_clips() -> void:
	var data := Synth.samples({"notes": [[100.0, 50.0, 0.1]], "wave": "square", "noise": 0.5, "volume": 5.0})
	check(_peak(data) <= 32767, "Begrenzt auf 16 Bit")


func test_same_spec_gives_same_sound() -> void:
	var spec := {"notes": [[300.0, 100.0, 0.05]], "noise": 0.8}
	check(Synth.samples(spec) == Synth.samples(spec), "Rauschen ist wiederholbar")


func test_every_sound_is_valid() -> void:
	for id: String in AudioDirector.SOUNDS:
		var spec: Dictionary = AudioDirector.SOUNDS[id]
		check(AudioDirector.BUSES.has(spec["bus"]), "%s: Bus %s" % [id, spec["bus"]])
		check(Synth.duration(spec) > 0.0 and Synth.duration(spec) <= 1.5, "%s: Dauer" % id)
		check(_peak(Synth.samples(spec)) > 3000, "%s ist hörbar" % id)


func test_every_chassis_has_a_shot_sound() -> void:
	for chassis: String in Parts.CHASSIS:
		check(AudioDirector.SOUNDS.has("shot_" + chassis), "Schussklang für %s" % chassis)


func test_music_files_exist_and_are_documented() -> void:
	var licenses := FileAccess.get_file_as_string("res://docs/lizenzen.md")
	for id: String in AudioDirector.MUSIC:
		var path: String = AudioDirector.MUSIC[id]
		check(FileAccess.file_exists(path), "Musik %s: Datei %s" % [id, path])
		check(licenses.contains(path.get_file()), "%s steht in docs/lizenzen.md" % path.get_file())
	check(AudioDirector.BUSES.has("Music"), "Musik-Bus")


func test_stream_format() -> void:
	var stream := Synth.make({"notes": [[440.0, 440.0, 0.05]]})
	check_eq(stream.mix_rate, Synth.RATE, "Abtastrate")
	check_eq(stream.format, AudioStreamWAV.FORMAT_16_BITS, "16 Bit")
	check(not stream.stereo, "Mono")

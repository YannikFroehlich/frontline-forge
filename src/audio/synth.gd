class_name Synth
## Builds short sound effects from a description instead of audio files (plan 11.4: own effects by synthesis).
## A sound is a list of notes played one after another. Each note sweeps from one frequency to another,
## mixes an oscillator with noise and fades out. Everything is free of licenses and adds nothing to the download.
##
## Spec keys:
##   notes     [[from_hz, to_hz, seconds], ...]   required
##   wave      "sine", "square", "saw" or "tri"   default "sine"
##   noise     0..1 share of noise                default 0
##   lowpass   0..1, smaller = duller noise       default 1 (off)
##   attack    seconds to full volume             default 0.003
##   curve     fade shape, larger = shorter tail  default 2
##   volume    0..1                               default 0.6
# ponytail: one voice per sound, no layering or reverb. Enough for the base sound set; replace single
# sounds with recorded ones if synthesis sounds too thin.

const RATE := 22050


static func make(spec: Dictionary) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = samples(spec)
	return stream


## 16-bit little-endian mono samples. The seed makes the noise repeatable.
static func samples(spec: Dictionary) -> PackedByteArray:
	var wave: String = spec.get("wave", "sine")
	var noise: float = spec.get("noise", 0.0)
	var lowpass: float = spec.get("lowpass", 1.0)
	var attack: float = maxf(spec.get("attack", 0.003), 0.0005)
	var curve: float = spec.get("curve", 2.0)
	var volume: float = spec.get("volume", 0.6)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(spec)
	var data := PackedByteArray()
	var filtered := 0.0
	for note: Array in spec["notes"]:
		var from_hz: float = note[0]
		var to_hz: float = note[1]
		var count := int(float(note[2]) * RATE)
		var start := data.size()
		data.resize(start + count * 2)
		var phase := 0.0
		for i in count:
			var t := float(i) / count
			# Exponential sweep sounds even to the ear.
			phase += from_hz * pow(to_hz / from_hz, t) / RATE
			var value := _oscillator(wave, phase)
			if noise > 0.0:
				filtered += lowpass * (rng.randf_range(-1.0, 1.0) - filtered)
				value = lerpf(value, filtered, noise)
			var envelope := minf(float(i) / (attack * RATE), 1.0) * pow(1.0 - t, curve)
			data.encode_s16(start + i * 2, int(clampf(value * envelope * volume, -1.0, 1.0) * 32767.0))
	return data


static func duration(spec: Dictionary) -> float:
	var total := 0.0
	for note: Array in spec["notes"]:
		total += float(note[2])
	return total


static func _oscillator(wave: String, phase: float) -> float:
	var p := fposmod(phase, 1.0)
	match wave:
		"square":
			return 1.0 if p < 0.5 else -1.0
		"saw":
			return p * 2.0 - 1.0
		"tri":
			return absf(p * 4.0 - 2.0) - 1.0
		_:
			return sin(p * TAU)

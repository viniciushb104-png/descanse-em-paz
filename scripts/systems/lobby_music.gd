extends AudioStreamPlayer
## Musica ambiente do mapa externo. Nao exige arquivo no primeiro boot.
## Colocar assets/audio/lobby/santa_mortalha.mp3, .ogg ou .wav.
const MP3_PATH := "res://assets/audio/lobby/santa_mortalha.mp3"
const OGG_PATH := "res://assets/audio/lobby/santa_mortalha.ogg"
const WAV_PATH := "res://assets/audio/lobby/santa_mortalha.wav"
const BASE_VOLUME_DB := -15.0
const DIALOGUE_VOLUME_DB := -24.0
const MUTED_VOLUME_DB := -60.0
const FADE_SPEED_DB := 22.0

var requested_volume_db: float = MUTED_VOLUME_DB
var audio_ready := false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    volume_db = MUTED_VOLUME_DB
    var path := ""
    if ResourceLoader.exists(MP3_PATH):
        path = MP3_PATH
    elif ResourceLoader.exists(OGG_PATH):
        path = OGG_PATH
    elif ResourceLoader.exists(WAV_PATH):
        path = WAV_PATH
    if path.is_empty():
        push_warning("Trilha do lobby ausente: coloque santa_mortalha.mp3 em assets/audio/lobby/")
        return
    var loaded: Resource = load(path)
    if not loaded is AudioStream:
        push_warning("Arquivo de trilha nao e AudioStream: " + path)
        return
    stream = loaded as AudioStream
    if stream is AudioStreamMP3:
        (stream as AudioStreamMP3).loop = true
    elif stream is AudioStreamOggVorbis:
        (stream as AudioStreamOggVorbis).loop = true
    elif stream is AudioStreamWAV:
        (stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
    audio_ready = true

func update_context(outside: bool, dialogue: bool, minigame: bool, delta: float) -> void:
    if not audio_ready:
        return
    requested_volume_db = MUTED_VOLUME_DB
    if outside and not minigame:
        requested_volume_db = DIALOGUE_VOLUME_DB if dialogue else BASE_VOLUME_DB
    if outside and not minigame and not playing:
        play()
    volume_db = move_toward(volume_db,requested_volume_db,FADE_SPEED_DB * delta)
    # Interromper somente apos o fade, evitando musica no interior ou minigame.
    if (not outside or minigame) and playing and volume_db <= MUTED_VOLUME_DB + 0.1:
        stop()

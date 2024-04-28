extends Node

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS

func play_bgm(audio: AudioStream) -> AudioStreamPlayer2D:
    var instance: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
    instance.stream = audio
    #instance.volume_db = -10
    add_child(instance)

    instance.play()
    return instance

func play_sfx(audio: AudioStream) -> AudioStreamPlayer2D:
    var instance: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
    instance.stream = audio
    instance.finished.connect(free_player.bind(instance))
    add_child(instance)

    instance.play()
    return instance    

func free_player(player: AudioStreamPlayer2D):
    player.queue_free()

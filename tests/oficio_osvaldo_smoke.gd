extends SceneTree
## Testa ordem autorizada, cinco etapas, salvar/retomar e nao repetir enterro.
const QUEUE = preload("res://scripts/systems/burial_service_queue.gd")
const GAME = preload("res://scripts/minigames/oficio_osvaldo.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String, code: int) -> void:
    push_error(message)
    quit(code)

func _run() -> void:
    var jobs = QUEUE.new()
    if jobs.ensure_initial_order(3,true,1):
        _fail("Ordem apareceu sem registro do atendimento.", 101)
        return
    if jobs.ensure_initial_order(4,false,1):
        _fail("Ordem apareceu sem reserva de jazigo.", 102)
        return
    if jobs.enqueue("indevido","Cliente","B-14",1,false,true):
        _fail("Ordem sem documentos foi aceita.", 103)
        return
    if jobs.enqueue("indevido","Cliente","B-14",1,true,false):
        _fail("Ordem sem autorizacao foi aceita.", 104)
        return
    if not jobs.ensure_initial_order(4,true,1) or not jobs.has_pending():
        _fail("B-13 registrado nao gerou ordem para Osvaldo.", 105)
        return
    if jobs.ensure_initial_order(4,true,1) or jobs.orders.size() != 1:
        _fail("B-13 recebeu ordem duplicada.", 106)
        return

    var job: Dictionary = jobs.pending()
    var activity := GAME.new() as Control
    activity.configure(job)
    root.add_child(activity)
    await process_frame
    for etapa in range(3):
        var required: int = [3,5,6][etapa]
        for idx in range(required):
            activity.activate_target(idx)
        if int(activity.phase) != etapa + 1:
            _fail("Etapa interativa nao avancou: %d." % etapa, 107)
            return
    jobs.update_progress(str(job["id"]), activity.snapshot())
    var cfg := ConfigFile.new()
    jobs.save_state(cfg)
    var reloaded = QUEUE.new()
    reloaded.load_state(cfg)
    if not reloaded.has_pending() or not reloaded.initial_issued:
        _fail("Fila de sepultamentos nao persistiu.", 108)
        return
    if int(reloaded.pending()["progress"]["phase"]) != 3:
        _fail("Retomada nao preservou o progresso.", 109)
        return
    activity.queue_free()
    var resumed := GAME.new() as Control
    resumed.configure(reloaded.pending())
    root.add_child(resumed)
    await process_frame
    if resumed.phase != 3:
        _fail("Minigame retomou etapa incorreta.", 110)
        return
    var result := {"success": false, "quality": 0}
    resumed.finished.connect(func(ok: bool, quality: int) -> void:
        result["success"] = ok
        result["quality"] = quality
    )
    resumed._press(Vector2(724,351))
    resumed._release()
    if resumed.phase != 4:
        _fail("Controle de descida nao avancou.", 111)
        return
    for idx in range(3):
        resumed.activate_target(idx)
    if not bool(result["success"]) or int(result["quality"]) < 60:
        _fail("Finalizacao do minigame nao aconteceu.", 112)
        return
    if not reloaded.complete(str(job["id"])):
        _fail("B-13 nao concluiu na fila.", 113)
        return
    if reloaded.has_pending() or not reloaded.is_done(QUEUE.INITIAL_ORDER):
        _fail("Ordem concluida continua ativa.", 114)
        return
    if reloaded.complete(str(job["id"])):
        _fail("Sepultamento foi creditado duas vezes.", 115)
        return
    print("OSVALDO OK: bloqueio legal, B-13, cinco etapas, persistencia e conclusao unica.")
    quit(0)

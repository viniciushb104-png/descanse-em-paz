extends RefCounted
## Fila separada dos 20 atendimentos: so ordens explicitamente autorizadas
## podem abrir o minigame do coveiro. Persistida no mesmo save.cfg.
const INITIAL_ORDER := "tutorial_b13"
var orders: Array[Dictionary] = []
var initial_issued: bool = false

static func new_progress() -> Dictionary:
    return {"phase": 0, "completed": [[], [], [], [], []], "lowering": 0.0, "mistakes": 0}

func enqueue(identifier: String, customer: String, plot: String, day: int, documents_ok: bool, authorized: bool) -> bool:
    if identifier.is_empty() or plot.is_empty() or not documents_ok or not authorized:
        return false
    for item in orders:
        if str(item.get("id", "")) == identifier:
            return false
    orders.append({
        "id": identifier, "customer": customer, "plot": plot,
        "scheduled_day": maxi(1, day),
        "authorized": true, "documents_ok": true, "finished": false,
        "progress": new_progress()
    })
    return true

func ensure_initial_order(stage: int, plot_reserved: bool, day: int) -> bool:
    # A missao de introducao verifica documentos, reserva B-13 e conclui
    # o registro do atendimento ao entrar na etapa 4.
    if initial_issued or stage < 4 or not plot_reserved:
        return false
    if not enqueue(INITIAL_ORDER, "Primeiro atendimento do B-13", "B-13", day, true, true):
        return false
    initial_issued = true
    return true

func pending() -> Dictionary:
    for item in orders:
        if not bool(item.get("finished", false)) and bool(item.get("authorized", false)) and bool(item.get("documents_ok", false)):
            return item.duplicate(true)
    return {}

func has_pending() -> bool:
    return not pending().is_empty()

func update_progress(identifier: String, progress: Dictionary) -> void:
    for i in range(orders.size()):
        if str(orders[i].get("id", "")) == identifier and not bool(orders[i].get("finished", false)):
            orders[i]["progress"] = progress.duplicate(true)
            return

func complete(identifier: String) -> bool:
    for i in range(orders.size()):
        if str(orders[i].get("id", "")) == identifier and not bool(orders[i].get("finished", false)):
            orders[i]["finished"] = true
            return true
    return false

func is_done(identifier: String) -> bool:
    for item in orders:
        if str(item.get("id", "")) == identifier:
            return bool(item.get("finished", false))
    return false

func save_state(cfg: ConfigFile) -> void:
    cfg.set_value("save", "burial_orders", orders.duplicate(true))
    cfg.set_value("save", "burial_initial_issued", initial_issued)

func load_state(cfg: ConfigFile) -> void:
    orders.clear()
    initial_issued = bool(cfg.get_value("save", "burial_initial_issued", false))
    var stored: Variant = cfg.get_value("save", "burial_orders", [])
    if not stored is Array:
        return
    for entry in stored:
        if not entry is Dictionary:
            continue
        if not bool(entry.get("authorized", false)) or not bool(entry.get("documents_ok", false)):
            continue
        if str(entry.get("id", "")).is_empty() or str(entry.get("plot", "")).is_empty():
            continue
        orders.append(entry.duplicate(true))
    for item in orders:
        if str(item.get("id", "")) == INITIAL_ORDER:
            initial_issued = true

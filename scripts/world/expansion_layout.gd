extends RefCounted
## Expansao a leste: coordenadas globais, sem alterar os jardins antigos.
const STATIONS = [
    {"id":"exp_memorial","name":"Memorial dos Esquecidos","p":Vector2(1840,-350),"activity":"restore"},
    {"id":"exp_crypt","name":"Cripta de Dona Eudoxia","p":Vector2(2700,-350),"activity":"crypt"},
    {"id":"exp_nursery","name":"Viveiro das Violetas","p":Vector2(2200,1630),"activity":"nursery"},
    {"id":"exp_registry","name":"Casa da Memoria","p":Vector2(2740,1850),"activity":"memorial_records"}
]
const BUILDINGS = [Rect2(1720,-600,240,205),Rect2(2580,-600,240,205),Rect2(2080,1415,240,170),Rect2(2620,1635,240,170)]
const ORDER = ["restore","crypt","nursery","memorial_records"]
static func station(id: String) -> Dictionary:
    for entry in STATIONS:
        if entry["id"]==id:
            return entry
    return {}
static func available(id: String, done: Dictionary) -> bool:
    var i := ORDER.find(id)
    return i<=0 or bool(done.get(ORDER[i-1],false))
static func plots() -> Array[Dictionary]:
    var out: Array[Dictionary] = []
    for row in range(3):
        for col in range(8):
            var x: float = 1680.0+float(col%4)*140.0+(800.0 if col>=4 else 0.0)
            out.append({"id":"L-%02d" % (row*8+col+1),"p":Vector2(x,-1120.0-float(row)*185.0)})
    return out
static func is_blocked(p: Vector2) -> bool:
    for footprint in BUILDINGS:
        if footprint.has_point(p):
            return true
    return false

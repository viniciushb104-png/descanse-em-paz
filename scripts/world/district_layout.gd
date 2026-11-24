extends RefCounted
## Distrito dos Eternos: pontos de interacao e colisoes fixos.
const WORLD_SIZE := Vector2(3072, 2304)
const BUILDINGS = [
    Rect2(1654,148,353,254),
    Rect2(1609,758,337,233),
    Rect2(2039,754,337,246),
    Rect2(1655,1151,410,215),
    Rect2(2077,454,263,95),
    Rect2(2105,1194,233,84),
    Rect2(2464,151,288,260),
    Rect2(2785,153,255,258),
    Rect2(2700,850,280,190)
]
const HEARSE_AREAS = [Rect2(2083,434,236,118), Rect2(2110,1171,212.4,106.2)]
const STATIONS = [
    {"id":"hospital","name":"Hospital Santa Ultima Hora","p":Vector2(1813,446)},
    {"id":"garagem","name":"Garagem funeraria","p":Vector2(1818,1116)},
    {"id":"preparo","name":"Sala de conservacao","p":Vector2(1794,1035)},
    {"id":"crematorio","name":"Crematorio Cinzas & Cia","p":Vector2(2192,1039)},
    {"id":"fiscalizacao","name":"Posto de fiscalizacao","p":Vector2(2840,1085)},
    {"id":"biblioteca","name":"Arquivo Legal","p":Vector2(1604,658)},
    {"id":"carro","name":"Carro funerario","p":Vector2(2080,566)},
    {"id":"funeraria","name":"Casa Funeraria Umbra","p":Vector2(2607,449)},
    {"id":"fornecedor","name":"Emporio das Ultimas Coisas","p":Vector2(2906,449)}
]
static func is_blocked(where: Vector2) -> bool:
    for footprint in BUILDINGS:
        if footprint.has_point(where):
            return true
    return false

extends RefCounted
## Estoque e valores de simulacao; nao representam precos reais.
const DEFAULT := "essencia"
const FAMILY_BUDGET := 380
const URNS := [
    {"id":"essencia","name":"Essência","description":"Madeira natural, linhas simples","price":180},
    {"id":"lirio_eterno","name":"Lírio Eterno","description":"Porcelana clara com lírios","price":240},
    {"id":"nocturne","name":"Nocturne","description":"Preto com detalhes prateados","price":280},
    {"id":"memoria_da_lua","name":"Memória da Lua","description":"Motivo lunar","price":260},
    {"id":"abobora_eterna","name":"Abóbora Eterna","description":"Cerâmica em forma de abóbora","price":320},
    {"id":"jardim_de_estrelas","name":"Jardim de Estrelas","description":"Violeta e constelações","price":380},
    {"id":"silencio","name":"Silêncio","description":"Cerâmica cinza discreta","price":200},
    {"id":"aurora","name":"Aurora","description":"Tons rosados e dourados","price":420},
    {"id":"jardim","name":"Jardim da Saudade","description":"Folhas ornamentais","price":460},
    {"id":"vesper","name":"Vesper","description":"Vidrado violeta","price":480},
    {"id":"reliquia","name":"Relíquia","description":"Metal de acabamento clássico","price":550},
    {"id":"legado","name":"Legado","description":"Acabamento artesanal","price":650}
]

static func item(id: String) -> Dictionary:
    for model in URNS:
        if model["id"]==id:
            return model.duplicate(true)
    return {}

static func cost(id: String) -> int:
    var model := item(id)
    if model.is_empty():
        return 0
    return 80 if id==DEFAULT else int(round(float(model["price"])*0.55/10.0))*10

static func normalize(raw: Dictionary, total: int) -> Dictionary:
    var out := {}
    var count := 0
    for model in URNS:
        var id: String = model["id"]
        out[id] = maxi(0,int(raw.get(id,0)))
        count += int(out[id])
    if count < total:
        out[DEFAULT] = int(out[DEFAULT])+total-count
    else:
        var excess := count-maxi(0,total)
        for id in out:
            var take := mini(excess,int(out[id]))
            out[id] = int(out[id])-take
            excess -= take
    return out

static func can_offer(id: String, stock: Dictionary) -> bool:
    var model := item(id)
    return not model.is_empty() and int(model["price"])<=FAMILY_BUDGET and int(stock.get(id,0))>0

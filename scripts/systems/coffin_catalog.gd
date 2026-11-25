extends RefCounted
## Precos e limites exclusivamente ficticios, para simulacao.
const DEFAULT := "serenidade"
const MODELS := {
    "serenidade":{"name":"Serenidade","description":"Madeira simples","cost":180,"price":300},
    "ultimo_suspiro":{"name":"Último Suspiro","description":"Madeira clara","cost":240,"price":420},
    "descanso_eterno":{"name":"Descanso Eterno","description":"Madeira escura","cost":320,"price":560},
    "lirio_branco":{"name":"Lírio Branco","description":"Acabamento branco","cost":380,"price":650},
    "rosa_da_saudade":{"name":"Rosa da Saudade","description":"Detalhes florais","cost":450,"price":790},
    "memorias":{"name":"Memórias","description":"Acabamento clássico","cost":520,"price":900},
    "vesper":{"name":"Vesper","description":"Madeira violeta","cost":600,"price":1050},
    "jardim_celestial":{"name":"Jardim Celestial","description":"Ornamentos de folhas","cost":700,"price":1200},
    "nocturne":{"name":"Nocturne","description":"Preto e prata","cost":800,"price":1400},
    "requiem":{"name":"Réquiem","description":"Madeira ornamentada","cost":950,"price":1650},
    "eternum":{"name":"Eternum","description":"Detalhes dourados","cost":1200,"price":2100},
    "legado":{"name":"Legado","description":"Artesanal personalizado","cost":1500,"price":2600}
}
const BUDGETS := {1:420,5:300,16:1050}

static func budget(case_id: int) -> int:
    return int(BUDGETS.get(case_id,0))

static func permitted(case_id: int, model: String) -> bool:
    return MODELS.has(model) and budget(case_id)>0 and int(MODELS[model]["price"])<=budget(case_id)

static func normalize(raw: Dictionary, total: int) -> Dictionary:
    var result := {}
    var count := 0
    for id in MODELS:
        result[id] = maxi(0,int(raw.get(id,0)))
        count += int(result[id])
    var target := maxi(0,total)
    if count < target:
        result[DEFAULT] = int(result[DEFAULT])+target-count
    elif count > target:
        var excess := count-target
        for id in MODELS:
            var take := mini(excess,int(result[id]))
            result[id] = int(result[id])-take
            excess -= take
    return result

static func snapshot(model: String) -> Dictionary:
    if not MODELS.has(model):
        return {}
    var info: Dictionary = MODELS[model]
    return {"model":model,"name":info["name"],"price":info["price"],"cost":info["cost"],"legacy":false}

static func legacy_snapshot() -> Dictionary:
    return {"model":DEFAULT,"name":"Serenidade","price":0,"cost":0,"legacy":true}

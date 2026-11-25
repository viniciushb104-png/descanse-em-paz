extends RefCounted
## Preferencias ficticias por familia; estado armazenado na ordem de servico.
const COFFINS = preload("res://scripts/systems/coffin_catalog.gd")
const FUNERAL_LORE = preload("res://scripts/systems/funeral_lore.gd")
const KEYS := ["flowers","light","music","chairs","tribute"]
const OPTIONS := {
    "flowers":["Lirios","Rosas","Margaridas","Violetas"],
    "light":["Velas","Ambar","Suave","Natural"],
    "music":["Piano","Orgao","Violino","Silencio"],
    "chairs":["Fileiras","Semicirculo","Intimista"],
    "tribute":["Retrato","Carta","Objeto pessoal","Sem homenagem"]
}
const LABELS := {"flowers":"Flores","light":"Iluminacao","music":"Musica","chairs":"Cadeiras","tribute":"Homenagem"}
const PROFILES := {
    "tutorial_b13":{"story":"A familia deseja uma despedida tranquila, sem ostentacao.","values":[0,0,0,0,0],"farewell":"Obrigado por nos dar um momento de paz."},
    "case_1":{"story":"A familia do Sr. Afonso lembra os jardins que ele cultivava. Prefere uma cerimonia simples.","values":[0,2,3,2,0],"farewell":"Ele sempre dizia que as coisas simples eram as melhores."},
    "case_5":{"story":"Sr. Gil quer uma despedida digna dentro do orcamento, com as flores favoritas da familia.","values":[2,3,3,0,1],"farewell":"A carta diz tudo aquilo que nao conseguimos dizer antes."},
    "case_16":{"story":"Sr. Benicio traz um objeto de familia e pede musica instrumental para a despedida.","values":[1,1,2,1,2],"farewell":"Este objeto vai nos lembrar dos bons momentos."}
}
static func profile(id: String) -> Dictionary:
    return PROFILES.get(id,PROFILES["tutorial_b13"])

static func new_state() -> Dictionary:
    return {"choices":{},"received":false,"farewell":false,"done":false}

static func state(order: Dictionary) -> Dictionary:
    var progress: Dictionary = order.get("progress",{})
    return progress.get("wake",new_state()).duplicate(true)

static func matches(order: Dictionary) -> int:
    var choices: Dictionary = state(order).get("choices",{})
    var wanted: Array = profile(str(order.get("id","")))["values"]
    var score := 0
    for i in range(KEYS.size()):
        if int(choices.get(KEYS[i],-1))==int(wanted[i]):
            score += 1
    return score

static func ready(order: Dictionary) -> bool:
    return matches(order)==KEYS.size()

static func done(order: Dictionary) -> bool:
    return bool(state(order).get("done",false))

static func requests(order: Dictionary) -> String:
    var p := profile(str(order.get("id","")))
    var lines: Array[String] = []
    for i in range(KEYS.size()):
        var key: String = KEYS[i]
        lines.append(str(LABELS[key])+": "+str(OPTIONS[key][int(p["values"][i])]))
    var coffin: Dictionary = order.get("coffin",COFFINS.legacy_snapshot())
    var memory: Dictionary = FUNERAL_LORE.story(str(order.get("id","")))
    var tribute := "" if memory.is_empty() else "\nEm memória de "+str(memory["name"])+": "+str(memory["memory"])+"\n"
    return str(p["story"])+tribute+"\n\nCaixão: "+str(coffin.get("name","Serenidade"))+"\n"+ "\n".join(lines)

static func farewell_text(order: Dictionary) -> String:
    var id := str(order.get("id",""))
    var memory: Dictionary = FUNERAL_LORE.story(id)
    var original := str(profile(id)["farewell"])
    return original if memory.is_empty() else original+"\n\n"+str(memory["goodbye"])

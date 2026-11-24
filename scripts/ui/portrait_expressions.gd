extends RefCounted
## Retratos expressivos do primeiro elenco. Imagens mantidas separadas e com alfa.
## Baltazar/Osvaldo trazem a propria moldura integrada; Amalia usa a moldura do lote 1.
const EMOTIONS := ["preocupado", "alegre", "surpreso", "ironico"]
const FRAMED := {"baltazar": true, "osvaldo": true, "amalia": false}
const TEXTURES := {
    "baltazar": {
        "preocupado": preload("res://assets/portraits/expressions/baltazar_preocupado.png"),
        "alegre": preload("res://assets/portraits/expressions/baltazar_alegre.png"),
        "surpreso": preload("res://assets/portraits/expressions/baltazar_surpreso.png"),
        "ironico": preload("res://assets/portraits/expressions/baltazar_ironico.png"),
    },
    "osvaldo": {
        "preocupado": preload("res://assets/portraits/expressions/osvaldo_preocupado.png"),
        "alegre": preload("res://assets/portraits/expressions/osvaldo_alegre.png"),
        "surpreso": preload("res://assets/portraits/expressions/osvaldo_surpreso.png"),
        "ironico": preload("res://assets/portraits/expressions/osvaldo_ironico.png"),
    },
    "amalia": {
        "preocupado": preload("res://assets/portraits/expressions/amalia_preocupado.png"),
        "alegre": preload("res://assets/portraits/expressions/amalia_alegre.png"),
        "surpreso": preload("res://assets/portraits/expressions/amalia_surpreso.png"),
        "ironico": preload("res://assets/portraits/expressions/amalia_ironico.png"),
    },
}

static func has_actor(id: String) -> bool:
    return TEXTURES.has(id)

static func has_frame(id: String) -> bool:
    return bool(FRAMED.get(id,false))

static func texture(id: String, mood: String) -> Texture2D:
    if not TEXTURES.has(id):
        return null
    var faces: Dictionary = TEXTURES[id]
    return faces.get(mood,faces["alegre"]) as Texture2D

static func infer(text: String) -> String:
    var lowered: String = text.to_lower()
    if "!" in text and ("opa" in lowered or "surpresa" in lowered or "incrivel" in lowered):
        return "surpreso"
    if "problema" in lowered or "perigo" in lowered or "document" in lowered or "nao conformidade" in lowered or "urgente" in lowered or "precisamos conferir" in lowered:
        return "preocupado"
    if "?" in text or "ironia" in lowered or "burocracia" in lowered or "contas" in lowered:
        return "ironico"
    return "alegre"

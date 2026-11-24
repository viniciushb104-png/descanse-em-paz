extends RefCounted
## Lote 1 aprovado: 8 PNGs transparentes, sem textos gravados.
## As molduras de retrato sao vazias: o busto dinamico continua por tras.
const BASE: Texture2D = preload("res://assets/dialogue/lote_01/base_dialogue.png")
const ANSWER: Texture2D = preload("res://assets/dialogue/lote_01/answer_button.png")
const LOT2 = preload("res://scripts/ui/dialogue_art_lote_02.gd")
const PORTRAITS := {
    "baltazar": preload("res://assets/dialogue/lote_01/portrait_frame_baltazar.png"),
    "osvaldo": preload("res://assets/dialogue/lote_01/portrait_frame_osvaldo.png"),
    "amalia": preload("res://assets/dialogue/lote_01/portrait_frame_amalia.png")
}
const PLATES := {
    "baltazar": preload("res://assets/dialogue/lote_01/nameplate_baltazar.png"),
    "osvaldo": preload("res://assets/dialogue/lote_01/nameplate_osvaldo.png"),
    "amalia": preload("res://assets/dialogue/lote_01/nameplate_amalia.png")
}

static func supports(identity: String) -> bool:
    return (PORTRAITS.has(identity) and PLATES.has(identity)) or LOT2.supports(identity)

static func has_integrated_nameplate(identity: String) -> bool:
    return LOT2.supports(identity)

static func portrait(identity: String) -> Texture2D:
    if LOT2.supports(identity):
        return LOT2.portrait(identity)
    return PORTRAITS.get(identity) as Texture2D

static func nameplate(identity: String) -> Texture2D:
    return PLATES.get(identity) as Texture2D

static func answer_style(tone: Color = Color.WHITE) -> StyleBoxTexture:
    var panel := StyleBoxTexture.new()
    panel.texture = ANSWER
    panel.texture_margin_left = 44.0
    panel.texture_margin_right = 27.0
    panel.texture_margin_top = 14.0
    panel.texture_margin_bottom = 14.0
    panel.content_margin_left = 55.0
    panel.content_margin_right = 16.0
    panel.content_margin_top = 7.0
    panel.content_margin_bottom = 7.0
    panel.modulate_color = tone
    return panel

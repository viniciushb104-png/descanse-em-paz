extends RefCounted
## Recortes da prancha aprovada. PNGs individuais de maior resolucao
## substituem o atlas compacto automaticamente quando disponiveis.
const ATLAS = preload("res://assets/ui/funeral_magazine/revista_atlas.png")
const DIR := "res://assets/ui/funeral_magazine/definitivos/"
const REGIONS := {
    "cover":Rect2(0,0,30,36),
    "back":Rect2(31,0,23,36),
    "book":Rect2(55,0,72,46),
    "frame":Rect2(0,37,24,31),
    "label":Rect2(25,37,24,13),
    "divider":Rect2(25,51,24,7),
    "seal":Rect2(51,47,12,15),
    "coffins_tab":Rect2(64,47,10,16),
    "urns_tab":Rect2(75,47,10,16),
    "services_tab":Rect2(86,47,10,16),
    "quote_tab":Rect2(97,47,10,16),
    "button":Rect2(0,69,38,10),
    "next":Rect2(39,69,26,10),
    "previous":Rect2(66,69,26,10),
    "close":Rect2(93,69,26,10),
    "left":Rect2(25,59,11,9),
    "right":Rect2(38,59,10,9),
    "page_marker":Rect2(108,47,19,8),
    "curl":Rect2(108,56,11,12)
}
static func texture(id: String) -> Texture2D:
    var path := DIR+id+".png"
    if ResourceLoader.exists(path,"Texture2D"):
        return load(path) as Texture2D
    if not REGIONS.has(id):
        return null
    var tex := AtlasTexture.new()
    tex.atlas = ATLAS
    tex.region = REGIONS[id]
    tex.filter_clip = true
    return tex

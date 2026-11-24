extends RefCounted
## Lote 2: atlas 3x2, cada celula com uma moldura com janela e placa transparentes.
## Os personagens antigos mantem o Lote 1 sem alteracoes.
const ATLAS: Texture2D = preload("res://assets/dialogue/lote_02/molduras_lote_02_game_atlas.png")
const CELL := Vector2i(256,256)
const CELLS := {
    "cinerio": Vector2i(0,0),       # Caveira, cortinas e velas
    "penelope": Vector2i(1,0),      # Vitral e heras
    "clotilde": Vector2i(2,0),      # Caixao e rosas
    "arquimedes": Vector2i(0,1),    # Relogio mecanico
    "gervasio": Vector2i(1,1),      # Abobora e galhos
    "umbelina": Vector2i(2,1)      # Fantasmas e velas
}

static func supports(identity: String) -> bool:
    return CELLS.has(identity)

static func portrait(identity: String) -> Texture2D:
    if not supports(identity):
        return null
    var cell: Vector2i = CELLS[identity]
    var section := AtlasTexture.new()
    section.atlas = ATLAS
    section.region = Rect2(Vector2(cell * CELL), Vector2(CELL))
    section.filter_clip = true
    return section

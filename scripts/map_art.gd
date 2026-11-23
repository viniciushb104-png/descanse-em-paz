extends RefCounted
## V0.3: importa e posiciona PIXEL ART RECORTADA DAS IMAGENS OFICIAIS do projeto.
## Texturas PNG sao atlases com alfa; as regioes preservam assets independentes.
## Os SVGs da v0.2 nao sao mais utilizados neste mapa.

const WORLD_ATLAS: Texture2D = preload("res://assets/art/world.png")
const CHARACTER_ATLAS: Texture2D = preload("res://assets/art/characters.png")

const SPRITES = {
    "grass": Rect2(3, 3, 40, 40),
    "flowers_grass": Rect2(47, 3, 40, 40),
    "stone_path": Rect2(91, 3, 40, 40),
    "earth": Rect2(135, 3, 40, 40),
    "wall": Rect2(179, 3, 137, 80),
    "gate": Rect2(320, 3, 198, 100),
    "fence": Rect2(522, 3, 112, 87),
    "grave_a": Rect2(638, 3, 48, 65),
    "grave_b": Rect2(690, 3, 52, 65),
    "grave_c": Rect2(746, 3, 46, 65),
    "plot": Rect2(796, 3, 57, 65),
    "family_plot": Rect2(3, 107, 150, 70),
    "bush": Rect2(157, 107, 52, 52),
    "flowerbed": Rect2(213, 107, 62, 46),
    "hedge": Rect2(279, 107, 54, 52),
    "tree": Rect2(337, 107, 174, 187),
    "lantern": Rect2(515, 107, 38, 92),
    "bench": Rect2(557, 107, 86, 64),
    "pumpkin": Rect2(647, 107, 35, 45),
    "statue": Rect2(686, 107, 138, 138),
    "fountain": Rect2(3, 298, 207, 137),
    "office": Rect2(214, 298, 300, 223),
    "shed": Rect2(518, 298, 250, 188),
    "marker": Rect2(772, 298, 48, 65)
}

const NPC_RECTS = {
    "osvaldo_down_0": Rect2(3, 92, 52, 65),
    "osvaldo_down_1": Rect2(59, 92, 52, 65),
    "baltazar_down_0": Rect2(3, 161, 53, 70),
    "baltazar_down_1": Rect2(60, 161, 53, 70)
}

const GRASS = "grass"
const FLOWERS_GRASS = "flowers_grass"
const PATH = "stone_path"
const EARTH = "earth"
const WALL = "wall"
const GATE = "gate"
const FENCE = "fence"
const GRAVE0 = "grave_a"
const GRAVE1 = "grave_b"
const GRAVE2 = "grave_c"
const PLOT = "plot"
const PLOT_RESERVED = "plot_reserved"
const HEDGE = "hedge"
const FLOWERS = "flowerbed"
const TREE = "tree"
const LANTERN = "lantern"
const BENCH = "bench"
const PUMPKIN = "pumpkin"
const STATUE = "statue"
const FOUNTAIN = "fountain"
const OFFICE = "office"
const SHED = "shed"
const FAMILY = "family_plot"
const OSVALDO = "osvaldo_down_0"
const BALTAZAR = "baltazar_down_0"

const WORLD_RECT := Rect2(0, 0, 1536, 960)
const PAPER := Color("#f6e5cb")

static func stamp(ctx: Node2D, sprite_key: String, x: float, y: float, w: float, h: float) -> void:
    var is_plot_reserved: bool = sprite_key == "plot_reserved"
    var lookup_key: String = "plot" if is_plot_reserved else sprite_key
    var atlas: Texture2D = CHARACTER_ATLAS if NPC_RECTS.has(lookup_key) else WORLD_ATLAS
    var sources: Dictionary = NPC_RECTS if NPC_RECTS.has(lookup_key) else SPRITES
    if not sources.has(lookup_key):
        return
    ctx.draw_texture_rect_region(atlas, Rect2(x, y, w, h), sources[lookup_key], Color.WHITE, false, true)
    if is_plot_reserved:
        ctx.draw_rect(Rect2(x + 2, y + 4, w - 4, h - 8), Color("#f0c068"), false, 4.0)

static func writing(ctx: Node2D, pos: Vector2, message: String, size_px: int = 19, color: Color = PAPER) -> void:
    ctx.draw_string(ThemeDB.fallback_font, pos, message, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)

static func paint(ctx: Node2D, reserved_plot: bool, time_minute: float) -> void:
    # Terreno modular: 64x64 px, caminhos por cima e decoracoes como objetos independentes.
    for y in range(0, 960, 64):
        for x in range(0, 1536, 64):
            stamp(ctx, FLOWERS_GRASS if (int(x / 64) + int(y / 64) * 3) % 7 == 0 else GRASS, x, y, 64, 64)
    # Caminho central do portao para a administracao.
    for yy in range(430, 950, 64):
        for xx in range(665, 857, 64):
            stamp(ctx, PATH, xx, yy, 64, 64)
    for yy in range(510, 610, 64):
        for xx in range(170, 1450, 64):
            stamp(ctx, PATH, xx, yy, 64, 64)
    for yy in range(368, 584, 64):
        for xx in range(351, 550, 64):
            stamp(ctx, PATH, xx, yy, 64, 64)
    for yy in range(580, 915, 64):
        for xx in range(1160, 1395, 64):
            stamp(ctx, PATH, xx, yy, 64, 64)

    # Muros, jardins e areas delimitadas, mantendo entrada inferior desobstruida.
    for xx in range(0, 1536, 152):
        stamp(ctx, WALL, xx, 0, 152, 85)
    for yy in range(77, 879, 80):
        stamp(ctx, WALL, 0, yy, 50, 80)
        stamp(ctx, WALL, 1488, yy, 50, 80)
    for xx in range(0, 600, 152):
        stamp(ctx, WALL, xx, 880, 152, 85)
    for xx in range(915, 1536, 152):
        stamp(ctx, WALL, xx, 880, 152, 85)
    stamp(ctx, GATE, 650, 792, 250, 171)
    writing(ctx, Vector2(704, 928), "ULTIMO SUSPIRO", 18, Color("#efc98a"))

    # Sombras e vegetacao ambiente.
    stamp(ctx, TREE, 22, 82, 216, 237)
    stamp(ctx, TREE, 1320, 90, 180, 205)
    stamp(ctx, TREE, 44, 667, 150, 174)
    stamp(ctx, HEDGE, 540, 460, 91, 59)
    stamp(ctx, HEDGE, 934, 487, 88, 57)
    stamp(ctx, HEDGE, 1003, 490, 91, 57)
    for pos in [Vector2(80, 464), Vector2(260, 460), Vector2(946, 110), Vector2(1040, 100), Vector2(1454, 599)]:
        stamp(ctx, FLOWERS, pos.x, pos.y, 82, 50)

    # Administracao e contabilidade: entrada em baixo, proximo ao ponto E do escritorio.
    stamp(ctx, OFFICE, 204, 120, 485, 344)
    writing(ctx, Vector2(314, 151), "ADMINISTRACAO", 19)
    stamp(ctx, LANTERN, 287, 408, 34, 80)
    stamp(ctx, LANTERN, 600, 407, 34, 80)

    # Quadra B: jazigos posicionados em fileiras e acessiveis pela lateral dos caminhos.
    writing(ctx, Vector2(861, 198), "QUADRA B", 24)
    for row in range(3):
        for col in range(6):
            var px: float = 798 + col * 103
            var py: float = 246 + row * 103
            if row == 1 and col == 3:
                stamp(ctx, PLOT_RESERVED if reserved_plot else PLOT, px - 13, py - 5, 88, 77)
                writing(ctx, Vector2(px + 4, py - 9), "B-13", 17, Color("#ffe8aa"))
            else:
                stamp(ctx, EARTH, px + 10, py + 33, 47, 28)
                var grave_texture: String = GRAVE0 if (row + col) % 3 == 0 else (GRAVE1 if (row + col) % 3 == 1 else GRAVE2)
                stamp(ctx, grave_texture, px - 2, py - 28, 66, 92)
                if (row + col) % 2 == 0:
                    stamp(ctx, FLOWERS, px + 28, py + 30, 38, 26)

    # Jardins familiares do lado oeste.
    stamp(ctx, FAMILY, 108, 610, 208, 111)
    stamp(ctx, FAMILY, 340, 701, 210, 113)
    stamp(ctx, STATUE, 95, 347, 147, 157)
    stamp(ctx, FOUNTAIN, 611, 742, 221, 171)
    stamp(ctx, BENCH, 312, 585, 136, 79)
    stamp(ctx, BENCH, 962, 694, 123, 70)
    for pos in [Vector2(78, 762), Vector2(239, 774), Vector2(492, 758), Vector2(352, 608)]:
        stamp(ctx, GRAVE0, pos.x, pos.y, 70, 100)

    # Galpao de manutencao — ponto interativo fica na porta, na parte de baixo.
    stamp(ctx, SHED, 1116, 628, 324, 225)
    writing(ctx, Vector2(1176, 673), "MANUTENCAO", 18)
    for pos in [Vector2(552, 525), Vector2(850, 525), Vector2(681, 883), Vector2(935, 877), Vector2(1037, 525)]:
        stamp(ctx, LANTERN, pos.x, pos.y, 38, 93)
    for pos in [Vector2(132, 826), Vector2(1420, 830), Vector2(580, 845), Vector2(1010, 850)]:
        stamp(ctx, PUMPKIN, pos.x, pos.y, 48, 52)
    for pos in [Vector2(430, 525), Vector2(1165, 568), Vector2(1439, 521)]:
        stamp(ctx, HEDGE, pos.x, pos.y, 66, 53)

    # Personagens fixos: as coordenadas coincidem com o sistema de interacao.
    stamp(ctx, "osvaldo_down_1" if int(time_minute / 2.0) % 2 == 0 else OSVALDO, 695, 588, 62, 90)
    writing(ctx, Vector2(681, 590), "OSVALDO", 15, PAPER)
    var float_y: float = sin(time_minute * 0.18) * 5.0
    stamp(ctx, "baltazar_down_1" if int(time_minute / 2.0) % 2 == 0 else BALTAZAR, 328, 470 + float_y, 71, 92)
    writing(ctx, Vector2(318, 468), "BALTAZAR", 15, Color("#bdf7fa"))
    if time_minute > 930.0:
        var alpha: float = clampf((time_minute - 930.0) / 180.0, 0.0, 0.24)
        ctx.draw_rect(WORLD_RECT, Color(0.06, 0.04, 0.15, alpha), true)

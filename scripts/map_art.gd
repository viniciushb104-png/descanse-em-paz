extends RefCounted
## Mapa V0.4: as artes reais (PNG atlases) em blocos coerentes.
## Renderizacao separada em terreno, caminhos, predios e decoracao.
## Camera inicial exibe todo o terreno, para evitar cortes de edificios.
const ATLAS: Texture2D = preload("res://assets/art/world.png")
const CHARACTERS: Texture2D = preload("res://assets/art/characters.png")
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
    "shed": Rect2(518, 298, 250, 188)
}
const NPC_RECTS = {
    "osvaldo_down_0": Rect2(3, 92, 52, 65),
    "osvaldo_down_1": Rect2(59, 92, 52, 65),
    "baltazar_down_0": Rect2(3, 161, 53, 70),
    "baltazar_down_1": Rect2(60, 161, 53, 70)
}
const GREEN := Color("#34473b")
const STONE := Color("#79697b")
const LIGHT := Color("#f6e3be")

static func stamp(ctx: Node2D, key: String, x: float, y: float, w: float, h: float, opacity: float = 1.0) -> void:
    var is_npc: bool = NPC_RECTS.has(key)
    var area: Dictionary = NPC_RECTS if is_npc else SPRITES
    if not area.has(key):
        return
    var texture: Texture2D = CHARACTERS if is_npc else ATLAS
    ctx.draw_texture_rect_region(texture, Rect2(x, y, w, h), area[key], Color(1, 1, 1, opacity), false, true)

static func path(ctx: Node2D, region: Rect2) -> void:
    ctx.draw_rect(region, STONE, true)
    ctx.draw_rect(region, Color("#b49aac"), false, 3.0)
    var x: int = int(region.position.x)
    while x < int(region.end.x):
        var y: int = int(region.position.y)
        while y < int(region.end.y):
            var w: float = minf(48.0, region.end.x - float(x))
            var h: float = minf(48.0, region.end.y - float(y))
            stamp(ctx, "stone_path", float(x), float(y), w, h, 0.78)
            y += 48
        x += 48

static func paint(ctx: Node2D, reserved: bool, time_minute: float) -> void:
    paint_ground(ctx)
    paint_paths(ctx)
    paint_buildings(ctx)
    paint_plots(ctx, reserved)
    paint_decoration(ctx)
    paint_characters(ctx, time_minute)
    if time_minute > 1020.0:
        var alpha: float = clampf((time_minute - 1020.0) / 120.0, 0.0, 0.12)
        ctx.draw_rect(Rect2(0, 0, 1536, 960), Color(0.03, 0.03, 0.12, alpha), true)

static func paint_ground(ctx: Node2D) -> void:
    ctx.draw_rect(Rect2(0, 0, 1536, 960), GREEN, true)
    # Sem o padrao de quadriculado: os recortes de grama viram detalhes pontuais.
    for i in range(80):
        var x: float = 75.0 + float((i * 211 + 13) % 1392)
        var y: float = 93.0 + float((i * 157 + 27) % 775)
        stamp(ctx, "flowers_grass" if i % 7 == 0 else "grass", x, y, 34, 34, 0.22)

static func paint_paths(ctx: Node2D) -> void:
    path(ctx, Rect2(700, 364, 137, 552))
    path(ctx, Rect2(150, 544, 1243, 108))
    path(ctx, Rect2(394, 396, 111, 180))
    path(ctx, Rect2(1220, 340, 110, 225))
    path(ctx, Rect2(1058, 609, 160, 113))
    path(ctx, Rect2(435, 700, 267, 84))

static func paint_buildings(ctx: Node2D) -> void:
    # Topo inteiro da capela e do galpao fica dentro do mundo.
    stamp(ctx, "office", 168, 116, 466, 315)
    stamp(ctx, "shed", 1101, 132, 340, 226)
    # Muros discretos, sem cobrir as edificacoes.
    for x in range(0, 1536, 137):
        stamp(ctx, "wall", float(x), 5, 137, 76)
    for y in range(90, 883, 76):
        stamp(ctx, "wall", 4, float(y), 48, 76)
        stamp(ctx, "wall", 1480, float(y), 48, 76)
    for x in range(0, 625, 137):
        stamp(ctx, "wall", float(x), 890, 137, 70)
    for x in range(910, 1536, 137):
        stamp(ctx, "wall", float(x), 890, 137, 70)
    stamp(ctx, "gate", 646, 808, 240, 145)

static func paint_plots(ctx: Node2D, reserved: bool) -> void:
    # Quadra B separada da oficina; fileiras ordenadas.
    for row in range(2):
        for col in range(5):
            var px: float = 883.0 + float(col * 110)
            var py: float = 429.0 + float(row * 127)
            if row == 1 and col == 2:
                stamp(ctx, "plot", px, py + 12, 79, 82)
                ctx.draw_rect(Rect2(px + 1, py + 13, 78, 80), Color("#e9bd6e") if reserved else Color("#addbd5"), false, 3.0)
                ctx.draw_string(ThemeDB.fallback_font, Vector2(px + 17, py + 9), "B-13", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, LIGHT)
            else:
                stamp(ctx, "grave_a" if (col + row) % 3 == 0 else ("grave_b" if col % 2 == 0 else "grave_c"), px, py, 65, 89)
                if (col + row) % 2 == 0:
                    stamp(ctx, "flowerbed", px + 6, py + 74, 53, 33)
    stamp(ctx, "family_plot", 132, 700, 180, 90)
    stamp(ctx, "family_plot", 333, 703, 159, 83)
    stamp(ctx, "grave_c", 225, 472, 63, 86)
    stamp(ctx, "grave_a", 105, 462, 60, 86)
    stamp(ctx, "grave_b", 522, 653, 59, 83)

static func paint_decoration(ctx: Node2D) -> void:
    stamp(ctx, "tree", 61, 118, 180, 192)
    stamp(ctx, "tree", 850, 99, 167, 183)
    stamp(ctx, "tree", 1340, 704, 143, 164)
    stamp(ctx, "statue", 89, 305, 137, 143)
    stamp(ctx, "fountain", 489, 723, 195, 136)
    stamp(ctx, "bench", 274, 481, 122, 73)
    stamp(ctx, "bench", 860, 735, 114, 65)
    for p in [Vector2(622, 532), Vector2(851, 536), Vector2(1080, 534), Vector2(1240, 537)]:
        stamp(ctx, "lantern", p.x, p.y, 29, 73)
    for p in [Vector2(173, 839), Vector2(970, 826), Vector2(1410, 805)]:
        stamp(ctx, "pumpkin", p.x, p.y, 40, 46)
    for p in [Vector2(570, 467), Vector2(984, 352), Vector2(995, 690), Vector2(192, 827)]:
        stamp(ctx, "flowerbed", p.x, p.y, 66, 46)
    for p in [Vector2(80, 452), Vector2(599, 468), Vector2(1095, 690), Vector2(1342, 624)]:
        stamp(ctx, "hedge", p.x, p.y, 62, 57)

static func paint_characters(ctx: Node2D, time_minute: float) -> void:
    stamp(ctx, "osvaldo_down_0" if int(time_minute / 3.0) % 2 == 0 else "osvaldo_down_1", 746, 556, 65, 89)
    stamp(ctx, "baltazar_down_0" if int(time_minute / 3.0) % 2 == 0 else "baltazar_down_1", 537, 412 + sin(time_minute * 0.12) * 4.0, 70, 93)

extends RefCounted
## Mapa visual versionado em Godot; cada elemento e um recurso independente.
## Visual base V0.2: arte vetorial original (substituivel por atlas PNG definitivo).

const GRASS = preload("res://assets/sprites/grass.svg")
const FLOWERS_GRASS = preload("res://assets/sprites/flowers_grass.svg")
const PATH = preload("res://assets/sprites/path.svg")
const EARTH = preload("res://assets/sprites/earth.svg")
const WALL = preload("res://assets/sprites/wall.svg")
const GATE = preload("res://assets/sprites/gate.svg")
const FENCE = preload("res://assets/sprites/fence.svg")
const GRAVE0 = preload("res://assets/sprites/grave_0.svg")
const GRAVE1 = preload("res://assets/sprites/grave_1.svg")
const GRAVE2 = preload("res://assets/sprites/grave_2.svg")
const PLOT = preload("res://assets/sprites/plot.svg")
const PLOT_RESERVED = preload("res://assets/sprites/plot_reserved.svg")
const HEDGE = preload("res://assets/sprites/hedge.svg")
const FLOWERS = preload("res://assets/sprites/flowers.svg")
const TREE = preload("res://assets/sprites/tree.svg")
const LANTERN = preload("res://assets/sprites/lantern.svg")
const BENCH = preload("res://assets/sprites/bench.svg")
const PUMPKIN = preload("res://assets/sprites/pumpkin.svg")
const STATUE = preload("res://assets/sprites/statue.svg")
const FOUNTAIN = preload("res://assets/sprites/fountain.svg")
const OFFICE = preload("res://assets/sprites/office.svg")
const SHED = preload("res://assets/sprites/shed.svg")
const FAMILY = preload("res://assets/sprites/family_plot.svg")
const OSVALDO = preload("res://assets/sprites/osvaldo_down_0.svg")
const BALTAZAR = preload("res://assets/sprites/baltazar_down_0.svg")

const WORLD_RECT := Rect2(0, 0, 1536, 960)
const PAPER := Color("#f6e5cb")

static func stamp(ctx: Node2D, tex: Texture2D, x: float, y: float, w: float, h: float) -> void:
    ctx.draw_texture_rect(tex, Rect2(x, y, w, h), false)

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
                var grave_texture: Texture2D = GRAVE0 if (row + col) % 3 == 0 else (GRAVE1 if (row + col) % 3 == 1 else GRAVE2)
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
    stamp(ctx, OSVALDO, 695, 588, 62, 96)
    writing(ctx, Vector2(681, 590), "OSVALDO", 15, PAPER)
    var float_y: float = sin(time_minute * 0.18) * 5.0
    stamp(ctx, BALTAZAR, 328, 470 + float_y, 71, 100)
    writing(ctx, Vector2(318, 468), "BALTAZAR", 15, Color("#bdf7fa"))
    if time_minute > 930.0:
        var alpha: float = clampf((time_minute - 930.0) / 180.0, 0.0, 0.24)
        ctx.draw_rect(WORLD_RECT, Color(0.06, 0.04, 0.15, alpha), true)

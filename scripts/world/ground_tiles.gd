extends RefCounted
## Chao de Santa Mortalha. Unica fonte para materiais e conexoes.
## Malha de 32px: 48 colunas x 30 linhas. Renderizacao procedural deterministica.
const TILE: int = 32
const WIDTH: int = 96
const HEIGHT: int = 72
const GRASS: int = 0
const STONE: int = 1
const DIRT: int = 2
const GREEN := Color("#35493e")
const GRASS_ACCENTS = [Color("#405a45"),Color("#465d49"),Color("#536a4d")]
const STONES = [Color("#a28d9e"),Color("#958292"),Color("#ab98a6"),Color("#8f7f92"),Color("#a999ac")]
const DIRT_COLORS = [Color("#715243"),Color("#765645"),Color("#634a3e")]
# Areas em unidades de tile. Ajuste estes retangulos para modificar o piso.
# Os caminhos conectam as entradas de capela, oficina, jazigo B-13 e portao.
const PATHS = [
    Rect2i(22,13,4,58),
    Rect2i(4,45,40,2),
    Rect2i(4,52,40,2),
    Rect2i(4,59,40,2),
    Rect2i(4,66,40,2), # alameda central
    Rect2i(5,17,39,3),  # eixo leste/oeste
    Rect2i(12,12,4,5),  # escritorio
    Rect2i(38,11,4,6),  # oficina
    Rect2i(32,19,6,3),  # quadra B
    Rect2i(13,22,9,3),  # jardins
    Rect2i(7,19,5,4),   # sepulturas oeste
    Rect2i(43,17,33,4), # passagem para o leste
    Rect2i(55,12,4,6),  # hospital
    Rect2i(54,20,4,12), # preparacao
    Rect2i(67,20,3,14), # crematorio
    Rect2i(54,33,14,3), # garagem
    Rect2i(65,35,7,3), # fiscalizacao
    Rect2i(76,17,20,4), # extensao para o comercio
    Rect2i(80,12,4,6), # entrada da casa funeraria
    Rect2i(89,12,4,6) # entrada da fornecedora
]
const SOIL = [
    Rect2i(26,12,2,3),
    Rect2i(28,14,4,2),
    Rect2i(3,22,4,3),
    Rect2i(42,12,2,3),
    Rect2i(31,23,4,2),
    Rect2i(51,27,3,4),
    Rect2i(71,30,3,3)
]

static func hash_at(x: int, y: int, salt: int = 0) -> int:
    var n: int = x * 73856093 + y * 19349663 + salt * 83492791 + 197
    return absi(n ^ (n >> 13)) % 9973

static func material_at(cell: Vector2i) -> int:
    if cell.x < 0 or cell.x >= WIDTH or cell.y < 0 or cell.y >= HEIGHT:
        return -1
    for section in PATHS:
        if section.has_point(cell):
            return STONE
    for section in SOIL:
        if section.has_point(cell):
            return DIRT
    return GRASS

static func material_at_world(pos: Vector2) -> int:
    return material_at(Vector2i(int(floorf(pos.x / float(TILE))),int(floorf(pos.y / float(TILE)))))

static func paint(ctx: Node2D) -> void:
    ctx.draw_rect(Rect2(0,0,WIDTH*TILE,HEIGHT*TILE),GREEN)
    for cy in range(HEIGHT):
        for cx in range(WIDTH):
            var cell := Vector2i(cx,cy)
            match material_at(cell):
                STONE: _stone(ctx,cell)
                DIRT: _soil(ctx,cell)
                _: _grass(ctx,cell)

static func _grass(ctx: Node2D, cell: Vector2i) -> void:
    # Evita um quadriculado visivel: nao pinta quadrados inteiros na grama.
    var x: float = float(cell.x*TILE)
    var y: float = float(cell.y*TILE)
    var n: int = hash_at(cell.x,cell.y)
    if n % 4 == 0:
        ctx.draw_rect(Rect2(x+float(n%19), y+float((n/7)%25), 11,4),GRASS_ACCENTS[0])
    if n % 3 == 0:
        ctx.draw_rect(Rect2(x+float(n%23), y+float((n/11)%22), 6,3),GRASS_ACCENTS[1])
    if n % 7 == 0:
        ctx.draw_line(Vector2(x+7,y+22),Vector2(x+10,y+16),GRASS_ACCENTS[2],2.0)
        ctx.draw_line(Vector2(x+10,y+23),Vector2(x+14,y+17),GRASS_ACCENTS[1],2.0)
    if n % 23 == 0:
        ctx.draw_rect(Rect2(x+20,y+8,3,3),Color("#bf7eab"))
        ctx.draw_rect(Rect2(x+24,y+10,3,3),Color("#cda6b4"))
    elif n % 29 == 0:
        ctx.draw_rect(Rect2(x+17,y+16,4,2),Color("#bb8255"))
    if n % 13 == 0:
        ctx.draw_rect(Rect2(x+8,y+4,3,2),GRASS_ACCENTS[0])

static func _soil(ctx: Node2D, cell: Vector2i) -> void:
    var x: float = float(cell.x*TILE)
    var y: float = float(cell.y*TILE)
    var n: int = hash_at(cell.x,cell.y,3)
    ctx.draw_rect(Rect2(x,y,TILE,TILE),DIRT_COLORS[n%DIRT_COLORS.size()])
    for i in range(4):
        var q: int = hash_at(cell.x*9+i,cell.y*17,5)
        ctx.draw_rect(Rect2(x+float(q%27),y+float((q/8)%28),3,2),Color("#a07d5e"))
    if material_at(cell+Vector2i.UP) == GRASS:
        ctx.draw_rect(Rect2(x,y,TILE,3),Color("#40563e"))
    if material_at(cell+Vector2i.DOWN) == GRASS:
        ctx.draw_rect(Rect2(x,y+TILE-3,TILE,3),Color("#40563e"))

static func _stone(ctx: Node2D, cell: Vector2i) -> void:
    var x: float = float(cell.x*TILE)
    var y: float = float(cell.y*TILE)
    var n: int = hash_at(cell.x,cell.y,4)
    ctx.draw_rect(Rect2(x,y,TILE,TILE),Color("#584c5c"))
    # Pedras com fileiras desencontradas e tamanhos irregulares.
    for row in range(3):
        var top: float = y+float(row*11)+1.0
        var height: float = minf(9.0,y+float(TILE)-top)
        if height <= 0.0:
            continue
        var shift: int = (cell.y*7+row*11+cell.x*3)%16
        var offset: int = -shift
        while offset < TILE:
            var width: int = 14+((n+row*3+offset+64)%11)
            var left: float = x+float(maxi(offset,0))
            var right: float = x+float(mini(offset+width,TILE))
            if right > left:
                var color_index: int = (n+row*7+offset+64)%STONES.size()
                ctx.draw_rect(Rect2(left,top,right-left,height),STONES[color_index])
                if right-left >= 7.0:
                    ctx.draw_rect(Rect2(left+2,top+1,3,2),Color("#c0a9b6",0.45))
            offset += width+2
    # Bordas so nas transicoes de materiais, nao entre tiles iguais.
    var ink := Color("#4c5344")
    if material_at(cell+Vector2i.UP) != STONE:
        ctx.draw_rect(Rect2(x,y,TILE,3),ink)
        ctx.draw_rect(Rect2(x,y+3,TILE,2),Color("#7b8268"))
    if material_at(cell+Vector2i.DOWN) != STONE:
        ctx.draw_rect(Rect2(x,y+TILE-5,TILE,2),Color("#7b8268"))
        ctx.draw_rect(Rect2(x,y+TILE-3,TILE,3),ink)
    if material_at(cell+Vector2i.LEFT) != STONE:
        ctx.draw_rect(Rect2(x,y,3,TILE),ink)
    if material_at(cell+Vector2i.RIGHT) != STONE:
        ctx.draw_rect(Rect2(x+TILE-3,y,3,TILE),ink)

extends Node2D
## Oficina: bancada, ferramentas, caixas e lampadas em desenhos separados.
## Area central livre para movimentacao e interacao.
const DARK := Color("#27202d")
const WOOD := Color("#7e5b4a")
const METAL := Color("#a4a6ac")
const GOLD := Color("#d9ad70")

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    # Piso da oficina: marcas discretas de rodinhas e de ferramentas.
    for i in range(9):
        draw_rect(Rect2(480+i*25,492+float(i%3)*4,13,3),Color("#82726b",0.24))
    # Bancada lateral.
    draw_rect(Rect2(65,384,180,31),WOOD)
    draw_rect(Rect2(79,416,15,84),DARK)
    draw_rect(Rect2(208,416,15,84),DARK)
    for x in [78.0, 139.0, 199.0]:
        draw_rect(Rect2(x,365,37,18),METAL)
    # Painel de ferramentas suspensas.
    draw_rect(Rect2(66,194,187,118),Color("#503a3f"))
    for i in range(7):
        var x: float = 83.0+float(i*24)
        draw_line(Vector2(x,214),Vector2(x,283),METAL,3)
        draw_circle(Vector2(x,211),5,GOLD)
    # Prateleiras de suprimentos e lanternas.
    for x in [908.0, 1020.0]:
        draw_rect(Rect2(x,386,84,124),DARK)
        for y in [396.0,446.0,488.0]:
            draw_rect(Rect2(x+7,y,67,8),WOOD)
        for idx in range(2):
            draw_rect(Rect2(x+14+idx*28,408,24,25),Color("#bca277"))
    # Relogio de manutencao e vaso de plantas desajeitado.
    draw_circle(Vector2(581,224),26,DARK)
    draw_circle(Vector2(581,224),18,Color("#e3c6a0"))
    draw_line(Vector2(581,224),Vector2(587,210),DARK,3)
    draw_line(Vector2(581,224),Vector2(566,226),DARK,2)
    draw_rect(Rect2(425,443,36,36),WOOD)
    for i in range(5):
        draw_line(Vector2(443,444),Vector2(425+i*9,413+i%2*6),Color("#64816a"),3)

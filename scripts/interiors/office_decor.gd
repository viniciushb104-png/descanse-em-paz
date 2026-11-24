extends Node2D
## Cenario artesanal do escritorio; fachada e jogador permanecem intactos.
## Esta arte modular pode receber PNGs individuais posteriormente.
const INK := Color("#261a31")
const WOOD := Color("#644355")
const GOLD := Color("#caa16b")
const PAPER := Color("#dfd0b6")

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    # Cortinas drapeadas e estante de livros contabeis.
    for side in [76.0, 1014.0]:
        draw_rect(Rect2(side, 171, 49, 158), Color("#4d304a"))
        draw_line(Vector2(side,171),Vector2(side+49,171),GOLD,4.0)
        for fold in range(4):
            draw_line(Vector2(side+8+fold*10,178),Vector2(side+8+fold*10,317),Color("#795268"),2.0)
    draw_rect(Rect2(69,337,128,95),INK)
    draw_rect(Rect2(77,345,111,79),WOOD)
    for shelf in range(3):
        var py: float = 353.0+shelf*23.0
        draw_rect(Rect2(83,py,99,4),GOLD)
        for book in range(8):
            var bx: float = 86.0+book*12.0
            draw_rect(Rect2(bx,py-17,9,16),Color("#997889") if book%2==0 else Color("#aa865d"))
    # Relogio de parede tortinho e livros de balanco.
    draw_line(Vector2(598,177),Vector2(602,215),Color("#3c303d"),5)
    draw_circle(Vector2(600,221),30,INK)
    draw_circle(Vector2(600,221),23,GOLD)
    draw_circle(Vector2(600,221),17,Color("#ede1cb"))
    draw_line(Vector2(600,221),Vector2(600,211),INK,2)
    draw_line(Vector2(600,221),Vector2(613,226),INK,2)
    # Tapete oval gótico no corredor central, sem criar colisao invisivel.
    draw_colored_polygon(PackedVector2Array([
        Vector2(436,435),Vector2(476,409),Vector2(675,409),
        Vector2(720,435),Vector2(675,471),Vector2(476,471)]),Color("#51344d"))
    for inset in range(3):
        draw_arc(Vector2(576,440),float(43+inset*8),0,TAU,24,Color("#a67f8d",0.25),2.0)
    # Cofre pequeno e pastas arquivadas, sem ocupar o ponto de interacao.
    draw_rect(Rect2(945,405,109,96),Color("#342d3d"))
    draw_rect(Rect2(955,414,90,76),Color("#6e606e"))
    draw_circle(Vector2(1004,453),15,INK)
    draw_circle(Vector2(1004,453),7,GOLD)
    for idx in range(4):
        draw_rect(Rect2(960+idx*20,391,13,13),PAPER)

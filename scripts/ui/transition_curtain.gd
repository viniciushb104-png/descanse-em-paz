extends Control
## Cortinas goticas que se encontram antes da troca de ambiente.
## Independente de resolucao: usa toda a area visivel.
const SHADE := Color("#17101d")
const EDGE := Color("#c49b68")
var closure: float = 0.0:
    set(value):
        closure = clampf(value, 0.0, 1.0)
        queue_redraw()

func _draw() -> void:
    if closure <= 0.0:
        return
    var half: float = size.x * 0.5 * closure
    draw_rect(Rect2(0, 0, half, size.y), SHADE)
    draw_rect(Rect2(size.x - half, 0, half, size.y), SHADE)
    draw_line(Vector2(half,0),Vector2(half,size.y),EDGE,3.0)
    draw_line(Vector2(size.x-half,0),Vector2(size.x-half,size.y),EDGE,3.0)
    if closure > 0.35:
        var center := Vector2(size.x*0.5,size.y*0.5)
        var alpha: float = clampf((closure - 0.35) / 0.65, 0.0, 1.0)
        draw_arc(center,38,0.0,TAU,24,Color(0.82,0.67,0.46,alpha),2.0)
        draw_line(center+Vector2(-16,0),center+Vector2(16,0),Color(0.82,0.67,0.46,alpha),3.0)
        draw_line(center+Vector2(0,-16),center+Vector2(0,16),Color(0.82,0.67,0.46,alpha),3.0)

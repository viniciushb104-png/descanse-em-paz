extends RefCounted
## Bases solidas do mobiliario; a altura do sprite nao e uma parede invisivel.
const SOLID = [
    Rect2(761,635,35,21), Rect2(554,495,36,21), # Osvaldo e Baltazar
    Rect2(119,412,76,34), # pedestal da estatua
    Rect2(482,776,128,62), # fonte
    Rect2(271,500,82,25), # banco
    Rect2(140,725,164,63), Rect2(341,727,143,60), # jazigos familiares
    Rect2(627,588,18,17), Rect2(856,592,18,17), Rect2(1085,590,18,17), Rect2(1245,593,18,17),
    Rect2(91,487,40,22), Rect2(486,515,40,22), Rect2(1353,659,40,22),
    Rect2(181,868,24,15), Rect2(1048,888,24,15), Rect2(1328,863,24,15),
    Rect2(485,523,10,16), Rect2(855,373,10,16), Rect2(1350,523,10,16), Rect2(1405,678,10,16),
    Rect2(2304,683,46,79), Rect2(1551,735,139,29), Rect2(2720,1136,240,16)
]
static func blocked(p: Vector2) -> bool:
    for rect in SOLID:
        if rect.has_point(p):
            return true
    # Bases dos objetos ornamentais repetidos da expansao.
    for y in [-1550.0,-950.0,-200.0,2120.0]:
        for x in [1610.0,2990.0]:
            if Rect2(x-16,y-18,32,18).has_point(p):
                return true
    for y in [-1450.0,-1250.0,-1030.0,-750.0,-120.0,1510.0,2070.0]:
        for x in [2190.0,2440.0]:
            if Rect2(x-9,y-14,18,14).has_point(p):
                return true
    for x in [1740.0,1940.0,2600.0,2860.0]:
        if Rect2(x-26,-930,52,20).has_point(p):
            return true
    for y in [-220.0,-820.0,-1510.0]:
        for x in [90.0,780.0,1460.0]:
            if Rect2(x-9,y-14,18,14).has_point(p):
                return true
        for x in [105.0,1450.0]:
            if Rect2(x-15,y-108,30,18).has_point(p):
                return true
    for y in [-650.0,-1340.0]:
        if Rect2(676,y-18,58,18).has_point(p) or Rect2(829,y-24,52,24).has_point(p):
            return true
    for x in [370.0,1170.0]:
        if Rect2(x-45,-1577,90,42).has_point(p):
            return true
    return false

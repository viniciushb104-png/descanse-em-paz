extends SceneTree
## PNGs reais e fluxo entre personagens sem perder textos, cliques ou fallback.
const ART = preload("res://scripts/ui/dialogue_art_lote_01.gd")
const ACTORS = preload("res://scripts/ui/dialogue_characters.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game._close()
    var panel := game.dialog_panel as Control
    var body := panel.get_node("BodyScroll") as ScrollContainer
    var choices := panel.get_node("ChoicesScroll") as ScrollContainer
    var frame := panel.get_node("DialogueFrame") as Control
    var ornament := panel.get_node("PortraitFrameArt") as TextureRect
    var plate := panel.get_node("NameplateArt") as TextureRect
    var portrait := panel.get_node("ClientPortrait") as Control
    if ART.BASE.get_size()!=Vector2(727,299) or ART.ANSWER.get_size()!=Vector2(674,64):
        push_error("Sprites do lote 1 nao correspondem aos arquivos aprovados")
        quit(171)
        return
    for identity in ["baltazar","osvaldo","amalia"]:
        var actor: Dictionary = ACTORS.by_id(identity)
        game._show_character(str(actor["name"]),"Mensagem de teste longa, "+("com muita papelada. ".repeat(32)),str(actor["profile"]),[
            {"text":"Primeira resposta educativa e muito comprida para testar leitura sem cortes","action":"close"},
            {"text":"Segunda resposta com humor respeitoso e transparencia","action":"close"},
            {"text":"Terceira alternativa com os requisitos legais, mais detalhada","action":"close"}
        ])
        await process_frame
        if not bool(frame.get("sprite_mode")) or ornament.texture != ART.portrait(identity) or plate.texture != ART.nameplate(identity):
            push_error("O PNG correto nao acompanha o personagem: "+identity)
            quit(172)
            return
        var expected_separate_frame: bool = identity == "amalia"
        if ornament.visible != expected_separate_frame or not plate.visible or not portrait.visible or not game.dialog_role.visible:
            push_error("Moldura duplicada ou retrato invisivel: "+identity)
            quit(173)
            return
        if portrait.position.x+portrait.size.x >= body.position.x or body.size.y<90.0:
            push_error("Retrato cobriu a fala: "+identity)
            quit(174)
            return
        if Rect2(portrait.position,portrait.size).intersects(Rect2(choices.position,choices.size)):
            push_error("Respostas colidiram com a imagem: "+identity)
            quit(175)
            return
        var first: Button = game.options_box.get_child(0)
        if not first.get_theme_stylebox("normal") is StyleBoxTexture or first.size.x <= 0:
            push_error("Resposta nao recebeu sprite do botao: "+identity)
            quit(176)
            return
        if game.options_box.get_child_count()!=3:
            push_error("Opcoes desapareceram: "+identity)
            quit(177)
            return
    game._show_character("Dra. Penélope","Atendimento do hospital","medica",[{"text":"Fechar","action":"close"}])
    if bool(frame.get("sprite_mode")) or ornament.visible or plate.visible:
        push_error("Fallback dos personagens sem PNG ficou quebrado")
        quit(178)
        return
    game._show("Arquivo Legal","Texto institucional.",[{"text":"Fechar","action":"close"}])
    if ornament.visible or plate.visible or portrait.visible:
        push_error("Janela institucional nao deve usar retrato de pessoa")
        quit(179)
        return
    print("LOTE 1 OK: base, 3 molduras de retrato, 3 placas, botao responsivo e fallback.")
    quit(0)

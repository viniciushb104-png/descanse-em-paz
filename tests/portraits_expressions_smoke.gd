extends SceneTree
## Testa as 12 imagens reais e o ciclo de visualizacao sem alterar o expediente.
const EXPRESSIONS = preload("res://scripts/ui/portrait_expressions.gd")
const CHARACTERS = preload("res://scripts/ui/dialogue_characters.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game._close()
    var old_money: int = game.money
    var old_stage: int = game.stage
    var old_index: int = game.get_node("RoomsRuntime").case_index
    var portrait := game.dialog_panel.get_node("ClientPortrait") as Control
    var ornament := game.dialog_panel.get_node("PortraitFrameArt") as TextureRect
    var nameplate := game.dialog_panel.get_node("NameplateArt") as TextureRect
    var speech := game.dialog_panel.get_node("BodyScroll") as ScrollContainer
    var choices := game.dialog_panel.get_node("ChoicesScroll") as ScrollContainer
    game._open_journal()
    game._on_choice("portrait_gallery")
    if not game.dialogue_open or game.dialog_title.text != "GALERIA DE RETRATOS":
        push_error("Galeria inacessivel pelo Diario")
        quit(181)
        return
    for id in ["baltazar","osvaldo","amalia"]:
        game._on_choice("portrait_select_"+id)
        for emotion in EXPRESSIONS.EMOTIONS:
            var path: String = "res://assets/portraits/expressions/"+id+"_"+str(emotion)+".png"
            if not ResourceLoader.exists(path):
                push_error("Imagem de expressao nao encontrada: "+path)
                quit(182)
                return
            var texture: Texture2D = EXPRESSIONS.texture(id,str(emotion))
            if texture == null or texture.get_size()!=Vector2(352,352):
                push_error("Imagem de expressao com tamanho errado: "+path)
                quit(183)
                return
            var picture: Image = texture.get_image()
            if not picture.detect_alpha():
                push_error("Transparencia inexistente: "+path)
                quit(184)
                return
            game._on_choice("portrait_emotion_"+id+"_"+str(emotion))
            if not portrait.visible or str(portrait.get("current_expression"))!=str(emotion) or portrait.get("portrait_texture")!=texture:
                push_error("Retrato nao trocou de expressao: "+id+" / "+str(emotion))
                quit(185)
                return
            if not nameplate.visible:
                push_error("Placa do personagem sumiu")
                quit(186)
                return
            var embedded: bool = id in ["baltazar","osvaldo"]
            if bool(portrait.get("embedded_frame")) != embedded or ornament.visible == embedded:
                push_error("Sobreposicao de moldura no personagem "+id)
                quit(187)
                return
            if Rect2(portrait.position,portrait.size).intersects(Rect2(speech.position,speech.size)):
                push_error("Retrato ocupou a area de leitura")
                quit(188)
                return
            if Rect2(portrait.position,portrait.size).intersects(Rect2(choices.position,choices.size)):
                push_error("Retrato ocupou respostas")
                quit(189)
                return
        game._on_choice("portrait_gallery")
    game._show_character("Sr. Afonso","Atendimento geral","calmo",[{"text":"Fechar","action":"close"}])
    if ornament.visible or nameplate.visible or bool(portrait.get("embedded_frame")):
        push_error("Fallback dos demais NPCs alterado")
        quit(190)
        return
    if game.money!=old_money or game.stage!=old_stage or game.get_node("RoomsRuntime").case_index!=old_index:
        push_error("Galeria alterou o progresso")
        quit(191)
        return
    game._close()
    print("EXPRESSIONS OK: 12 PNGs transparentes, 4 emocoes x 3 atores, molduras sem duplicidade, galeria e progresso intacto.")
    quit(0)

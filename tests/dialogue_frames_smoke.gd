extends SceneTree
## Confere painel de Jack adaptado para todo o elenco de Santa Mortalha.
const PEOPLE = preload("res://scripts/ui/dialogue_characters.gd")
const CASES = preload("res://scripts/systems/customer_cases.gd")
const SCENES = preload("res://scripts/systems/dialogue_scenes.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game._close()
    if PEOPLE.CHARACTERS.size() < 46:
        push_error("Catalogo de personagens incompleto")
        quit(141)
        return
    var panel := game.dialog_panel as Control
    var frame := panel.get_node_or_null("DialogueFrame") as Control
    var portrait := panel.get_node_or_null("ClientPortrait") as Control
    var role := panel.get_node_or_null("CharacterRole") as Label
    var text_scroll := panel.get_node_or_null("BodyScroll") as ScrollContainer
    var choices_scroll := panel.get_node_or_null("ChoicesScroll") as ScrollContainer
    if frame == null or portrait == null or role == null or text_scroll == null or choices_scroll == null:
        push_error("Elementos da caixa de dialogo ausentes")
        quit(142)
        return
    if portrait.position.x < 20 or portrait.position.x+portrait.size.x > text_scroll.position.x-10:
        push_error("Retrato invadiu a area da fala")
        quit(143)
        return
    if choices_scroll.position.y <= portrait.position.y+portrait.size.y:
        push_error("Escolhas colidiram com a moldura do retrato")
        quit(144)
        return
    if panel.size.x < 850 or panel.position.y < 185:
        push_error("Caixa deveria ser larga e estar na base da tela")
        quit(145)
        return
    var variants: Dictionary = {}
    for key in PEOPLE.CHARACTERS.keys():
        var spec: Dictionary = PEOPLE.by_id(str(key))
        var speaker: String = str(spec["name"])
        var resolved: Dictionary = PEOPLE.resolve(speaker)
        if str(resolved.get("id","")) != str(key):
            push_error("Elenco nao resolve corretamente: "+speaker)
            quit(146)
            return
        game._show_character(speaker,"Fala de teste; incluindo leitura com rolagem e retrato individual.",str(spec["profile"]),[
            {"text":"Responder com respeito","action":"close"},
            {"text":"Pedir esclarecimentos","action":"close"},
            {"text":"Consultar informacoes","action":"close"}
        ])
        if not portrait.visible or not role.visible or not bool(frame.get("show_portrait")):
            push_error("Retrato ou placa do personagem nao apareceu: "+speaker)
            quit(147)
            return
        if str(portrait.get("actor_name")) != speaker or role.text.is_empty():
            push_error("Retrato ou profissao nao acompanharam o personagem: "+speaker)
            quit(148)
            return
        if str((portrait.get("identity") as Dictionary).get("id","")) != str(key):
            push_error("Retrato trocou identidade: "+speaker)
            quit(149)
            return
        var tint: Color = frame.get("accent")
        variants[tint.to_html()] = true
    if variants.size() < 12:
        push_error("Faltam molduras de cores distintas")
        quit(150)
        return
    for case in CASES.CASES:
        if PEOPLE.resolve(str(case["client"])).is_empty():
            push_error("Cliente sem identidade cadastrada: "+str(case["client"]))
            quit(151)
            return
    for voice in SCENES.SUPPORTING_VOICES:
        if PEOPLE.resolve(str(voice["name"])).is_empty():
            push_error("Participante secundario sem identidade: "+str(voice["name"]))
            quit(152)
            return
    # Dialogos legados sao reconhecidos sem reescrever as historias.
    game._show("Seu Osvaldo, o coveiro","Opa, chefe!",[{"text":"Fechar","action":"close"}])
    if not portrait.visible or str(portrait.get("actor_name")) != "Seu Osvaldo, o coveiro":
        push_error("Dialogue legado nao usa retrato de Osvaldo")
        quit(153)
        return
    game._show("Arquivo Legal","Texto generico sem personagem.",[{"text":"Voltar","action":"close"}])
    if portrait.visible or role.visible or bool(frame.get("show_portrait")):
        push_error("Janela institucional deveria ocultar retrato")
        quit(154)
        return
    game._show_character("Baltazar","Uma longa explicacao, "+("com papelada. ".repeat(90)),"profissional",[
        {"text":"Fechar","action":"close"}])
    await process_frame
    if text_scroll.size.y < 100.0 or portrait.position.x+portrait.size.x >= text_scroll.position.x:
        push_error("Caixa nao respeita rolagem ou janela de retrato")
        quit(155)
        return
    game._close()
    print("DIALOGUE FRAMES OK: 46 pessoas com placas, retratos, molduras, troca de locutor e area de leitura segura.")
    quit(0)

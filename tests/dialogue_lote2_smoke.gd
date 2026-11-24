extends SceneTree
## Lote 2: confirma seis molduras personalizadas com alfa e os tres estilos anteriores.
const ART = preload("res://scripts/ui/dialogue_art_lote_01.gd")
const ART2 = preload("res://scripts/ui/dialogue_art_lote_02.gd")
const ACTORS = preload("res://scripts/ui/dialogue_characters.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game._close()
    var panel: Control = game.dialog_panel
    var overlay := panel.get_node("PortraitFrameArt") as TextureRect
    var plate := panel.get_node("NameplateArt") as TextureRect
    var plate_text := panel.get_node("PortraitNameplateText") as Label
    var portrait := panel.get_node("ClientPortrait") as Control
    var speech := panel.get_node("BodyScroll") as ScrollContainer
    var choices := panel.get_node("ChoicesScroll") as ScrollContainer
    var bg := panel.get_node("DialogueFrame") as Control
    if ART2.ATLAS.get_size() != Vector2(768,512):
        push_error("Atlas do lote 2 deveria ter seis celulas de 256x256")
        quit(211)
        return
    var original_money: int = game.money
    var original_stage: int = game.stage
    var visited := {}
    for id in ["cinerio","penelope","clotilde","arquimedes","gervasio","umbelina"]:
        var actor: Dictionary = ACTORS.by_id(id)
        game._show_character(str(actor["name"]),"Teste de moldura e leitura",str(actor["profile"]),[
            {"text":"Continuar","action":"close"}, {"text":"Voltar","action":"close"}
        ])
        await process_frame
        if not ART.supports(id) or not bool(bg.get("sprite_mode")):
            push_error("Sistema nao reconheceu moldura do personagem: "+id)
            quit(212)
            return
        if not overlay.visible or overlay.texture == null or plate.visible or not plate_text.visible or not portrait.visible:
            push_error("Moldura ou nome dinamico nao apareceu: "+id)
            quit(213)
            return
        if plate_text.text != str(actor["name"]):
            push_error("Nome exibido no porta-retrato nao corresponde ao NPC: "+id)
            quit(214)
            return
        var texture := overlay.texture as AtlasTexture
        if texture == null or texture.region.size != Vector2(256,256):
            push_error("AtlasTexture ausente para "+id)
            quit(215)
            return
        var region_key := str(texture.region.position)
        if visited.has(region_key):
            push_error("Moldura duplicada entre NPCs: "+id)
            quit(216)
            return
        visited[region_key] = true
        # Ler explicitamente a regiao evita diferencas entre APIs de AtlasTexture.
        var top_left := Vector2i(int(texture.region.position.x),int(texture.region.position.y))
        var image := ART2.ATLAS.get_image().get_region(Rect2i(top_left,Vector2i(256,256)))
        if image == null or image.get_size() != Vector2i(256,256) or image.get_pixel(128,128).a > 0.08:
            push_error("Janela de retrato nao esta transparente: "+id)
            quit(217)
            return
        if Rect2(portrait.position,portrait.size).intersects(Rect2(speech.position,speech.size)) or Rect2(overlay.position,overlay.size).intersects(Rect2(choices.position,choices.size)):
            push_error("A moldura invade as opcoes ou a fala: "+id)
            quit(218)
            return
    if visited.size() != 6:
        push_error("Nem todas as seis molduras foram usadas")
        quit(219)
        return
    for id in ["osvaldo","baltazar","amalia"]:
        var actor: Dictionary = ACTORS.by_id(id)
        game._show_character(str(actor["name"]),"Moldura original",str(actor["profile"]),[{"text":"Fechar","action":"close"}])
        if not plate.visible or plate_text.visible:
            push_error("A moldura original foi modificada: "+id)
            quit(220)
            return
    game._show_character("Sr. Afonso","Outro atendimento","calmo",[{"text":"Fechar","action":"close"}])
    if overlay.visible or plate.visible or plate_text.visible or bool(bg.get("sprite_mode")):
        push_error("O fallback dos clientes deixou de funcionar")
        quit(221)
        return
    game._show("Arquivo Legal","Texto institucional.",[{"text":"Fechar","action":"close"}])
    if portrait.visible or plate_text.visible or overlay.visible:
        push_error("Janela generica exibe retrato indevido")
        quit(222)
        return
    if game.money != original_money or game.stage != original_stage:
        push_error("Molduras alteraram dinheiro ou progresso")
        quit(223)
        return
    print("LOTE 2 OK: seis molduras transparentes, nomes dinamicos, tres antigas intactas, fallback e layout seguros.")
    quit(0)

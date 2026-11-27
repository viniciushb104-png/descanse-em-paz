extends RefCounted
const COFFINS = preload("res://scripts/systems/coffin_catalog.gd")
const ART := "res://assets/ui/funeral_magazine/"
const URN_CATALOG = preload("res://scripts/systems/urn_catalog.gd")
const SERENIDADE_PREVIEW := "res://assets/sprites/coffins/serenidade/pagina_preview.webp"
const AMALIA_FULL := ART+"pagina_02_amalia.jpg"
const SPREAD_DIR := ART+"duplas/"
const AMALIA_PREVIEW := ART+"pagina_02_amalia_preview.webp"
const AMALIA_TEXT := "Consultora de despedidas, memória e bom senso\n\nBem-vindo à Casa Funerária Umbra. Sou Madame Amália, sua anfitriã entre orçamentos, homenagens e escolhas delicadas. Em Santa Mortalha, cada família merece escuta, transparência e respeito.\n\nO QUE VOCÊ APRENDE COMIGO\n• Ouvir a família antes de oferecer produtos.\n• Respeitar orçamento, vontade e contexto.\n• Explicar diferenças entre sepultamento, cremação e cerimônia.\n• Apresentar opções com ética, clareza e acolhimento.\n\nNA LORE DO JOGO\nAmália é o coração comercial da funerária. Ela apresenta o catálogo, orienta as escolhas da família e ajuda o jogador a transformar decisões difíceis em despedidas dignas.\n\nFRASE DA AMÁLIA\nLuxo sem sentido? Nem pensar. Até no além, bom atendimento vale mais que ostentação.\n\nDICA PROFISSIONAL\nNo ramo funerário, acolhimento, organização e transparência são tão importantes quanto o produto oferecido."
static func amalia_page() -> Dictionary:
    var full := ResourceLoader.exists(AMALIA_FULL,"Texture2D")
    return {"title":"Madame Amália Umbra","section":"Apresentação","body":AMALIA_TEXT,"art":AMALIA_FULL if full else AMALIA_PREVIEW,"preview":not full,"editorial":true,"spread":SPREAD_DIR+"amalia_dupla.webp"}
static func pages(stock: Dictionary = {}, case_id: int = 0, mode: String = "browse", cash: int = 0) -> Array:
    var out: Array = [{"title":"A Eternidade em Detalhes","section":"Capa","body":"Casa Funerária Umbra • Santa Mortalha\nToda memória merece respeito.","art":ART+"cover.svg","spread":SPREAD_DIR+"capa_dupla.webp"}]
    out.append(amalia_page())
    for id in COFFINS.MODELS:
        var item: Dictionary = COFFINS.MODELS[id]
        var count := int(stock.get(id,0))
        var price := int(item["cost"] if mode=="shop" else item["price"])
        var page := {"title":item["name"],"section":"Caixões","body":str(item["description"])+"\nEstoque: %d unidade(s).\n%s R$ %d" % [count,"Aquisição:" if mode=="shop" else "Venda:",price],"art":ART+"coffin_"+str(id)+".svg","preview":true,"action":"","reason":""}
        page["transaction_line"] = "%s R$ %d  •  Estoque: %d" % ["Aquisição:" if mode=="shop" else "Venda:",price,count]
        var catalog_art := "res://assets/sprites/coffins/"+str(id)+"/pagina.png"
        # O encarte impresso do Serenidade tem preço de venda fixo na arte;
        # não o mostrar na compra de fornecedor nem quando o preço mudar.
        var show_serenidade_page: bool = str(id)=="serenidade" and mode!="shop" and price==300
        if id=="serenidade":
            page["body"] += "\n\nColeção Clássica — tradição, respeito e dignidade para o último adeus.\nMadeira marrom, forração marfim, alças douradas e cruz clássica na tampa.\n\nMadame Amália: Uma escolha clássica, como um bom chá: simples, elegante e sempre bem-vinda.\n\nDica profissional: apresente opções compatíveis com a vontade e o orçamento da família. O preço acima é do caixão, não de todos os serviços do funeral. Valores fictícios."
            if show_serenidade_page:
                var full := ResourceLoader.exists(catalog_art,"Texture2D")
                page["art"]=catalog_art if full else SERENIDADE_PREVIEW
                page["preview"]=not full
                page["editorial"]=true
                page["spread"]=SPREAD_DIR+"serenidade_dupla.webp"
            else:
                page["art"]="res://assets/sprites/coffins/serenidade/aberto.png"
                page["preview"]=false
        else:
            if ResourceLoader.exists(catalog_art,"Texture2D"):
                page["art"]=catalog_art
                page["preview"]=false
                page["editorial"]=true
            var open_art := "res://assets/sprites/coffins/"+str(id)+"/aberto.png"
            if ResourceLoader.exists(open_art,"Texture2D") and (mode=="shop" or not ResourceLoader.exists(catalog_art,"Texture2D")):
                page["art"]=open_art
                page["preview"]=false
                page["editorial"]=false
            # A página 04 também tem o preço de venda impresso: nunca confundir com aquisição.
            if mode!="shop" and (str(id)!="ultimo_suspiro" or price==420):
                page["spread"]=SPREAD_DIR+str(id)+"_dupla.webp"
                if ResourceLoader.exists(str(page["spread"]),"Texture2D"):
                    page["editorial"]=true
                    page["preview"]=false
            if str(id)=="ultimo_suspiro":
                page["body"] += "\n\nColeção Clássica — madeira clara, forração marfim acolchoada, alças douradas e cruz discreta na tampa.\n\nDica profissional: apresente os materiais e o acabamento com clareza, respeitando as preferências e o orçamento da família. O valor indicado é do caixão, não do funeral completo."
            if str(id)=="descanso_eterno":
                page["body"] += "\n\nColeção Clássica — madeira escura, forração em cetim marfim, alças ornamentadas e cruz dourada em relevo.\n\nMadame Amália: A memória não se mede pelo preço do caixão.\n\nDica profissional: explique as diferenças de acabamento, respeite o orçamento da família e discrimine os demais serviços."
            if str(id)=="lirio_branco":
                page["body"] += "\n\nColeção Clássica — acabamento branco marfim, ornamentos dourados e forração acetinada.\n\nDica profissional: confirme as preferências culturais e religiosas da família; as cores e os símbolos não têm o mesmo significado para todas as pessoas."
            if str(id)=="rosa_da_saudade":
                page["body"] += "\n\nColeção Clássica — madeira em tom vinho, rosas ornamentais, alças douradas e forração em veludo rubro.\n\nMadame Amália: Algumas lembranças continuam a florescer. Mas nenhuma flor precisa vir com uma dívida.\n\nDica profissional: apresente os ornamentos como opções estéticas, sem associar o preço à intensidade do afeto."
            if str(id)=="memorias":
                page["body"] += "\n\nColeção Clássica — madeira escura, entalhes florais artesanais e forração em cetim champanhe.\n\nMadame Amália: Há histórias que nem o tempo consegue arquivar. E olha que Baltazar já tentou!\n\nDica profissional: ofereça a personalização como escolha, nunca como obrigação."
            if str(id)=="vesper":
                page["body"] += "\n\nColeção Clássica — madeira violeta, entalhes florais góticos, alças em latão envelhecido e cetim lavanda perolado.\n\nMadame Amália: Um toque de violeta para quem aprecia a beleza serena das antigas tradições.\n\nDica profissional: explique os ornamentos com sensibilidade e respeite os valores e as preferências da família. O valor é do caixão, não do funeral completo."
            if str(id)=="jardim_celestial":
                page["body"] += "\n\nMadeira verde-musgo, heras ornamentais, detalhes em bronze dourado e cetim verde-sálvia.\n\nMadame Amália: Até as mais belas flores precisam descansar. Mas Baltazar insiste que as contas não tiram férias!\n\nDica profissional: ofereça os ornamentos conforme os desejos da família, sem atribuir qualidades ambientais ao acabamento."
            if str(id)=="nocturne":
                page["body"] += "\n\nMadeira preta, ornamentos prateados e veludo violeta escuro.\n\nDica profissional: respeite as preferências estéticas e religiosas da família, sem impor símbolos."
            if str(id)=="requiem":
                page["body"] += "\n\nMadeira escura, entalhes barrocos, bronze envelhecido e forração vinho. Ornamentos inspirados na música sacra.\n\nMadame Amália: Até as despedidas têm sua própria melodia.\n\nDica profissional: a música e os símbolos da cerimônia devem refletir as preferências da família."
            if str(id)=="eternum":
                page["body"] += "\n\nMadeira negra, ornamentação barroca dourada e forração em cetim marfim acolchoado.\n\nMadame Amália: O dourado é uma questão de gosto. A dignidade, meu caro, não é um adicional na fatura!\n\nDica profissional: apresente as diferenças de acabamento sem associar o preço do caixão ao valor da vida homenageada."
        if mode=="offer":
            if not COFFINS.permitted(case_id,str(id)):
                page["reason"]="Acima do orçamento familiar."
            elif count<=0:
                page["reason"]="Sem estoque. Reponha no Empório."
            else:
                page["action"]="coffin_select_"+str(id)
        elif mode=="shop":
            if cash>=price:
                page["action"]="coffin_buy_"+str(id)
            else:
                page["reason"]="Caixa insuficiente."
        out.append(page)
    out.append({"title":"Sepultamento","section":"Serviços","body":"Documentação, escolha de caixão, despedida e sepultamento autorizado. Consulte os atendentes.","art":ART+"burial.svg"})
    out.append({"title":"Cremação","section":"Serviços","body":"Quando a família manifesta preferência pela cremação, Madame Amália encaminha ao Empório para consultar a revista de urnas de Violeta. A execução depende de documentação e autorização aplicáveis.","art":ART+"cremation.svg"})
    out.append({"title":"Cerimônias","section":"Serviços","body":"Anselmo organiza flores, iluminação, música, cadeiras e homenagem conforme a família.","art":ART+"ceremony.svg"})
    out.append({"title":"Flores e ornamentação","section":"Serviços","body":"Arranjos escolhidos pela família. Nenhum adicional é imposto.","art":ART+"flowers.svg"})
    out.append({"title":"Serviços opcionais","section":"Serviços","body":"Valores e condições devem ser discriminados antes do aceite.","art":ART+"optional.svg"})
    out.append({"title":"Orçamento personalizado","section":"Serviços","body":"Baltazar: Sou transparente, mas a receita não pode ser invisível! Confirme itens, valores e autorização antes de registrar.","art":ART+"quote.svg"})
    return out

static func urn_pages(stock: Dictionary = {}, mode: String = "browse", cash: int = 0) -> Array:
    var out: Array = [{"title":"Memórias que Permanecem","section":"Capa","body":"Empório das Últimas Coisas • Santa Mortalha\nColeção de urnas cinerárias.","art":ART+"urn_cover.svg","book":"urns"}]
    out.append({"title":"Sra. Violeta","section":"Apresentação","body":"Conheci este Empório como cliente. Agora ajudo Gervásio a apresentar urnas com respeito, sem transformar lembranças em competição de luxo. Minha abóbora favorita não dispensa documento algum!","art":ART+"urn_abobora_eterna.svg","book":"urns","preview":true})
    for model in URN_CATALOG.URNS:
        var id: String = model["id"]
        var count := int(stock.get(id,0))
        var price := URN_CATALOG.cost(id) if mode=="shop" else int(model["price"])
        var page := {"title":model["name"],"section":"Urnas","body":str(model["description"])+"\nEstoque: %d unidade(s).\n%s R$ %d" % [count,"Aquisição:" if mode=="shop" else "Venda:",price],"art":ART+"urn_"+id+".svg","book":"urns","preview":true,"action":"","reason":""}
        page["transaction_line"] = "%s R$ %d  •  Estoque: %d" % ["Aquisição:" if mode=="shop" else "Venda:",price,count]
        var final_art := "res://assets/sprites/urns/"+id+"/pagina.png"
        if ResourceLoader.exists(final_art,"Texture2D"):
            page["art"] = final_art
            page["preview"] = false
        if mode=="shop":
            if cash>=price:
                page["action"]="urn_buy_"+id
            else:
                page["reason"]="Caixa insuficiente."
        elif mode=="offer":
            if int(model["price"])>URN_CATALOG.FAMILY_BUDGET:
                page["reason"]="Acima do orçamento familiar."
            elif count<=0:
                page["reason"]="Sem estoque. Consulte Gervásio."
            else:
                page["action"]="urn_select_"+id
        out.append(page)
    out.append({"title":"Da escolha à entrega","section":"Serviços","body":"A urna não autoriza uma cremação. Baltazar confere os registros e Cinério recebe apenas ordens adequadas. O minigame operacional será acrescentado em etapa futura.","art":ART+"cremation.svg","book":"urns"})
    out.append({"title":"Orçamento e memória","section":"Serviços","body":"A família confirma o modelo, o preço e os serviços em separado. Nenhum adicional é obrigatório.","art":ART+"quote.svg","book":"urns"})
    return out

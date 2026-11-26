extends RefCounted
const COFFINS = preload("res://scripts/systems/coffin_catalog.gd")
const ART := "res://assets/ui/funeral_magazine/"
const URNS := [
    {"id":"essencia","name":"Essência","description":"Madeira natural, linhas simples","price":180},
    {"id":"lirio_eterno","name":"Lírio Eterno","description":"Porcelana clara com lírios","price":240},
    {"id":"nocturne","name":"Nocturne","description":"Preto com detalhes prateados","price":280},
    {"id":"memoria_da_lua","name":"Memória da Lua","description":"Motivo lunar","price":260},
    {"id":"abobora_eterna","name":"Abóbora Eterna","description":"Cerâmica em forma de abóbora","price":320},
    {"id":"jardim_de_estrelas","name":"Jardim de Estrelas","description":"Violeta e constelações","price":380},
    {"id":"silencio","name":"Silêncio","description":"Cerâmica cinza discreta","price":200},
    {"id":"aurora","name":"Aurora","description":"Tons rosados e dourados","price":420},
    {"id":"jardim","name":"Jardim da Saudade","description":"Folhas ornamentais","price":460},
    {"id":"vesper","name":"Vesper","description":"Vidrado violeta","price":480},
    {"id":"reliquia","name":"Relíquia","description":"Metal de acabamento clássico","price":550},
    {"id":"legado","name":"Legado","description":"Acabamento artesanal","price":650}
]
static func pages(stock: Dictionary = {}, case_id: int = 0, mode: String = "browse", cash: int = 0) -> Array:
    var out: Array = [{"title":"A Eternidade em Detalhes","section":"Capa","body":"Casa Funerária Umbra • Santa Mortalha\nToda memória merece respeito.","art":ART+"cover.svg"}]
    out.append({"title":"Uma escolha, muitas memórias","section":"Apresentação","body":"Madame Amália: O catálogo ajuda a escolher, não a impor. Preços fictícios; a família decide com calma.","art":ART+"intro.svg"})
    for id in COFFINS.MODELS:
        var item: Dictionary = COFFINS.MODELS[id]
        var count := int(stock.get(id,0))
        var price := int(item["cost"] if mode=="shop" else item["price"])
        var page := {"title":item["name"],"section":"Caixões","body":str(item["description"])+"\nEstoque: %d unidade(s).\n%s R$ %d" % [count,"Aquisição:" if mode=="shop" else "Venda:",price],"art":ART+"coffin_"+str(id)+".svg","preview":true,"action":"","reason":""}
        if id=="serenidade":
            page["art"]="res://assets/sprites/coffins/serenidade/aberto.png"
            page["preview"]=false
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
    for item in URNS:
        out.append({"title":item["name"],"section":"Urnas","body":str(item["description"])+"\nPreço proposto: R$ %d\nPrévia da coleção; contratação ainda não disponível." % int(item["price"]),"art":ART+"urn_"+str(item["id"])+".svg","preview":true})
    out.append({"title":"Sepultamento","section":"Serviços","body":"Documentação, escolha de caixão, despedida e sepultamento autorizado. Consulte os atendentes.","art":ART+"burial.svg"})
    out.append({"title":"Cremação","section":"Serviços","body":"Serviço condicionado aos documentos, autorizações e condições legais aplicáveis. Operação futura; não contratável nesta edição.","art":ART+"cremation.svg"})
    out.append({"title":"Cerimônias","section":"Serviços","body":"Anselmo organiza flores, iluminação, música, cadeiras e homenagem conforme a família.","art":ART+"ceremony.svg"})
    out.append({"title":"Flores e ornamentação","section":"Serviços","body":"Arranjos escolhidos pela família. Nenhum adicional é imposto.","art":ART+"flowers.svg"})
    out.append({"title":"Serviços opcionais","section":"Serviços","body":"Valores e condições devem ser discriminados antes do aceite.","art":ART+"optional.svg"})
    out.append({"title":"Orçamento personalizado","section":"Serviços","body":"Baltazar: Sou transparente, mas a receita não pode ser invisível! Confirme itens, valores e autorização antes de registrar.","art":ART+"quote.svg"})
    return out

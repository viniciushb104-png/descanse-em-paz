extends RefCounted
## Novas memorias ficcionais, independentes das falas e pontuacoes originais.
## O cliente vivo nao e a pessoa homenageada.
const STORIES := {
    "tutorial_b13":{"name":"Ernesto Vale","sprite":"ernesto_vale","memory":"Ernesto era relojoeiro em Santa Mortalha. Gostava de ouvir o sino da capela no fim do expediente.","attire":"Traje cinza discreto, camisa clara e mãos repousadas.","family":"Queremos apenas um momento tranquilo para lembrar dele.","goodbye":"Que os ponteiros da saudade encontrem um pouco de repouso."},
    "case_1":{"name":"Artur","sprite":"artur_jardineiro","memory":"Artur, irmão do Sr. Afonso, cultivava lírios e dividia mudas com os vizinhos. Preferia a simplicidade.","attire":"Colete verde-oliva e camisa creme; um lírio como homenagem.","family":"Meu irmão gostava de madeira e flores. Não precisava de nada chamativo. Mostre as opções simples, por favor.","goodbye":"Na primavera vamos plantar os lírios de que ele tanto gostava."},
    "case_5":{"name":"Rosa","sprite":"rosa_costureira","memory":"Rosa, tia do Sr. Gil, costurava para os vizinhos e guardava cartas de família em uma caixa de madeira.","attire":"Vestido azul-marinho discreto, pequeno broche de tecido.","family":"Minha tia valorizava o cuidado, não o luxo. Temos um limite de dinheiro e queremos respeitá-lo.","goodbye":"Vou guardar a lembrança dela em cada carta que ainda escrevemos."},
    "case_16":{"name":"Augusto","sprite":"augusto_musico","memory":"Augusto, tio do Sr. Benício, tocava violino nas reuniões da família e conservava um relógio de bolso como recordação.","attire":"Traje clássico vinho escuro e camisa clara.","family":"Meu tio gostava de coisas bem feitas, sem ostentação. Quero comparar acabamento, preço e entrega, sem surpresas.","goodbye":"O violino dele ficará em casa, para que a música continue fazendo parte da família."}
}

static func story(order_id: String) -> Dictionary:
    return STORIES.get(order_id,{}).duplicate(true)

static func response(case_id: int, model: String) -> String:
    match case_id:
        1:
            if model=="serenidade":
                return "A madeira simples combina com meu irmão. Prefiro deixar o restante para a família."
            return "A madeira clara me lembra as caixas de mudas dele. Quero confirmar esse valor antes de decidir."
        5:
            return "Esse modelo cabe no nosso orçamento. Obrigado por não confundir carinho com preço."
        16:
            if model in ["serenidade","ultimo_suspiro","descanso_eterno"]:
                return "Esse acabamento discreto combina com meu tio. Confirme o prazo e o valor."
            return "Gostei do acabamento, mas não preciso de luxo. Quero conferir o preço e comparar com os modelos simples antes de confirmar."
    return "Vamos conferir o modelo e o valor antes de confirmar."

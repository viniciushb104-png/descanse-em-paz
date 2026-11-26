extends RefCounted
## Ambientes independentes de Santa Mortalha.
const SIZE := Vector2(1152,648)
const ENTRY := Vector2(575,478)
const ROOMS = {
 "office":{"title":"ESCRITORIO ADMINISTRATIVO","agent":"Baltazar, o contador fantasma","description":"Papeis, registros, Arquivo Legal e as eternas planilhas.","theme":"office"},
 "maintenance":{"title":"OFICINA DE SANTA MORTALHA","agent":"Seu Osvaldo","description":"Bancadas, ferramentas e manutencao preventiva.","theme":"maintenance"},
 "hospital":{"title":"HOSPITAL SANTA ULTIMA HORA","agent":"Dra. Penelope","description":"Acolhimento e documentacao de saude.","theme":"hospital"},
 "garagem":{"title":"GARAGEM DA ULTIMA VIAGEM","agent":"Arquimedes","description":"Revisao da frota e rotas.","theme":"garage"},
 "preparo":{"title":"SALA DE CONSERVACAO","agent":"Dona Clotilde","description":"Controle sanitario e residuos; nenhuma tecnica clinica.","theme":"lab"},
 "crematorio":{"title":"CREMATORIO CINZAS & CIA","agent":"Seu Cinerio","description":"Sala de orientacao e controle documental.","theme":"crematory"},
 "fiscalizacao":{"title":"POSTO DE FISCALIZACAO","agent":"Marcela Meia-Noite","description":"Licencas e boas praticas.","theme":"inspection"},
 "funeraria":{"title":"CASA FUNERARIA UMBRA","agent":"Madame Amalia","description":"Atendimento humanizado e orcamentos transparentes.","theme":"parlor"},
 "chapel":{"title":"CAPELA DO ULTIMO ADEUS","agent":"Anselmo Velario","description":"Um lugar de memoria e despedida.","theme":"chapel"},
 "fornecedor":{"title":"EMPORIO DAS ULTIMAS COISAS","agent":"Gervasio Caixote","description":"Caixoes, urnas cinerarias e notas de estoque.","theme":"supply"}
}
# Mesa independente dos balcoes e das missoes; sempre disponivel.
static func magazine_table(key: String) -> Rect2:
    match key:
        "office": return Rect2(346,198,120,62)
        "funeraria","fornecedor": return Rect2(640,416,120,62)
    return Rect2()

static func magazine_point(key: String) -> Vector2:
    var table := magazine_table(key)
    return Vector2(table.get_center().x,table.end.y+18)

static func points(key: String) -> Array:
    if not ROOMS.has(key):
        return []
    if key=="chapel":
        return [{"id":"chapel_attendant","name":"Anselmo Velario","p":Vector2(155,390)},{"id":"exit","name":"Sair da capela","p":Vector2(575,556)},{"id":"wake_flowers","name":"Arranjos de flores","p":Vector2(275,245)},{"id":"wake_light","name":"Iluminacao","p":Vector2(875,245)},{"id":"wake_music","name":"Musica","p":Vector2(970,430)},{"id":"wake_chairs","name":"Bancos e cadeiras","p":Vector2(360,420)},{"id":"wake_tribute","name":"Mesa de homenagem","p":Vector2(575,220)},{"id":"wake_family","name":"Visitante ou familia","p":Vector2(800,485)},{"id":"wake_coffin","name":"Caixao e despedida","p":Vector2(575,435)}]
    var result := [
        {"id":"exit","name":"Voltar para a rua","p":Vector2(575,556)},
        {"id":"agent","name":str(ROOMS[key]["agent"]),"p":Vector2(294,373)},
        {"id":"client","name":"Cliente em atendimento","p":Vector2(818,374)},
        {"id":"catalog","name":"Arquivo Legal" if key=="office" else "Catalogo e informacoes","p":Vector2(970,450) if key=="office" else Vector2(971,263)},
        {"id":"board","name":"Livro de ocorrencias","p":Vector2(214,218)}
    ]
    if key=="fornecedor":
        result.append({"id":"violeta","name":"Balcão de urnas","p":Vector2(570,330)})
    if magazine_table(key).has_area():
        result.append({"id":"magazine_table","name":"Mesa de revistas — leitura livre","p":magazine_point(key)})
    return result

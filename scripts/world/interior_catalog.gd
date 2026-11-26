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
static func points(key: String) -> Array:
    if not ROOMS.has(key):
        return []
    if key=="chapel":
        return [{"id":"chapel_attendant","name":"Anselmo Velario","p":Vector2(155,390)},{"id":"exit","name":"Sair da capela","p":Vector2(575,556)},{"id":"wake_flowers","name":"Arranjos de flores","p":Vector2(275,245)},{"id":"wake_light","name":"Iluminacao","p":Vector2(875,245)},{"id":"wake_music","name":"Musica","p":Vector2(970,430)},{"id":"wake_chairs","name":"Bancos e cadeiras","p":Vector2(360,420)},{"id":"wake_tribute","name":"Mesa de homenagem","p":Vector2(575,220)},{"id":"wake_family","name":"Visitante ou familia","p":Vector2(800,485)},{"id":"wake_coffin","name":"Caixao e despedida","p":Vector2(575,435)}]
    return [
        {"id":"exit","name":"Voltar para a rua","p":Vector2(575,556)},
        {"id":"agent","name":str(ROOMS[key]["agent"]),"p":Vector2(294,373)},
        {"id":"client","name":"Cliente em atendimento","p":Vector2(818,374)},
        {"id":"catalog","name":"Arquivo Legal" if key=="office" else "Catalogo e informacoes","p":Vector2(970,450) if key=="office" else Vector2(971,263)},
        {"id":"board","name":"Livro de ocorrencias","p":Vector2(214,218)}
    ]

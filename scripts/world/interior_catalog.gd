extends RefCounted
## Ambientes independentes de Santa Mortalha.
const SIZE := Vector2(1152,648)
const ENTRY := Vector2(575,508)
const ROOMS = {
 "office":{"title":"ESCRITORIO ADMINISTRATIVO","agent":"Baltazar","description":"Papeis, registros e as eternas planilhas.","theme":"office"},
 "maintenance":{"title":"OFICINA DE SANTA MORTALHA","agent":"Seu Osvaldo","description":"Bancadas, ferramentas e manutencao preventiva.","theme":"maintenance"},
 "hospital":{"title":"HOSPITAL SANTA ULTIMA HORA","agent":"Dra. Penelope","description":"Acolhimento e documentacao de saude.","theme":"hospital"},
 "garagem":{"title":"GARAGEM DA ULTIMA VIAGEM","agent":"Arquimedes","description":"Revisao da frota e rotas.","theme":"garage"},
 "preparo":{"title":"SALA DE CONSERVACAO","agent":"Dona Clotilde","description":"Controle sanitario e residuos; nenhuma tecnica clinica.","theme":"lab"},
 "crematorio":{"title":"CREMATORIO CINZAS & CIA","agent":"Seu Cinerio","description":"Sala de orientacao e controle documental.","theme":"crematory"},
 "biblioteca":{"title":"ARQUIVO LEGAL","agent":"Umbelina","description":"Leis, pastas e carimbos.","theme":"archive"},
 "fiscalizacao":{"title":"POSTO DE FISCALIZACAO","agent":"Marcela Meia-Noite","description":"Licencas e boas praticas.","theme":"inspection"},
 "funeraria":{"title":"CASA FUNERARIA UMBRA","agent":"Madame Amalia","description":"Atendimento humanizado e orcamentos transparentes.","theme":"parlor"},
 "fornecedor":{"title":"EMPORIO DAS ULTIMAS COISAS","agent":"Gervasio Caixote","description":"Caixoes, urnas cinerarias e notas de estoque.","theme":"supply"}
}
static func points(key: String) -> Array:
    if not ROOMS.has(key):
        return []
    return [
        {"id":"exit","name":"Voltar para a rua","p":Vector2(575,556)},
        {"id":"agent","name":str(ROOMS[key]["agent"]),"p":Vector2(294,373)},
        {"id":"client","name":"Cliente em atendimento","p":Vector2(818,374)},
        {"id":"catalog","name":"Catalogo e informacoes","p":Vector2(971,263)},
        {"id":"board","name":"Livro de ocorrencias","p":Vector2(214,218)}
    ]

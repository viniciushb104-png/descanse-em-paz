extends RefCounted
## Elenco visual com uma identidade por personagem e retratos individuais opcionais.
## Para adicionar arte definitiva: assets/portraits/<id>.png (PNG transparente).
## Sem dependencia de fontes externas ou personagens gerados em tempo de execucao.
const CHARACTERS = {
  "baltazar": {
    "name": "Baltazar",
    "role": "Contador fantasma",
    "profile": "conta",
    "accent": "#72dde1",
    "shade": "#164a58",
    "motif": "ledger",
    "accessory": "ghost",
    "aliases": [
      "Baltazar",
      "Baltazar, o contador fantasma"
    ],
    "portrait": "res://assets/portraits/baltazar.png"
  },
  "osvaldo": {
    "name": "Seu Osvaldo",
    "role": "Coveiro de Santa Mortalha",
    "profile": "coveiro",
    "accent": "#d3a16f",
    "shade": "#46342a",
    "motif": "spade",
    "accessory": "worker",
    "aliases": [
      "Seu Osvaldo",
      "Osvaldo"
    ],
    "portrait": "res://assets/portraits/osvaldo.png"
  },
  "penelope": {
    "name": "Dra. Penélope Alvorada",
    "role": "Hospital Santa Última Hora",
    "profile": "medica",
    "accent": "#9bcbd6",
    "shade": "#394b66",
    "motif": "cross",
    "accessory": "doctor",
    "aliases": [
      "Dra. Penelope",
      "Dra. Penélope",
      "Dra. Penelope Alvorada",
      "Dra. Penélope Alvorada"
    ],
    "portrait": "res://assets/portraits/penelope.png"
  },
  "arquimedes": {
    "name": "Arquimedes Ossário",
    "role": "Garagem da Última Viagem",
    "profile": "motorista",
    "accent": "#c49d76",
    "shade": "#59434a",
    "motif": "wheel",
    "accessory": "driver",
    "aliases": [
      "Arquimedes",
      "Arquimedes Ossario",
      "Arquimedes Ossário"
    ],
    "portrait": "res://assets/portraits/arquimedes.png"
  },
  "clotilde": {
    "name": "Dona Clotilde Eternélia",
    "role": "Sala de Conservação",
    "profile": "tecnica",
    "accent": "#c9a5ba",
    "shade": "#624257",
    "motif": "bottle",
    "accessory": "scientist",
    "aliases": [
      "Dona Clotilde",
      "Dona Clotilde Eternelia",
      "Dona Clotilde Eternélia",
      "Clotilde"
    ],
    "portrait": "res://assets/portraits/clotilde.png"
  },
  "cinerio": {
    "name": "Seu Cinério Brasa",
    "role": "Crematório Cinzas & Cia",
    "profile": "crematorio",
    "accent": "#e6a96d",
    "shade": "#693d35",
    "motif": "flame",
    "accessory": "gentleman",
    "aliases": [
      "Seu Cinerio",
      "Seu Cinério",
      "Seu Cinerio Brasa",
      "Seu Cinério Brasa"
    ],
    "portrait": "res://assets/portraits/cinerio.png"
  },
  "marcela": {
    "name": "Marcela Meia-Noite",
    "role": "Fiscalização ambiental",
    "profile": "fiscal",
    "accent": "#b0c0cf",
    "shade": "#3f5360",
    "motif": "scales",
    "accessory": "inspector",
    "aliases": [
      "Marcela Meia-Noite",
      "Fiscal Marcela",
      "Marcela"
    ],
    "portrait": "res://assets/portraits/marcela.png"
  },
  "umbelina": {
    "name": "Umbelina",
    "role": "Arquivo Legal",
    "profile": "arquivista",
    "accent": "#c7b4db",
    "shade": "#4d4566",
    "motif": "book",
    "accessory": "scholar",
    "aliases": [
      "Umbelina",
      "Arquivista Umbelina"
    ],
    "portrait": "res://assets/portraits/umbelina.png"
  },
  "amalia": {
    "name": "Madame Amália Umbra",
    "role": "Casa Funerária Umbra",
    "profile": "diretora",
    "accent": "#ebadc4",
    "shade": "#653b52",
    "motif": "rose",
    "accessory": "lady",
    "aliases": [
      "Madame Amalia",
      "Madame Amália",
      "Madame Amalia Umbra",
      "Madame Amália Umbra"
    ],
    "portrait": "res://assets/portraits/amalia.png"
  },
  "gervasio": {
    "name": "Gervásio Caixote",
    "role": "Empório das Últimas Coisas",
    "profile": "fornecedor",
    "accent": "#d1b482",
    "shade": "#6f5540",
    "motif": "box",
    "accessory": "merchant",
    "aliases": [
      "Gervasio",
      "Gervásio",
      "Gervasio Caixote",
      "Gervásio Caixote"
    ],
    "portrait": "res://assets/portraits/gervasio.png"
  },
  "client_01": {
    "name": "Sr. Afonso",
    "role": "Atendimento 01",
    "profile": "calmo",
    "accent": "#dfb5a0",
    "shade": "#604757",
    "motif": "flower",
    "accessory": "none",
    "aliases": [
      "Sr. Afonso"
    ],
    "portrait": "res://assets/portraits/client_01.png"
  },
  "client_02": {
    "name": "Dona Ester",
    "role": "Atendimento 02",
    "profile": "sofredor",
    "accent": "#a2c0de",
    "shade": "#3f5367",
    "motif": "candle",
    "accessory": "scarf",
    "aliases": [
      "Dona Ester"
    ],
    "portrait": "res://assets/portraits/client_02.png"
  },
  "client_03": {
    "name": "Sra. Violeta",
    "role": "Atendimento 03",
    "profile": "estranho",
    "accent": "#e8bd72",
    "shade": "#665070",
    "motif": "pumpkin",
    "accessory": "spectacles",
    "aliases": [
      "Sra. Violeta"
    ],
    "portrait": "res://assets/portraits/client_03.png"
  },
  "client_04": {
    "name": "Sr. Leopoldo",
    "role": "Atendimento 04",
    "profile": "suspeito",
    "accent": "#b7bdcc",
    "shade": "#3b4755",
    "motif": "key",
    "accessory": "hood",
    "aliases": [
      "Sr. Leopoldo"
    ],
    "portrait": "res://assets/portraits/client_04.png"
  },
  "client_05": {
    "name": "Sr. Gil",
    "role": "Atendimento 05",
    "profile": "economico",
    "accent": "#afc1a0",
    "shade": "#4f5d49",
    "motif": "coin",
    "accessory": "none",
    "aliases": [
      "Sr. Gil"
    ],
    "portrait": "res://assets/portraits/client_05.png"
  },
  "client_06": {
    "name": "Sra. Palmira",
    "role": "Atendimento 06",
    "profile": "confuso",
    "accent": "#c3a4c6",
    "shade": "#554666",
    "motif": "book",
    "accessory": "none",
    "aliases": [
      "Sra. Palmira"
    ],
    "portrait": "res://assets/portraits/client_06.png"
  },
  "client_07": {
    "name": "Sr. Tadeu",
    "role": "Atendimento 07",
    "profile": "apressado",
    "accent": "#d4aa8e",
    "shade": "#665042",
    "motif": "clock",
    "accessory": "hat",
    "aliases": [
      "Sr. Tadeu"
    ],
    "portrait": "res://assets/portraits/client_07.png"
  },
  "client_08": {
    "name": "Dona Aurea",
    "role": "Atendimento 08",
    "profile": "profissional",
    "accent": "#b8b8cf",
    "shade": "#4a496c",
    "motif": "star",
    "accessory": "tie",
    "aliases": [
      "Dona Aurea"
    ],
    "portrait": "res://assets/portraits/client_08.png"
  },
  "client_09": {
    "name": "Familia de Helena",
    "role": "Atendimento 09",
    "profile": "sofredor",
    "accent": "#cbaac0",
    "shade": "#5d4058",
    "motif": "rose",
    "accessory": "scarf",
    "aliases": [
      "Familia de Helena"
    ],
    "portrait": "res://assets/portraits/client_09.png"
  },
  "client_10": {
    "name": "Sr. Noctilio",
    "role": "Atendimento 10",
    "profile": "suspeito",
    "accent": "#c6af95",
    "shade": "#4d4a54",
    "motif": "scales",
    "accessory": "hood",
    "aliases": [
      "Sr. Noctilio"
    ],
    "portrait": "res://assets/portraits/client_10.png"
  },
  "client_11": {
    "name": "Sra. Agatha",
    "role": "Atendimento 11",
    "profile": "curioso",
    "accent": "#9cbed0",
    "shade": "#46596a",
    "motif": "moon",
    "accessory": "none",
    "aliases": [
      "Sra. Agatha"
    ],
    "portrait": "res://assets/portraits/client_11.png"
  },
  "client_12": {
    "name": "Dona Hortensia",
    "role": "Atendimento 12",
    "profile": "estranho",
    "accent": "#d7abc8",
    "shade": "#754b5a",
    "motif": "flower",
    "accessory": "spectacles",
    "aliases": [
      "Dona Hortensia"
    ],
    "portrait": "res://assets/portraits/client_12.png"
  },
  "client_13": {
    "name": "Sr. Valdemar",
    "role": "Atendimento 13",
    "profile": "fornecedor",
    "accent": "#c1b59d",
    "shade": "#575440",
    "motif": "box",
    "accessory": "none",
    "aliases": [
      "Sr. Valdemar"
    ],
    "portrait": "res://assets/portraits/client_13.png"
  },
  "client_14": {
    "name": "Fiscal Marcela",
    "role": "Atendimento 14",
    "profile": "fiscal",
    "accent": "#bac7b6",
    "shade": "#475e5b",
    "motif": "leaf",
    "accessory": "glasses",
    "aliases": [
      "Fiscal Marcela"
    ],
    "portrait": "res://assets/portraits/client_14.png"
  },
  "client_15": {
    "name": "Motorista Tiburcio",
    "role": "Atendimento 15",
    "profile": "apressado",
    "accent": "#c5ac8b",
    "shade": "#56505f",
    "motif": "wheel",
    "accessory": "hat",
    "aliases": [
      "Motorista Tiburcio"
    ],
    "portrait": "res://assets/portraits/client_15.png"
  },
  "client_16": {
    "name": "Sr. Benicio",
    "role": "Atendimento 16",
    "profile": "calmo",
    "accent": "#d9b9a3",
    "shade": "#694b48",
    "motif": "lamp",
    "accessory": "none",
    "aliases": [
      "Sr. Benicio"
    ],
    "portrait": "res://assets/portraits/client_16.png"
  },
  "client_17": {
    "name": "Sra. Mirtes",
    "role": "Atendimento 17",
    "profile": "reservado",
    "accent": "#bea6c6",
    "shade": "#554968",
    "motif": "key",
    "accessory": "none",
    "aliases": [
      "Sra. Mirtes"
    ],
    "portrait": "res://assets/portraits/client_17.png"
  },
  "client_18": {
    "name": "Sr. Inacio",
    "role": "Atendimento 18",
    "profile": "confuso",
    "accent": "#c2c9af",
    "shade": "#545f57",
    "motif": "book",
    "accessory": "none",
    "aliases": [
      "Sr. Inacio"
    ],
    "portrait": "res://assets/portraits/client_18.png"
  },
  "client_19": {
    "name": "Dona Lucinda",
    "role": "Atendimento 19",
    "profile": "suspeito",
    "accent": "#d7baac",
    "shade": "#61535f",
    "motif": "candle",
    "accessory": "hood",
    "aliases": [
      "Dona Lucinda"
    ],
    "portrait": "res://assets/portraits/client_19.png"
  },
  "client_20": {
    "name": "Familia de Aurora",
    "role": "Atendimento 20",
    "profile": "sofredor",
    "accent": "#a9c0d4",
    "shade": "#3d5368",
    "motif": "star",
    "accessory": "scarf",
    "aliases": [
      "Familia de Aurora"
    ],
    "portrait": "res://assets/portraits/client_20.png"
  },
  "support_01": {
    "name": "Irmã de Afonso",
    "role": "Participante da conversa",
    "profile": "calmo",
    "accent": "#b8b8cf",
    "shade": "#4a496c",
    "motif": "star",
    "accessory": "hat",
    "aliases": [
      "Irmã de Afonso"
    ],
    "portrait": "res://assets/portraits/support_01.png"
  },
  "support_02": {
    "name": "Filha de Ester",
    "role": "Participante da conversa",
    "profile": "sofredor",
    "accent": "#cbaac0",
    "shade": "#5d4058",
    "motif": "rose",
    "accessory": "scarf",
    "aliases": [
      "Filha de Ester"
    ],
    "portrait": "res://assets/portraits/support_02.png"
  },
  "support_04": {
    "name": "Prima de Leopoldo",
    "role": "Participante da conversa",
    "profile": "reservado",
    "accent": "#9cbed0",
    "shade": "#46596a",
    "motif": "moon",
    "accessory": "none",
    "aliases": [
      "Prima de Leopoldo"
    ],
    "portrait": "res://assets/portraits/support_04.png"
  },
  "support_05": {
    "name": "Irmão de Gil",
    "role": "Participante da conversa",
    "profile": "economico",
    "accent": "#d7abc8",
    "shade": "#754b5a",
    "motif": "flower",
    "accessory": "hat",
    "aliases": [
      "Irmão de Gil"
    ],
    "portrait": "res://assets/portraits/support_05.png"
  },
  "support_06": {
    "name": "Funcionária do hospital",
    "role": "Participante da conversa",
    "profile": "profissional",
    "accent": "#c1b59d",
    "shade": "#575440",
    "motif": "box",
    "accessory": "scarf",
    "aliases": [
      "Funcionária do hospital"
    ],
    "portrait": "res://assets/portraits/support_06.png"
  },
  "support_08": {
    "name": "Assistente de estoque",
    "role": "Participante da conversa",
    "profile": "profissional",
    "accent": "#c5ac8b",
    "shade": "#56505f",
    "motif": "wheel",
    "accessory": "none",
    "aliases": [
      "Assistente de estoque"
    ],
    "portrait": "res://assets/portraits/support_08.png"
  },
  "support_11": {
    "name": "Engenheira do cemitério",
    "role": "Participante da conversa",
    "profile": "profissional",
    "accent": "#c2c9af",
    "shade": "#545f57",
    "motif": "book",
    "accessory": "spectacles",
    "aliases": [
      "Engenheira do cemitério"
    ],
    "portrait": "res://assets/portraits/support_11.png"
  },
  "support_12": {
    "name": "Sobrinha de Hortênsia",
    "role": "Participante da conversa",
    "profile": "calmo",
    "accent": "#d7baac",
    "shade": "#61535f",
    "motif": "candle",
    "accessory": "none",
    "aliases": [
      "Sobrinha de Hortênsia"
    ],
    "portrait": "res://assets/portraits/support_12.png"
  },
  "support_13": {
    "name": "Conferente do Empório",
    "role": "Participante da conversa",
    "profile": "profissional",
    "accent": "#a9c0d4",
    "shade": "#3d5368",
    "motif": "star",
    "accessory": "hat",
    "aliases": [
      "Conferente do Empório"
    ],
    "portrait": "res://assets/portraits/support_13.png"
  },
  "support_14": {
    "name": "Auxiliar ambiental",
    "role": "Participante da conversa",
    "profile": "profissional",
    "accent": "#dfb5a0",
    "shade": "#604757",
    "motif": "flower",
    "accessory": "scarf",
    "aliases": [
      "Auxiliar ambiental"
    ],
    "portrait": "res://assets/portraits/support_14.png"
  },
  "support_15": {
    "name": "Mecânico da frota",
    "role": "Participante da conversa",
    "profile": "profissional",
    "accent": "#a2c0de",
    "shade": "#3f5367",
    "motif": "candle",
    "accessory": "spectacles",
    "aliases": [
      "Mecânico da frota"
    ],
    "portrait": "res://assets/portraits/support_15.png"
  },
  "support_16": {
    "name": "Vendedor da funerária",
    "role": "Participante da conversa",
    "profile": "profissional",
    "accent": "#e8bd72",
    "shade": "#665070",
    "motif": "pumpkin",
    "accessory": "none",
    "aliases": [
      "Vendedor da funerária"
    ],
    "portrait": "res://assets/portraits/support_16.png"
  },
  "support_17": {
    "name": "Funcionária do arquivo",
    "role": "Participante da conversa",
    "profile": "reservado",
    "accent": "#b7bdcc",
    "shade": "#3b4755",
    "motif": "key",
    "accessory": "hat",
    "aliases": [
      "Funcionária do arquivo"
    ],
    "portrait": "res://assets/portraits/support_17.png"
  },
  "support_18": {
    "name": "Irmão de Inácio",
    "role": "Participante da conversa",
    "profile": "confuso",
    "accent": "#afc1a0",
    "shade": "#4f5d49",
    "motif": "coin",
    "accessory": "scarf",
    "aliases": [
      "Irmão de Inácio"
    ],
    "portrait": "res://assets/portraits/support_18.png"
  },
  "support_19": {
    "name": "Atendente do crematório",
    "role": "Participante da conversa",
    "profile": "profissional",
    "accent": "#c3a4c6",
    "shade": "#554666",
    "motif": "book",
    "accessory": "spectacles",
    "aliases": [
      "Atendente do crematório"
    ],
    "portrait": "res://assets/portraits/support_19.png"
  },
  "support_20": {
    "name": "Irmã de Aurora",
    "role": "Participante da conversa",
    "profile": "sofredor",
    "accent": "#d4aa8e",
    "shade": "#665042",
    "motif": "clock",
    "accessory": "none",
    "aliases": [
      "Irmã de Aurora"
    ],
    "portrait": "res://assets/portraits/support_20.png"
  }
}

static func resolve(speaker: String) -> Dictionary:
    var key: String = speaker.strip_edges().to_lower()
    for identity in CHARACTERS.keys():
        var entry: Dictionary = CHARACTERS[identity]
        for candidate in entry["aliases"]:
            var alias: String = str(candidate).to_lower()
            if key == alias or key.begins_with(alias + ",") or key.begins_with(alias + " -") or key.begins_with(alias + " |"):
                var found: Dictionary = entry.duplicate(true)
                found["id"] = str(identity)
                return found
    return {}

static func by_id(identity: String) -> Dictionary:
    if not CHARACTERS.has(identity):
        return {}
    var result: Dictionary = CHARACTERS[identity].duplicate(true)
    result["id"] = identity
    return result

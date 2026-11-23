extends RefCounted
## Campanha paralela: 20 situacoes humanas para praticar atendimento.
## Nomes e cenarios sao ficticios; as opcoes certas mostram diretrizes gerais.
const CASES = [
  {
    "id": 1,
    "profile": "calmo",
    "room": "funeraria",
    "client": "Sr. Afonso",
    "context": "Uma familia deseja uma despedida simples, sem itens extras.",
    "best": "Apresentar opcoes e precos claros.",
    "bad": "Empurrar o plano mais caro sem explicar.",
    "lesson": "valores",
    "reward": 240,
    "stock": "caixao"
  },
  {
    "id": 2,
    "profile": "sofredor",
    "room": "funeraria",
    "client": "Dona Ester",
    "context": "A cliente esta em luto e nao consegue decidir imediatamente.",
    "best": "Dar tempo, oferecer informacoes objetivas e nao pressionar.",
    "bad": "Apressar a assinatura antes de ela compreender.",
    "lesson": "valores",
    "reward": 0,
    "stock": ""
  },
  {
    "id": 3,
    "profile": "estranho",
    "room": "fornecedor",
    "client": "Sra. Violeta",
    "context": "Uma cliente deseja uma urna cineraria decorativa de abobora para uso futuro.",
    "best": "Mostrar opcoes e explicar que a escolha nao dispensa requisitos da cremacao.",
    "bad": "Prometer uma cremacao imediata, sem documentos.",
    "lesson": "cremacao",
    "reward": 75,
    "stock": ""
  },
  {
    "id": 4,
    "profile": "suspeito",
    "room": "office",
    "client": "Sr. Leopoldo",
    "context": "Uma pessoa pede para alterar um cadastro de jazigo sem demonstrar legitimidade.",
    "best": "Conferir documentos e direitos de uso com cautela, sem acusacoes.",
    "bad": "Modificar o cadastro somente por insistencia verbal.",
    "lesson": "registro",
    "reward": 0,
    "stock": ""
  },
  {
    "id": 5,
    "profile": "economico",
    "room": "funeraria",
    "client": "Sr. Gil",
    "context": "O orcamento familiar e pequeno e ele teme servicos obrigatorios inventados.",
    "best": "Detalhar alternativas e itens opcionais sem constrangimento.",
    "bad": "Condicionar um item essencial a decoracao luxuosa.",
    "lesson": "valores",
    "reward": 180,
    "stock": "caixao"
  },
  {
    "id": 6,
    "profile": "confuso",
    "room": "hospital",
    "client": "Sra. Palmira",
    "context": "Uma pessoa recebeu uma Declaracao de Obito e pergunta se aquilo ja e certidao.",
    "best": "Explicar a diferenca e orientar o Registro Civil conforme as regras.",
    "bad": "Dizer que todo o processo acabou no hospital.",
    "lesson": "registro",
    "reward": 0,
    "stock": ""
  },
  {
    "id": 7,
    "profile": "apressado",
    "room": "garagem",
    "client": "Sr. Tadeu",
    "context": "Um cliente exige saida imediata apesar de manutencao pendente no veiculo.",
    "best": "Conferir seguranca e providenciar alternativa regular.",
    "bad": "Liberar veiculo com defeito por pressao do cliente.",
    "lesson": "transporte",
    "reward": 40,
    "stock": ""
  },
  {
    "id": 8,
    "profile": "profissional",
    "room": "fornecedor",
    "client": "Dona Aurea",
    "context": "O estoque de caixoes precisa de reposicao. O fornecedor apresenta um lote barato sem nota.",
    "best": "Comprar com identificacao, nota e conferindo as caracteristicas do produto.",
    "bad": "Aceitar lote sem registro de procedencia.",
    "lesson": "valores",
    "reward": 60,
    "stock": "caixao"
  },
  {
    "id": 9,
    "profile": "sofredor",
    "room": "preparo",
    "client": "Familia de Helena",
    "context": "A familia pergunta se conservacao e obrigatoria em qualquer circunstancia.",
    "best": "Informar criterios e exigencias aplicaveis; consultar profissionais habilitados.",
    "bad": "Afirmar obrigatoriedade universal para vender o procedimento.",
    "lesson": "preparo",
    "reward": 0,
    "stock": ""
  },
  {
    "id": 10,
    "profile": "suspeito",
    "room": "crematorio",
    "client": "Sr. Noctilio",
    "context": "Caso declarado de morte violenta chega para solicitacao de cremacao sem autorizacao judicial.",
    "best": "Suspender a etapa e orientar sobre a autorizacao da autoridade judicial.",
    "bad": "Realizar a cremacao apesar da falta de autorizacao.",
    "lesson": "cremacao",
    "reward": 0,
    "stock": ""
  },
  {
    "id": 11,
    "profile": "curioso",
    "room": "biblioteca",
    "client": "Sra. Agatha",
    "context": "Uma estudante pergunta por que cemiterios precisam observar o terreno.",
    "best": "Explicar licenciamento ambiental e encaminhar a fonte oficial.",
    "bad": "Dizer que solo e agua nunca importam em cemiterios.",
    "lesson": "ambiente",
    "reward": 0,
    "stock": ""
  },
  {
    "id": 12,
    "profile": "estranho",
    "room": "funeraria",
    "client": "Dona Hortensia",
    "context": "Uma colecionadora quer urna cineraria roxa com estrelas, respeitando um desejo familiar.",
    "best": "Apresentar catalogo, confirmar preferencia e condicoes reais.",
    "bad": "Fazer piadas com a familia e vender sem explicar precos.",
    "lesson": "valores",
    "reward": 165,
    "stock": "urna"
  },
  {
    "id": 13,
    "profile": "fornecedor",
    "room": "fornecedor",
    "client": "Sr. Valdemar",
    "context": "Um lote de urnas chega com tampas danificadas e divergencia na nota.",
    "best": "Registrar nao conformidade e pedir substituicao antes de colocar a venda.",
    "bad": "Colocar o material danificado no balcao assim mesmo.",
    "lesson": "valores",
    "reward": 20,
    "stock": ""
  },
  {
    "id": 14,
    "profile": "fiscal",
    "room": "fiscalizacao",
    "client": "Fiscal Marcela",
    "context": "O local recebeu observacao sobre gestao de residuos e treinamento.",
    "best": "Revisar o PGRSS aplicavel e registrar capacitao e correcoes.",
    "bad": "Ignorar notificacao e esconder os registros.",
    "lesson": "residuos",
    "reward": 0,
    "stock": ""
  },
  {
    "id": 15,
    "profile": "apressado",
    "room": "garagem",
    "client": "Motorista Tiburcio",
    "context": "O carro funerario apresenta um problema no freio antes de uma viagem.",
    "best": "Retirar o veiculo de servico e planejar outro trajeto seguro.",
    "bad": "Mandar seguir viagem sem revisao.",
    "lesson": "transporte",
    "reward": 0,
    "stock": ""
  },
  {
    "id": 16,
    "profile": "calmo",
    "room": "funeraria",
    "client": "Sr. Benicio",
    "context": "Um cliente solicita descricao detalhada do caixao e custos de entrega.",
    "best": "Mostrar caracteristicas, valores e obter concordancia.",
    "bad": "Inserir taxas extras so apos o pagamento.",
    "lesson": "valores",
    "reward": 215,
    "stock": "caixao"
  },
  {
    "id": 17,
    "profile": "reservado",
    "room": "office",
    "client": "Sra. Mirtes",
    "context": "Uma pessoa pede dados pessoais de um cliente anterior sem demonstrar autorizacao.",
    "best": "Proteger os registros e solicitar fundamento e autorizacao adequados.",
    "bad": "Entregar o cadastro porque a pessoa parece confiavel.",
    "lesson": "valores",
    "reward": 0,
    "stock": ""
  },
  {
    "id": 18,
    "profile": "confuso",
    "room": "hospital",
    "client": "Sr. Inacio",
    "context": "Um parente nao sabe a quem recorrer para regularizar os documentos.",
    "best": "Acolher e explicar papeis do hospital, Registro Civil e funeraria.",
    "bad": "Prometer que o hospital substituira o registro civil.",
    "lesson": "registro",
    "reward": 0,
    "stock": ""
  },
  {
    "id": 19,
    "profile": "suspeito",
    "room": "crematorio",
    "client": "Dona Lucinda",
    "context": "Uma familia pede cremação e nao apresentou documentos suficientes nem a manifestacao exigida.",
    "best": "Conferir os requisitos da Lei de Registros Publicos e orientar sem executar.",
    "bad": "Aceitar uma promessa verbal como se bastasse sempre.",
    "lesson": "cremacao",
    "reward": 0,
    "stock": ""
  },
  {
    "id": 20,
    "profile": "sofredor",
    "room": "funeraria",
    "client": "Familia de Aurora",
    "context": "A familia quer despedida simples, urnas/custos discriminados e um momento de privacidade.",
    "best": "Organizar atendimento sensivel, com escolhas livres e comprovante.",
    "bad": "Forcar a compra de flores e fotografias para liberar o atendimento.",
    "lesson": "valores",
    "reward": 180,
    "stock": "urna"
  }
]
static func total() -> int:
    return CASES.size()
static func active(index: int) -> Dictionary:
    if index < 0 or index >= CASES.size():
        return {}
    return CASES[index]

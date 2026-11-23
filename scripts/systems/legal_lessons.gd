extends RefCounted
## Conteudo educativo brasileiro. Conferencia em 23-11-2026.
## Normas municipais, estaduais e excecoes precisam de verificacao especifica.
const ITEMS = {
    "registro":{
        "title":"Declaracao x Certidao",
        "body":"A Declaracao de Obito (DO) e documento de saude, em regra emitido por medico; a Certidao de Obito vem do Registro Civil. O art. 77 da Lei 6.015/1973 disciplina documentos para sepultamento e excecoes legais.",
        "source":"Lei 6.015/1973, art. 77; Ministerio da Saude - SIM",
        "url":"https://www.planalto.gov.br/ccivil_03/leis/l6015compilada.htm"
    },
    "cremacao":{
        "title":"Requisitos da cremacao",
        "body":"O art. 77, paragrafo 2, exige considerar vontade manifestada ou interesse de saude publica, atestado firmado por dois medicos ou um medico legista e, para morte violenta, autorizacao da autoridade judiciaria. Regras locais tambem se aplicam.",
        "source":"Lei 6.015/1973, art. 77, paragrafo 2",
        "url":"https://www.planalto.gov.br/ccivil_03/leis/l6015compilada.htm"
    },
    "residuos":{
        "title":"Biosseguranca e residuos",
        "body":"Necroterios, funerarias e atividades de conservacao fazem parte dos setores abrangidos pela RDC Anvisa 222/2018 conforme o enquadramento. Avalie gerenciamento de residuos, equipe, procedimentos e PGRSS aplicavel.",
        "source":"RDC Anvisa 222/2018; CONAMA 358/2005",
        "url":"https://www.gov.br/anvisa/pt-br/assuntos/servicosdesaude/gerenciamento-de-residuos"
    },
    "ambiente":{
        "title":"Licenciamento ambiental",
        "body":"A Resolucao CONAMA 335/2003 e suas alteracoes tratam do licenciamento ambiental de cemiterios. Requisitos do terreno e condicoes ambientais devem ser avaliados com o orgao competente.",
        "source":"CONAMA 335/2003, 368/2006 e 402/2008",
        "url":"https://conama.mma.gov.br/images/conteudo/LivroConama.pdf"
    },
    "transporte":{
        "title":"Transporte e translado",
        "body":"Confira autorizacoes, documentacao, seguranca e normas da jurisdicao aplicavel. A RDC Anvisa 33/2011 trata do controle sanitario do translado em portos, aeroportos e fronteiras, e nao substitui todas as regras locais.",
        "source":"RDC Anvisa 33/2011",
        "url":"https://bvs.saude.gov.br/bvs/saudelegis/anvisa/2011/rdc0033_08_07_2011.html"
    },
    "preparo":{
        "title":"Conservacao e tanatopraxia",
        "body":"O preparo ou conservacao deve observar competencia profissional, supervisao quando exigida, licencas locais, biosseguranca e gerenciamento de residuos. A simulacao nao ensina tecnicas clinicas.",
        "source":"Vigilancia sanitaria local; RDC Anvisa 222/2018",
        "url":"https://www.gov.br/anvisa/pt-br/assuntos/servicosdesaude/gerenciamento-de-residuos"
    },
    "valores":{
        "title":"Orcamento transparente",
        "body":"Separe despesas, tarifas publicas e servicos opcionais; nao condicione atendimento a compras extras. Os valores deste jogo sao inteiramente ficticios. Consulte tambem regras municipais e a defesa do consumidor.",
        "source":"Regulamentos municipais e principios de protecao do consumidor",
        "url":"https://www.planalto.gov.br/ccivil_03/leis/l8078compilado.htm"
    }
}

static func info(id: String) -> String:
    if not ITEMS.has(id):
        return "Assunto ainda nao cadastrado."
    var data: Dictionary = ITEMS[id]
    return str(data["body"]) + "\n\nFonte: " + str(data["source"]) + "\n" + str(data["url"]) + "\n\nVerifique regras locais atualizadas."

extends RefCounted
const ACTIVITIES = {
"memory":{"title":"Memórias de Osvaldo","place":"Cemitério","intro":"Osvaldo misturou as fichas dos jazigos. Encontre os pares antes de arquivar.","lesson":"Identificação e rastreabilidade evitam trocas de jazigos.","mode":"memory","reward":35},
"stock":{"title":"Estoque dos Mortais","place":"Empório","intro":"Organize as entregas no depósito sem bloquear o corredor.","lesson":"Controle de espaço, estoque e circulação segura.","mode":"stock","reward":45},
"finance":{"title":"Baltazar e os Boletos Malditos","place":"Escritório","intro":"Separe os comprovantes de entradas, saídas e cobranças duplicadas.","lesson":"Receita não é lucro; confira documentos antes de pagar.","mode":"sort","reward":50},
"garden":{"title":"Jardim do Último Suspiro","place":"Manutenção","intro":"Percorra o jardim, retire folhas e restaure os caminhos.","lesson":"Conservação de acessos e prevenção de acidentes.","mode":"garden","reward":35},
"ghost":{"title":"Fantasma Fora do Lugar","place":"Cemitério","intro":"Guie o fantasma pelo labirinto até seu jazigo identificado.","lesson":"Localização e sinalização dos setores; fantasia não é procedimento real.","mode":"maze","reward":30},
"flowers":{"title":"Flores para a Eternidade","place":"Funerária","intro":"Monte uma homenagem respeitando a encomenda e o orçamento fictício.","lesson":"Respeito às preferências e transparência de preços.","mode":"flowers","reward":40},
"patrol":{"title":"Plantão da Meia-Noite","place":"Cemitério","intro":"Atravesse o jardim dos sonhos de Baltazar, recolha lanternas e chegue ao portão.","lesson":"Rondas, iluminação e identificação de riscos. A plataforma é uma fantasia.","mode":"platform","reward":50},
"workshop":{"title":"Oficina do Osvaldo","place":"Garagem","intro":"Confira os itens da frota e separe os que exigem manutenção.","lesson":"Inspeção preventiva e retirada de veículos inadequados de circulação.","mode":"sort","reward":45},
"archive":{"title":"O Arquivo dos Esquecidos","place":"Fiscalização / Biblioteca","intro":"Classifique os documentos fictícios antes de liberar qualquer serviço.","lesson":"Documentação, autorização e rastreabilidade; exigências reais variam.","mode":"sort","reward":50}
}
const LOCATIONS = {"ghost":["finance"],"maintenance":["garden","workshop"],"osvaldo":["memory","ghost","patrol"],"garagem":["workshop"],"fornecedor":["stock"],"funeraria":["flowers"],"biblioteca":["archive"],"fiscalizacao":["archive"],"office":["finance"]}

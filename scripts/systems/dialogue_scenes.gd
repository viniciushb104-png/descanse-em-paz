extends RefCounted
## Dialogue writing room: human, layered and informed by Brazilian regulations.
## 20 authored stories; progression 2, 3, 4, 5 beats per chapter group.
## No per-choice color or 'correct' labeling. Humor never at a grieving family's expense.
const STORIES = [
  {
    "voice": "Quero algo simples para meu irmão. Ele dizia que até os morcegos deviam pagar o próprio funeral.",
    "wit": "Os morcegos são opcionais; a transparência do orçamento vem incluída.",
    "plain": "Me conte o que importa para sua família e eu detalho cada serviço.",
    "hasty": "Mostro primeiro nosso pacote padrão para ganhar tempo.",
    "clue": "Vi um valor na vitrine e outro na folha que me entregaram. O que mudou?",
    "check": "Vamos comparar item por item, inclusive o que é opcional.",
    "support": "Posso separar as duas propostas e esclarecer as diferenças antes da escolha.",
    "shortcut": "A vitrine deve estar certa; assine e depois ajustamos.",
    "twist": "Minha irmã prefere uma flor, não um cortejo. O pacote não deixa isso claro.",
    "deep": "Se a flor não virar taxa obrigatória, estaremos florescendo na direção certa.",
    "detail": "Vou registrar a preferência e conferir o que pode ser retirado da proposta.",
    "approx": "Deixo para esclarecer a diferença de serviços depois da assinatura.",
    "pressure": "O atendente anterior disse que a promoção termina hoje. Existe um prazo legal para pensar?",
    "plan": "Sem susto promocional: explico prazos, valores e condições que realmente se aplicam.",
    "alternate": "Verifico validade da oferta e deixo a decisão com a família.",
    "temptation": "Digo que a oferta acaba em minutos, embora eu não tenha confirmado.",
    "last": "Estou pronto, mas queria reler tudo com calma antes de decidir."
  },
  {
    "voice": "Meu marido brincava que, quando morresse, teria finalmente folga dos boletos. Eu não consigo rir agora.",
    "wit": "Não precisamos rir hoje. Os boletos podem esperar enquanto explicamos suas opções.",
    "plain": "Sinto muito. Podemos fazer isso no seu ritmo, sem pressionar decisões.",
    "hasty": "Deixo os formulários aqui e volto com o contrato já preenchido.",
    "clue": "Não sei quem mais deve participar. Minha filha ainda está vindo.",
    "check": "Vamos identificar quem precisa participar e quais escolhas podem aguardar.",
    "support": "Posso organizar por escrito o que já sabemos e esperar sua filha.",
    "shortcut": "É mais rápido pedir que a senhora assine por todos agora.",
    "twist": "Ela disse ao telefone que queria algo diferente do que eu imaginei.",
    "deep": "Parece que a família tem mais de uma voz. Oremos pelo bom senso dos vivos.",
    "detail": "Vamos ouvir as preferências sem criar obrigação de compra.",
    "approx": "Escolho a preferência da primeira pessoa que chegou, para simplificar.",
    "pressure": "Um vizinho disse que só há um tipo de despedida que demonstra amor.",
    "plan": "Explico alternativas sem medir afeto pelo preço do serviço.",
    "alternate": "Ofereço um espaço de conversa entre familiares e descrevo opções sem pressa indevida.",
    "temptation": "Sugiro que um serviço mais caro demonstra respeito maior.",
    "last": "Quero entender os custos, mas não quero sentir que estou comprando sentimentos."
  },
  {
    "voice": "Minha urna precisa parecer uma abóbora. Ainda estou vivíssima; meu médico ficou ofendido com o catálogo.",
    "wit": "Podemos planejar a abóbora, mas a burocracia não pode virar purê.",
    "plain": "Vamos separar a escolha estética do procedimento e de seus requisitos.",
    "hasty": "Reservo a cremação para amanhã sem perguntar mais detalhes.",
    "clue": "Eu queria deixar tudo organizado, não executar nada agora. Isso é possível?",
    "check": "Registramos preferências futuras sem prometer execução automática.",
    "support": "Podemos mostrar modelos e orientar quais documentos verificar no momento apropriado.",
    "shortcut": "Assumo que escolher a urna equivale a autorizar a cremação.",
    "twist": "A família diz que escolher o desenho já resolve toda a documentação.",
    "deep": "Arte na urna é uma escolha; papelada é outra espécie de abóbora.",
    "detail": "Explico os requisitos aplicáveis da cremação sem afirmar que a compra os substitui.",
    "approx": "Deixo a família acreditar que a compra garante o procedimento.",
    "pressure": "O vendedor quer me dar desconto se eu 'fechar o ritual completo' hoje.",
    "plan": "Peço a descrição exata dos itens e o que pode ser adquirido separadamente.",
    "alternate": "Separo os preços do objeto e dos serviços, sem vincular operações futuras.",
    "temptation": "Aproveito o pacote prometendo uma autorização que não conferi.",
    "last": "Então posso escolher uma urna engraçada e, ainda assim, levar a legislação a sério?"
  },
  {
    "voice": "Meu tio dizia que o jazigo era dele. Não trouxe documento; trouxe uma chave enorme e um retrato mal-assombrado.",
    "wit": "Chave abre cadeado; titularidade pede outro tipo de chave: documento.",
    "plain": "Vamos consultar o registro de uso antes de alterar qualquer cadastro.",
    "hasty": "Faço a mudança provisória porque você parece conhecer a família.",
    "clue": "A matrícula antiga tem outro nome. Isso significa que fui enganado?",
    "check": "Vamos conferir a documentação e direitos registrados antes de concluir algo.",
    "support": "Posso explicar quais dados precisamos e como solicitar a verificação.",
    "shortcut": "Riscamos o nome anterior e corrigimos se alguém reclamar.",
    "twist": "Minha prima disse que também tem direitos sobre esse jazigo.",
    "deep": "A família tem mais ramos que nossa árvore torta. Melhor ouvir os documentos.",
    "detail": "Vamos levantar registros e normas locais para orientar quem tem legitimidade.",
    "approx": "Resolvo a disputa escolhendo quem apareceu primeiro no balcão.",
    "pressure": "Se não mudar hoje, ele disse que vai chamar um advogado do além.",
    "plan": "Registro o pedido e explico os limites de decisão da administração.",
    "alternate": "Oriento uma verificação formal, sem alterar dados enquanto houver dúvida.",
    "temptation": "Mudo o cadastro para evitar a reclamação, sem conferir direitos.",
    "last": "Prefiro uma resposta confiável a uma resposta rápida."
  },
  {
    "voice": "O dinheiro está curto. O senhor vende despedidas ou prestações de susto?",
    "wit": "Prometemos separar os sustos da planilha: vamos ver as opções reais.",
    "plain": "Podemos organizar alternativas por valor e indicar itens opcionais.",
    "hasty": "Indico uma opção intermediária antes de conhecer o orçamento.",
    "clue": "No orçamento aparecem flores e música. Achei que fossem obrigatórias.",
    "check": "Vamos distinguir serviço contratado, opção extra e eventual tarifa regulamentada.",
    "support": "Posso revisar cada linha e retirar escolhas não desejadas quando possível.",
    "shortcut": "Não mexo no pacote, porque 'sempre foi assim'.",
    "twist": "Meu irmão quer pagar uma parte, mas gostaria de saber exatamente o que compra.",
    "deep": "Até fantasmas gostam de recibo; vamos dar transparência aos vivos.",
    "detail": "Faço um documento claro com valores, responsáveis e condições.",
    "approx": "Anoto um valor total e prometo detalhar numa próxima visita.",
    "pressure": "Uma pessoa falou que pedir desconto seria falta de respeito.",
    "plan": "Explico que orçamento e respeito não são inimigos.",
    "alternate": "Apresento condições de pagamento sem constranger a família.",
    "temptation": "Apresento itens luxuosos como prova de afeto, apesar do limite informado.",
    "last": "Se eu escolher o serviço mais simples, vocês continuarão me tratando bem?"
  },
  {
    "voice": "Tenho um papel do hospital e três parentes me dando orientações diferentes. Qual deles é o cartório?",
    "wit": "Nenhum parente vira cartório por votação, infelizmente.",
    "plain": "Vamos distinguir a declaração médica do registro civil.",
    "hasty": "Recebo a declaração como prova suficiente para qualquer etapa.",
    "clue": "Aqui diz Declaração de Óbito. Não deveria vir escrito Certidão de Óbito?",
    "check": "Explico quem emite cada documento e os passos de registro aplicáveis.",
    "support": "Posso separar uma lista simples de documentos e encaminhamentos.",
    "shortcut": "Troco o nome no papel e tratamos como certidão.",
    "twist": "Um parente quer marcar o sepultamento antes de confirmar a documentação.",
    "deep": "Nossa agenda sabe esperar; o registro civil não é uma opção decorativa.",
    "detail": "Confiro as condições legais antes de autorizar etapas dependentes do registro.",
    "approx": "Deixo a cerimônia marcada sem verificar o que pode ser realizado.",
    "pressure": "Todos estão cansados. Isso muda as exigências de documentação?",
    "plan": "Acolho a urgência, mas separo o que é possível organizar do que depende de registro.",
    "alternate": "Ajudo a montar uma ordem prática de providências sem improvisar documentos.",
    "temptation": "Digo que o cansaço autoriza pular a etapa documental.",
    "last": "Obrigado. Agora consigo explicar aos outros sem aumentar a confusão."
  },
  {
    "voice": "A família quer sair agora. Meu carro funerário está na revisão; o relógio me persegue.",
    "wit": "O relógio é cruel; o freio ruim costuma ser ainda mais.",
    "plain": "Vamos checar a frota disponível e combinar uma alternativa segura.",
    "hasty": "Prometo um horário sem consultar o mecânico.",
    "clue": "Há outra viatura, mas não sei se está pronta. O que eu digo à família?",
    "check": "Verifico condição do veículo e regras aplicáveis antes de confirmar.",
    "support": "Informo um prazo realista e ofereço nova atualização.",
    "shortcut": "Libero a viatura em revisão porque o atraso custa reputação.",
    "twist": "O deslocamento atravessa uma fronteira; dizem que é igual a sair da garagem.",
    "deep": "Até carro assombrado precisa de documentos para cruzar certas fronteiras.",
    "detail": "Confiro exigências específicas do percurso e dos órgãos envolvidos.",
    "approx": "Uso as mesmas regras para qualquer distância sem checar a rota.",
    "pressure": "O relógio avança e Baltazar conta as horas como se fossem moedas.",
    "plan": "Faço plano de transporte viável e aviso a família das condições.",
    "alternate": "Reavalio rota, equipe e documentação e registro a decisão.",
    "temptation": "Confirmo tudo agora e verifico as exigências depois da partida.",
    "last": "Prefiro uma viagem segura a um milagre de pontualidade."
  },
  {
    "voice": "Tenho um lote de caixões a preço de liquidação. A nota fiscal deve ter ido visitar os ancestrais.",
    "wit": "Podemos visitar os ancestrais depois; a nota tem prioridade de balcão.",
    "plain": "Preciso verificar procedência e documentação da compra.",
    "hasty": "Recebo a mercadoria e deixo a nota para depois.",
    "clue": "O catálogo diz madeira nobre, mas as etiquetas dizem outro material.",
    "check": "Conferimos características, etiquetas e condições antes de aceitar.",
    "support": "Posso documentar a divergência e solicitar correção do fornecedor.",
    "shortcut": "Aceito a descrição da vitrine sem conferir o produto.",
    "twist": "O lote é grande e ocupa toda a oficina; não posso perder o preço.",
    "deep": "Preço baixo não ressuscita material danificado.",
    "detail": "Planejo estoque e risco antes de decidir quanto comprar.",
    "approx": "Compro primeiro e vejo depois se há espaço e qualidade.",
    "pressure": "O fornecedor garante a oferta apenas se fecharmos a porta da loja agora.",
    "plan": "Formalizo condições por escrito e verifico custo total.",
    "alternate": "Negocio prazo razoável para conferência sem assumir riscos desnecessários.",
    "temptation": "Aceito sem conferência porque a promoção é vantajosa.",
    "last": "Uma boa compra deve continuar boa quando Baltazar conferir o livro-caixa."
  },
  {
    "voice": "Me disseram que conservar o corpo é obrigatório em qualquer caso. Ninguém explica o porquê.",
    "wit": "Obrigatório é explicar direito; milagres de balcão não são norma.",
    "plain": "Vamos verificar quando o procedimento é indicado ou exigido pelas regras aplicáveis.",
    "hasty": "Incluo a preparação sem perguntar a necessidade.",
    "clue": "A família quer saber se existem alternativas ao serviço extra.",
    "check": "Consulto as condições sanitárias, o destino e a situação concreta.",
    "support": "Encaminho a questão a profissionais habilitados sem pressupor obrigatoriedade universal.",
    "shortcut": "Digo que todos devem contratar por padrão.",
    "twist": "Um funcionário propôs realizar o serviço sem a equipe licenciada.",
    "deep": "Até o mais destemido fantasma pediria uma equipe habilitada.",
    "detail": "Interrompo qualquer ação técnica até conferir estrutura e competência profissional.",
    "approx": "Deixo a equipe se organizar depois, porque será um procedimento simples.",
    "pressure": "A família está ansiosa e quer certeza agora.",
    "plan": "Comunico o que sabemos e o que precisa ser validado, sem promessas absolutas.",
    "alternate": "Registro a dúvida e retorno com orientação confirmada.",
    "temptation": "Garanto que o procedimento é sempre obrigatório para encerrar a conversa.",
    "last": "O que eu queria era uma explicação, não uma obrigação inventada."
  },
  {
    "voice": "Houve uma morte violenta e a família deseja cremação hoje. Tenho uma autorização assinada por um primo.",
    "wit": "O papel do primo é valioso para a família; para a lei, preciso conferir outra coisa.",
    "plain": "Devemos verificar os requisitos legais antes de qualquer providência de cremação.",
    "hasty": "Aceito o documento familiar enquanto buscamos os demais.",
    "clue": "O registro da ocorrência indica morte violenta. Qual autorização muda o caso?",
    "check": "Confiro os requisitos do art. 77, incluindo a autoridade judiciária.",
    "support": "Explico com respeito o motivo da suspensão e os caminhos regulares.",
    "shortcut": "Realizo agora e regularizo os papéis depois.",
    "twist": "Um amigo diz que a família pode dispensar a decisão judicial se todos concordarem.",
    "deep": "Concordância familiar não substitui a autorização judicial exigida no caso.",
    "detail": "Oriento a família sem prometer um procedimento juridicamente inviável.",
    "approx": "Faço uma reserva definitiva sem esclarecer a condição judicial.",
    "pressure": "Há medo de atrasos; exigem resposta imediata.",
    "plan": "Organizo alternativas permitidas enquanto a documentação é verificada.",
    "alternate": "Informo próximos passos e responsáveis, sem realizar a cremação.",
    "temptation": "Trato a urgência como uma dispensa automática da autorização.",
    "last": "A família precisa de sinceridade, ainda que a notícia seja difícil."
  },
  {
    "voice": "Estudo solos. As sepulturas ficam por cima de lençóis d'água? Minha avó prefere terra firme.",
    "wit": "Até as raízes querem saber por onde a água corre.",
    "plain": "Podemos explicar licenciamento e análise ambiental do terreno.",
    "hasty": "Digo que qualquer terra serve desde que haja uma cerca.",
    "clue": "O projeto antigo mostra uma área de drenagem que desapareceu do mapa.",
    "check": "Consulto registros técnicos e condicionantes ambientais vigentes.",
    "support": "Encaminho o projeto e a dúvida ao setor ambiental responsável.",
    "shortcut": "Assumo que a licença antiga cobre qualquer ampliação.",
    "twist": "O responsável quer aumentar a quadra antes de avaliar o local.",
    "deep": "Cemitério não cresce como abóbora; planejamento importa.",
    "detail": "Verifico a necessidade de estudos e licença antes de expandir.",
    "approx": "Inicio marcações no terreno e deixo os estudos para mais tarde.",
    "pressure": "Um investidor diz que o licenciamento é somente um carimbo.",
    "plan": "Explico o papel dos órgãos competentes e o impacto da área escolhida.",
    "alternate": "Registro os riscos e condicionantes para avaliação técnica.",
    "temptation": "Pulo a consulta ambiental para inaugurar a quadra a tempo.",
    "last": "Obrigada. A ciência fica melhor quando não é enterrada junto com a licença."
  },
  {
    "voice": "Quero uma urna roxa com constelações. Ela lembraria minha tia, astrônoma e rainha das piadas ruins.",
    "wit": "As estrelas combinam; prometo deixar os custos em órbita bem definida.",
    "plain": "Vamos conferir o modelo, o preço e o desejo da família.",
    "hasty": "Escolho qualquer urna roxa e só depois pergunto se corresponde ao pedido.",
    "clue": "Uma sobrinha diz que a tia pediu algo discreto. Como respeitar isso?",
    "check": "Convido a família a esclarecer preferências sem impor uma estética.",
    "support": "Apresento modelos e registro o que foi efetivamente autorizado.",
    "shortcut": "Faço a encomenda com base na pessoa que falou mais alto.",
    "twist": "O fornecedor oferece gravação adicional com preço separado.",
    "deep": "Constelações opcionais, transparência obrigatória.",
    "detail": "Distingo custo do objeto e personalizações antes da compra.",
    "approx": "Incluo a gravação agora e explico seu valor depois.",
    "pressure": "A família quer decidir antes de fechar o fornecedor.",
    "plan": "Verifico disponibilidade, valor total e prazo sem prometer além do possível.",
    "alternate": "Organizo aprovação das personalizações por escrito.",
    "temptation": "Digo que a gravação é obrigatória para receber a urna escolhida.",
    "last": "Minha tia odiava surpresas no orçamento. Nas estrelas, ela aceitava."
  },
  {
    "voice": "Recebi seis urnas com tampas tortas. Talvez seja a nova moda pós-moderna.",
    "wit": "A moda pode ser torta, mas a entrega deve corresponder ao pedido.",
    "plain": "Vamos conferir quantidade, qualidade e documento de recebimento.",
    "hasty": "Ponho tudo no estoque até ter tempo de examinar.",
    "clue": "A nota diz seis unidades intactas; duas estão danificadas.",
    "check": "Registro divergência e separo as unidades não conformes.",
    "support": "Solicito troca ou solução documentada ao fornecedor.",
    "shortcut": "Coloco as danificadas à venda para não perder o lote.",
    "twist": "Um pedido urgente pode consumir todo o estoque bom.",
    "deep": "A pressa não conserta tampa; planejamento evita problemas novos.",
    "detail": "Reavalio a disponibilidade e informo prazos com precisão.",
    "approx": "Prometo entregar as unidades danificadas se não houver alternativa.",
    "pressure": "O fornecedor quer crédito futuro em vez de substituição.",
    "plan": "Comparo solução contratual, prazo e condições antes de aceitar.",
    "alternate": "Registro a proposta sem encerrar a reclamação prematuramente.",
    "temptation": "Concordo com qualquer crédito e não informo os clientes.",
    "last": "O inventário deve contar urnas úteis, não apenas caixas ocupadas."
  },
  {
    "voice": "Sou fiscal. Os relatórios de resíduos sumiram misteriosamente... e o fantasma do arquivo não foi convincente.",
    "wit": "Fantasma extraviador é folclore; rastreabilidade é trabalho.",
    "plain": "Vamos localizar o PGRSS aplicável e os registros exigidos.",
    "hasty": "Mostro um formulário genérico e digo que o resto está arquivado.",
    "clue": "Os colaboradores não sabem onde ficam as instruções de segregação.",
    "check": "Avalio treinamento e registros conforme a RDC 222/2018 aplicável.",
    "support": "Identifico lacunas e documento um plano de correção verificável.",
    "shortcut": "Crio um registro retroativo sem comprovação.",
    "twist": "Um prestador terceirizado não apresentou documentos da destinação.",
    "deep": "O resíduo não desaparece porque alguém escreveu 'resolvido' no livro.",
    "detail": "Confiro responsabilidades e evidências do gerenciamento.",
    "approx": "Confio na palavra do fornecedor sem verificar o contrato ou registros.",
    "pressure": "A inspeção precisa de respostas ainda hoje.",
    "plan": "Apresento informações verificadas e o cronograma de adequação.",
    "alternate": "Assumo a lacuna com transparência e busco orientação do órgão competente.",
    "temptation": "Oculto a falha para evitar consequência financeira.",
    "last": "O trabalho sério também pode ter humor; o relatório, não pode ser inventado."
  },
  {
    "voice": "O carro dá um chiado estranho no freio. Achei que era um fantasma cantando.",
    "wit": "Fantasma afinado não é certificado de freio; vamos inspecionar.",
    "plain": "Retiro o veículo de serviço até verificar a segurança.",
    "hasty": "Peço que dirija lentamente e vejo o problema amanhã.",
    "clue": "A outra viatura está disponível, mas o motorista precisa reorganizar a rota.",
    "check": "Replanejo a escala e confiro condições da alternativa.",
    "support": "Informo à família o atraso e a mudança proposta.",
    "shortcut": "Mantenho a viagem original para não perder o horário.",
    "twist": "O mecânico diz que precisa de mais tempo do que a agenda permite.",
    "deep": "A agenda não manda na física; o freio definitivamente manda.",
    "detail": "Reorganizo os compromissos e documento a revisão necessária.",
    "approx": "Prometo a entrega no horário habitual sem confirmar.",
    "pressure": "Baltazar contabilizou a perda de receita do atraso.",
    "plan": "Priorizo segurança e avalio impactos econômicos de forma transparente.",
    "alternate": "Registro custo da revisão e mantenho a família informada.",
    "temptation": "Ignoro a manutenção porque o caixa sofreu neste mês.",
    "last": "Prefiro perder alguns minutos a transformar o mecânico em personagem da história."
  },
  {
    "voice": "Quero caixão simples e entrega pontual. O catálogo tem uma beleza que assusta o cartão.",
    "wit": "A única coisa que deve assustar o cartão é o valor explicado antes.",
    "plain": "Vamos especificar modelo, entrega e condições de pagamento.",
    "hasty": "Faço o pedido primeiro e calculo o frete depois.",
    "clue": "O valor de entrega não consta na página. Ele faz parte da proposta?",
    "check": "Consolido todos os custos previsíveis no orçamento prévio.",
    "support": "Confiro prazo de entrega e condições antes do aceite.",
    "shortcut": "Anuncio frete grátis e lanço o transporte na nota final.",
    "twist": "O fornecedor não garante a cor exata prometida na vitrine.",
    "deep": "Prometer madeira mágica não cria estoque; vamos conferir a descrição.",
    "detail": "Confirmo características disponíveis e documento alterações autorizadas.",
    "approx": "Deixo a família acreditar que receberá o modelo exato.",
    "pressure": "O pedido precisa ser feito até fechar o expediente.",
    "plan": "Valido disponibilidade, prazo e preço antes da confirmação.",
    "alternate": "Registro as alternativas e peço concordância para eventual substituição.",
    "temptation": "Entrego outro modelo sem avisar se o prometido atrasar.",
    "last": "Quero poder conferir a nota e reconhecer o serviço contratado."
  },
  {
    "voice": "Queria saber quem foi atendido aqui mês passado. Sou uma conhecida antiga da família.",
    "wit": "A memória dos vivos é delicada; nosso arquivo não é uma janela aberta.",
    "plain": "Precisamos verificar a legitimidade do pedido e os limites de acesso.",
    "hasty": "Mostro um resumo do cadastro para ver se você reconhece.",
    "clue": "Não tenho autorização, mas conheço detalhes da vida dessa pessoa.",
    "check": "Explico que conhecimento pessoal não é prova suficiente de direito de acesso.",
    "support": "Indico um canal adequado para pedido legítimo sem revelar dados.",
    "shortcut": "Compartilho o registro porque parece ser parente próximo.",
    "twist": "A pessoa insiste que um dado isolado não pode prejudicar ninguém.",
    "deep": "Até uma informação pequena pode ter dono e contexto.",
    "detail": "Avalio o pedido conforme deveres de confidencialidade e normas aplicáveis.",
    "approx": "Leio uma parte do cadastro em voz baixa.",
    "pressure": "A visitante ameaça publicar que a funerária não colabora.",
    "plan": "Registro a solicitação sem ceder a pressão pela divulgação de dados.",
    "alternate": "Encaminho formalmente, com respeito e sem exposição indevida.",
    "temptation": "Entrego o arquivo para evitar uma avaliação negativa.",
    "last": "A resposta profissional pode ser educada sem abrir o arquivo."
  },
  {
    "voice": "Tenho uma lista de providências, mas meu irmão fez outra. Os papeis brigam mais que a família.",
    "wit": "Papel não precisa vencer discussão; vamos dar nome a cada etapa.",
    "plain": "Organizo uma sequência clara de documentos e responsáveis.",
    "hasty": "Entrego todos os formulários para vocês resolverem sozinhos.",
    "clue": "Recebemos uma Declaração de Óbito. Isso já permite todas as etapas?",
    "check": "Diferencio declaração de saúde e certidão do registro civil.",
    "support": "Oriento o próximo passo de forma simples, confirmando as condições locais.",
    "shortcut": "Digo que a declaração basta para qualquer procedimento.",
    "twist": "Uma pessoa recomenda ir direto ao cemitério sem passar por registro.",
    "deep": "Entre o hospital e o cemitério existem regras que não cabem em atalhos.",
    "detail": "Verifico o documento exigido para a etapa e as exceções legais.",
    "approx": "Faço uma reserva sem explicar a documentação necessária.",
    "pressure": "O horário do cartório preocupa a família.",
    "plan": "Indico canais oficiais e o que pode ser preparado sem burlar etapas.",
    "alternate": "Divido as tarefas entre familiares de acordo com consentimento.",
    "temptation": "Prometo concluir tudo sem conferir normas para reduzir ansiedade.",
    "last": "Agora consigo explicar a sequência à família sem espalhar medo."
  },
  {
    "voice": "Desejamos cremação, mas a documentação veio incompleta. Não quero que pensem que desrespeitamos ninguém.",
    "wit": "Respeito também é não transformar papéis faltantes em magia.",
    "plain": "Vamos checar os requisitos legais antes de confirmar qualquer execução.",
    "hasty": "Reservo o procedimento como garantido enquanto coletamos documentos.",
    "clue": "Há manifestação de vontade registrada? É isso que precisamos comprovar?",
    "check": "Examinamos as condições aplicáveis do art. 77, §2º, e os documentos exigidos.",
    "support": "Oriento a família sobre o que confirmar e com quais autoridades.",
    "shortcut": "Trato uma promessa informal como autorização universal.",
    "twist": "Um parente quer decidir pela pessoa falecida sem esclarecer sua vontade.",
    "deep": "A voz de quem partiu não é substituída por quem fala mais alto.",
    "detail": "Reviso manifestação e exigências específicas, sem fazer promessas indevidas.",
    "approx": "Uso uma versão verbal sem documentação para não contrariar a família.",
    "pressure": "A data da homenagem já foi divulgada.",
    "plan": "Separo a homenagem possível dos procedimentos que dependem de requisitos legais.",
    "alternate": "Ajudo a reorganizar o cronograma com informações verdadeiras.",
    "temptation": "Realizo primeiro e regularizo os documentos depois.",
    "last": "Prefiro remarcar um plano a desrespeitar a vontade e a lei."
  },
  {
    "voice": "A família está dividida entre flores, silêncio e música. A única unanimidade é a saudade.",
    "wit": "Até os fantasmas desafinam. Vamos construir um momento em que todos caibam.",
    "plain": "Podemos ouvir as preferências e definir um orçamento com clareza.",
    "hasty": "Escolho o pacote que vende mais e deixo a família ajustar.",
    "clue": "Uma pessoa diz que a música era desejo da falecida; outra não confirma.",
    "check": "Vamos distinguir preferências conhecidas de suposições familiares.",
    "support": "Ofereço espaço para consenso sem forçar decisões.",
    "shortcut": "Sigo a voz mais firme porque o tempo está curto.",
    "twist": "O orçamento inclui serviços não pedidos, e ninguém percebeu no início.",
    "deep": "O luto já custa caro emocionalmente; extras precisam ser escolhas.",
    "detail": "Reviso a proposta item a item e peço confirmação.",
    "approx": "Preservo os extras para não reabrir a conversa.",
    "pressure": "O velório será em poucas horas, e há mais detalhes a definir.",
    "plan": "Prioriza-se o que é necessário e combinado, com informação confiável.",
    "alternate": "Ajusto cronograma e confirmo cada item antes de executar.",
    "temptation": "Cobro flores e música sem explicar, alegando urgência.",
    "last": "Seria bom sair daqui sentindo que fomos ouvidos, não apenas atendidos."
  }
]
const SUPPORTING_VOICES = [
  {
    "name": "Irmã de Afonso",
    "line": "Ele não queria cerimônia cara, mas queria que todos estivessem presentes.",
    "profile": "calmo"
  },
  {
    "name": "Filha de Ester",
    "line": "Mãe, eu também sinto falta dele. Podemos decidir isso juntas?",
    "profile": "sofredor"
  },
  {
    "name": "Gervásio Caixote",
    "line": "Violeta, minha loja vende urnas, não autorizações automáticas de cremação.",
    "profile": "fornecedor"
  },
  {
    "name": "Prima de Leopoldo",
    "line": "Esse registro é antigo; nossa família inteira precisa entender os direitos do jazigo.",
    "profile": "reservado"
  },
  {
    "name": "Irmão de Gil",
    "line": "Quero ajudar com a conta, mas não aceito um valor que ninguém consegue explicar.",
    "profile": "economico"
  },
  {
    "name": "Funcionária do hospital",
    "line": "A Declaração de Óbito e a Certidão de Óbito são etapas diferentes; vamos orientar com calma.",
    "profile": "profissional"
  },
  {
    "name": "Arquimedes Ossário",
    "line": "Sem revisão, esse veículo fica na garagem. Meu terno não é um extintor.",
    "profile": "profissional"
  },
  {
    "name": "Assistente de estoque",
    "line": "As caixas chegaram com etiquetas diferentes. Prefiro conferir antes de receber.",
    "profile": "profissional"
  },
  {
    "name": "Dona Clotilde",
    "line": "Procedimentos técnicos exigem equipe, estrutura e regras aplicáveis; não inventamos obrigação.",
    "profile": "profissional"
  },
  {
    "name": "Seu Cinério Brasa",
    "line": "No caso de morte violenta, não seguimos sem a autorização judicial exigida.",
    "profile": "profissional"
  },
  {
    "name": "Engenheira do cemitério",
    "line": "Antes de ampliar, preciso verificar o projeto e a licença ambiental vigente.",
    "profile": "profissional"
  },
  {
    "name": "Sobrinha de Hortênsia",
    "line": "Titia gostava de estrelas, mas nunca gostaria que decidissem por ela sem perguntar.",
    "profile": "calmo"
  },
  {
    "name": "Conferente do Empório",
    "line": "Aqui constam seis unidades intactas, mas há avarias. Preciso registrar a diferença.",
    "profile": "profissional"
  },
  {
    "name": "Auxiliar ambiental",
    "line": "Encontrei o plano, porém faltam registros de treinamento. Melhor admitir e corrigir.",
    "profile": "profissional"
  },
  {
    "name": "Mecânico da frota",
    "line": "O barulho é do freio, Tibúrcio. Não é um solo de jazz do além.",
    "profile": "profissional"
  },
  {
    "name": "Vendedor da funerária",
    "line": "O modelo prometido não está em estoque. Precisamos avisar antes de substituir.",
    "profile": "profissional"
  },
  {
    "name": "Funcionária do arquivo",
    "line": "Nem todo pedido de informação autoriza revelar dados pessoais.",
    "profile": "reservado"
  },
  {
    "name": "Irmão de Inácio",
    "line": "O cartório já foi citado três vezes, mas eu ainda não entendi o passo seguinte.",
    "profile": "confuso"
  },
  {
    "name": "Atendente do crematório",
    "line": "Precisamos conferir a manifestação de vontade e os requisitos legais da situação.",
    "profile": "profissional"
  },
  {
    "name": "Irmã de Aurora",
    "line": "Ela gostava de flores, mas principalmente de ver a família em paz.",
    "profile": "sofredor"
  }
]
const PERSONAL_REPLIES = [
  {
    "humor": "Afonso ri baixinho: 'Então a única surpresa deve ser boa, não uma cobrança escondida.'",
    "sober": "Afonso assente: 'Com os itens separados consigo conversar com meus irmãos.'"
  },
  {
    "humor": "Ester diz: 'Ele fazia piada com tudo. Obrigada por não exigir que eu sorria.'",
    "sober": "Ester responde: 'É bom poder pensar sem sentir que estou atrasada para algo.'"
  },
  {
    "humor": "Violeta responde: 'Perfeito, vamos escolher a arte sem fingir que ela substitui documentos.'",
    "sober": "Violeta aprova: 'Planejar direito me diverte mais que um contrato mágico.'"
  },
  {
    "humor": "Leopoldo suspira: 'Justo. Até minha chave gigante não deve substituir o registro.'",
    "sober": "Leopoldo aceita: 'Vou buscar os documentos e esclarecer com a família.'"
  },
  {
    "humor": "Gil responde: 'Finalmente um susto que não vem do preço! Obrigado.'",
    "sober": "Gil diz: 'Assim consigo decidir dentro do orçamento sem constrangimento.'"
  },
  {
    "humor": "Palmira suspira: 'Que bom, achei que meus primos tinham fundado um novo cartório.'",
    "sober": "Palmira agradece: 'Agora sei exatamente a diferença entre os documentos.'"
  },
  {
    "humor": "Tadeu ri: 'Está bem, meu relógio pode resmungar dentro da oficina.'",
    "sober": "Tadeu anota a alternativa: 'Prefiro explicar o atraso a criar outro problema.'"
  },
  {
    "humor": "Áurea responde: 'Até os preços baixos precisam de documento em vida.'",
    "sober": "Áurea concorda: 'Vamos verificar a nota antes da entrada no estoque.'"
  },
  {
    "humor": "Helena fala baixo: 'Obrigada por não transformar nossa dúvida em venda.'",
    "sober": "A família concorda: 'Vamos ouvir o responsável técnico antes de decidir.'"
  },
  {
    "humor": "Noctílio percebe: 'A papelada afinal não é um capricho do Cinério.'",
    "sober": "Noctílio responde: 'Vamos verificar a autorização e organizar o possível.'"
  },
  {
    "humor": "Agatha sorri: 'Gosto de ciência com menos assombração e mais mapas.'",
    "sober": "Agatha responde: 'Isso ajuda a entender por que o terreno precisa de análise.'"
  },
  {
    "humor": "Hortênsia ri de leve: 'Minha tia teria amado a transparência intergaláctica.'",
    "sober": "Hortênsia concorda: 'Vamos consultar a família antes da personalização.'"
  },
  {
    "humor": "Valdemar observa: 'A moda torta pode ficar só no cabelo, não nas tampas.'",
    "sober": "Valdemar aceita: 'Vou registrar as avarias e propor solução formal.'"
  },
  {
    "humor": "Marcela não sorri, mas responde: 'Assim já começamos com dados reais.'",
    "sober": "Marcela anota: 'Registros verificados são mais úteis que desculpas elegantes.'"
  },
  {
    "humor": "Tibúrcio responde: 'A canção do freio fica para o concerto da oficina.'",
    "sober": "Tibúrcio concorda: 'Vou planejar a rota com o veículo seguro.'"
  },
  {
    "humor": "Benício ri: 'Se o cartão levar um susto, que seja previsto no orçamento.'",
    "sober": "Benício assente: 'Agora sei exatamente pelo que estarei pagando.'"
  },
  {
    "humor": "Mirtes concorda: 'Prefiro sigilo sério a simpatia que exponha alguém.'",
    "sober": "Mirtes responde: 'Vou seguir o canal adequado de solicitação.'"
  },
  {
    "humor": "Inácio sorri: 'Papel organizadinho talvez seja um pequeno milagre.'",
    "sober": "Inácio anota: 'Agora consigo orientar o restante da família.'"
  },
  {
    "humor": "Lucinda responde: 'Então podemos planejar a homenagem sem antecipar procedimentos.'",
    "sober": "Lucinda aceita: 'Vamos verificar a vontade e os requisitos aplicáveis.'"
  },
  {
    "humor": "Aurora parece aliviada: 'Um pouco de leveza sem esquecer o essencial ajuda.'",
    "sober": "A família responde: 'A decisão precisa refletir o que conversamos.'"
  }
]
const FEEDBACK = {
    "warm":[
        "A pessoa relaxa um pouco e conta um detalhe que não estava no cadastro.",
        "A conversa ganha espaço para informações importantes.",
        "O atendimento prossegue, mas o cliente ainda parece inseguro."
    ],
    "verify":[
        "A conferência revela uma informação nova. É melhor esclarecê-la do que assumir.",
        "O cliente percebe que você considera documentos e necessidades.",
        "A pressa trouxe uma dúvida séria; será preciso rever esse passo."
    ],
    "deep":[
        "O cliente sorri de leve e conta algo da história familiar.",
        "Com as informações reunidas, surge uma alternativa responsável.",
        "Há uma lacuna no combinado; não feche o caso antes de esclarecer."
    ],
    "plan":[
        "Agora o plano é compatível com o que foi verificado e escolhido.",
        "O cronograma fica mais claro, mesmo que leve um pouco mais de tempo.",
        "O atalho abriu um risco que precisa ser corrigido antes de continuar."
    ],
    "close":[
        "A pessoa pode tomar a decisão com informações compreensíveis.",
        "O atendimento chega à etapa final de modo organizado.",
        "Ainda há informação pendente; é cedo para encerrar."
    ]
}

static func total() -> int:
    return STORIES.size()

static func tier(index: int) -> int:
    return clampi(int(index / 5) + 1, 1, 4)

static func beat_keys(index: int) -> Array:
    match tier(index):
        1:
            return ["warm","verify"]
        2:
            return ["warm","verify","deep"]
        3:
            return ["warm","verify","deep","plan"]
        _:
            return ["warm","verify","deep","plan","close"]

static func scene(index: int, step: int, client_name: String) -> Dictionary:
    if index < 0 or index >= STORIES.size():
        return {}
    var story: Dictionary = STORIES[index]
    var keys: Array = beat_keys(index)
    if step < 0 or step >= keys.size():
        return {}
    var mode: String = str(keys[step])
    var lines: Dictionary = {
        "warm":story["voice"],
        "verify":story["clue"],
        "deep":story["twist"],
        "plan":story["pressure"],
        "close":story["last"]
    }
    var choices: Array = []
    match mode:
        "warm":
            choices = [
                {"text":story["wit"],"grade":2,"tone":"humor","insight":"escuta"},
                {"text":story["plain"],"grade":2,"tone":"sereno","insight":"acolhimento"},
                {"text":story["hasty"],"grade":1,"tone":"apressado","insight":""}
            ]
        "verify":
            choices = [
                {"text":story["check"],"grade":2,"tone":"cuidadoso","insight":"verificacao"},
                {"text":story["support"],"grade":2,"tone":"atencioso","insight":"documentacao"},
                {"text":story["shortcut"],"grade":0,"tone":"atalho","insight":""}
            ]
        "deep":
            choices = [
                {"text":story["deep"],"grade":2,"tone":"humor","insight":"escuta"},
                {"text":story["detail"],"grade":2,"tone":"cuidadoso","insight":"claridade"},
                {"text":story["approx"],"grade":1,"tone":"apressado","insight":""}
            ]
        "plan":
            choices = [
                {"text":story["plan"],"grade":2,"tone":"humor","insight":"planejamento"},
                {"text":story["alternate"],"grade":2,"tone":"cuidadoso","insight":"planejamento"},
                {"text":story["temptation"],"grade":0,"tone":"atalho","insight":""}
            ]
        "close":
            choices = [
                {"text":"Registrar o que foi combinado, confirmar os itens e deixar a família revisar.", "grade":2,"tone":"cuidadoso","insight":"confirmacao"},
                {"text":"Encerrar com resumo escrito, perguntar o que ficou em dúvida e confirmar consentimento.", "grade":2,"tone":"atencioso","insight":"confirmacao"},
                {"text":"Confirmar o pedido rapidamente e esclarecer divergências somente se surgir reclamação.", "grade":0,"tone":"atalho","insight":""}
            ]
    # Nao marque visualmente a escolha certa: ordenacao muda conforme caso/etapa.
    # Duas abordagens responsaveis (humor ou seriedade) continuam possiveis.
    var rotation: int = posmod(index + step * 2,3)
    var rearranged: Array = []
    for i in range(choices.size()):
        rearranged.append(choices[(i+rotation)%choices.size()])
    var speaker_name: String = client_name
    var speaker_profile: String = ""
    var text_line: String = str(lines[mode])
    if mode == "deep" and index >= 5:
        var supporting: Dictionary = SUPPORTING_VOICES[index]
        speaker_name = str(supporting["name"])
        speaker_profile = str(supporting["profile"])
        text_line = str(supporting["line"])
    return {"speaker":speaker_name, "profile":speaker_profile, "line":text_line,"mode":mode,"choices":rearranged,"step":step,"total":keys.size(),"tier":tier(index)}

static func reaction(index: int, step: int, choice_index: int, speaker: String) -> Dictionary:
    var current: Dictionary = scene(index,step,speaker)
    if current.is_empty():
        return {}
    var choices: Array = current["choices"]
    if choice_index < 0 or choice_index >= choices.size():
        return {}
    var selected: Dictionary = choices[choice_index]
    var score: int = int(selected["grade"])
    var mode: String = str(current["mode"])
    var summary: String = str(FEEDBACK[mode][0 if score==2 else 1 if score==1 else 2])
    if score==2 and mode == "warm":
        var personal: Dictionary = PERSONAL_REPLIES[index]
        summary = str(personal["humor"] if str(selected["tone"])=="humor" else personal["sober"])
    if score==0:
        summary += "\n\nEssa abordagem precisa ser corrigida antes de autorizar serviços ou concluir o caso."
    return {"speaker":str(current["speaker"]),"profile":str(current["profile"]),"line":summary,"score":score,"insight":str(selected["insight"]),"tone":str(selected["tone"]),"unsafe":score==0}

static func required_score(index: int) -> int:
    var count: int = beat_keys(index).size()
    return count * 2 - 2

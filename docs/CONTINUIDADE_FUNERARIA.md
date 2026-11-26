# Continuidade — Casa Funerária Umbra / O Último Adeus

Prioridade aprovada: concluir a revista antes de retomar a produção de caixões e pessoas homenageadas.

## Estado
- Lote 01: 12 caixões, estoque por modelo, orçamento, contratação, persistência.
- Lote 01.1: lore de Ernesto Vale (B-13), Artur (caso 1), Rosa (caso 5), Augusto (caso 16).
- Lote 02: Serenidade aberto e tampa já integrados em assets/sprites/coffins/serenidade/. Render modular em scripts/world/chapel_coffin_art.gd. Faltam borda_frontal.png, fechado.png e Ernesto em assets/sprites/funeral_people/ernesto_vale.png. Retomar após revista.
- Lote 02.1: revista A Eternidade em Detalhes, 32 páginas, navegação e propostas pelo sistema de caixa/estoque existente; compra de caixões via Empório. Ilustrações SVG provisórias em assets/ui/funeral_magazine; Serenidade usa a arte aprovada. Urnas e cremação são prévias, não contratos.
- Lote 02.2: prancha aprovada recortada em 19 componentes. Atlas compacto instalado, capa, livro aberto, moldura, abas e setas ligados à interface; contracapa navegável. Textos e preços nativos. Recortes em resolução maior podem ser instalados em `assets/ui/funeral_magazine/definitivos/` com os nomes de `funeral_magazine_skin.gd` sem alterar código. Teste visual e resolução final pendentes.
- Nova regra de produção aprovada: cada caixão terá página comercial (`pagina.png`, ilustração sem preço/texto fixo), base aberta (`aberto.png`), tampa (`tampa.png`), e, quando necessário, borda frontal (`borda_frontal.png`) e fechado (`fechado.png`), todos no mesmo diretório de modelo. A revista carrega a página definitiva automaticamente, sem alterar dados de preço/estoque. Próximo: página do Serenidade, cuja base e tampa já existem.

## Depois da revista
1. Retomar Lote 02 (borda, fechado, Ernesto, teste de encaixe).
2. Caixões 02–12, um conjunto por modelo: página comercial, aberto e tampa; borda/fechado conforme necessário. Manter perspectiva e encaixe do Serenidade.
3. Artur, Rosa e Augusto; ornamentação, visitantes e capela.
4. Urnas 12 modelos: arte, preços validados, estoque e contratação real nos casos adequados.
5. Crematório: interior, Cinério, ordens autorizadas e minigame abstrato de documentação, identificação, segurança, rastreabilidade e entrega; sem parâmetros técnicos reais nem imagens gráficas. Casos de documentação insuficiente permanecem bloqueados.
6. Novas jornadas e cerimônias, animações, áudio, testes e balanceamento.

## Regras
Preservar os 20 casos, condições de progressão e recompensas existentes; não confundir familiares vivos com falecidos; nenhum luxo aumenta reputação. Sprites 2D pixel art gótica, transparentes, individuais; preços fictícios; interface por toque e teclado. Não considerar commits publicados/testados sem verificar CI.

## Desdobramento aprovado — revistas separadas
- A Eternidade em Detalhes: 20 páginas (capa 1, Amália 2, caixões 3–14, serviços 15–20). Retomar página 02 da Amália (arte criada, upload ainda pendente) e depois página 03 Serenidade. Não alterar os sprites aberto/tampa já integrados.
- Memórias que Permanecem: revista independente do Empório, 16 páginas: capa, Violeta, 12 urnas, orientação e orçamento. Preços fictícios, aquisição unitária, estoque persistente por modelo; ilustrações provisórias. O estoque legado e a compra de duas urnas continuam.
- Violeta permanece cliente do caso 03; após concluí-lo, passa a colaborar no Empório (sprite provisório). Gervásio mantém suas funções.
- Jornada opcional adicional: família de Celeste declara interesse em cremação com Amália, escolhe urna com Violeta, Baltazar registra a proposta e Cinério faz triagem. Estado salvo separadamente; sem execução, cobrança ou reserva definitiva nesta etapa. Preservar casos 10 e 19 que exigem bloqueio documental, assim como todos os 20 casos, sepultamentos e pontuações originais. A futura ordem operacional exige autorização explícita e minigame próprio.
- Próximos: conferir revistas e encaminhamento no jogo, integrar Página 02 aprovada, completar coleção de caixões (página/aberto/tampa por modelo); depois arte definitiva das urnas, Violeta e crematório.

## Página 02 — Madame Amália
- Texto integral da página aprovada (apresentação, pedagogia, lore, frase e dica profissional) integrado como editorial, sem compra ou alteração de missões. Aba Amália e acesso direto pelo NPC; botão de leitura ampliada rolável.
- Prévia da arte original instalada em `assets/ui/funeral_magazine/pagina_02_amalia_preview.webp` (90×120, resolução reduzida). A versão definitiva de alta resolução deve ser enviada como `assets/ui/funeral_magazine/pagina_02_amalia.jpg`; será reconhecida automaticamente. Não considerar a arte final instalada até confirmar o arquivo.
- Próximo asset: Página 03 — Serenidade. Base e tampa já integradas; manter o padrão dos três assets por modelo. Revisar visual após compilação.

## Mesas de revistas — consulta livre
- Escritório, Casa Funerária Umbra e Empório: móvel de madeira com os dois exemplares, interação E/toque independente de cliente e estágio. Posições e colisões em interior_catalog.gd; arte reutilizável em magazine_table.gd.
- Ambas as revistas abrem em modo browse, sem compra, proposta, alteração de estoque ou progressão; todos os 20/16 conteúdos podem ser inspecionados desde o início. Atendimentos comerciais originais continuam nos NPCs.
- Teste em interior_smoke.gd cobre acesso antes da campanha, abertura das duas revistas, bloqueio de compra e ausência de alterações econômicas. Próximo: Página 03 Serenidade; verificar visual das mesas e da página 02.

## Página 03 — Serenidade
- Arte comercial aprovada: dupla página com vistas fechada, aberta, lateral, detalhes de acabamento, comentário de Amália e quadro educativo. Prévia compacta (88×96) instalada em assets/sprites/coffins/serenidade/pagina_preview.webp. Arte integral de 1199×1312 deve ser enviada como assets/sprites/coffins/serenidade/pagina.png; código detecta automaticamente. Texto nativo e leitura ampliada preservam legibilidade; não replicar curiosidade histórica sem verificação. A ilustração contém preço fixo de venda (R$ 300), portanto modo de compra no Empório exibe apenas a base aberta e preço de aquisição R$ 180. Preço oficial e estoque continuam no catálogo.
- Base aberta e tampa já instaladas anteriormente na capela, sem mudanças. Próxima produção: Página 04 Último Suspiro, aberto e tampa correspondentes; preferir arte comercial sem valores fixos e título correto.
- CI anterior das mesas falhou no teste de economia (entrada salva e normaliza estoque); teste agora mede leitura após entrada em cada sala, mantendo a checagem de não alteração. Revalidar CI.

## Estabilidade — correção dos dois CI
- Execução 45729930863 falhou no teste de leitura: comparação antes da entrada incluía normalização de estoque durante salvamento. Baseline passou a ser após entrada (70d684a9); teste agora percorre todas as páginas dos dois catálogos e relata qual campo divergiu, sem afrouxar verificações.
- Execução 45730483057 falhou na compilação de funeral_magazine_data.gd: inferência de tipo de show_serenidade_page a partir de chave Variant. Corrigido com bool explícito e str(id). Não remover testes, assets, economia ou missões. Confirmar CI integral antes de considerar publicação válida.

## Revista V2 — leitura como livro físico
- CI de estabilidade 45731062244 passou. Nova interface: mesa de madeira, fundo de livro em SVG de alta resolução, placas ornamentadas independentes com estados normal/hover/pressionado/desabilitado/aba ativa, navegação por toque/teclado. Ilustrações de dupla página substituem todo o miolo, sem moldura, texto duplicado ou imagem sobre outra imagem. Transição breve de opacidade, sem prometer dobra real de página. Controles de seleção, preço e estoque permanecem fora da arte.
- Artes novas aprovadas (capa dupla, Amália, Serenidade) devem ser enviadas em `assets/ui/funeral_magazine/duplas/` com nomes `capa_dupla.webp`, `amalia_dupla.webp`, `serenidade_dupla.webp`, `mesa_de_leitura.webp`, `capa_fechada.webp`. PNGs antigos preservados como fallback; novas artes usam filtro linear. A arte do Serenidade contém R$ 300 e fica fora do modo fornecedor. A próxima página dupla segue o formato horizontal 1672×941, preferencialmente sem preço impresso. Próximo: testar V2 e completar Último Suspiro (página dupla, aberto, tampa).

## Página 04 — Último Suspiro
- Três arquivos artísticos preparados: `ultimo_suspiro_dupla.webp` (1258×726, horizontal), `aberto.png` e `tampa.png` (320×520, RGBA com transparência). Upload dos três pendente. Página em `assets/ui/funeral_magazine/duplas/`; sprites em `assets/sprites/coffins/ultimo_suspiro/`. O carregador da capela já seleciona pelo contrato. Preço de venda impresso R$ 420; não exibir encarte no fornecedor nem se o preço mudar. Custo R$ 240. Próximo após upload e teste: Página 05 Descanso Eterno, três assets individuais.

## Último Suspiro — integração dos sprites
- Instalados `aberto.png` e `tampa.png`, derivados das artes aprovadas, PNG indexado transparente (56×112 e 55×112). Versões compactas para escala da capela; originais 320×520 podem substituir os mesmos arquivos. Teste exige ambos, transparência e vínculo pelo modelo. A página 04 apresenta o sprite correspondente até a chegada de `ultimo_suspiro_dupla.webp` em alta resolução; não reduzir a arte editorial. Custo R$ 240 e venda R$ 420 preservados. Aguardar CI e conferir visual antes de considerar concluído.

- Confirmação posterior: página `ultimo_suspiro_dupla.webp` em alta resolução (489508 bytes) chegou ao GitHub no commit 5d0ddf6a, preservada na integração seguinte. Os três assets estão no repositório. Teste cobre também seleção no caso 1 e separação do preço de aquisição. CI e aparência em jogo ainda a validar.

## Página 05 — Descanso Eterno
- Três assets em alta resolução confirmados em fc0fd7ef: aberto.png (225567 bytes), tampa.png (182734 bytes), descanso_eterno_dupla.webp (579382 bytes). Página dupla no catálogo, base e tampa selecionadas pelo contrato no velório; preço de aquisição R$ 320 e venda R$ 560 preservados. Adicionado texto pedagógico nativo e teste de arte, transparência, encaixe, compra e orçamento (caso 16 elegível, caso 1 bloqueado). CI e visual ainda a validar. Coleção: 3 de 12 modelos, 9 de 36 assets principais. Próximo: Página 06 — Lírio Branco, três imagens individuais.

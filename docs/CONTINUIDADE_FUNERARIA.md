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

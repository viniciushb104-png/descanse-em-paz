# 💀 Descanse em Paz & Pague em Dia

**“A morte é inevitável. A burocracia também.”**

Jogo de comédia gótica e administração funerária, criado por **Vinicius Diniz — Asas do Medo Games**, em Godot 4.7.2.

## Protótipo 0.4 — mapa reorganizado e jogabilidade restaurada
- Explore o cemitério de Santa Mortalha em perspectiva superior;
- converse com Seu Osvaldo e com Baltazar, o contador fantasma;
- confira documentação, reserve um jazigo, registre o atendimento e faça manutenção;
- gerencie caixa, reputação, conformidade, horário e salvamento automático.

## Jogar online
Quando o GitHub Pages estiver ativado em **Settings → Pages → Build and deployment → Source: GitHub Actions**, cada atualização em `main` gera um novo jogo para Web. Endereço esperado, **apenas depois da primeira implantação bem-sucedida**:
https://viniciushb104-png.github.io/descanse-em-paz/

## Controles
**Computador:** WASD/setas = mover, **E** = interagir, **R** = resgatar o personagem para o caminho central, **Esc** = fechar. **Toque:** botões direcionais e Interagir na tela.

## Rodar na Godot
Abra `project.godot` na Godot **4.7.2** e pressione F5.

## Importante
Valores monetários fictícios; documentação e processos simplificados. Legislação, tarifas, prazos e normas específicas mudam por local e tipo de serviço. Não use o jogo como manual jurídico, contábil, sanitário ou profissional. Referências em `docs/REFERENCIAS.md`.

Código e arte originais reservados ao autor até definição de licença.

## Atualizacao V0.4 (23/11/2026)
O mapa foi redesenhado para preservar a leitura visual e o enquadramento dos predios; personagem agora usa um Sprite2D independente, com anel de localizacao. Salvamentos anteriores mantem a missao, mas reposicionam o jogador em local seguro. A camera inicial mostra o cemiterio completo. A CI testa presenca da textura e capacidade de deslocamento do jogador.

## Versao 0.5 — piso reorganizado
- Terreno em grid de **32 x 32 px**, com grama, terra e pedra.
- A grama nao repete quadriculados de imagens recortadas; caminho com pedras de juntas irregulares.
- **GroundLayer** desenha apenas o chao; **PropsLayer** conserva construcoes, objetos e NPCs.
- Rotas entre portao, administracao, oficina, jazigo B-13 e jardins sao validadas automaticamente.
- Personagem, camera, salvamento, controle e missao preservados.

## Versao 0.6 — Lote 1: 10 covas/tumulos reais
- 10 PNGs individuais, 4 covas e 6 tumulos, em `assets/props/` com transparencia.
- `GravesLayer` exibe os objetos sem cortes de atlas; `graves_layout.gd` define posicoes, escala e colisao por ID.
- O B-13 recebeu a imagem `Cova_01` com marcador dinamico, preservando a interacao e o progresso.
- Os tumulos genericos do atlas antigo nao sao mais desenhados; demais predios, personagens, logica e UI foram preservados.
- Novo smoke test confere as 10 texturas e verifica acesso e colisao da cova B-13.

## Versão 0.7 — Primeiras árvores góticas
- O cenário agora inclui 4 árvores novas retiradas das nossas artes originais, em `assets/trees/`.
- `TreeLayer` carrega PNGs independentes e evita os cortes do atlas anterior.
- A colisão corresponde apenas ao tronco/raízes; caminhos e missões permanecem acessíveis.
- As demais árvores criadas ficam para uma próxima rodada de posicionamento e testes.

## Versão 0.8 — Menu inicial gótico
- Tela inicial própria com lua, capela, árvores góticas e tipografia dramática.
- **Continuar expediente** verifica o salvamento local; **Novo jogo** exige confirmação se houver progresso.
- Painéis interativos **Como Jogar** e **Créditos**.
- No cemitério, **Esc** sem diálogo ou botão **MENU** permite salvar e voltar à abertura.
- Testes da Godot agora validam o menu e a preservação do jogo. Detalhes em `docs/MENU_V08.md`.

## Versão 0.9 — Distrito dos Eternos
- Mapa ampliado para 2432 x 1408 pixels; camera acompanha o protagonista com limites do terreno.
- Novos setores: hospital, sala de conservacao, crematório, garagem, carros funerarios, posto de fiscalizacao e Arquivo Legal.
- Nova campanha de sete etapas depois da primeira missao; cartorio, translado, biosseguranca, cremacao, ambiente e orcamento.
- Fontes oficiais e ressalvas em `docs/DISTRITO_V09.md` e `scripts/systems/legal_lessons.gd`.
- Primeiras construcoes do distrito sao **arte provisoria modular**, para substituir depois por sprites independentes.
- Antigos salvamentos ate a etapa 5 continuam validos; o proximo objetivo passa a ser o hospital.

## Versao 1.0 — Interiores, Emporio e clientes
- Distrito expandido para 3072 x 1408, Casa Funeraria Umbra e Emporio das Ultimas Coisas.
- Nove ambientes internos acessiveis por portas: escritorio, hospital, garagem, conservacao, crematorio, arquivo, fiscalizacao, funeraria e fornecedora.
- Protagonista pode caminhar nos interiores, conversar com atendentes e clientes, examinar catalogo e consultar mural.
- Campanha paralela de 20 atendimentos humanos com perfis variados (calmo, enlutado, estranho, desconfiado etc.).
- Estoque real no jogo: compra de caixoes e urnas cinerarias, custos ficticios e consumo por caso.
- Pausa e salvamento persistem entre exterior e interior. Testes automatizados evitam quebrar as versoes anteriores.
- Conteudo educacional refere-se ao CDC, ao registro civil, ao ambiente e a regras sanitarias, sempre com ressalvas locais.

## Sprint 1.1: interiores próprios e transição
- A oficina/manutencao agora e uma sala visitavel; sua fachada continua idêntica.
- Escritorio e oficina tem cenas individuais de arte em `scenes/interiors/`.
- Entradas e saidas usam cortinas goticas animadas de CanvasLayer, com troca no momento de fechamento.
- O progresso e o fluxo dos 20 casos foram preservados. Mais detalhes em `docs/SPRINT_V11.md`.

## Sprint 1.1 mobile
- Tela planejada para smartphone Android em modo paisagem, conservando o jogo no computador/Web.
- Joystick multitouch a esquerda, Interagir/Diario/Menu a direita, posicionados com ancoras.
- Caixas de dialogo centralizadas e rolaveis; botoes grandes com quebra de linha para casos longos.
- Controles touch somem nos dialogos e nas transicoes de porta.
- Android APK/AAB e publicacao na Google Play **ainda nao foram realizados**; `docs/MOBILE_V11.md` explica os proximos requisitos.

## Versao 1.1.1 — Sprites do escritorio e da manutencao
- 12 PNGs individuais extraidos do kit gótico do autor, com transparência.
- Escritório com mesa, tapete, vitral, estante, armário e porta.
- Oficina com bancada, painel de ferramentas, prateleiras, vitral, carrinho e porta.
- Transição com 8 quadros de animação gótica de porta ao entrar/sair.
- Fachadas e missões mantidas. Documentação: `docs/SPRITES_INTERIORES_V111.md`.

## Versão 1.2 — Diálogos e escolhas
- Vinte casos com textos próprios, pistas e quatro patamares de complexidade (2, 3, 4 ou 5 etapas).
- Humor acolhedor e abordagem séria são caminhos igualmente válidos quando responsáveis.
- Respostas parciais permitem revisão; atalhos inseguros bloqueiam a conclusão até serem corrigidos.
- Retratos provisórios modulares podem ser substituídos por character sheets em PNG sem mudar o motor.
- Decisões e reações persistem no save local. Narrativas em `scripts/systems/dialogue_scenes.gd`.

# Lote real de sprites — Interiores 1.1.1 (23/11/2026)

## Integracao
Os sprites usados sao derivados diretamente das **artes aprovadas** do escritorio, da oficina e da sequencia de oito quadros de porta. Os PNGs transparentes foram recortados respeitando os limites visuais e redimensionados para renderizacao pixel art em aparelhos mais modestos. Sao independentes e podem ser movidos sem editar a arte.

- `assets/interiors/office/`: mesa, estante, armario, janela, porta, tapete.
- `assets/interiors/maintenance/`: bancada, painel de ferramentas, prateleiras, janela, porta, carrinho de mao.
- `assets/interiors/transitions/door_anim_8.png`: animacao original 4 colunas x 2 linhas, 68x95 pixels por quadro.

## Render
`office_decor.gd` e `maintenance_decor.gd` criam Sprite2Ds nomeados por componente. O piso, as paredes, NPCs e os pontos de interacao continuam na camada interior existente. Os moveis genericos nao sao mais desenhados no escritorio ou oficina.

`door_transition.gd` usa TextureRect com AtlasTexture para percorrer os quadros da porta: quadros 0-3 ao fechar e 4-7 ao abrir. A troca de sala ocorre somente com as cortinas completamente fechadas. O modo de teste headless troca instantaneamente para preservar o smoke test.

## Restricoes
- Fachadas do escritorio e da manutencao **inalteradas**.
- Caminhos centrais e pontos de interacao livres.
- Camera e UI mobile existentes preservados.
- Nenhuma imagem de referencia precisa ser recortada em runtime para os moveis; cada PNG e individual.
- As texturas sao otimizadas para jogo web e Android; o kit original permanece o arquivo-fonte de arte.

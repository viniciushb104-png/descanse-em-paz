# Menu cômico — turminha do cemitério

## Identidade visual
Arte de fundo: protagonista, Seu Osvaldo, Baltazar e gato preto no Jardim do Último Suspiro. Os personagens ficam à esquerda, enquanto os controles ocupam o gramado à direita. A composição é 16:9 (1152 × 648).

## Integração
- Cena de entrada preservada: `scenes/menu/main_menu.tscn`.
- Script do menu: `scripts/ui/main_menu.gd`.
- Ornamentos interativos: `scripts/ui/menu_grave_marker.gd`.
- Imagem que deve ser carregada: `assets/menu/menu_turma.png`.

O PNG é carregado por `ResourceLoader.exists`; até sua importação, o jogo abre com o cenário procedimental antigo, sem quebrar o menu. A interface é nativa da Godot e **não** deve ser embutida no fundo. O código desenha duas placas de caixão (Continuar e Novo Jogo) e duas lápides (Como Jogar e Créditos), com borda dourada ao passar o mouse ou receber foco pelo teclado/controle. Área de clique/toque: 286 × 56 px no viewport de 1152 × 648.

## Como adicionar a imagem
1. Adicione `menu_turma.png` nesta pasta (`assets/menu/`) com exatamente esse nome, usando o PNG fornecido na conversa.
2. Abra o projeto no Godot para importar o arquivo.
3. Execute o jogo. A cena principal e todas as ações de salvamento permanecem intactas.

## Preservação do gameplay
- `Continuar` só ativa com `user://save.cfg`.
- `Novo Jogo` solicita confirmação antes de apagar o único salvamento existente.
- `Como Jogar` e `Créditos` abrem os mesmos modais de antes.
- Não há mudanças em `scenes/main.tscn`, interiores, personagens, missões, estoque ou controles móveis.
- O fundo é uma imagem estática nesta etapa; um loop do Gemini poderá ser acrescentado posteriormente como uma camada visual não interativa.

## Arquitetura mobile
Os botões são `Button`s reais e aceitam mouse, teclado e toque. O projeto preserva o viewport de 1152 × 648 com aspect `keep`. Antes de lançar na Play Store, testar em telas físicas com diferentes proporções e áreas seguras (notch).

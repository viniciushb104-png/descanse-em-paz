# Menu cômico — turminha do cemitério

## Identidade visual
Arte de fundo: protagonista, Seu Osvaldo, Baltazar e gato preto no Jardim do Último Suspiro. Os personagens ficam à esquerda, enquanto os controles ocupam o gramado à direita. A composição é 16:9 (1152 × 648).

## Integração
- Cena de entrada preservada: `scenes/menu/main_menu.tscn`.
- Script do menu: `scripts/ui/main_menu.gd`.
- Ornamentos interativos: `scripts/ui/menu_grave_marker.gd`.
- Imagem que deve ser carregada: `assets/menu/menu_turma.png`.

O PNG original **já está integrado ao repositório** (1152 × 648, imagem binária idêntica à arte aprovada). É carregado por `ResourceLoader.exists` e aparece atrás dos personagens, do logotipo pendurado e dos controles. O fundo procedimental só é usado caso o recurso esteja ausente. A interface é nativa da Godot e **não** deve ser embutida no fundo. O código desenha duas placas de caixão (Continuar e Novo Jogo) e duas lápides (Como Jogar e Créditos), com borda dourada ao passar o mouse ou receber foco pelo teclado/controle. Área de clique/toque: 286 × 56 px no viewport de 1152 × 648.

## Instalação já concluída
O arquivo `assets/menu/menu_turma.png` faz parte da branch `main`. Não é necessário upload manual nem download de pacote externo. Ao abrir o projeto no Godot, o editor importa a textura automaticamente. `tests/menu_smoke.gd` verifica carregamento, dimensões, ordem de camadas e clique/toque livre.

O logotipo oficial `assets/menu/logo_descanse_em_paz.png`, integrado em versão 1.2.2, continua separado e animado. Sua oscilação não altera o fundo nem a interface.

## Preservação do gameplay
- `Continuar` só ativa com `user://save.cfg`.
- `Novo Jogo` solicita confirmação antes de apagar o único salvamento existente.
- `Como Jogar` e `Créditos` abrem os mesmos modais de antes.
- A integração do fundo não alterou `scenes/main.tscn`, interiores, personagens, missões, estoque, minigame do carro funerário nem controles móveis.
- O fundo é uma imagem estática nesta etapa; um loop do Gemini poderá ser acrescentado posteriormente como uma camada visual não interativa.

## Arquitetura mobile
Os botões são `Button`s reais e aceitam mouse, teclado e toque. O projeto preserva o viewport de 1152 × 648 com aspect `keep`. Antes de lançar na Play Store, testar em telas físicas com diferentes proporções e áreas seguras (notch).

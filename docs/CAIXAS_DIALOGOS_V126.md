# Santa Mortalha — Molduras individuais de diálogos (v1.2.6)

## Referência de design
Segue a estrutura de interface consagrada em `Jack, o Miserável — Caminhos de Luz`: **retrato preso à janela esquerda**, **nome em placa ornamental superior**, **fala no painel central** e **alternativas numa área independente**, sem encostar na borda. Letras creme/douradas sobre materiais góticos, com bom contraste.

## Entrega técnica
- `scripts/ui/dialogue_characters.gd`: registro de **46 pessoas**: 10 funcionários recorrentes, 20 clientes e 16 vozes secundárias. Cada identidade inclui nome, função, paleta de cores, adorno, fisionomia provisória e caminho opcional de PNG definitivo.
- `scripts/ui/dialogue_frame.gd`: desenha o painel ornamental, metal, brasão, encaixe do retrato, placa do nome, área de fala e painel de escolhas. A moldura muda conforme o falante.
- `scripts/ui/client_portrait.gd`: busto provisório individualizado por cabelo, figurino, acessório e expressão (fantasma, coveiro, médica, atendimento, fiscal etc.). Renderiza PNG específico quando disponível, mantendo a proporção e sem cortar.
- `scripts/main.gd`: detecta automaticamente os interlocutores já existentes, inclusive diálogos antigos de Seu Osvaldo e Baltazar; mostra nome e função, ajusta leitura e preserva rolagem, teclas 1–4 e botões mobile. As caixas institucionais sem locutor continuam sem retrato.
- `tests/dialogue_frames_smoke.gd`: percorre 46 identidades e verifica encaixes, cores, troca de interlocutor, conteúdo e versão longa.

## Próximos assets
O sistema **não afirma que os retratos definitivos já foram desenhados**. Para incorporar um PNG de personagem, criar arquivo em `assets/portraits/<id>.png` seguindo o `id` cadastrado, retrato vertical RGBA com fundo transparente, busto centralizado e margens para cabelo/chapéu, por exemplo `assets/portraits/baltazar.png`. Depois da importação, o retrato substitui o boneco provisório sem mudar posicionamentos nem lógica de diálogos.

Para cada novo personagem, adicionar ao registro o nome e apelidos, função, perfil, cor, sombra, símbolo e caminho do retrato. Evitar reutilizar imagens de outros personagens ou modificar as fachadas aprovadas.

## Continuidade e mobile
Retornos, economia, save, missões, menus e controles mobile não são alterados. Painel ancorado à parte inferior, numa base Godot de 1152×648; área de respostas e fala com rolagem independente; janela do retrato fisicamente separada da leitura. O sistema continua válido para modo paisagem na futura exportação Android.

# Santa Mortalha v1.2.7 — Lote 1 das molduras integrado

Fonte: PNGs transparentes criados e aprovados nesta conversa em 23/11/2026.

## Arquivos
- `assets/dialogue/lote_01/base_dialogue.png`: moldura-base com abertura lateral, espaço de fala, duas guias para respostas e placa superior vazia
- `portrait_frame_baltazar.png`, `portrait_frame_osvaldo.png`, `portrait_frame_amalia.png`: ornamentos **vazios**, sem rosto integrado
- `nameplate_baltazar.png`, `nameplate_osvaldo.png`, `nameplate_amalia.png`: placas sem texto
- `answer_button.png`: botão de resposta sem texto, com caveirinha

## Integração
`scripts/ui/dialogue_art_lote_01.gd` mapeia texturas por ID. Os três retratos provisórios ficam **atrás** das molduras novas; nomes, cargos, falas e alternativas continuam nativos da Godot. A placa e o enquadramento mudam automaticamente quando Baltazar, Seu Osvaldo ou Madame Amália começam a falar. Os outros personagens preservam as molduras coloridas anteriores, até receberem suas artes próprias.

A moldura utiliza a proporção original de 727x299, ampliada à largura do painel de 894px, sem distorção. Botões recebem uma StyleBoxTexture com margens para proteger os detalhes e permitir escalonamento e texto mais longo. Rolagem e botões no celular são preservados. Nenhuma fachada nem sprite do mapa foi alterado.

## Próximo passo artístico
Os quadros produzidos não possuem o rosto do personagem. Para substituir os bustos atuais, adicionar PNGs RGBA em `assets/portraits/baltazar.png`, `osvaldo.png` e `amalia.png` preservando a janela da moldura. Não gravar falas dentro das imagens.

# Retratos com expressões — Santa Mortalha 1.2.8

## Arte integrada
12 PNGs RGBA individuais aprovados pelo autor, com 4 expressões para cada um:
- Baltazar (contabilidade fantasma)
- Seu Osvaldo (coveiro)
- Madame Amália (funerária)

Emoções disponíveis: preocupado, alegre, surpreso e irônico. O código em `scripts/ui/portrait_expressions.gd` mapeia cada expressão para `assets/portraits/expressions/<id>_<emocao>.png`.

São versões **352×352 otimizadas para Web/mobile**, derivadas dos PNGs originais 627×627 sem editar a identidade visual. Os originais permanecem no pacote artístico do projeto (fora do repositório); não foram perdidos.

Baltazar e Seu Osvaldo têm detalhes da moldura pintados no próprio retrato: para eles, a moldura do lote anterior fica oculta, mas a placa de nome e o painel principal permanecem. Madame Amália usa sua moldura externa do lote anterior. Textos continuam nativos da Godot; o sistema de carregamento mantém fallback para outros personagens.

## Como testar
- No PC, abra um jogo e pressione **J** (Diário); escolha **Galeria de retratos (teste)**.
- No celular, use o botão **Diário** e entre na mesma galeria.
- Escolha Baltazar, Seu Osvaldo ou Madame Amália e troque entre as quatro expressões.
- A galeria não altera caixa, reputação, conformidade, missões ou estoque.

A inferência textual escolhe a expressão em falas antigas; os casos com diálogo estruturado agora podem indicar explicitamente a emoção pela etapa da conversa. Escolhas arriscadas evocam preocupação; reações e situações podem usar surpresa ou ironia.

## Testes
`tests/portraits_expressions_smoke.gd` verifica existência e transparência das 12 imagens, tamanho, troca de expressão, placas, molduras, leitura, alternativas e preservação de estado. Testes do lote anterior foram atualizados para reconhecer quando a arte já contém uma moldura.

## Próximas melhorias
Os retratos são provas de conceito; vale conferir no navegador o tamanho visual e eventuais cortes antes de aprovar o posicionamento definitivo para Play Store.

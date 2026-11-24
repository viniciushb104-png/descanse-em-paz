# Minigame 02 — O Ofício de Osvaldo (protótipo jogável)

## Entrada no jogo
- O NPC **Seu Osvaldo**, no mapa externo, inicia o minigame diretamente com **E/Interagir** quando existe uma ordem de sepultamento **explicitamente autorizada**.
- Sem ordem pendente, Osvaldo conserva os diálogos de sempre.
- Um marcador **SERVIÇO!** aparece sobre Osvaldo somente com trabalho disponível.
- A primeira ordem é o tutorial do **B-13**, liberada depois de conferir a documentação, reservar o jazigo e registrar o atendimento da missão de abertura (**stage >= 4** e `reserved_plot = true`).
- Não convertemos automaticamente os 20 atendimentos em sepultamentos: casos de aconselhamento, cremação ou fornecimento continuam sendo apenas o que dizem.

## Gameplay (sem perguntas em sequência)
1. **Separar as ferramentas** — três itens interativos.
2. **Limpar o jazigo** — cinco pontos de folhas.
3. **Preparar o terreno** — seis partes do solo interativas (abstração lúdica).
4. **Posicionar o caixão** — controle horizontal arrastável para acompanhar o movimento; setas também funcionam.
5. **Finalizar** — nivelar, conferir identificação e arrumar flores na ordem certa.

Os botões são **objetos jogáveis** e não respostas de diálogo. O visual é desenhado em 2D, reutilizando o sprite de Osvaldo de `assets/art/characters.png`; não requer baixar imagens extras. A simulação é estilizada e **não substitui treinamento técnico ou normas de sepultamento reais**.

## Controles
- **Mouse:** clique em ferramentas, pontos do cenário e arraste o controle horizontal na etapa 4.
- **Celular:** toque nos objetos e arraste o controle; os controles do mapa ficam suspensos.
- **Teclado:** números 1 a 6 para selecionar alvos nas etapas 1, 2, 3 e 5; setas esquerda/direita (ou A/D) para a etapa 4.
- **Sair:** Esc ou o botão **Guardar e voltar**. A retomada acontece novamente pelo NPC e conserva o progresso.

## Persistência
A fila está em `scripts/systems/burial_service_queue.gd`, com dados em `user://save.cfg`:
- `burial_orders`: lista dos serviços e seu progresso
- `burial_initial_issued`: trava contra duplicação do B-13

A conclusão é registrada uma única vez: reputação e conformidade podem aumentar, mas **a receita já registrada no escritório não é cobrada novamente**.

## Visual persistente no mapa
O B-13 preparado troca a arte da cova pelo PNG de um túmulo já existente, com a indicação **B-13 CONCLUÍDO**. O restante das fachadas, das construções, das sepulturas e das rotas do mapa não é alterado.

## Extensão futura para clientes
Somente um caso que **explicitamente** possua uma ordem de sepultamento e conclua sua narrativa e auditoria poderá abrir um novo serviço. O sistema verifica o metadado `burial_order`, por exemplo:

```gdscript
"burial_order": {
    "plot": "B-14",
    "documents_checked": true,
    "authorized": true
}
```

Este metadado só pode ser usado quando o **roteiro do caso** comprovar que a documentação foi conferida e que o procedimento está autorizado. **Nenhum** dos 20 casos legados foi marcado automaticamente, porque vários não descrevem um enterro autorizado.

## Arquivos afetados
- Novo: `scripts/systems/burial_service_queue.gd`
- Novo: `scripts/minigames/oficio_osvaldo.gd`
- Integrado: `scripts/main.gd`
- Integração futura em casos: `scripts/systems/interior_runtime.gd`
- Visual do jazigo: `scripts/world/graves_layer.gd`
- Teste: `tests/oficio_osvaldo_smoke.gd`

## Verificar na Godot
Na raiz do projeto, com Godot 4.x compatível:

```sh
godot --headless --path . --script res://tests/oficio_osvaldo_smoke.gd
```

Abrir o jogo, completar as etapas iniciais até registrar o atendimento B-13, voltar até Seu Osvaldo e interagir. Iniciar, realizar uma etapa, sair, recarregar o jogo e retomar. Finalizar e verificar a mudança do B-13 no mapa.

## Proteções
- Não reescreve as missões originais, a economia, o menu, os interiores, a direção ou o salvamento antigo.
- A ordem só nasce depois de ser explicitamente autorizada.
- Não há sepultamento efetivo sem jogar as etapas.
- Não revela corpos nem procedimentos gráficos.
- Os personagens permanecem com suas artes e personalidade existentes.

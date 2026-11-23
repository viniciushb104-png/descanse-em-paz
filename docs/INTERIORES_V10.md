# V1.0 — Atendimento funerario e edificios por dentro

## Entrega
9 salas tematicas exploraveis; 2 novos predios: Casa Funeraria Umbra e Emporio das Ultimas Coisas; vinte casos humanos com escolha, impacto na reputacao e conformidade, fontes legais, controle de estoque e caixa ficticio.

## Controles
No mapa, E proximo da entrada abre opcoes. Escolha Entrar, ande na sala com WASD/setas; E no atendente, cliente, catalogo, mural ou saida. Esc abre pausa. O salvamento do local e do progresso e unico e preserva os indicadores anteriores.

## Integracao
`scripts/world/interior_catalog.gd` define as salas e estacoes, `interior_layer.gd` desenha cada interior em camadas simples, `scripts/systems/interior_runtime.gd` cuida de entradas, saidas, compras, atendimento e persistencia, `customer_cases.gd` define os vinte roteiros. `main.gd` mantem movimento, dialogos, HUD e missao original.

## Valores, etica e legislacao
Todos os valores sao ficticios. O atendimento nao deve impor produtos opcionais, esconder precos ou explorar vulnerabilidade de familias. Direito a informacao clara e orcamento discriminado: Lei 8.078/1990, arts. 6, 39 e 40:
https://www.planalto.gov.br/ccivil_03/leis/l8078compilado.htm

Registro civil e cremacao: Lei 6.015/1973, art. 77:
https://www.planalto.gov.br/ccivil_03/leis/l6015compilada.htm

Residuos de servicos de saude, incluindo funerarias e atividades de tanatopraxia no alcance aplicavel: Anvisa RDC 222/2018:
https://www.gov.br/anvisa/pt-br/assuntos/servicosdesaude/gerenciamento-de-residuos

Normas estaduais e municipais tambem se aplicam; o jogo nao substitui assessoria juridica ou treinamento sanitario.

## Proxima arte
As salas usam primeiro geometria gotica modular. Convertidas, futuramente, em sprites PNG separados de escritorios, urnas, caixoes, prateleiras e NPCs, com hitboxes proprias. Nao voltar a recortar imagens compostas.

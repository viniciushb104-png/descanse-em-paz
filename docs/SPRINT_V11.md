# Sprint 1 da versao 1.1 — Ambientes e mobile

## Mantido sem alteracoes
As fachadas do escritorio/administracao e da manutencao, o protagonista, as arvores goticas, covas e tumulos aprovados, os 20 atendimentos e toda a economia.

## Implementado
- Sala propria `scenes/interiors/office.tscn` com decoracoes góticas autorais.
- Sala propria `scenes/interiors/maintenance.tscn` com bancada, ferramentas e armazenamento.
- Transicao de cortinas/portas em `scripts/ui/door_transition.gd`, cobrindo a cena antes de trocar de ambiente; atalhos headless para CI.
- `maintenance` agora integra o catalogo de interiores.
- Entrada e saida permanecem ligadas aos pontos do mapa e aos salvamentos.
- Etapa mobile da sprint continua nas proximas alteracoes de UI.

## Proxima camada de arte
Os elementos das salas estao desenhados de forma modular. A arquitetura permite trocar cada desenho por PNG individual com origem e colisao claras, sem utilizar recortes improvisados de pranchas.

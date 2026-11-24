# Lote 2: seis novas molduras de diálogo

## Elenco e tema
| ID | Personagem | Decoração | Célula do atlas |
|---|---|---|---|
| cinerio | Seu Cinério Brasa | Caveira, veludo e velas | (0,0) |
| penelope | Dra. Penélope Alvorada | Vitral, hera, lanternas | (1,0) |
| clotilde | Dona Clotilde Eternélia | Caixão e rosas | (2,0) |
| arquimedes | Arquimedes Ossário | Engrenagens e relógio | (0,1) |
| gervasio | Gervásio Caixote | Abóbora e galhos | (1,1) |
| umbelina | Umbelina | Fantasmas e velas | (2,1) |

## Implementação
- Um atlas PNG RGBA de 768×512 (`assets/dialogue/lote_02/molduras_lote_02_game_atlas.png`), 3 colunas e 2 linhas, células 256×256.
- As janelas centrais estão transparentes. Cada moldura é recortada por `AtlasTexture`, no módulo `scripts/ui/dialogue_art_lote_02.gd`.
- A placa ornamental vem integrada à moldura e o nome é renderizado em `PortraitNameplateText`, sem texto gravado no PNG.
- Integração com o motor de diálogos existente `dialogue_art_lote_01.gd`; os três atores do Lote 1 continuam usando seus PNGs originais, inclusive as molduras já integradas aos retratos expressivos de Osvaldo e Baltazar.
- Não há alterações nas falas, decisões, níveis de atendimento, saldos, missões ou salvamentos.
- Clientes e participantes sem arte personalizada mantêm a moldura procedural anterior.
- Teste: `tests/dialogue_lote2_smoke.gd` acionado no workflow de publicação.

Os seis retratos com molduras devem ser verificados no navegador e celular. O teste automatizado cobre identificação, transparência, hierarquia e ausência de sobreposição com falas/escolhas.

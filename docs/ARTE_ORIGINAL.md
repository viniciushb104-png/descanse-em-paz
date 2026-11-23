# Arte original integrada ao jogo — v0.3

Agora `assets/art/world.png` e `assets/art/characters.png` contem **recortes em pixel art das imagens geradas para o Jardim do Ultimo Suspiro**. A importacao de ambas as imagens e feita com atlas e regioes em `scripts/map_art.gd` e `scripts/player.gd`.

Esses atlas sao versoes otimizadas em PNG de 64 cores para acelerar a abertura no navegador. A versao original (PNG de alta resolucao) continua no kit de artes distribuido separadamente.

**Notas de arte:**
- capela, oficina, arvores roxas, fonte, muros, portao, jazigos e outras pecas agora sao PNG recortados das imagens criadas;
- protagonista usa imagens reais nas quatro direcoes, com os frames da animacao;
- Osvaldo e Baltazar usam imagens reais, com alternancia simples de dois quadros;
- nomes, valores e missao sao desenhados na interface e preservados, nao estao embutidos nas texturas;
- para melhorar os pixels: revisar recortes com halo, ajustar limites de colisao e associar mais quadros para cada NPC.

## Limitacoes tecnicas e de fidelidade
As ilustracoes originais foram geradas como folhas artisticas, nao em uma grade de pixels perfeitamente uniforme. Alguns recortes podem conter pequenas partes vizinhas e halos. A integracao V0.3 prioriza finalmente mostrar **as imagens de pixel art oficiais** ao jogar, sem ainda prometer animacoes finais de producao.

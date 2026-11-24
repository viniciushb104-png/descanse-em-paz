# Logo pendurado — Menu principal (v1.2.2)

O logotipo oficial aprovado de **Descanse em Paz & Pague em Dia** foi inserido como PNG transparente em `assets/menu/logo_descanse_em_paz.png`, preservando a ornamentacao, correntes e letras douradas. A textura foi otimizada a 1100×584 pixels (paleta RGBA indexada) para reduzir o peso na Web e em celulares, sem necessidade de atlas ou recortes durante o jogo.

`scripts/ui/main_menu.gd` instala um `TextureRect` nomeado `HangingGameLogo` no canto superior esquerdo. Ele usa 546×290 unidades de tela em uma base de 1152×648 e gira ao redor de um pivo central no topo. A oscilacao é uma senoide discreta de cerca de **1,5 grau**, periodicidade de aproximadamente 7,6 segundos. Nao existe queda de fato: o movimento simula uma placa suspensa pelas correntes.

O texto grande anterior foi retirado para evitar titulo duplicado. A frase de humor fica abaixo do logotipo. Fundo ilustrado, quatro botoes em forma de lapides/caixoes, dialogos, creditos, salvamento e versao mobile foram preservados.

Teste `tests/menu_smoke.gd` verifica carregamento, transparencia de hit test e movimento. Esta atualizacao afeta somente o menu principal, nao modifica fachadas, interiores nem o estado do jogo.

# Gato do Cemitério — assets integrados

O pacote original de 43 quadros transparentes está **no GitHub** em `assets/cat/gato_santa_mortalha_sprites.zip`. Todos os quadros possuem 112 × 112 px. Os nomes dentro do ZIP seguem `assets/cat/<animacao>_<quadro>.png`.

`scripts/world/cemetery_cat.gd` carrega automaticamente os PNGs individuais, se houver, ou lê os quadros direto do ZIP por meio de `ZIPReader` e `ImageTexture`. O pacote é incluído no export Web por `export_presets.cfg`.

Animações: idle (4), sit (5), walk_right (8), walk_left (8), meow (4), pet (6), purr (4), sleep (4).

O gato aparece no mapa externo, passeia, mia e aceita carinho pelo comando de interação. Nunca fala; não altera dinheiro ou missões. A representação procedural continua como fallback caso os recursos não possam ser carregados.

Verificar execução na Godot 4.7.2 e no navegador após o deploy: o gato deve aparecer usando a arte nova; andar em ambas direções, miar, ser acariciado, ronronar, sentar e dormir. Confirmar Android quando houver build.

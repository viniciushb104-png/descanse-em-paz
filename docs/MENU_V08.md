# Menu Inicial — v0.8

## Conceito
Menu original de comedia gotica de Santa Mortalha, que reutiliza a **arte ja presente no repositorio** (capela e arvores goticas) para preservar a identidade do jogo. O titulo e as acoes sao elementos de interface, nao texto fixo em imagens. A atmosfera inclui lua, ceu roxo, nevoa sutil e pequenas luzes.

## Cena principal
`project.godot` inicia `scenes/menu/main_menu.tscn`; o jogo permanece em `scenes/main.tscn`. Os testes existentes que instanciam a cena jogavel continuam funcionando.

## Acoes
- Continuar: habilitado somente com `user://save.cfg`; carrega o expediente gravado.
- Novo Jogo: quando existe salvamento, pede confirmacao **antes de apagar**. Se a exclusao falhar, nao inicia um falso novo jogo.
- Como Jogar: controles e objetivos.
- Creditos: autoria e ferramentas.
- No jogo: `Esc` (quando nao houver dialogo) ou botao MENU abre a pausa; "Salvar e ir ao menu inicial" retorna sem perder o progresso.

## Garantias
Nenhum arquivo anterior de cova, tumulo, arvore, personagem ou missao foi substituido. Uma nova verificacao em CI testa a abertura e os botoes informativos, e a cena jogavel permanece testada pelo smoke test existente.

## Observacao Web
Os arquivos de salvamento usam `user://` local ao navegador. Diferentes navegadores ou limpeza de dados podem afetar a persistencia. Esta versao conserva apenas um slot de save.

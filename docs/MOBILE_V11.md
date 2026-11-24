# Versao 1.1 — Fase mobile (Android/Web)

## Escopo implementado
- Projeto Godot 4.7.2 configurado para **paisagem** (landscape).
- HUD com ancoras: painel de missao no topo direito, controles no canto inferior em dispositivos de toque, dialogo centralizado.
- Joystick analogico com multitouch, botao de interacao, diario e pausa.
- Controles de toque se ocultam durante dialogos ou transicoes.
- Caixas de dialogo com corpo e alternativas em **rolagem**, para que normas e estudos de caso longos possam ser lidos no celular.
- Teclado e versao Web/PC continuam disponiveis; codigo do toque funciona no navegador de celular quando o dispositivo informa capacidade touch.

## Nao e publicacao Android
A versao 1.1 **ainda nao gera APK nem AAB assinado**. A proxima etapa exige instalar templates e toolchain Android, criar export preset e assinatura, testar em aparelhos fisicos, verificar requisitos e politica da Google Play na data do lancamento, avaliar acessibilidade, privacidade e performance.

## Testes
`tests/mobile_smoke.gd` verifica joystick, sinal de movimento, bloqueio durante dialogos e area rolavel. A publicacao Web continua em GitHub Pages.

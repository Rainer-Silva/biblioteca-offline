# Biblioteca Offline de Sobrevivência

Uma biblioteca do conhecimento humano que funciona **sem internet**, num HD/SSD de 1 TB:
enciclopédias (Wikipédia e outras), manuais de saúde, agricultura (Embrapa), sobrevivência,
manuais do Exército Brasileiro, livros acadêmicos, mapas do Brasil, textos religiosos, e uma
**IA local** que responde perguntas citando as fontes, tudo em português.

**Criado por Breno Paiva**: Instagram [@breno.paiva40](https://instagram.com/breno.paiva40).
Feito para ajudar as pessoas em tempos difíceis. **Gratuito**: não estou cobrando nada, só peço
que me sigam no Instagram.

## Como instalar

Você precisa de:

- Windows 10 ou 11;
- um HD/SSD vazio de **1 TB**;
- internet para o download inicial (cerca de 830 GB).

> ⚠️ **Baixar o kit não é baixar a biblioteca.** O kit tem só ~28 MB: ele é o *instalador*.
> Se você só abrir o app sem rodar o `INSTALAR_BIBLIOTECA.bat`, ele abre **vazio**.

Passos:

1. **Baixe o kit:** abra
   **[github.com/brenobernardes25-afk/biblioteca-offline/releases/latest](https://github.com/brenobernardes25-afk/biblioteca-offline/releases/latest)**
   e clique em `Kit_Biblioteca_Offline_<data>.zip` (em "Assets").
   No celular, a parte de "Releases" fica lá embaixo da página. Faça isso **no computador**.
2. **Descompacte** o zip na **raiz** do HD/SSD vazio: botão direito no zip > *Extrair tudo…* > escolha
   a letra do HD (ex.: `E:\`). Não deixe dentro de uma pasta. Devem aparecer as pastas `App`,
   `_Baixador` e `Programas`, e os arquivos `INSTALAR_BIBLIOTECA.bat` e `ABRIR_BIBLIOTECA.bat`.
3. **Instale (é aqui que o conteúdo é baixado):** dê dois cliques em **`INSTALAR_BIBLIOTECA.bat`**.
   - Se o Windows mostrar "O Windows protegeu o computador", clique em *Mais informações* > *Executar assim mesmo*.
   - Vai abrir uma **janela preta**, que mostra o andamento. **Deixe-a aberta.**
   - Pode levar de horas a dias, conforme a internet (~830 GB).
   - Se fechar, faltar luz ou a internet cair, rode de novo: ele continua de onde parou.
4. **Use:** quando aparecer **PRONTO**, dê dois cliques em **`ABRIR_BIBLIOTECA.bat`**.
   - Abre outra **janela preta** e, em seguida, a biblioteca no navegador.
   - **Não feche a janela preta enquanto usa a biblioteca.** Ela é o programa; o navegador é só a tela.
     Para sair, aí sim feche a janela preta.

Leia o `LEIA-ME_PRIMEIRO.txt` que vem dentro do kit.

## Problemas comuns

- **A busca mostra "Failed to fetch" (ou nada acontece ao clicar):** a janela preta do
  `ABRIR_BIBLIOTECA.bat` foi fechada (ou o app foi aberto por um favorito/histórico do navegador).
  Dê dois cliques em `ABRIR_BIBLIOTECA.bat` de novo e **deixe a janela preta aberta**.
- **A busca diz "Nada encontrado" para tudo:** a biblioteca ainda não foi baixada. Rode o
  `INSTALAR_BIBLIOTECA.bat` (passo 3) e espere aparecer PRONTO. Logo depois da instalação, o app
  ainda monta o índice de busca por algumas horas; dá para ir usando enquanto isso.
- **Quero ver o que falta baixar:** abra o Prompt de Comando na pasta do HD e digite
  `INSTALAR_BIBLIOTECA.bat --verificar`.
- **Registro detalhado da instalação:** `_Baixador\instalador\instalacao_registro.txt`.

## O que o kit contém

O zip é pequeno (~28 MB) porque não leva o conteúdo em si. Ele traz:

- **O aplicativo**, que oferece:
  - busca
  - leitor
  - IA
  - tradutor
  - leitor de texto em fotos (OCR)
  - mapa
  - ajuda
- **Os baixadores** e o **Python portátil**.
- **Uma lista com mais de 54 mil arquivos**, cada um com o endereço público de onde vem.

O instalador baixa tudo direto das fontes originais, por exemplo Kiwix, Embrapa, SciELO,
Hesperian e Biblioteca Digital do Exército.

## Licenças

Cada material baixado pertence a quem o publicou e segue a licença da fonte original.
Alguns, como o Alcorão (Tanzil) e a Torá em português (Sefaria), são **apenas para uso
pessoal e não comercial**. As bibliotecas incluídas no app são de código aberto: MapLibre,
Protomaps, pdf.js, tesseract.js e Python.

Projeto pessoal, distribuído de graça. **Não é para venda.**

## Autor

**Breno Paiva**: se esta biblioteca te ajudou, me siga no Instagram:
[@breno.paiva40](https://instagram.com/breno.paiva40).

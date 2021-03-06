INCLUDE Irvine32.inc

.data
Xmargin BYTE ? ; Margem da lateral esquerda usada para centralizar o ambiente do jogo
CurrentLine BYTE 0 ; Auxilia na contagem de linhas ao desenhar o cenario
CurrentColumn BYTE 0; Auxilia na contagem de colunas ao calcular a posicacao na tela em que estao as portas

logo1 BYTE ' ______     ______     ______      ______   __  __     ______        __  __     ______     __  __ ',0dh,0ah,0
logo2 BYTE '/\  ___\   /\  ___\   /\__  _\    /\__  _\ /\ \_\ \   /\  ___\      /\ \/ /    /\  ___\   /\ \_\ \ ',0dh,0ah,0
logo3 BYTE '\ \ \__ \  \ \  __\   \/_/\ \/    \/_/\ \/ \ \  __ \  \ \  __\      \ \  _"-.  \ \  __\   \ \____ \',0dh,0ah,0
logo4 BYTE ' \ \_____\  \ \_____\    \ \_\       \ \_\  \ \_\ \_\  \ \_____\     \ \_\ \_\  \ \_____\  \/\_____\ ',0dh,0ah,0
logo5 BYTE '  \/_____/   \/_____/     \/_/        \/_/   \/_/\/_/   \/_____/      \/_/\/_/   \/_____/   \/_____/ ',0dh,0ah,0

msgVenceu1 BYTE " _  _ ____ ____ ____    _  _ ____ _  _ ____ ____ _  _ ",0dh,0ah,0
msgVenceu2 BYTE " |  | |  | |    |___    |  | |___ |\ | |    |___ |  | ",0dh,0ah,0
msgVenceu3 BYTE "  \/  |__| |___ |___     \/  |___ | \| |___ |___ |__| ",0dh,0ah,0
msgVenceu4 BYTE "                                                      ",0dh,0ah,0
msgVenceu5 BYTE "      Pressione qualquer tecla para continuar         ",0dh,0ah,0

; Menu
jogarString BYTE "JOGAR",0 ; Opcao do menu
posJogar WORD ? ; Posicao onde sera exibida a opcao "jogar"

instrucoesString BYTE "INSTRUCOES",0 ; Opcao do menu
posInst WORD ? ; Posicao onde sera exibida a opcao "Instrucoes"

msgMenu BYTE '"Maximize a janela antes de iniciar o jogo para uma melhor experiencia."',0
opcaoSelecionada BYTE 0 ; Armazena a opcao do menu selecionada em dado momento

textoInst BYTE "INSTRUCOES",0dh,0ah,0dh,0ah ; Texto das instrucoes do jogo
BYTE 'O  que e o jogo:',0dh,0ah,0dh,0ah
BYTE 'O "Get The Key" e um jogo que desafia o jogador a escapar de um labirinto por meio da resolucao de enigmas.',0dh,0ah,0dh,0ah
BYTE '=========================================',0dh,0ah,0dh,0ah
BYTE 'Objetivo:',0dh,0ah,0dh,0ah
BYTE 'Capturar a chave que se encontra centralizada no labirinto e fechada por 4 portas vermelhas no menor tempo possivel.',0dh,0ah
BYTE 'Para a abertura das portas o jogador precisa percorrer o labirinto passando pelos dispositivos (numeros) conforme a ordem crescente.',0dh,0ah
BYTE 'Cada um dos dispositivos compreende uma letra da resposta do enigma.',0dh,0ah
BYTE 'Uma vez acertada a resposta do enigma as portas centrais irao se tornar verdes, permitindo a passagem para resgatar a chave.',0dh,0ah,0dh,0ah
BYTE '=========================================',0dh,0ah,0dh,0ah
BYTE 'Como Jogar:',0dh,0ah,0dh,0ah
BYTE '1 - Leia  atentamente o enigma do jogo e descubra sua resposta. A resposta tem o tamanho da quantidade de numeros disponiveis no labirinto.',0dh,0ah
BYTE '2 - Use as setas de movimentacao do teclado para caminhar pelo labirinto.',0dh,0ah
BYTE '3 - Posicione-se sobre os numeros coloridos no cenario e digite a letra correspondente a resposta do enigma.',0dh,0ah
BYTE '    As letras serao computadas apenas se voce estiver com o jogador sobre um dos dispositivos.',0dh,0ah
BYTE '4 - Ao digitar a ultima letra (sobre o  ultimo numero) as portas que bloqueiam a passagem para a chave central ficarao verdes (SOMENTE SE A RESPOSTA ESTIVER CORRETA).',0dh,0ah
BYTE '    Caso a resposta n�o esteja correta, retorne aos numeros e digite as letras corretamente.',0dh,0ah
BYTE '5 - Ao acertar a resposta dirija-se ate a chave central (quadrado verde central). O cronometro sera pausado neste ponto e seu desempenho sera registrado.',0dh,0ah
BYTE 'Pronto. Voce VENCEU!',0dh,0ah,0dh,0ah
BYTE '=========================================',0dh,0ah,0dh,0ah
BYTE 'Desenvolvido por Felipe Sampaio e Juliano Lanssarini - Jan/2017',0dh,0ah,0

; Mapa
msgError BYTE "Erro ao abrir o arquivo com a fase do jogo.",0dh,0ah

minMap WORD ? ; Limite minimo do espaco onde o jogador pode se locomover
			  ; Formato (Limite X | Limite Y)
maxMap WORD ? ; Limite maximo do espaco onde o jogador pode se locomover
			  ; Formato (Limite X | Limite Y)

mapHeight = 36 ; Numero de linhas do mapa
mapWidth = 98 ; Numero de colunas do mapa

BUFSIZE = mapHeight*mapWidth + 200 ; Tamanho do mapa mais o tamanho do enigma+resposta (numero de bytes que sera lido do arquivo externo) 
BUFFERMAPA BYTE BUFSIZE DUP (?) ; Utilizado para guardar os dados do arquivo externo
mapMatrix BYTE BUFSIZE-200 DUP (?) ; Tamanho da matriz, retira 200 referente a parte do enigma
mapaFileName BYTE 'nivel1.mapa',0 ; Nome do arquivo externo que contem o mapa e o enigma
elementoAux BYTE ? ; Utilizado para armazenar temporariamente o conteudo da matriz que esta na posicao que o jogador esta tentando mover

;Estrutura Player
playerSymbol BYTE 0FEh ; Armazena o caracter que representa o jogador
playerX BYTE ? ; Posicao X do jogador na tela
playerY BYTE ? ; Posicao Y do jogador na tela
playerXAux BYTE ? ; Posicao X futura (que esta preste a mover), serve para verificar a validade do movimento
playerYAux BYTE ? ; Posicao Y futura (que esta preste a mover), serve para verificar a validade do movimento

; Estrutura Enigma
enigma BYTE 150 DUP (?) ; Contera a pergunta que sera exibida
labelResposta BYTE " RESPOSTA: ",0 ; Label que imprimida na tela antes da resposta inserida pelo usuario
OFFSETRESPOSTA = 74 ; Quantidade de espacamento para exibir a resposta
respostaOriginal BYTE 4 DUP(?) ; Contera a resposta original para ser comparada com a do jogador
respostaJogador BYTE 4 DUP(?) ; A letras fornecidas pelo jogador serao armazenadas aqui
statusResposta BYTE 0 ; Indica se a resposta foi descoberta ou nao
posRespostaJogador WORD ? ; Indica a posicao na tela onde a resposta do jogador sera exibida

; Portas
posPortas WORD 4 DUP (?) ; Armazena a posicao de cada porta

; Temporizador
tempoInicial DWORD ? ; Armazena o tempo inicial da partida para calcular o tempo decorrido
posTemporizador WORD ? ; Posicao onde sera desenhado o temporizador
labelTempo BYTE "TEMPO:",0 ; Label que antecede o temporizador

.code
main PROC
	call LoadMapaFile
	jnz RETORNA

INICIALIZADOR: ; Configuracoes iniciais
	call MenuInicial
	jz RETORNA

	call GetMaxXY ; Pega o tamanho do terminal atual para configurar as posicoes na tela
	sub dl, LENGTHOF logo1
	shr dl,1
	mov Xmargin,dl ; Calcula a margem esquerda em funcao do tamanho da tela e do logo, dessa forma o jogo sempre estar� centralizado

	call DrawLogo ; Desenha o logo do jogo 
	call DrawEnigma ; Desenha o local onde ficara o enigma e o proprio enigma (temos que resolver isso)
	call DrawMapa ; Desenha o mapa do labirinto
	mov al, BYTE PTR minMap ; Coloca o jogador em uma posicao predefinida no inicio (mudar essa parte em funcao do mapa)
	inc al
	mov playerX, al
	mov al, BYTE PTR minMap+1
	inc al
	mov playerY, al
	call DrawPlayer ; Desenha o jogador na tela na posicao configurada
	
	call GetMseconds
	mov tempoInicial,eax

MAINLOOP:
	call DrawTempo

	movzx cx, playerY
	push cx
	movzx cx, playerX
	push cx
	call GetElementoMatriz
	.IF al == ' '
		call ReadKey ; Le do teclado alguma tecla
		jz FIM ; Se nao foi apertada nenhuma tecla, pula para o fim da iteracao atual
		call HandleControl ; Caso contrario e realizada uma acao em funcao da tecla apertada
		cmp al,1
		jz INICIALIZADOR
	.ELSE
		mov elementoAux, al ; Coloca em elementoAux o caracter encontrado na posicao onde o jogador esta
		call ReadKey ; Le do teclado alguma tecla
		jz FIM ; Se nao foi apertada nenhuma tecla, pula para o fim da iteracao atual
		call HandleSenha
		cmp al,1
		jz INICIALIZADOR
	.ENDIF
FIM:
	mov eax, 50 ; Configura um delay de 50 milisegundos, isso garante que o jogo nao exija muita da cpu de forma desnecessaria e
				; cause bugs na leitura das teclas
	call delay
	jmp MAINLOOP ; Executa o loop principal do jogo

RETORNA:
exit
main ENDP

;---------------------------------------------------
ReiniciaVariaveis PROC
; Retorna o valor das variaveis principais para seu estado inicial (zeradas), para tornar possivel jogar de novo
; Recebe: resposta do jogador, status resposta
; Retorna: nada
;---------------------------------------------------
	mov edx, OFFSET respostaJogador
	mov bl, ' '
	mov ecx, 4
L1:
	mov [edx], bl
	inc edx
	loop L1

	mov statusResposta, 0

	ret
ReiniciaVariaveis ENDP
;---------------------------------------------------
MenuInicial PROC
; Desenha na tela o menu inicial e controla as opcoes de jogar ou ver as instrucoes
; Recebe: ?
; Retorna: al == 0 se pressionado o botao ESC, al == 0 caso contrario 
;---------------------------------------------------
INICIALIZADOR:
	mov opcaoSelecionada, 0
	call GetMaxXY ; Pega o tamanho do terminal atual para configurar as posicoes na tela (DL = X e DH = Y)
	push dx
	; Desenha o Logo
	sub dl, LENGTHOF logo1
	shr dl,1
	mov Xmargin,dl ; Calcula a magem esquerda em funcao do tamanho da tela e do logo, dessa forma o jogo sempre estar� centralizado
	call DrawLogo ; Desenha o logo do jogo
	
	mov al, '_'
	mov ecx, LENGTHOF logo1
	mov dl,Xmargin
	mov dh,CurrentLine
	inc CurrentLine
	call GoToxy 
L1:
	call WriteChar
	loop L1

	add CurrentLine, 1

	pop dx
	push dx

	sub dl, LENGTHOF msgMenu
	shr dl,1
	mov dh,CurrentLine
	call GoToxy
	mov edx, OFFSET msgMenu
	call WriteString

	add CurrentLine, 5

	pop dx
	push dx

	call GetTextColor
	push eax
	; Desenha a opcao Jogar
	sub dl, LENGTHOF jogarString
	shr dl,1
	mov dh,CurrentLine
	mov posJogar, dx
	dec dl
	call GoToxy
	mov al, '>'
	call WriteChar
	mov eax,black + (white * 16)
	call settextcolor
	mov edx, OFFSET JogarString
	call WriteString
	
	pop eax
	call settextcolor
	
	mov al, '<'
	call WriteChar
	
	add CurrentLine,2

	pop dx
	; Desenha a opcao Intrucoes
	sub dl, LENGTHOF instrucoesString
	shr dl,1
	mov dh,CurrentLine
	mov posInst, dx
	call GoToxy
	mov edx, OFFSET instrucoesString
	call WriteString
	 
MAINLOOP:
	call ReadKey
	jz FIM ; Se nao foi apertada nenhuma tecla, pula para o fim da iteracao atual
	
	.IF ah == 48h ; Se for seta para cima
		mov opcaoSelecionada, 0

		mov dx, posInst
		dec dl
		call GoToxy
		mov al, ' '
		call WriteChar
		mov edx, OFFSET instrucoesString
		call WriteString
		mov al, ' '
		call WriteChar

		call GetTextColor
		push eax
		
		mov dx, posJogar
		dec dl
		call GoToxy
		mov al, '>'
		call WriteChar
		mov eax,black + (white * 16)
		call settextcolor
		mov edx, OFFSET JogarString
		call WriteString
		
		pop eax
		call settextcolor

		mov al, '<'
		call WriteChar

	.ELSEIF ah == 50h ;Seta para baixo
		mov opcaoSelecionada, 1

		mov dx, posJogar
		dec dl
		call GoToxy
		mov al, ' '
		call WriteChar
		mov edx, OFFSET jogarString
		call WriteString
		mov al, ' '
		call WriteChar

		call GetTextColor
		push eax
		
		
		mov dx, posInst
		dec dl
		call GoToxy
		mov al, '>'
		call WriteChar
		mov eax,black + (white * 16)
		call settextcolor
		mov edx, OFFSET instrucoesString
		call WriteString
		
		pop eax
		call settextcolor

		mov al, '<'
		call WriteChar
	.ELSEIF al == 0dh ; Tecla enter
		mov al, opcaoSelecionada
		.IF al == 0
			jmp RETORNA
		.ELSEIF al == 1
			call Clrscr

			mov dh,1
			mov dl,0
			call GoToxy
			mov edx, OFFSET textoInst
			call WriteString
			
			call readChar
			call Clrscr
			jmp INICIALIZADOR
		.ENDIF
	.ELSEIF al == 01bh ; Tecla ESC
		mov al, 1
		jmp RETORNAESC
	.ENDIF
FIM:
	mov eax, 50 ; Configura um delay de 50 milisegundos, isso garante que o jogo nao exija muita da cpu de forma desnecessaria e
				; cause bugs na leitura das teclas
	call delay
	jmp MainLoop

RETORNA:
	call Clrscr
	mov al,0
RETORNAESC:
	ret
MenuInicial ENDP

;---------------------------------------------------
GetElementoMatriz PROC
; Mapeia um par ordenado (x,y), passado por parametro, em posicao de memoria da matriz do mapa
; e recupera o elemento que armazenado nessa posicao
; Recebe: Par ordenado (x,y) por parametro
; Retorna: al com o elemento encontrado
;---------------------------------------------------
	push ebp
	mov ebp,esp

	mov eax, 0

	mov ax, [ebp + 10] ; Y
	mov bx, [ebp + 8] ; X

	sub al, BYTE PTR minMap+1
	dec al

	sub bl, BYTE PTR minMap
	dec bl

	mov cl, 98
	mul cl ; AX = Y * 98

	movzx cx, bl
	add ax, cx

	mov esi, OFFSET mapMatrix
	add esi, eax
	mov al, [esi]

	pop ebp
	ret 4
GetElementoMatriz ENDP

;---------------------------------------------------
HandleControl PROC
; Gerencia o controle do jogo executando a operacao correta em funcao da tecla apertada
; Recebe: eax = tecla que foi acionada
; Retorna: ax indicando se a tecla esc foi pressionada ou nao
;---------------------------------------------------
	.IF ah == 48h ; Verifica se foi a tecla de seta pra cima
		mov bl, BYTE PTR minMap+1 ; Recupera o valor do limite do mapa
		inc bl
		cmp playerY, bl ; Se o movimento fizer com que o jogador ultrapasse o limite do mapa, esse movimento nao e realizado
		je Fim

		mov cl, playerX
		mov playerXAux, cl

		mov cl, playerY
		dec cl
		mov playerYAux, cl

		jmp VerificaColisaoLabirinto
	.ELSEIF ah == 50h ; Seta para baixo
		mov bl, BYTE PTR maxMap+1
		dec bl
		cmp playerY, bl
		je Fim

		mov cl, playerX
		mov playerXAux, cl

		mov cl, playerY
		inc cl
		mov playerYAux, cl

		jmp VerificaColisaoLabirinto
	.ELSEIF ah == 4dh ; Seta para a direita
		mov bl, BYTE PTR maxMap
		dec bl
		cmp playerX, bl
		je Fim

		mov cl, playerX
		inc cl
		mov playerXAux, cl

		mov cl, playerY
		mov playerYAux, cl

		jmp VerificaColisaoLabirinto
	.ELSEIF ah == 4bh ; Seta para a esquerda
		mov bl, BYTE PTR minMap
		inc bl
		cmp playerX, bl
		je Fim

		mov cl, playerX
		dec cl
		mov playerXAux, cl

		mov cl, playerY
		mov playerYAux, cl

		jmp VerificaColisaoLabirinto
	.ELSEIF al == 01bh ; Tecla ESC
		mov al, 1
		call clrscr
		call ReiniciaVariaveis
		jmp RETORNA
	.ELSE
		jmp Fim ;
	.ENDIF	

VerificaColisaoLabirinto:
	; Verifica se h� colis�o com os elementos da matriz
	movzx cx, playerYAux
	push cx
	movzx cx, playerXAux
	push cx
	call GetElementoMatriz

	.IF al == 0dbh
		jmp fim
	.ELSEIF al == 0bah
		mov bl, statusResposta
		.IF bl == 0
			jmp fim
		.ENDIF
	.ELSEIF al == 0feh ; Encontrou a chave e venceu
		call GetTextColor
		push eax
	
		mov eax,lightcyan
		call settextcolor

		call GetMaxXY ; Pega o tamanho do terminal atual para configurar as posicoes na tela (DL = X e DH = Y)
		mov CurrentLine, 26 
		; Desenha a msg
		sub dl, LENGTHOF msgVenceu1
		shr dl,1
		mov Xmargin,dl ; Calcula a magem esquerda em funcao do tamanho da tela e do logo, dessa forma o jogo sempre estar� centralizado

		mov dl, Xmargin
		mov dh,CurrentLine
		inc CurrentLine
		call GoToxy
		mov edx, offset msgVenceu4
		call writestring

		mov dl, Xmargin
		mov dh, CurrentLine
		inc CurrentLine
		call GoToxy
		mov edx, offset msgVenceu1
		call writestring

		mov dl, Xmargin
		mov dh,CurrentLine
		inc CurrentLine
		call GoToxy
		mov edx, offset msgVenceu2
		call writestring

		mov dl, Xmargin
		mov dh,CurrentLine
		inc CurrentLine
		call GoToxy
		mov edx, offset msgVenceu3
		call writestring

		mov dl, Xmargin
		mov dh,CurrentLine
		inc CurrentLine
		call GoToxy
		mov edx, offset msgVenceu4
		call writestring

		mov dl, Xmargin
		mov dh,CurrentLine
		inc CurrentLine
		call GoToxy
		mov edx, offset msgVenceu5
		call writestring

		mov dl, Xmargin
		mov dh,CurrentLine
		inc CurrentLine
		call GoToxy
		mov edx, offset msgVenceu4
		call writestring

		pop eax
		call settextcolor
		
		call ReadChar
		mov al, 1
		call clrscr
		call ReiniciaVariaveis
		jmp RETORNA
	.ENDIF

		call ClearPlayer
		mov cl, playerXAux
		mov playerX, cl
		mov cl, playerYAux
		mov playerY, cl

	call DrawPlayer ; Desenha o jogador na nova posicao
Fim:
	mov ax, 0
RETORNA:
	ret
HandleControl ENDP

;---------------------------------------------------
HandleSenha PROC
; Gerencia o movimento e a entrada de caracteres fornecidos pelo jogador quando este esta em um dispositivo de senha
; Recebe: eax = tecla que foi acionada, bl
; Retorna: ax indicando se a tecla esc foi pressionada ou nao
;---------------------------------------------------
	.IF ah == 48h ; Verifica se foi a tecla de seta pra cima
		mov bl, BYTE PTR minMap+1 ; Recupera o valor do limite do mapa
		inc bl
		cmp playerY, bl ; Se o movimento fizer com que o jogador ultrapasse o limite do mapa, esse movimento nao e realizado
		je Fim

		mov cl, playerX
		mov playerXAux, cl

		mov cl, playerY
		dec cl
		mov playerYAux, cl

		jmp VerificaColisaoLabirinto
	.ELSEIF ah == 50h ; Seta para baixo
		mov bl, BYTE PTR maxMap+1
		dec bl
		cmp playerY, bl
		je Fim

		mov cl, playerX
		mov playerXAux, cl

		mov cl, playerY
		inc cl
		mov playerYAux, cl

		jmp VerificaColisaoLabirinto
	.ELSEIF ah == 4dh ; Seta para a direita
		mov bl, BYTE PTR maxMap
		dec bl
		cmp playerX, bl
		je Fim

		mov cl, playerX
		inc cl
		mov playerXAux, cl

		mov cl, playerY
		mov playerYAux, cl

		jmp VerificaColisaoLabirinto
	.ELSEIF ah == 4bh ; Seta para a esquerda
		mov bl, BYTE PTR minMap
		inc bl
		cmp playerX, bl
		je Fim

		mov cl, playerX
		dec cl
		mov playerXAux, cl

		mov cl, playerY
		mov playerYAux, cl

		jmp VerificaColisaoLabirinto
	.ELSEIF al == 01bh ; Tecla ESC
		mov al, 1
		call clrscr
		call ReiniciaVariaveis
		jmp RETORNA
	.ELSEIF al == 0dh ; Se for tecla Enter nao faca nada
	.ELSE
		mov bl, elementoAux
		mov edx, OFFSET respostaJogador
		.IF bl == '1'
			mov [edx], al
		.ELSEIF bl == '2'
			mov [edx + 1], al
		.ELSEIF bl == '3'
			mov [edx + 2], al
		.ELSEIF bl == '4'
			mov [edx + 3], al
		.ENDIF
		call DrawRespostaJogador
		call VerificaSenha
		jmp Fim
	.ENDIF	

VerificaColisaoLabirinto:
	; Verifica se h� colis�o com os elementos da matriz
	movzx cx, playerYAux
	push cx
	movzx cx, playerXAux
	push cx
	call GetElementoMatriz

	.IF al == 0dbh
		jmp fim
	.Else
		mov dl, playerX
		mov dh, playerY
		mov bl, elementoAux
		call GetTextColor
		push eax
		.IF bl == '1'
			mov eax,white + (green * 16)
			call settextcolor
			mov al, '1'
		.ELSEIF bl == '2'
			mov eax,black + (lightmagenta * 16)
			call settextcolor
			mov al, '2'
		.ELSEIF bl == '3'
			mov eax,black + (yellow * 16)
			call settextcolor
			mov al, '3'
		.ELSEIF bl == '4'
			mov eax,white + (lightBlue * 16)
			call settextcolor
			mov al, '4'
		.ELSEIF bl == 0bah
			mov eax,lightgreen + (lightgreen * 16)
			call settextcolor
			mov al, '4'
		.ENDIF
		call GoToxy

		call WriteChar
		
		pop eax
		call settextcolor

		mov cl, playerXAux
		mov playerX, cl
		mov cl, playerYAux
		mov playerY, cl
	.ENDIF

	call DrawPlayer ; Desenha o jogador na nova posicao
Fim:
	mov al,0
RETORNA:
	ret
HandleSenha ENDP

;---------------------------------------------------
VerificaSenha PROC
; Verifica se a resposta fornecida pelo jogador e igual a resposta do enigma, caso for, abre as portas
; Recebe: resposta original e resposta do jogador
; Retorna: statusResposta com  1 se est� correto, ou com 0 se errado
;---------------------------------------------------
	mov esi, OFFSET respostaOriginal
	mov edx, OFFSET respostaJogador
	mov ecx, 4
Verifica:
	mov al, [esi]
	mov bl, [edx]
	cmp al,bl
	jnz Diferente

	inc esi
	inc edx
	loop Verifica

	call GetTextColor
    push eax
	mov eax,lightgreen + (lightgreen * 16)
	call settextcolor

	mov esi, OFFSET posPortas
	mov ecx, 4
	mov al, ' '
AbrePorta:
	mov dx, [esi]
	call GoToXY
	call WriteChar
	add esi, 2
	loop AbrePorta

	pop eax
	call settextcolor

	mov statusResposta, 1

Diferente:
	ret
VerificaSenha ENDP

;---------------------------------------------------
DrawPlayer PROC
; Desenha na tela o jogador em sua posicao atual
; Recebe: playerX, playerY
; Retorna: Nada
;---------------------------------------------------
	call GetTextColor
    push eax

	mov dl, playerX
	mov dh, playerY
	call GoToxy

	mov eax,lightcyan
	call settextcolor
	mov al, playerSymbol
	call WriteChar

	pop eax
	call settextcolor

	ret
DrawPlayer ENDP

;---------------------------------------------------	
ClearPlayer PROC
; Limpa a posicao antiga do jogador, evita que forme um rastro na tela devido ao movimento do jogador
; Recebe: playerX, playerY
; Retorna: Nada
;---------------------------------------------------
	call GetTextColor
    push eax

	mov dl, playerX
	mov dh, playerY
	call GoToxy

	mov eax,black
	call settextcolor
	mov al, playerSymbol
	call WriteChar

	pop eax
	call settextcolor
	ret
ClearPlayer ENDP

;---------------------------------------------------
LoadMapaFile PROC
; Le um arquivo externo e carrega na memoria seu conteudo. Preenche os dados do enigma e popula a matriz com os dados obtidos desse arquivo
; Recebe: nome do arquivo 
; Retorna: CL = 1 se houve um erro ao abrir o arquivo, CL = 0 caso contrario
;---------------------------------------------------
; Abertura do arquivo	
	mov edx, OFFSET mapaFileName 
	call OpenInputFile

    mov  edx,OFFSET BUFFERMAPA
    mov  ecx,BUFSIZE
    call ReadFromFile
    jnc   SemErro

	mov edx, OFFSET msgError
	call WriteString
	call ReadChar
	mov cl,1
	jmp Fim
SemErro:
; Recupera as informacoes sobre a pergunta e o enigma 
	mov edx,OFFSET BUFFERMAPA
	mov eax, OFFSET enigma
; Identifica a pergunta
PerguntaInicio:
	mov cl, [edx]
	cmp cl,'#'
	je PerguntaFim
	mov [eax], cl
	inc eax
	inc edx
	jmp PerguntaInicio
PerguntaFim:
	
	inc edx
	mov eax, OFFSET respostaOriginal
; Identifica a resposta
RespostaInicio:
	mov cl, [edx]
	cmp cl,'#'
	je RespostaFim
	mov [eax], cl
	inc eax
	inc edx
	jmp RespostaInicio
RespostaFim:

	add edx,3
	mov eax, OFFSET mapMatrix
	mov ebx, mapHeight*mapWidth

; Inicializa a matriz do mapa
MapaInicio:
	mov cl, [edx]
	
	cmp cl, 0dh
	jne ColocaNaMatriz

	add edx, 2
	jmp MapaInicio

ColocaNaMatriz:
	.IF cl == 'x'
		mov cl, 0dbh
	.ELSEIF cl == 'p'
		mov cl, 0bah
	.ELSEIF cl == 'c'
		mov cl, 0feh
	.ENDIF

	mov [eax], cl
	inc eax
	inc edx
	dec ebx
	jz MapaFim
	jmp MapaInicio

MapaFim:
	mov cl,0
Fim:
	ret
LoadMapaFile ENDP

;---------------------------------------------------
DrawLogo PROC
; Desenha na tela o logo do jogo
; Recebe: strings com o logo
; Retorna: NADA
;---------------------------------------------------
	call GetTextColor
    push eax
	
	mov eax,lightblue
	call settextcolor

	mov dl, Xmargin
	mov dh,0
	mov CurrentLine,1
	call GoToxy
	mov edx, offset logo1
	call writestring

	mov eax,lightblue
	call settextcolor

	mov dl, Xmargin
	mov dh,CurrentLine
	inc CurrentLine
	call GoToxy
	mov edx, offset logo2
	call writestring

	mov eax,lightcyan
	call settextcolor

	mov dl, Xmargin
	mov dh,CurrentLine
	inc CurrentLine
	call GoToxy
	mov edx, offset logo3
	call writestring

	mov eax,lightgreen
	call settextcolor

	mov dl, Xmargin
	mov dh,CurrentLine
	inc CurrentLine
	call GoToxy
	mov edx, offset logo4
	call writestring

	mov eax,cyan
	call settextcolor

	mov dl, Xmargin
	mov dh,CurrentLine
	inc CurrentLine
	call GoToxy
	mov edx, offset logo5
	call writestring

	pop eax
	call settextcolor

	ret
DrawLogo ENDP

;---------------------------------------------------
DrawEnigma PROC
; Desenha na tela o local do enigma, o enigma propriamente dito e o local onde ficara a resposta do jogador
; Recebe: Enigma 
; Retorna: NADA
;---------------------------------------------------
	mov al, '+'
	mov ecx, LENGTHOF logo1 - 1
	inc CurrentLine
	mov dl,Xmargin
	mov dh,CurrentLine
	inc CurrentLine
	call GoToxy 
L1:
	call WriteChar
	loop L1

	mov dl,Xmargin
	mov dh,CurrentLine
	call GoToxy
	call WriteChar
	mov ecx, 5 ;Espacamento esquerdo para comecar a escrever a pergunta
	mov al, ' '
L2:
	call WriteChar
	loop L2

	mov edx, OFFSET enigma
	call WriteString

	mov dl,Xmargin
	mov dh,CurrentLine
	add dl, OFFSETRESPOSTA ; Aponta para o final da linha do meio da caixa do enigma
	call GoToxy
	mov al, '+'
	call WriteChar

	mov edx, OFFSET labelResposta
	call WriteString

	mov dl, LENGTHOF labelResposta
	add dl, Xmargin
	add dl, OFFSETRESPOSTA
	mov dh,CurrentLine
	mov posRespostaJogador, dx

	call DrawRespostaJogador

	mov dl,Xmargin
	mov dh,CurrentLine
	add dl, 99 ; Aponta para o final da linha do meio da caixa do enigma
	call GoToxy
	mov al, '+'
	call WriteChar

	inc CurrentLine
	mov ecx, LENGTHOF logo1 - 1
	mov dl,Xmargin
	mov dh,CurrentLine
	inc CurrentLine
	call GoToxy 
L3:
	call WriteChar
	loop L3
	ret
DrawEnigma ENDP

;---------------------------------------------------
DrawRespostaJogador PROC
; Desenha na tela a situacao atual da string que representa a resposta fornecida pelo jogador
; Recebe: resposta do jogador e local onde sera desenhada
; Retorna: NADA
;---------------------------------------------------
	call GetTextColor
	push eax

	mov dx, posRespostaJogador
	call GoToxy

	mov edx, OFFSET respostaJogador

	mov eax,white + (green * 16)
	call settextcolor
	
	mov al, ' '
	call WriteChar
	mov al, [edx]
	call WriteChar
	mov al, ' '
	call WriteChar

	mov eax,black + (lightmagenta * 16)
	call settextcolor

	mov al, ' '
	call WriteChar
	mov al, [edx+1]
	call WriteChar
	mov al, ' '
	call WriteChar

	mov eax,black + (yellow * 16)
	call settextcolor

	mov al, ' '
	call WriteChar
	mov al, [edx+2]
	call WriteChar
	mov al, ' '
	call WriteChar

	mov eax,white + (lightblue * 16)
	call settextcolor

	mov al, ' '
	call WriteChar
	mov al, [edx+3]
	call WriteChar
	mov al, ' '
	call WriteChar

	pop eax
	call settextcolor
	ret
DrawRespostaJogador ENDP

;---------------------------------------------------
DrawMapa PROC
; Desenha na tela o mapa do labirinto
; Recebe: mapa
; Retorna: NADA
;---------------------------------------------------
	call GetTextColor
	push eax
	mov eax,white
	call settextcolor

	mov al, 0dbh
	mov ecx, mapWidth + 2
	inc CurrentLine
	mov dl,Xmargin
	mov dh,CurrentLine
	mov minMap,dx
	inc CurrentLine
	call GoToxy

ParedeDeCima:
	call WriteChar
	loop ParedeDeCima

	mov ebx, OFFSET mapMatrix
	mov esi, OFFSET posPortas

	mov al, 0dbh
	mov ecx, mapHeight
Labirinto:
	mov dl, BYTE PTR minMap
	mov dh, CurrentLine
	call GoToxy
	call WriteChar; Inicio parede externa esquerda

	push ecx
	mov ecx, mapWidth
	call GetTextColor
	push eax
	mov eax,gray
	call settextcolor
	LabirintoInterno:
		call GetTextColor
		push eax
		mov al, [ebx]
		.IF al == 0bah
			push dx

			add dl, CurrentColumn
			inc dl
			mov [esi], dx

			pop dx
			add esi,2
			mov eax,lightRed
			call settextcolor
			mov al, 0bah
		.ELSEIF al == 0feh
			mov eax,lightgreen
			call settextcolor
			mov al, 0feh
		.ELSEIF al == '1'
			mov eax,white + (green * 16)
			call settextcolor
			mov al, '1'
		.ELSEIF al == '2'
			mov eax,black + (lightmagenta * 16)
			call settextcolor
			mov al, '2'
		.ELSEIF al == '3'
			mov eax,black + (yellow * 16)
			call settextcolor
			mov al, '3'
		.ELSEIF al == '4'
			mov eax,white + (lightBlue * 16)
			call settextcolor
			mov al, '4'
		.ENDIF

		call WriteChar
		pop eax
		call settextcolor
		
		inc ebx
		inc CurrentColumn
		dec cx
		jnz LabirintoInterno
	pop eax
	call settextcolor
	pop ecx

	mov al, 0dbh
	call WriteChar; Inicio parede externa esquerda
	inc CurrentLine
	mov CurrentColumn, 0
	dec cx
	jnz Labirinto

	mov al, 0dbh
	mov ecx, mapWidth + 2
	mov dl,Xmargin
	mov dh,CurrentLine
	call GoToxy
L3:
	call WriteChar
	loop L3

	mov dl, Xmargin
	add dl, mapWidth + 1
	mov maxMap,dx

	mov dl, Xmargin
	add dh, 2
	call Gotoxy

	add dl, LENGTHOF labelTempo
	mov posTemporizador,dx

	mov edx, OFFSET labelTempo
	call WriteString

	pop eax
	call settextcolor

	ret
DrawMapa ENDP

;---------------------------------------------------
DrawTempo PROC
; Desenha na tela o tempo corrido desde a inicializacao da partida
; Recebe: tempo inicial e posicao onde sera desenhado
; Retorna: NADA
;---------------------------------------------------
	mov dx, posTemporizador
	call GoToxy
	
	call GetMseconds
	sub	eax, tempoInicial
	shr eax,10
	call WriteDec

	ret
DrawTempo ENDP
END main
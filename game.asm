;;; M. Anas Farooq, Usman Azam.
;;; I210813		  , I210653.
;;; G.
;;; BRICK BREAKER GAME (masm x8086).

; STRUCTURE FOR THE BALL.
BALL struct
	ball_size dw	 	0h								; Size of the ball.

	ball_x dw  		 	0h								; x position (column) 96H.
	ball_y dw 		 	0h								; y position (row) 	  BEh.
	ball_vx dw 	 	 	0h								; Traverse the columns with the following speed.
	ball_vy dw 	 	 	0h								; Traverse the rows with the following speed.
	
	ball_color db       2h
BALL ENDS

; STRUCTURE FOR THE PADDLE.
PADDLE struct
	PADDLE_X DW 		0d								; x position (column).
	PADDLE_Y DW 		0d								; y position (row).
	
PADDLE_VEL DW 			0h 								; The moving velocity of the paddle.
	
	PADDLE_WIDTH DW 	0d								; size of the paddle in horizontal direction.
	PADDLE_HEIGHT DW 	0d								; size of the paddle in vertical direction.
	PADDLE_COLOR db     7d
PADDLE ENDS

; STRUCTURE FOR THE BRICKS.
BRICKS struct
	bricks_x dw 		100d							; x position (column).
	bricks_y dw 		150d							; y position (row).
	
	bricks_life db 		0h
	bricks_color db 	0bh
BRICKS ENDS

.model HUGE
.stack 01000h
.data
include game.inc
include maps.inc
	bricks_height dw 10d
	bricks_width dw 20d
objball_1 BALL < 4h, 150d, 183d, 1h, 1h, 2h >
objpaddle_1 PADDLE < 130, 190, 10h, 45d, 3d >


SCREEN_WIDTH dw 320d									; 140h.
SCREEN_HEIGHT dw 200d									; 08Ch.

ball_copy_x dw 150d										; Initial position x-coordinates of the ball.
ball_copy_y dw 185d										; Initial position y-coordinates of the ball.
ball_copy_vx dw 1d
ball_copy_vy dw 1d
paddle_copy_x dw 130d									; Initial position x-coordinates of the paddle.
paddle_copy_y dw 190d									; Initial position x-coordinates of the paddle.

; CHANGES TO DO
movement_check db 1										; To move the ball and paddle left and right, at the start of the game and whenever a live is lost.
straight_check db 1										; To move the ball straight, at the start of the game and whenever a live is lost.
reset_flag db 1											; A bool for checking if the ball is reseted or not.
no_of_lives db 3d										; The number of lives in a round.
lives_str db "LIVES:$"

score_str db "SCORE:$"

total_score dw 0
counter db 0

name_str db "NAME:$"
Userstr db "A$$$$$$$$$$"
FILE_NAME db 'Scores.txt', 0
FILE_NAME_PTR dw 0


COL_DETECT db 0
UP_DOWN_COL db 0

level_back db 0
time_passed db 0
game_back db 0
reset_ball_check db 0
DESTROY DB 0

collision_count db 0
original_color db 2
paddle_check db 0
PADDLE_WIDTH_COPY dw 0

brick_hits db 0
level_1_end db 0
level_2_end db 0
level_3_end db 0


delay_time dw 111111111111111b

.code
; Removes the brick that has been passed.
REMOVE_BRICK MACRO obj
	.IF obj.bricks_x != 0 && obj.bricks_color != 7 && obj.bricks_color != 5
		DRAW_BLACK_BRICK obj
		mov obj.bricks_x, 0
		mov al, obj.bricks_color
		mov ah, 0
		add total_score, ax
		inc DESTROY
		inc brick_hits
	.ENDIF
ENDM

Beep MACRO voice
	mov ax, voice
	mov freq, ax
	CALL Sound
ENDM

; Draws the Borders
OUTLINE_UP_DOWN MACRO row, col
	mov cx, col	    		 							; Initial (column).
	mov dx, row    	  	 			   					; Initial(row).
	
	mov si, 0											; Outer loop Constaint.	
	mov di, 0											; Inner loop constraint.										

	.while si < 1										; Stopping condition of the loop.
		mov di, 0
		.while di < SCREEN_WIDTH						; Stopping condition of the loop.
			mov ah, 0Ch	 		  		    			; Writes a pixel.
			mov al, 0101b 		  	  	   				; color.
			mov bh, 00h
			int 10h
	
			inc cx				 		    			; Traversing column-wise.
			inc di
		.ENDW
		mov cx, 0										; Resetting the column.
		inc dx			        	    				; Traversing row-wise.
		inc si
	.ENDW
ENDM


; Draws the ball on the screen.
DRAW_BALL MACRO OBJ, color
	mov cx, OBJ.ball_x    		 						; Initial (column).
	mov dx, OBJ.ball_y    	  	    					; Initial(row).
	
	mov si, 0											; Outer loop Constaint.	
	mov di, 0											; Inner loop constraint.								

	.while si <= OBJ.ball_size							; Stopping condition of the loop.
		mov di, 0
		.while di <= OBJ.ball_size						; Stopping condition of the loop.
			mov ah, 0Ch	 		  		    			; Writes a pixel.
			mov al, color 		  	  	    			; Red color.
			mov bh, 00h
			int 10h
			inc cx				 		    			; Traversing column-wise.
			inc di
		.ENDW
		mov cx, OBJ.ball_x								; Resetting the column.
		inc dx			        	    				; Traversing row-wise.
		inc si
	.ENDW
	
	CALL Reshape
ENDM



; Resets the ball to the original position
RESET_BALL MACRO OBJ
	MOV AX, ball_copy_x
	mov OBJ.ball_x, AX 									; original x-coordinates (ball).
	MOV AX, ball_copy_y
	mov OBJ.ball_y, AX									; original y-coordinates (ball).
	MOV AX, ball_copy_vx
	mov OBJ.ball_vx, AX									; original velocity-x.
	MOV AX, ball_copy_vy
	mov OBJ.ball_vy, AX									; original velocity-y.
	
	MOV AX, paddle_copy_x
	mov objpaddle_1.PADDLE_X, AX		 				; original x-coordinates (paddle).
	MOV AX, paddle_copy_y
	mov objpaddle_1.PADDLE_Y, AX						; original y-coordinates (paddle).
	mov ax, PADDLE_WIDTH_COPY
	mov objpaddle_1.PADDLE_WIDTH, ax
	mov reset_flag, 1									; setting the reset_flag.
	dec no_of_lives										; reducing the number of lives.

	mov movement_check, 1
	mov straight_check, 1
	mov reset_ball_check, 1
ENDM

; Resets the ball to the original position
RESET_POSTIONS MACRO OBJ
	MOV AX, ball_copy_x
	mov OBJ.ball_x, AX 									; original x-coordinates (ball).
	MOV AX, ball_copy_y
	mov OBJ.ball_y, AX									; original y-coordinates (ball).
	MOV AX, ball_copy_vx
	mov OBJ.ball_vx, AX									; original velocity-x.
	MOV AX, ball_copy_vy
	mov OBJ.ball_vy, AX									; original velocity-y.
	
	MOV AX, paddle_copy_x
	mov objpaddle_1.PADDLE_X, AX		 				; original x-coordinates (paddle).
	MOV AX, paddle_copy_y
	mov objpaddle_1.PADDLE_Y, AX						; original y-coordinates (paddle).
	mov ax, PADDLE_WIDTH_COPY
	mov objpaddle_1.PADDLE_WIDTH, ax
	mov reset_flag, 1									; setting the reset_flag.
	
	MOV collision_count, 0
	mov bl, original_color
	mov OBJ.ball_color, bl
	
	mov movement_check, 1
	mov straight_check, 1
	
ENDM


; fUNCTION TO DRAW THE PADDLE.
DRAW_PADDLE MACRO OBJ_PADDLE, color
	mov cx, OBJ_PADDLE.PADDLE_X    		  				; Initial (column).
	mov dx, OBJ_PADDLE.PADDLE_Y    	  					; Initial(row).

.IF paddle_check == 1
	add OBJ_PADDLE.PADDLE_WIDTH, 5
	mov paddle_check, 0
.ENDIF

mov si, 0
mov di, 0
.while si <= OBJ_PADDLE.PADDLE_HEIGHT
	mov di, 0
	.while di <= OBJ_PADDLE.PADDLE_WIDTH
		mov ah, 0Ch	 		  		 		    		; Writes a pixel.
		mov al, color  		  	  	    				; Blue color.
		mov bh, 00h
		INT 10H
	
		inc cx				 		    				; Traversing column-wise.
		inc di
	.ENDW

	inc dx			        							; Traversing row-wise.
	mov cx, OBJ_PADDLE.PADDLE_X    	      				; Setting cx to inital position.
	inc si
.ENDW
ENDM



; Move the paddle through keyboard inputs.
MOVE_PADDLE MACRO OBJ_PADDLE, OBJ_BALL
	; checking if the right or left key is pressed, if not then exit.
	mov ah, 1h
	int 16h
	jz NO_PADDLE_COLLISION
	
	mov ah, 0h											; ah = scan-codes, al = ascii-codes.
	int 16h

	; For pausing the screen.
	.IF movement_check != 1								; At the start of the game, no need to check this condition.

		cmp al, 32d										; Ascii of space.
		jz pause_game
	.ENDIF
	jmp continue_game
	
; For pausing the game.
	pause_game:
		mov ah, 00h					    					; Sets the configuration to video mode.
		mov al, 13h											; 320 * 200.
		int 10h
		call Pause_Screen
		mov cursor, 1
		mov row_cursor, 12
		Print_Char_2 8, row_cursor, 14, 16
	cursor_move:
		mov ah, 0h										; ah = scan-codes, al = ascii-codes.
		int 16h
		
		.IF al == 32									; Ascii of space.
			.IF cursor == 1
				CALL VIDEO_MODE											; Entering Video mode.
				CALL STATUS_BAR
				CALL MAKE_ALL_BRICKS
				DRAW_PADDLE objpaddle_1, objpaddle_1.PADDLE_COLOR
				JMP continue_game
			.ELSEIF cursor == 2
				mov game_back, 1
				JMP continue_game
			.ENDIF
		.ENDIF
		
	.if ah == 050h  && cursor < 2                     	  ;down
		Beep 5672
		Print_Char_2 8, row_cursor, 0, 16
		inc cursor
		add row_cursor, 6
		Print_Char_2 8, row_cursor, 12, 16
		Print 12,8,12,8,15
	.elseif ah == 048h && cursor > 1                      ;up
		Beep 5672
		dec cursor
		Print_Char_2 8, row_cursor, 0, 16
		sub row_cursor, 6
		Print_Char_2 8, row_cursor, 14, 16
		Print 18,8,18,8,15
	.endif
	jmp cursor_move
	
; For continuing the game.
	continue_game:
	
	.IF ah == 04Dh										; Right-key scan-code.
		.IF movement_check == 1
			DRAW_BALL objball_1, 0h
			mov ax, OBJ_PADDLE.PADDLE_VEL
			add OBJ_BALL.ball_x, ax
			DRAW_BALL objball_1, objball_1.ball_color
		.ENDIF
		jmp move_right
	.ENDIF

	.IF ah == 04Bh										; Left-key scan-code.
		.IF movement_check == 1
			DRAW_BALL objball_1, 0h
			mov ax, OBJ_PADDLE.PADDLE_VEL
			sub OBJ_BALL.ball_x, ax
			DRAW_BALL objball_1, objball_1.ball_color
		.ENDIF
		jmp move_left
	.ENDIF

jmp NO_PADDLE_COLLISION

move_right:
	DRAW_PADDLE OBJ_PADDLE, 0h
	mov ax, OBJ_PADDLE.PADDLE_VEL
	add OBJ_PADDLE.PADDLE_X, ax

	mov bx, SCREEN_WIDTH
	sub bx, OBJ_PADDLE.PADDLE_WIDTH
	.IF OBJ_PADDLE.PADDLE_X >= bx 						; paddle_x > SCREEN_WIDTH - ball_size , Right side collided.
		SUB OBJ_PADDLE.PADDLE_X, ax
		.IF movement_check == 1
			DRAW_BALL objball_1, 0h
			mov ax, OBJ_PADDLE.PADDLE_VEL
			sub OBJ_BALL.ball_x, ax
			DRAW_BALL objball_1, objball_1.ball_color
		.ENDIF
	.ENDIF
	jmp movement_end
	
move_left:
	DRAW_PADDLE OBJ_PADDLE, 0h
	mov ax, OBJ_PADDLE.PADDLE_VEL
	sub OBJ_PADDLE.PADDLE_X, ax
	cmp OBJ_PADDLE.PADDLE_X, -5;						; paddle_x < 0 , Left side collided.
	jg movement_end
	
	add OBJ_PADDLE.PADDLE_X, ax
	.IF movement_check == 1
		DRAW_BALL objball_1, 0h
		mov ax, OBJ_PADDLE.PADDLE_VEL
		add OBJ_BALL.ball_x, ax
			DRAW_BALL objball_1, objball_1.ball_color
	.ENDIF
	jmp movement_end


movement_end:
	DRAW_PADDLE OBJ_PADDLE, OBJ_PADDLE.PADDLE_COLOR
	
NO_PADDLE_COLLISION:
ENDM



; FUNCTION TO DRAW THE BRICKS.
DRAW_BRICK MACRO OBJ_BRICK

	.IF OBJ_BRICK.bricks_x != 0 && OBJ_BRICK.bricks_y != 0
		mov cx, OBJ_BRICK.bricks_x   		  			; Initial (column).
		mov dx, OBJ_BRICK.bricks_y   	  				; Initial(row).

	mov si, 0
	mov di, 0
	.while si <= bricks_height
		mov di, 0
		.while di <= bricks_width
			mov ah, 0Ch	 		  		 		    	; Writes a pixel.
			mov al, OBJ_BRICK.bricks_color				; color.
			
			.IF OBJ_BRICK.bricks_color != 15
				.IF OBJ_BRICK.bricks_color == 16
					mov OBJ_BRICK.bricks_color, 14
				.ENDIF
			; Bodering the bricks.
				.IF si == 0 || di == 0
					mov al, 0Fh
				.ENDIF

				.IF si == bricks_height || di == bricks_width
					mov al, 0Fh
				.ENDIF
			.ENDIF
			
			mov bh, 00h
			INT 10H
		
			inc cx				 		    			; Traversing column-wise.
			inc di
		.ENDW

		inc dx			        						; Traversing row-wise.
		mov cx, OBJ_BRICK.bricks_x    	      			; Setting cx to inital position.
		inc si
	.ENDW
	.ENDIF

ENDM


; FUNCTION TO DRAW THE BRICKS.
DRAW_BLACK_BRICK MACRO OBJ_BRICK

	mov cx, OBJ_BRICK.bricks_x   		  				; Initial (column).
	mov dx, OBJ_BRICK.bricks_y   	  					; Initial(row).

	mov si, 0
	mov di, 0
	.while si <= bricks_height
		mov di, 0
		.while di <= bricks_width
			mov ah, 0Ch	 		  		 		    	; Writes a pixel.
			mov al, 0h
			mov bh, 00h
			INT 10H
		
			inc cx				 		    			; Traversing column-wise.
			inc di
		.ENDW

		inc dx			        						; Traversing row-wise.
		mov cx, OBJ_BRICK.bricks_x    	      			; Setting cx to inital position.
		inc si
	.ENDW

ENDM

DETECT_BRICK_COLLISION MACRO OBJ, OBJ_BRICK
	.IF OBJ_BRICK.bricks_x != 0 && OBJ_BRICK.bricks_y != 0 && COL_DETECT == 0
		mov ax, OBJ.ball_x
		add ax, OBJ.ball_size
		add ax, 3
		.IF ax > OBJ_BRICK.bricks_x
			mov ax, OBJ_BRICK.bricks_x
			add ax, bricks_width
			add ax, 2
			.IF OBJ.ball_x < ax
				mov ax, OBJ.ball_y
				add ax, OBJ.ball_size
				add ax, 2
				mov bx, OBJ_BRICK.bricks_y
				.IF ax > bx
					mov ax, OBJ_BRICK.bricks_y
					add ax, bricks_height
					add ax, 3
					.IF  OBJ.ball_y < ax
						.IF COL_DETECT == 0
							mov straight_check, 0
							inc collision_count
							; Special Ball.
							.IF collision_count >= 3
								 MOV OBJ_BRICK.bricks_life, 0
								 mov OBJ.ball_color, 39
							.ELSE
								dec OBJ_BRICK.bricks_life
							.ENDIF
							; Paddle size.
							.IF collision_count >= 4
								mov paddle_check, 1
							.ENDIF
							DRAW_BALL OBJ, OBJ.ball_color					
							.IF OBJ_BRICK.bricks_color == 5h
								CALL SPECIAL_DESTROY
							.ENDIF
							.IF OBJ_BRICK.bricks_color != 7h
								INC obj_BRICK.bricks_color
								.IF OBJ_BRICK.bricks_color == 5h || OBJ_BRICK.bricks_color == 7h
									INC obj_BRICK.bricks_color
								.ENDIF
							.ENDIF
							mov COL_DETECT, 1							
							Beep 4923
						.ENDIF

	
						.IF OBJ_BRICK.bricks_color != 7h
							.IF OBJ_BRICK.bricks_life == 0
								inc brick_hits
								mov ax, 0
								mov al, OBJ_BRICK.bricks_color
								add total_score, ax
								DRAW_BLACK_BRICK OBJ_BRICK
								mov OBJ_BRICK.bricks_x, 0
								mov OBJ_BRICK.bricks_y, 0
							.ENDIF
						.ENDIF
							CALL SCORE
							OUTLINE_UP_DOWN 30, 0
							CALL MAKE_ALL_BRICKS
					.ENDIF
				.ENDIF
			.ENDIF
		.ENDIF
	.ENDIF
ENDM

start:
	mov ax, @data
	mov ds, ax
	mov ax, 0
main PROC






;CALL Username_Screen
;CALL DELAY
CALL GAME_START





mov ah, 4ch
int 21h

main ENDP


; Takes the game to video mode.
VIDEO_MODE PROC
	mov ah, 00h					    					; Sets the configuration to video mode.
	;mov al, 0Dh										; 320x200 16 color graphics (EGA,VGA).
	mov al, 13h											; 320 * 200.
	int 10h
	
	OUTLINE_UP_DOWN 30, 0
	OUTLINE_UP_DOWN 199, 0
RET
VIDEO_MODE ENDP


STATUS_BAR PROC
	CALL LIVES												; Displays the remaining lives.
	CALL SCORE												; Displays the current score.
	CALL NAME_DISP											; Displays the user's name.
RET
STATUS_BAR ENDP


; Moves the Ball
MOVE_BALL PROC

	.IF straight_check == 0
		mov ax, objball_1.ball_vx
		add objball_1.ball_x, ax								; moves the ball horizontally.
	.ENDIF
	
	.IF UP_DOWN_COL == 0
		DETECT_ALL_COLIISON
		DRAW_BALL objball_1, 0h							
	.ENDIF
	.IF COL_DETECT == 1
		NEG objball_1.ball_vx
	.ENDIF
	
	cmp objball_1.ball_x, 3									; ball_x < 0 , Left side collided.
	jl neg_x
	
	mov bx, SCREEN_WIDTH
	sub bx, objball_1.ball_size
	sub bx, 4
	cmp objball_1.ball_x, bx									; ball_x > SCREEN_WIDTH - ball_size , Right side collided.
	jg neg_x
	
	mov ax, objball_1.ball_vy
	sub objball_1.ball_y, ax									; moves the ball vertically.
	
	mov UP_DOWN_COL, 0
	.IF COL_DETECT == 0
			DETECT_ALL_COLIISON
			DRAW_BALL objball_1, 0h							

		.IF COL_DETECT == 1
			NEG objball_1.ball_vy
			mov UP_DOWN_COL, 1
		.ENDIF
	.ENDIF
	mov COL_DETECT, 0	
	
	.IF objball_1.ball_y < 36									; ball_y < 0 , Up side collided.
		mov straight_check, 0
		MOV collision_count, 0
		mov bl, original_color
		mov objball_1.ball_color, bl
		jmp neg_y
	.ENDIF

	mov bx, SCREEN_HEIGHT								; Down side collided.
	.IF objball_1.ball_y >= bx
		MOV collision_count, 0
		mov bl, original_color
		mov objball_1.ball_color, bl
		jmp reset_ball_pos
	.ENDIF



; Detecting the collision of ball with the paddle
; ball_x + ball_size > PADDLE_X && ball_x < PADDLE_X + PADDLE_WIDTH
; ball_y + ball_size > PADDLE_Y && ball_y < PADDLE_Y + PADDLE_HEIGHT

	mov ax, objball_1.ball_x
	add ax, objball_1.ball_size
	add ax, 6
	.IF ax > objpaddle_1.PADDLE_X
		mov ax, objpaddle_1.PADDLE_X
		add ax, objpaddle_1.PADDLE_WIDTH
		add ax, 8
		.IF objball_1.ball_x < ax
			mov ax, objball_1.ball_y
			add ax, objball_1.ball_size
			mov bx, objpaddle_1.PADDLE_Y
			sub bx, 2									; So, that the ball, it doesn't look like that the ball goes into the paddle.
			.IF ax > bx
				mov ax, objpaddle_1.PADDLE_Y
				add ax, objpaddle_1.PADDLE_HEIGHT
				add ax, 6
				.IF  objball_1.ball_y < ax
					jmp neg_y
				.ENDIF
			.ENDIF
		.ENDIF
	.ENDIF

JMP EXIT_FOR_NOW

; Resets the ball position
reset_ball_pos:
	RESET_BALL objball_1
	JMP EXIT_FOR_NOW

; Reversing the y-velocity
neg_y:
	mov ax, objball_1.ball_vy
	mov bx, -1
	mul bx
	mov objball_1.ball_vy, ax									; Negating the ball_velocity-y.
	MOV collision_count, 0
	mov bl, original_color
	mov objball_1.ball_color, bl
	JMP EXIT_FOR_NOW
; Reversing the x-velocity
neg_x:
	mov ax, objball_1.ball_vx
	mov bx, -1
	mul bx
	mov objball_1.ball_vx, ax									; Negating the ball_velocity-x.
	MOV collision_count, 0
	mov bl, original_color
	mov objball_1.ball_color, bl
	JMP EXIT_FOR_NOW
	
EXIT_FOR_NOW:
RET
MOVE_BALL ENDP

out_it PROC
;OUTPUT multidigit number
 output:
		mov dx, 0
		mov ax, total_score
		mov bx, 10
Lk:
		mov dx, 0
		cmp ax, 0
		jz disp
		div bx
		MOV cx, dx
		push cx
		inc counter
		mov ah, 0
		jmp Lk
disp:
		cmp counter, 0
		jz exit
		pop dx
		add dx, 48
		mov ah, 02H
		int 21H
		dec counter
		jmp disp
exit:
ret
out_it ENDP


delay_it proc
	mov cx, 111111111111111b 
	delayloop:
	loop delayloop
	ret
delay_it endp


; Calls the clear screen and move the ball
DELAY PROC
start_again:
RESET_POSTIONS objball_1
	CALL VIDEO_MODE											; Entering Video mode.
	CALL STATUS_BAR
	CALL MAKE_ALL_BRICKS
	DRAW_PADDLE objpaddle_1, objpaddle_1.PADDLE_COLOR

check_time:
	DRAW_BALL objball_1, 0h								; Delete the ball at previous position.
	CALL MOVE_BALL									; Moves the ball, if collision occurs, deflects the ball.
	
	.IF no_of_lives == 0
		CALL DISPLAY
		CALL GAME_OVER
		MOV AH, 4CH
		INT 21H
	.ENDIF
	
	.IF reset_ball_check == 1
		mov reset_ball_check, 0
		CALL LiveLost
		jmp start_again
	.ENDIF

; Level Changings
.IF level_1_end != 1
	.IF brick_hits == 41 									; 41
		CALL LEVEL_2_CHANGINGS
		mov brick_hits, 0
		mov level_1_end, 1
		jmp start_again
	.ENDIF
.ENDIF

.IF level_2_end != 1
	.IF brick_hits == 57									; 57
		CALL LEVEL_3_CHANGINGS
		mov brick_hits, 0
		mov level_2_end, 1
		jmp start_again
	.ENDIF
.ENDIF

.IF level_3_end != 1
	.IF brick_hits == 52									; 52
		CALL LEVEL_3_CHANGINGS
		mov brick_hits, 0
		mov level_1_end, 0
		mov level_2_end, 0
		mov level_3_end, 0
		CALL DISPLAY
		CALL You_Win
		mov ah, 0h														; ah = scan-codes, al = ascii-codes.
		int 16h
		CALL File_Operations
		CALL GAME_START
	.ENDIF
.ENDIF
	
	DRAW_BALL objball_1, objball_1.ball_color							; Draws the ball with color.
	
	CALL RESET_REGISTERS												; Resets all the registers.
	
	MOVE_PADDLE objpaddle_1, objball_1									; Moves the padddle, if any key is pressed, then delete's the previous paddle and makes new.
	.IF game_back == 1
		mov level_1_end, 0
		mov level_2_end, 0
		mov level_3_end, 0
		CALL GAME_START
	.ENDIF

	mov bh, 1
	cmp bh, reset_flag
	jnz just_display
take_again:
		CALL CHANGES
		cmp al, 32d										; Ascii of space.
		jnz take_again
		mov reset_flag, 0
		mov movement_check, 0
	just_display:
	
		call delay_it
	jmp check_time										; Go to the time loop to check the time again.

out_delay:
ret
DELAY ENDP


CHANGES PROC
	MOVE_PADDLE objpaddle_1, objball_1
ret
CHANGES ENDP

MAKE_ALL_BRICKS PROC
	DRAW_BRICK b_1
	DRAW_BRICK b_2
	DRAW_BRICK b_3
	DRAW_BRICK b_4
	DRAW_BRICK b_5
	DRAW_BRICK b_6
	DRAW_BRICK b_7
	DRAW_BRICK b_8
	DRAW_BRICK b_9
	DRAW_BRICK b_10
	DRAW_BRICK b_11
	DRAW_BRICK b_12
	DRAW_BRICK b_13
	DRAW_BRICK b_14
	DRAW_BRICK b_15
	DRAW_BRICK b_16
	DRAW_BRICK b_17
	DRAW_BRICK b_18
	DRAW_BRICK b_19
	DRAW_BRICK b_20
	DRAW_BRICK b_21
	DRAW_BRICK b_22
	DRAW_BRICK b_23
	DRAW_BRICK b_24
	DRAW_BRICK b_25
	DRAW_BRICK b_26
	DRAW_BRICK b_27
	DRAW_BRICK b_28
	DRAW_BRICK b_29
	DRAW_BRICK b_30
	DRAW_BRICK b_31
	DRAW_BRICK b_32
	DRAW_BRICK b_33
	DRAW_BRICK b_34
	DRAW_BRICK b_35
	DRAW_BRICK b_36
	DRAW_BRICK b_37
	DRAW_BRICK b_38
	DRAW_BRICK b_39
	DRAW_BRICK b_40
	DRAW_BRICK b_41
	DRAW_BRICK b_42
	DRAW_BRICK b_43
	DRAW_BRICK b_44
	DRAW_BRICK b_45
	DRAW_BRICK b_46
	DRAW_BRICK b_47
	DRAW_BRICK b_48
	DRAW_BRICK b_49
	DRAW_BRICK b_50
	DRAW_BRICK b_51
	DRAW_BRICK b_52
	DRAW_BRICK b_53
	DRAW_BRICK b_54
	DRAW_BRICK b_55
	DRAW_BRICK b_56
	DRAW_BRICK b_57
ret
MAKE_ALL_BRICKS ENDP

; Resets all the registers
RESET_REGISTERS PROC
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov si, 0
	mov di, 0
	
ret
RESET_REGISTERS ENDP


BLINKING PROC
again_it:
	mov ah, 2ch
	int 21h
	mov time_passed, dh
	add time_passed, 2
	
	
go_take_again:
	Print_string Continue, 20,25
	
mov ah, 6
mov al, 0
mov bh, 0     ;color
mov ch, 19     ;top row of window
mov dh, 20     ;Bottom row of window
mov cl, 28     ;left most column of window
mov dl, 70     ;Right most column of window

int 10h

	; checking if the Enter key is pressed.
	mov ah, 1h											; ah = scan-codes, al = ascii-codes.
	int 16h
	jnz here
	
	mov ah, 2ch
	int 21h
	cmp time_passed, dh
	jnz go_take_again

jmp again_it

here:
ret
BLINKING ENDP


DISPLAY PROC
	; Setting the video mode.
	mov ah, 0h
	mov al, 12h     
	int 10h
ret
DISPLAY ENDP

File_Operations PROC
	; Opening a existing file.
	mov  ah, 3dh
	mov dx, offset FILE_NAME
	mov al, 2						 ; writing mode.
	int 21h

	mov FILE_NAME_PTR, ax
		
	; At the end position.
	mov cx, 0
	mov dx, 0
	mov ah, 42h
	mov bx, FILE_NAME_PTR
	mov al, 2 						 ; 0 beginning of file, 2 end of file
	int 21h

	mov cx, 0
.while [Userstr + si] != "$"
		inc cx
		inc si
.endw		

	; Writing in the file.
	mov ah, 40h
	mov bx, FILE_NAME_PTR
	mov dx, offset Userstr			  ; The string to write.
	add dx, 2
	int 21h

	; Closing the file
	mov ah, 3eh
	mov dx, FILE_NAME_PTR
	int 21h
		
ret
File_Operations ENDP


; Starting The Game.
GAME_START PROC
.IF game_back != 1
	CALL DISPLAY
	
	call Boarders
	call B_Letter
	call R_Letter
	call I_letter
	call C_letter
	call K_letter
	call B_2Letter
	call R_2letter
	call E_2letter
	call A_2letter
	call K_2letter
	call E_22letter
	call R_22letter
	call paddle_1
	call ball_1
	
; For blinking the Press any key button.
	CALL BLINKING

; System Pause.
	mov ah, 0h											; ah = scan-codes, al = ascii-codes.
	int 16h
	CALL PlaySound

; Loading Interface.	
.ENDIF
backgroundForMenu 0h
	mov game_back, 0
	
; Main Menu
reset_menu:
	call DISPLAY
	mov Rowno, 8h
	mov check, 1
again:
	call Boarders2
	call Start_2
	Print_Char 16, rowNo, 30, 0bh

; Traversing the cursor.
mov ah, 0h
int 16h
cmp al, 32
jz checker

.IF ah == 050h  && check < 5                     ;down
Beep 3824
	Print_Char 16, rowNo, 30, 0
	inc check
	add rowNo,3
.ENDIF
.IF ah == 048h && check > 1                   	 ;up
Beep 4891
	dec check
	Print_Char 16, rowNo, 30, 0
	sub rowno,3
.ENDIF
jmp again


checker:
; Start The Game.
.IF check == 1
; Resetting score and lives.
	mov no_of_lives, 3
	mov total_score, 0
	mov rowNo_2, 8h
	mov check_2, 1
		CALL DISPLAY
		CALL Username_Screen
		CALL DISPLAY
	again_2:
		Print_Char 16, rowNo_2, 30, 10
		call Levels_screen

		mov ah,0h
		int 16h	
		cmp al, 32
		jz checker_2
		cmp al, 08h
		jz reset_menu

	.if ah == 050h  && check_2 < 3                         ;down
		Beep 9872
		Print_Char 16, rowNo_2, 30, 0
		inc check_2
		add rowno_2,6
	.elseif ah == 048h && check_2 > 1                      ;up
		dec check_2
		Beep 9872
		Print_Char 16, rowNo_2, 30, 0
		sub rowno_2,6
	.endif
	jmp again_2

	checker_2:
		.IF check_2 == 1
			CALL LEVEL_1_CHANGINGS
			CALL DELAY
		.ELSEIF check_2 == 2
			CALL LEVEL_2_CHANGINGS
			CALL DELAY
		.ELSEIF check_2 == 3
			CALL LEVEL_3_CHANGINGS
			CALL DELAY
		.ENDIF
	jmp again_2

;Options menu.
.ELSEIF check == 2
		CALL DISPLAY
		CALL OPTIONS
here_come:
	mov check_3, 1
	mov Col_no, 14h
	mov Rowno, 11 
	mov B_P, 0
	again_3:
		mov ah,0h
		int 16h
		
		.IF al == 49
			Print_Char_2 Col_no, Rowno, check_3, 31
			mov B_P, 0
			jmp checker_3
		.ELSEIF al == 50
			add Rowno, 8
			Print_Char_2 Col_no, Rowno, check_3, 31
			mov B_P, 1
			jmp checker_3
		.ENDIF
		
		cmp al, 08h
		jz reset_menu
	jmp again_3
	
		checker_3:
	mov ah,0h
	int 16h
		.IF al == 8h
			Print_Char_2 Col_no, Rowno, 0, 31
			jmp here_come
		.ENDIF
		.IF al == 32
			.IF B_P == 0
				mov bl, check_3
				mov objpaddle_1.PADDLE_COLOR, bl
				Print_Char_2 Col_no, Rowno, 0, 31
				jmp here_come
			.ELSEIF B_P == 1
				mov bl, check_3
				mov objball_1.ball_color, bl
				mov original_color, bl
				Print_Char_2 Col_no, Rowno, 0, 31
				jmp here_come
			.ENDIF
		.ENDIF
	.if ah == 04Bh  && check_3 > 1                     		;left
		Print_Char_2 Col_no, Rowno, 0, 31
		dec check_3
		sub col_no, 3
		Print_Char_2 Col_no, Rowno, check_3, 31
	.elseif ah == 04Dh && check_3 < 15                     ; right
		Print_Char_2 Col_no, Rowno, 0, 31
		inc check_3
		add col_no, 3
		Print_Char_2 Col_no, Rowno, check_3, 31
	.endif
	jmp checker_3

; Instructions Menu.
.ELSEIF check == 3
		CALL DISPLAY
		CALL Instructions
no_change_instruction:
		mov ah, 0
		int 16h
		cmp al, 08h
		jnz no_change_instruction
		jmp reset_menu
; LeaderBoard Menu.
.ELSEIF check == 4
		CALL DISPLAY
		CALL HighScore
		CALL PrintScore
no_change_highscore:
		mov ah, 0
		int 16h
		cmp al, 08h
		jnz no_change_highscore
		jmp reset_menu

; Exit The Game.
.ELSEIF check == 5
		mov ah, 4ch
		int 21h
	.ENDIF
JMP AGAIN
ret
GAME_START ENDP


; Function for producing the sound.
Sound PROC FAR
 
		mov al, 182       		; Prepare the speaker for the
        out     43h, al         ;  note.
        mov     ax, freq        ; Frequency number (in decimal)
                                ;  for middle C.
        out     42h, al         ; Output low byte.
        mov     al, ah          ; Output high byte.
        out     42h, al 
        in      al, 61h         ; Turn on note (get value from
                                ;  port 61h).
        or      al, 00000011b   ; Set bits 1 and 0.
        out     61h, al         ; Send new value.
        mov     bx, 25          ; Pause for duration of note.
pause_1:
        mov     cx, 6550
pause_2:
        dec     cx
        jne     pause_2
        dec     bx
        jne     pause_1
        in      al, 61h         ; Turn off note (get value from
                                ;  port 61h).
        and     al, 11111100b   ; Reset bits 1 and 0.
        out     61h, al         ; Send new value.
ret	
Sound ENDP

PlaySound PROC
	 mov freq,2415
	 CALL Sound
	 mov freq,2559
	 CALL Sound
	 mov freq,2711
	 CALL Sound
	 mov freq,2873
	 CALL Sound
	 mov freq,3043
	 CALL Sound
	 mov freq,3225
	 CALL Sound
	 mov freq,3619
	 CALL Sound
	 mov freq,3834
	 CALL Sound
	 mov freq,4063
	 CALL Sound
	 mov freq,3043
	 CALL Sound
	 mov freq,2280
	 CALL Sound
	 mov freq,3043
	 CALL Sound
	 mov freq,3619
	 CALL Sound
	 mov freq,2711
	 CALL Sound
	 mov freq,2415
	 CALL Sound
	 mov freq,2559
	 CALL Sound
	 mov freq,2711
	 CALL Sound
	 mov freq,3043
	 CALL Sound
	 mov freq,1809
	 CALL Sound
	 mov freq,1521
	 CALL Sound
	 mov freq,1621
	 CALL Sound
	 mov freq,1521
	 CALL Sound
	 mov freq,1809
	 CALL Sound
	 mov freq,2280
	 CALL Sound
	 mov freq,2031
	 CALL Sound
	 mov freq,2415
	 CALL Sound
	
	RET
PlaySound endp


LiveLost PROC
	CALL Sound
	mov freq,1521
	CALL Sound
	mov freq,1612
	CALL Sound
	mov freq,1715
	CALL Sound
	mov freq,1809
	CALL Sound
	mov freq,1917
	CALL Sound
	mov freq,2031
	CALL Sound
	mov freq,2152
	CALL Sound
	mov freq,2280
	CALL Sound
	mov freq,2415
	CALL Sound
	mov freq,2559
	CALL Sound
	mov freq,2711
	CALL Sound
	mov freq,2873
	CALL Sound
	mov freq,3043
	CALL Sound
	mov freq,3225
	CALL Sound
	mov freq,3619
	CALL Sound
	mov freq,3834
	CALL Sound
	 
	RET
LiveLost endp


; Proceeds to Level_1
LEVEL_1_CHANGINGS PROC
	mov objball_1.ball_x, 150d
	; Increasing ball_speed
	mov delay_time, 111111111111111b

	mov ball_copy_x, 151d								; Initial position x-coordinates of the ball.
	mov ball_copy_y, 183d								; Initial position y-coordinates of the ball.

	mov objpaddle_1.PADDLE_X, 130
	mov paddle_copy_x, 130d								; Initial position x-coordinates of the paddle.
	mov objpaddle_1.PADDLE_WIDTH, 45d
	MOV PADDLE_WIDTH_COPY, 45
	
	CALL LEVEL_1
	RET
LEVEL_1_CHANGINGS ENDP

; Proceeds to Level_2
LEVEL_2_CHANGINGS PROC
	mov objball_1.ball_x, 153d
	; Increasing ball_speed
	mov delay_time, 111111111110000b
	
	mov ball_copy_x, 154d								; Initial position x-coordinates of the ball.
	mov ball_copy_y, 183d								; Initial position y-coordinates of the ball.

	mov objpaddle_1.PADDLE_X, 135
	mov paddle_copy_x, 135d								; Initial position x-coordinates of the paddle.
	mov objpaddle_1.PADDLE_WIDTH, 40d
	mov PADDLE_WIDTH_COPY, 40d
	
	CALL LEVEL_2
	RET
LEVEL_2_CHANGINGS ENDP

; Proceeds to Level_3
LEVEL_3_CHANGINGS PROC
	mov objball_1.ball_x, 154d
	; Increasing ball_speed
	mov delay_time, 111111111000000b
	
	mov ball_copy_x, 153d								; Initial position x-coordinates of the ball.
	mov ball_copy_y, 183d								; Initial position y-coordinates of the ball.

	mov objpaddle_1.PADDLE_X, 135
	mov paddle_copy_x, 135d								; Initial position x-coordinates of the paddle.
	mov objpaddle_1.PADDLE_WIDTH, 40d
	mov PADDLE_WIDTH_COPY, 40d
	
	CALL LEVEL_3
RET
LEVEL_3_CHANGINGS ENDP

; To print the lives of the player on the screen.
LIVES PROC
	;setting cursor position
	mov bh, 0
	mov ah, 2
	mov dh, 2     			  							; rows.
	mov dl, 1 	    		  							; columns.
	int 10h

	mov dx, offset lives_str							; Displaying the live str.
	mov ah, 9
	int 21h

	mov al, 3				  							; ASCII code of Heart.
	mov bx, 0
	mov bl, 0Ch  		   	  							; color.
	mov cl, no_of_lives       							; repetition count.
	mov ah, 09h
	int 10h
RET
LIVES ENDP

; To print the score of the player on the screen.
SCORE PROC
	;setting cursor position
	mov bh, 0
	mov ah, 2
	mov dh, 2     			  							; rows.
	mov dl, 15	    		  							; columns.
	int 10h

	mov dx, offset score_str							; Displaying the score str.
	mov ah, 9
	int 21h
	
	CALL out_it											; Displays the score multidigit output.
RET
SCORE ENDP



; To print the name of the player on the screen.
NAME_DISP PROC
	;setting cursor position
	mov bh, 0
	mov ah, 2
	mov dh, 2     			 		 					; rows.
	mov dl, 28	    		 	   	 					; columns.
	int 10h

	mov dx, offset name_str			 					; Displaying the name.
	mov ah, 9
	int 21h
	
	mov dx, offset Userstr		 					; Displaying the actual name.
	add dx, 2
	mov ah, 9
	int 21h
RET
NAME_DISP ENDP


; Destroys 5 random bricks.
SPECIAL_DESTROY PROC
	mov DESTROY, 0
REMOVE_BRICK b_1
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_13
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_57
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_48
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_32
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_22
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_38
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_28
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_53
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_21
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_4
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_46
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_5
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_44
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_2
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_41
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_23
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_17
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_54
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_19
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_7
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_20
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_11
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_50
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_30
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_14
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_9
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_35
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_24
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_15
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_25
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_6
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_26
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_12
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_27
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_29
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_31
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_33
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_8
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_36
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_56
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_16
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_37
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_40
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_3
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_42
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_45
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_34
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_10
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_51
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_43
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_52
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_18
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_55
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_39
.IF DESTROY == 5
jmp out_here
.ENDIF

REMOVE_BRICK b_49
.IF DESTROY == 5
jmp out_here
.ENDIF

out_here:
ret
SPECIAL_DESTROY ENDP

end start
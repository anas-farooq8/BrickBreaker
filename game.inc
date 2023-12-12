.data
x dw 0
y dw 0
z dw 0
check db 1h
check_2 db 1h
check_3 db 1h
Col_no db 14h
Rowno db 11h
Rowno_2 db 8h
B_P db 0h
Level1str db "Level No 1 $"
Level2str db "Level No 2 $"
Level3str db "Level No 3 $"
UserName db '   Please Enter Your Name       ',0ah,0dh
	db '$',0ah,0dh
opt db "            Options           $"
Select_str1 db " Option 1:    Select Paddle Color  (Press 1)    $"
Select_str2 db " Option 2:    Select Ball Color  (Press 2)    $"
nostr db " 1  2  3  4  5  6  7  8  9  10 11 12 13 14 15  $"
Str1 db "Start $"
Str2 db "Options $"
Str3 db "Instructions $"
Str4 db "Highscores $"
Str5 db "Exit $"
macroX dw ?
tempmacroX dw ?
macroY dw ?
tempX dw ?
tempY dw ?
freq dw 0
cursor db 1
row_cursor db 12

Buffer db 500 dup('$')

; Bricks
b_1 BRICKS < 145, 55, 1, 80d >
b_2 BRICKS < 145, 65, 1, 81d >
b_3 BRICKS < 125, 65, 1, 64d >
b_4 BRICKS < 165, 65, 1, 96d >
b_5 BRICKS < 145, 75, 1, 51d >
b_6 BRICKS < 125, 75, 1, 84d >
b_7 BRICKS < 105, 75, 1, 53d >
b_8 BRICKS < 165, 75, 1, 54d >
b_9 BRICKS < 185, 75, 1, 55d >
b_10 BRICKS < 145, 85, 1 >
b_11 BRICKS < 125, 85, 1 >
b_12 BRICKS < 105, 85, 1 >
b_13 BRICKS < 85, 85, 1 >
b_14 BRICKS < 165, 85, 1 >
b_15 BRICKS < 185, 85, 1 >
b_16 BRICKS < 205, 85, 1 >
b_17 BRICKS < 145, 95, 1 >
b_18 BRICKS < 125, 95, 1 >
b_19 BRICKS < 105, 95, 1 >
b_20 BRICKS < 85, 95, 1 >
b_21 BRICKS < 65, 95, 1 >
b_22 BRICKS < 165, 95, 1 >
b_23 BRICKS < 185, 95, 1 >
b_24 BRICKS < 205, 95, 1 >
b_25 BRICKS < 225, 95, 1 >
b_26 BRICKS < 145, 105, 1 >
b_27 BRICKS < 125, 105, 1 >
b_28 BRICKS < 105, 105, 1 >
b_29 BRICKS < 85, 105, 1 >
b_30 BRICKS < 165, 105, 1 >
b_31 BRICKS < 185, 105, 1 >
b_32 BRICKS < 205, 105, 1 >
b_33 BRICKS < 145, 115, 1 >
b_34 BRICKS < 125, 115, 1 >
b_35 BRICKS < 105, 115, 1 >
b_36 BRICKS < 165, 115, 1 >
b_37 BRICKS < 185, 115, 1 >
b_38 BRICKS < 145, 125, 1 >
b_39 BRICKS < 125, 125, 1 >
b_40 BRICKS < 165, 125, 1 >
b_41 BRICKS < 145, 135, 1 >
b_42 BRICKS < 0, 0, 1>
b_43 BRICKS < 0, 0, 1>
b_44 BRICKS < 0, 0, 1>
b_45 BRICKS < 0, 0, 1>
b_46 BRICKS < 0, 0, 1>
b_47 BRICKS < 0, 0, 1>
b_48 BRICKS < 0, 0, 1>
b_49 BRICKS < 0, 0, 1>
b_50 BRICKS < 0, 0, 1>
b_51 BRICKS < 0, 0, 1>
b_52 BRICKS < 0, 0, 1>
b_53 BRICKS < 0, 0, 1>
b_54 BRICKS < 0, 0, 1>
b_55 BRICKS < 0, 0, 1>
b_56 BRICKS < 0, 0, 1>
b_57 BRICKS < 0, 0, 1>

	

I1 db "            >>    Instructions     <<           $"
I2	db "     Use left and right key to move Paddle        $"
I3	db "       Press SpaceBar to begin the game           $"
I4	db "          Three lives for each player             $"
I5	db "     Select paddle and ball color in options      $"
I6	db "        Scoring points increase your lifes        $"
I7	db "               Press ESC to Exit                     $"


Yourscore_str  db "            >>       Your score       <<           $"
	
Continue     db '   >>   Press Any Key to Continue   <<   ',0ah,0dh
	db '$',0ah,0dh
	
	
Paus_str db "             Paused           $"
resume db "Resume $"
main_str db "  Main Menu$"


; Prints the Letter.
Print MACRO top_row, left_mostcolumn,bottom_row,right_most ,color 
   push ax
   push bx
   push cx
   push dx   
   
   mov ax, 0
   mov ah, 6
   mov al, 0
   mov bh, color     	;color
   mov ch, top_row    ;top row of window
   mov cl, left_mostcolumn     ;left most column of window
   mov dh, bottom_row     ;Bottom row of window
   mov dl, right_most     ;Right most column of window
   int 10h  
   
   pop dx
   pop cx
   pop bx
   pop ax
ENDM Print 



; Prints the string.
Print_string Macro string,row,column
;setting cursor position
	mov bh, 0
	mov ah, 2
	mov dh, row     			  ; row
	mov dl, column 	    		  ; column
	int 10h

	mov dx, offset string		; Displaying the live str.
	mov ah, 9
	int 21h
Endm Print_string


Print_Char Macro char, row, column, color
;setting cursor position
mov ah, 2
mov dh, row    ;row
mov dl, column     ;column
int 10h

mov al,char    ;ASCII code of Character 
mov bx,0
mov bl,color   ;Green color
mov cx,1       ;repetition count
mov ah,09h
int 10h
Endm Print_Char

;;;;
Print_Char_2 Macro col, row, color, ascii

;setting cursor position
mov ah, 2
mov dh, row    ;row
mov dl, col     ;column
int 10h

mov al, ascii    ;ASCII code of Character 
mov bx,0
mov bl, color   ;Green color
mov cx,1       ;repetition count
mov ah,09h
int 10h
Endm Print_Char_2

You_Win Proc Far

Print 0,0,30,4,2
Print 0,0,1,100,3
Print 0,75,30,80,4
Print 28,0,30,80,5

Print 5,18,6,19,9
Print 6,19,7,20,9
Print 7,20,8,21,9
Print 8,21,9,22,9
Print 9,22,10,23,9


Print 5,27,6,28,9
Print 6,26,7,27,9
Print 7,25,8,26,9
Print 8,24,9,25,9
Print 9,23,10,24,9
Print 10,22,12,24,9

Print 5,32,5,42,9
Print 5,32,12,32,9
Print 12,32,12,42,9
Print 5,42,12,42,9

Print 5,46,12,46,9
Print 12,46,12,56,9
Print 5,56,12,56,9

Print 18,18,25,19,4
Print 25,19,25,20,4
Print 24,20,24,21,4
Print 23,21,23,22,4
Print 22,22,22,23,4
Print 21,23,21,24,4

Print 21,24,21,25,4
Print 22,25,22,26,4
Print 23,26,23,27,4
Print 24,27,24,28,4
Print 25,28,25,29,4
Print 18,29,25,30,4

Print 18,34,25,35,4

Print 18,39,25,40,4
Print 18,40,18,41,4
Print 19,41,19,42,4
Print 20,42,20,43,4
Print 21,43,21,44,4
Print 22,44,22,45,4
Print 23,45,23,46,4
Print 24,46,24,47,4
Print 25,47,25,48,4
Print 18,48,25,49,4

Print 3,15,3,59,10
Print 3,15,14,15,10
Print 14,15,14,59,10
Print 3,59,14,59,10

Print 27,15,27,59,10
Print 16,15,16,59,10
Print 16,15,27,15,10
Print 16,59,27,59,10

Print_Char 30,12,9,10
Print_Char 30,12,10,10
Print_Char 17,13,8,10
Print_Char 17,14,8,10
Print_Char 17,15,8,10
Print_Char 17,16,8,10
Print_Char 17,17,8,10

Print_Char 16,13,11,10
Print_Char 16,14,11,10
Print_Char 16,15,11,10
Print_Char 16,16,11,10
Print_Char 16,17,11,10
Print_Char 31,18,9,10
Print_Char 31,18,10,10

Print_Char 30,12,65,10
Print_Char 30,12,66,10
Print_Char 17,13,64,10
Print_Char 17,14,64,10
Print_Char 17,15,64,10
Print_Char 17,16,64,10
Print_Char 17,17,64,10

Print_Char 16,13,67,10
Print_Char 16,14,67,10
Print_Char 16,15,67,10
Print_Char 16,16,67,10
Print_Char 16,17,67,10
Print_Char 31,18,65,10
Print_Char 31,18,66,10

ret
You_Win  Endp

Pause_Screen Proc Far

	Print 0,0,25,1,2
	;Print 0,0,1,39,3
	Print 0,38,25,39,4
	;Print 23,0,24,39,5
	
	Print 3,15,3,25,10
	Print 3,15,7,15,10
	Print 7,15,7,25,10
	Print 3,25,7,25,10
	Print_string Paus_str,5,5
	
	Print 12,8,12,8,15
	Print 10,11,10,30,14
	Print 10,30,14,30,14
	Print 14,11,14,30,14
	Print_string resume,12,13

	Print 18,8,18,8,15
	Print 16,11,16,30,12
	Print 16,30,20,30,12
	Print 20,11,20,30,12
	Print_string main_str,18,11
	
	ret

Pause_Screen endp

DETECT_ALL_COLIISON MACRO
	DETECT_BRICK_COLLISION objball_1, b_1
	DETECT_BRICK_COLLISION objball_1, b_2
	DETECT_BRICK_COLLISION objball_1, b_3
	DETECT_BRICK_COLLISION objball_1, b_4
	DETECT_BRICK_COLLISION objball_1, b_5
	DETECT_BRICK_COLLISION objball_1, b_6
	DETECT_BRICK_COLLISION objball_1, b_7
	DETECT_BRICK_COLLISION objball_1, b_8
	DETECT_BRICK_COLLISION objball_1, b_9
	DETECT_BRICK_COLLISION objball_1, b_10
	DETECT_BRICK_COLLISION objball_1, b_11
	DETECT_BRICK_COLLISION objball_1, b_12
	DETECT_BRICK_COLLISION objball_1, b_13
	DETECT_BRICK_COLLISION objball_1, b_14
	DETECT_BRICK_COLLISION objball_1, b_15
	DETECT_BRICK_COLLISION objball_1, b_16
	DETECT_BRICK_COLLISION objball_1, b_17
	DETECT_BRICK_COLLISION objball_1, b_18
	DETECT_BRICK_COLLISION objball_1, b_19
	DETECT_BRICK_COLLISION objball_1, b_20
	DETECT_BRICK_COLLISION objball_1, b_21
	DETECT_BRICK_COLLISION objball_1, b_22
	DETECT_BRICK_COLLISION objball_1, b_23
	DETECT_BRICK_COLLISION objball_1, b_24
	DETECT_BRICK_COLLISION objball_1, b_25
	DETECT_BRICK_COLLISION objball_1, b_26
	DETECT_BRICK_COLLISION objball_1, b_27
	DETECT_BRICK_COLLISION objball_1, b_28
	DETECT_BRICK_COLLISION objball_1, b_29
	DETECT_BRICK_COLLISION objball_1, b_30
	DETECT_BRICK_COLLISION objball_1, b_31
	DETECT_BRICK_COLLISION objball_1, b_32
	DETECT_BRICK_COLLISION objball_1, b_33
	DETECT_BRICK_COLLISION objball_1, b_34
	DETECT_BRICK_COLLISION objball_1, b_35
	DETECT_BRICK_COLLISION objball_1, b_36
	DETECT_BRICK_COLLISION objball_1, b_37
	DETECT_BRICK_COLLISION objball_1, b_38
	DETECT_BRICK_COLLISION objball_1, b_39
	DETECT_BRICK_COLLISION objball_1, b_40
	DETECT_BRICK_COLLISION objball_1, b_41
	DETECT_BRICK_COLLISION objball_1, b_42
	DETECT_BRICK_COLLISION objball_1, b_43
	DETECT_BRICK_COLLISION objball_1, b_44
	DETECT_BRICK_COLLISION objball_1, b_45
	DETECT_BRICK_COLLISION objball_1, b_46
	DETECT_BRICK_COLLISION objball_1, b_47
	DETECT_BRICK_COLLISION objball_1, b_48
	DETECT_BRICK_COLLISION objball_1, b_49
	DETECT_BRICK_COLLISION objball_1, b_50
	DETECT_BRICK_COLLISION objball_1, b_51
	DETECT_BRICK_COLLISION objball_1, b_52
	DETECT_BRICK_COLLISION objball_1, b_53
	DETECT_BRICK_COLLISION objball_1, b_54
	DETECT_BRICK_COLLISION objball_1, b_55
	DETECT_BRICK_COLLISION objball_1, b_56
	DETECT_BRICK_COLLISION objball_1, b_57
ENDM


drawPixel MACRO x_axis, y_axis, userColour
	mov dx, x_axis
	mov tempX, dx

	mov dx, y_axis
	mov tempY, dx

	mov ax, 5
	mov bx, x_axis

	mul bx
	mov x_axis, ax

	mov ax, 5
	mov bx, y_axis

	mul bx
	mov y_axis, ax

	mov bx, x_axis
	mov macroX, bx
	mov bx, y_axis
	mov macroY, bx
	mov bx, x_axis
	mov tempmacroX, bx

	add macroX, 5										; macroX will contain the x_axis+5 Value.
	add macroY, 5										; macroY will contain the y_axis+5 Value.

	mov dx, macroX
	mov bx, macroY

	.WHILE y_axis < bx ; rows
		push bx
		.WHILE x_axis < dx ; coumns
			push dx
			mov bx, 0
			mov ah, 0CH
			mov al, userColour
			mov cx, x_axis
			mov dx, y_axis
			int 10h
			inc x_axis
			pop dx
		.ENDW
		inc y_axis
		mov bx, tempmacroX
		mov x_axis, bx
		pop bx
	.ENDW

	mov dx, tempX
	mov x_axis, dx

	mov dx, tempY
	mov y_axis, dx
ENDM

backgroundForMenu MACRO color
	mov x,0
	mov y,0
	mov z,0
	.WHILE y < 96
	mov ax,z
	mov x,ax
	   .WHILE x < 128
		   drawPixel x, y, color
		   inc x 
	   .ENDW
	   inc y
	.ENDW
ENDM

Reshape PROC FAR
	mov cx, objball_1.ball_x
	mov dx, objball_1.ball_y
	mov al, 0
	mov ah, 0ch											; Writes a pixel.
	int 10h												; Top Left corner.
	add cx, 4
	mov ah, 0ch											; Writes a pixel.
	int 10h												; Top right corner.
	add dx, 4
	mov ah, 0ch											; Writes a pixel.
	int 10h												; Bottom right corner.
	sub cx, 4
	mov ah, 0ch											; Writes a pixel.
	int 10h												; Bottom left corner.
RET
Reshape ENDP

Levels_screen Proc 

	Print 0,0,30,4,2
	Print 0,0,1,100,3
	Print 0,75,30,80,4
	Print 28,0,30,80,5
	Print 6,25,7,52,15
	Print 9,25,10,52,15
	Print 12,25,13,52,10
	Print 15,25,16,52,10
	Print 18,25,19,52,12
	Print 21,25,22,52,12
	Print_string Level1str, 8,35
	Print_string Level2str, 14,35
	Print_string Level3str, 20,35

ret
Levels_screen Endp

Options Proc far

	Print 0,0,30,4,2
	Print 0,0,1,100,3
	Print 0,75,30,80,4
	Print 28,0,30,80,5
	Print 3,30,3,50,10
	Print 3,30,7,30,10
	Print 7,30,7,50,10
	Print 3,50,7,50,10
	Print 13,19,13,21,1
	Print 13,22,13,24,2
	Print 13,25,13,27,3
	Print 13,28,13,30,4
	Print 13,31,13,33,5
	Print 13,34,13,36,6
	Print 13,37,13,39,7
	Print 13,40,13,42,8
	Print 13,43,13,45,9
	Print 13,46,13,48,10
	Print 13,49,13,51,11
	Print 13,52,13,54,12
	Print 13,55,13,57,13
	Print 13,58,13,60,14
	Print 13,61,13,63,15

	Print 21,19,21,21,1
	Print 21,22,21,24,2
	Print 21,25,21,27,3
	Print 21,28,21,30,4
	Print 21,31,21,33,5
	Print 21,34,21,36,6
	Print 21,37,21,39,7
	Print 21,40,21,42,8
	Print 21,43,21,45,9
	Print 21,46,21,48,10
	Print 21,49,21,51,11
	Print 21,52,21,54,12
	Print 21,55,21,57,13
	Print 21,58,21,60,14
	Print 21,61,21,63,15


	Print 9,5,9,17,10
	Print 11,5,11,17,10
	Print 17,5,17,17,10
	Print 19,5,19,17,10
	Print_string nostr,15,19
	Print_string nostr,23,19
	Print_string opt,5,25
	Print_string Select_str1,10,5
	Print_string Select_str2,18,5
ret
Options Endp

Light_Borders PROC FAR
	Print 0,0,30,4,2
	Print 0,0,1,100,3
	Print 0,75,30,80,4
	Print 28,0,30,80,5
	Print 10,25,10,52,12
	Print 10,25,14,52,12
	Print 18,25,19,52,15
	Print 21,25,22,52,15
ret
Light_Borders ENDP

Username_Screen Proc Far

	CALL Light_Borders
	Print_string UserName, 12,25
	
	; Printing the Char
	mov ah, 02 
	mov bh,0 
	mov dh,20 
	mov dl, 37
	int 10h
	
	mov ah, 0Ah	
	mov dx, OFFSET Userstr
	int 21h
ret
Username_Screen Endp


Boarders PRoc Far
	Print 0,0,30,4,15
	Print 0,0,1,100,15
	Print 0,75,30,80,15
	Print 28,0,30,80,15
	
Print_string Continue, 20,25
ret 
Boarders Endp



B_Letter Proc Far
	Print 3,9,8,10,12
	Print 3,9,3,16,12
	Print 3,15,8,16,12
	Print 5,9,5,16,12
	Print 8,9,8,16,12
ret 
B_Letter endp


R_Letter Proc Far
	Print 3,18,8,18,12
	Print 3,18,3,23,12
	Print 3,23,5,23,12
	Print 5,18,5,23,12
	Print 6,18,6,19,12
	Print 7,20,7,21,12
	Print 8,22,8,23,12
ret
R_Letter Endp



I_Letter Proc Far
	Print 3,25,8,25,12
ret
I_letter Endp


C_Letter Proc Far
	Print 3,27,8,28,12
	Print 3,28,3,33,12
	Print 8,28,8,33,12
ret
C_letter Endp


K_letter Proc Far
	Print 3,35,8,37,12
	Print 5,37,5,39,12
	Print 4,39,4,41,12
	Print 3,41,3,43,12
	Print 6,37,6,39,12
	Print 7,39,7,41,12
	Print 8,41,8,43,12
ret
K_letter Endp


B_2Letter Proc Far
	Print 10,18,15,19,12
	Print 10,18,10,25,12
	Print 10,24,15,25,12
	Print 12,18,12,25,12
	Print 15,18,15,25,12
ret
B_2Letter Endp


R_2Letter Proc Far
	Print 10,27,15,28,12
	Print 10,27,10,33,12
	Print 10,33,12,34,12
	Print 12,27,12,33,12
	Print 13,27,13,29,12
	Print 14,30,14,31,12
	Print 15,31,15,33,12
ret
R_2Letter Endp


E_2letter Proc Far
	Print 10,36,15,37,12
	Print 10,36,10,41,12
	Print 12,36,12,41,12
	Print 15,36,15,41,12
ret
E_2letter Endp



A_2letter Proc Far
	Print 10,43,15,44,12
	Print 10,43,10,49,12
	Print 10,49,15,50,12
	Print 12,43,12,50,12
ret
A_2letter Endp


K_2letter Proc Far
	Print 10,52,15,53,12
	Print 12,52,12,54,12
	Print 11,54,11,56,12
	Print 10,56,10,57,12
	Print 13,54,13,55,12
	Print 14,55,14,56,12
	Print 15,56,15,57,12
ret
K_2letter endp


E_22letter Proc Far
	Print 10,59,15,60,12
	Print 10,59,10,64,12
	Print 12,59,12,64,12
	Print 15,59,15,64,12
ret
E_22letter Endp


R_22letter Proc Far
	Print 10,66,15,67,12
	Print 10,66,10,72,12
	Print 10,72,12,72,12
	Print 12,66,12,72,12
	Print 13,67,13,69,12
	Print 14,69,14,71,12
	Print 15,71,15,72,12
ret
R_22letter Endp


Paddle_1 Proc Far
	Print 24,36,24,38,15
	Print 24,39,24,46,12
	Print 24,46,24,48,15
ret
Paddle_1 endp 



ball_1 Proc Far
	Print 22,42,22,43,15
ret
ball_1 Endp




Boarders2 PROC far
	Print 0,0,30,4,28
	Print 0,75,30,80,28
	Print 4,13,4,66,10
	Print 4,66,25,66,10
	Print 25,13,25,66,10
	Print 4,13,25,13,10

	Print 0,30,0,50,14
	Print 1,32,1,48,14
	Print 2,34,2,46,14
	Print 3,36,3,44,14
	;Print 4,38,4,42,14

	Print 11,73,18,74,9
	Print 12,71,17,73,9
	Print 13,69,16,71,9
	Print 14,67,15,69,9

	Print 29,30,29,50,15
	Print 28,32,28,48,15
	Print 27,34,27,46,15
	Print 26,36,26,44,15

	Print 11,5,18,6,13
	Print 12,6,17,8,13
	Print 13,8,16,10,13
	Print 14,10,15,12,13
ret 
Boarders2 Endp



Start_2 PRoc Far
	Print_string str1,8,38
	Print_string Str2,11,37
	Print_string Str3,14,34
	Print_string Str4,17,35
	Print_string Str5,20,38
ret
Start_2 Endp



Instructions Proc Far
	Print 0,0,30,4,2
	Print 0,0,1,100,3
	Print 0,75,30,80,4
	Print 28,0,30,80,5
	Print 6,15,6,62,10
	Print 6,15,22,15,10
	Print 22,15,22,62,10
	Print 6,62,22,62,10
	Print_string I1,8,15
	Print_string I2,10,15
	Print_string I3,12,15
	Print_string I4,14,15
	Print_string I5,16,15
	Print_string I6,18,15
	Print_string I7,20,15

ret 
Instructions Endp

HighScore PROC
	Print 0,0,30,4,2
	Print 0,0,1,100,3
	Print 0,75,30,80,4
	Print 28,0,30,80,5
	Print 6,15,6,62,10
	Print 6,15,22,15,10
	Print 22,15,22,62,10
	Print 6,62,22,62,10
	
ret
HighScore ENDP

PrintScore Proc
	; Opening a existing file.
	mov  ah, 3dh
	mov dx, offset FILE_NAME
	mov al, 0
	int 21h

	mov FILE_NAME_PTR, ax
	
	; Reading the file.
	mov ah, 3fh
	mov bx, FILE_NAME_PTR
	mov cx, 25
	mov dx, offset Buffer
	int 21h
	
	; Closing the file
	mov ah, 3eh
	mov dx, FILE_NAME_PTR
	int 21h
	
	;setting cursor position
	mov bh, 0
	mov ah, 2
	mov dh, 8     			  							; rows.
	mov dl, 20	    		  							; columns.
	int 10h
	
	mov dx, offset Buffer								; Displaying the score str.
	mov ah, 9
	int 21h	
	
ret
PrintScore ENDP


Game_Over Proc Far
    Print 0,0,30,4,2
	Print 0,0,1,100,3
	Print 0,75,30,80,4
	Print 28,0,30,80,5
	
	Print 5,7,5,15,12
	Print 5,7,10,7,12
	Print 10,7,10,15,12
	Print 8,15,10,15,12
	Print 8,14,8,15,12

	Print 5,18,10,18,12
	Print 5,18,5,23,12
	Print 5,23,10,23,12
	Print 8,18,8,23,12

	Print 5,25,10,25,12
	Print 5,25,6,26,12
	Print 6,26,6,27,12
	Print 7,27,7,28,12

	Print 7,28,7,29,12
	Print 6,29,6,30,12
	Print 5,30,5,31,12
	Print 5,31,10,31,12

	Print 5,33,10,33,12
	Print 5,33,5,38,12
	Print 7,33,7,38,12
	Print 10,33,10,38,12

	Print 12,33,17,33,12
	Print 12,33,12,38,12
	Print 12,38,17,38,12
	Print 17,33,17,38,12

	Print 12,40,13,40,12
	Print 13,41,14,41,12
	Print 14,42,15,42,12
	Print 15,43,16,43,12
	Print 16,44,17,44,12

	Print 16,44,16,45,12
	Print 15,45,15,46,12
	Print 14,46,14,47,12
	Print 13,47,13,48,12
	Print 12,48,12,48,12

	Print 12,50,17,50,12
	Print 12,50,12,55,12
	Print 14,50,14,55,12
	Print 17,50,17,55,12

	Print 12,57,17,57,12
	Print 12,57,12,62,12
	Print 12,62,14,62,12
	Print 14,57,14,62,12

	Print 15,58,15,59,12
	Print 16,59,16,60,12
	Print 17,60,17,61,12

Print_string Yourscore_str,20,20

	;setting cursor position
	mov bh, 0
	mov ah, 2
	mov dh, 22     			 		 					; rows.
	mov dl, 45	    		 	   	 					; columns.
	int 10h

CALL out_it
ret
Game_Over Endp


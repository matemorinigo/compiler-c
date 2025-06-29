include macros2.asm
include number.asm
include macros.asm

.MODEL SMALL
.386
.STACK 200h

.DATA
NEW_LINE DB 0AH,0DH,'$'
CWprevio DW ?
I_0 dd 0
I_3 dd 3
I_6 dd 6
T__amarillo_ db "amarillo", '$'
T__verde_ db "verde", '$'
T__verderill_ db "verderill", '$'
a dd ?
aux_var_1 dd ?
b dd ?
c dd ?
d dd ?
j db 50 dup(?)
x dd ?
y dd ?
z dd ?

.CODE

MOV AX, @DATA
MOV DS, AX
MOV ES, AX
FINIT

start:
terceto_1:
fld dword ptr x
fstp dword ptr aux_var_1
terceto_2:
MOV EAX, aux_var_1
MOV a, EAX
terceto_3:
LEA ESI, T__verderill_
LEA EDI, j
STRCPY
terceto_4:
displayString j
displayString NEW_LINE
terceto_5:

MOV AH, 1
INT 21h
MOV AX, 4C00h
INT 21h

END

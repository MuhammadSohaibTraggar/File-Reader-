org 100h

section .data

basePath db 'TEST\',0

newline db 0Dh,0Ah,'$'

mainMenu db 0Dh,0Ah
         db '1. View File',0Dh,0Ah
         db '2. Edit File',0Dh,0Ah
         db '3. Delete File',0Dh,0Ah
         db '4. Add File',0Dh,0Ah
         db '5. Exit',0Dh,0Ah
         db 'Choice: $'

msgFilename db 0Dh,0Ah,'Enter filename: $'
msgText     db 0Dh,0Ah,'Enter text: $'

msgOpenErr  db 0Dh,0Ah,'Cannot open file.$'
msgDeleted  db 0Dh,0Ah,'File deleted successfully.$'
msgUpdated  db 0Dh,0Ah,'File updated successfully.$'
msgAdded    db 0Dh,0Ah,'File created successfully.$'

handle dw 0

filenameInput:
db 20
db 0
times 20 db 0

textInput:
db 100
db 0
times 100 db 0

fullPath:
times 40 db 0

buffer:
times 512 db 0


section .text

start:

push cs
pop ds


; ==================================
; MAIN MENU
; ==================================

main_menu:

mov dx,mainMenu
mov ah,09h
int 21h

mov ah,01h
int 21h

cmp al,'1'
je near view_file

cmp al,'2'
je near edit_file

cmp al,'3'
je near delete_file

cmp al,'4'
je near add_file

cmp al,'5'
je near exit

jmp main_menu


; ==================================
; GET FILENAME
; ==================================

get_filename:

mov dx,msgFilename
mov ah,09h
int 21h

mov dx,filenameInput
mov ah,0Ah
int 21h

ret


; ==================================
; BUILD FULL PATH
; ==================================

build_path:

mov si,basePath
mov di,fullPath

copy_base:

lodsb
stosb

cmp al,0
jne near copy_base

dec di

mov si,filenameInput+2

mov cl,[filenameInput+1]
xor ch,ch

copy_name:

cmp cx,0
je near finish_path

lodsb
stosb

dec cx
jmp copy_name

finish_path:

mov al,0
stosb

ret


; ==================================
; VIEW FILE
; ==================================

view_file:

call get_filename
call build_path

mov dx,newline
mov ah,09h
int 21h

mov ah,3Dh
mov al,0
mov dx,fullPath
int 21h

jc near open_error

mov [handle],ax

mov ah,3Fh
mov bx,[handle]
mov cx,512
mov dx,buffer
int 21h

mov cx,ax
mov si,buffer

print_data:

cmp cx,0
je near close_view

lodsb

mov dl,al
mov ah,02h
int 21h

dec cx
jmp print_data


close_view:

mov ah,3Eh
mov bx,[handle]
int 21h

jmp main_menu


; ==================================
; EDIT FILE
; ==================================

edit_file:

call get_filename
call build_path

mov dx,msgText
mov ah,09h
int 21h

mov dx,textInput
mov ah,0Ah
int 21h

mov ah,3Ch
mov cx,0
mov dx,fullPath
int 21h

mov [handle],ax

mov ah,40h
mov bx,[handle]

mov cl,[textInput+1]
xor ch,ch

mov dx,textInput+2

int 21h

mov ah,3Eh
mov bx,[handle]
int 21h

mov dx,msgUpdated
mov ah,09h
int 21h

jmp main_menu


; ==================================
; DELETE FILE
; ==================================

delete_file:

call get_filename
call build_path

mov ah,41h
mov dx,fullPath
int 21h

jc near open_error

mov dx,msgDeleted
mov ah,09h
int 21h

jmp main_menu


; ==================================
; ADD FILE
; ==================================

add_file:

call get_filename
call build_path

mov dx,msgText
mov ah,09h
int 21h

mov dx,textInput
mov ah,0Ah
int 21h

mov ah,3Ch
mov cx,0
mov dx,fullPath
int 21h

mov [handle],ax

mov ah,40h
mov bx,[handle]

mov cl,[textInput+1]
xor ch,ch

mov dx,textInput+2

int 21h

mov ah,3Eh
mov bx,[handle]
int 21h

mov dx,msgAdded
mov ah,09h
int 21h

jmp main_menu


; ==================================
; ERROR
; ==================================

open_error:

mov dx,msgOpenErr
mov ah,09h
int 21h

jmp main_menu


; ==================================
; EXIT
; ==================================

exit:

mov ax,4C00h
int 21h

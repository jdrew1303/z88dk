; int strncmp(char *s1, char *s2, int n)
; compare at most n chars of string s1 to string s2

; exit : if s==ct : hl = 0, Z flag set
;        if s<<ct : hl < 0, NC flag set
;        if s>>ct : hl > 0, C flag set
; uses : af, bc, de, hl

XLIB strncmp
XDEF ASMDISP_STRNCMP

.strncmp

   pop af
   pop bc
   pop de
   pop hl
   push hl
   push de
   push bc
   push af

   ; bc = int n
   ; de = char *s2
   ; hl = char *s1

.asmentry

   ld a,b
   or c
   jr z, equal
      
.strncmp1

   ld a,(de)
   inc de
   cpi
   jr nz, different
   jp po, equal
   or a
   jp nz, strncmp1
   
.equal

   ld hl,0
   ret

.different

   dec hl
   cp (hl)
   ld h,$80
   ret nc
   dec h
   ret

DEFC ASMDISP_STRNCMP = asmentry - strncmp

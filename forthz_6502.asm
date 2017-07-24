OSWRCH = $FFEE
OSRDCH = $FFE0
OSNEWL = $FFE7
OSBYTE = $FFF4

XSAVE	=	$68		; TEMPORARY FOR X REGISTER

;	ROM HEADER
	*=	$8000		; ROM ADDRESS

L8000   .BYTE   $C3
        .WORD   LANGENT
L8003	JMP	SERVENT		; SERVICE ENTRY
L8006	.BYTE	$E8		; ROM TYPE - 11100010b - service entry, language entry, 2nd proc reloc, z80, soft key exps
L8007	.BYTE	COPYR-L8000	; COPYRIGHT OFFSET
L8008	.BYTE	1		; BINARY VERSION NUMBER
TITLE	.BYTE	'Z80FORTH'	; TITLE STRING
	.BYTE	0
VERS	.BYTE	'1.03'		; VERSION STRING
COPYR	.BYTE	0,'(C)'		; COPYRIGHT IDENT
	.BYTE	' Acornsoft Ltd. 1983'
	.BYTE	0
        .WORD	L8000		; TUBE RELOC ADDRESS
	.WORD	0

WRSTR	LDA	#>L8000
	STA	$13
	LDY	#0
L8054	LDA	($12),Y
	BEQ	L805E
	JSR	OSWRCH
	INY
	BNE	L8054
L805E	RTS

;	SERVICE ENTRY

SERVENT	CMP	#4              ; unrecognised comand
	BEQ     _UNREC
	JMP     L80B0

_UNREC  PHA
	TYA
	PHA
        ;; compare to "FORTH", case-insensitive
	LDA	($F2),Y
	CMP	#'F'
	BEQ	L8070
	CMP	#'f'
	BNE	_CTEST
L8070	INY
	LDA	($F2),Y
	CMP	#'O'
	BEQ	L807B
	CMP	#'o'
	BNE	L80A8

L807B	INY
	LDA	($F2),Y
	CMP	#'R'
	BEQ	L8086
	CMP	#'r'
	BNE	L80A8
L8086	INY
	LDA	($F2),Y
	CMP	#'T'
	BEQ	L8091
	CMP	#'t'
	BNE	L80A8
L8091	INY
	LDA	($F2),Y
	CMP	#'H'
	BEQ	L809C
	CMP	#'h'
	BNE	L80A8
L809C	INY
	LDA	($F2),Y
	CMP	#$D             ; Carriage return
	BNE	L80A8
	LDA	#$8E            ; Enter language ROM
;         OSBYTE &8E (142) *FX 142
;         Enter language ROM
;         Entry parameters: X determines which language ROM is entered
;         The selected language will be re-entered after a soft BREAK.
;         The action of this call is to printout the language name and
;         enter the selected language ROM at &8000 with A=1. Locations
;         &FD and &FE in zero page point to the copyright message in
;         the ROM. When a Tube is present this call will copy the
;         language across to the second processor.
	JMP	OSBYTE

L80A8	CMP	#'.'            ; abbreviated command - *FOR. etc.
	BEQ	L809C

_CTEST	LDA	($F2),Y
	CMP	#'T'
	BNE	_RESTOR
	INY
	LDA	($F2),Y
	CMP	#'E'
	BNE	_RESTOR
	INY
	LDA	($F2),Y
	CMP	#'S'
	BNE	_RESTOR
	INY
	LDA	($F2),Y
	CMP	#'T'
	BNE	_RESTOR

        ;; configure serial I/O
        STX     XSAVE
	LDA     #3
        LDX     #1
        JSR    OSBYTE
        LDA     #2
        LDX     #1
        JSR    OSBYTE
        LDA     #7
        LDX     #8
        JSR    OSBYTE
        LDA     #8
        LDX     #8
        JSR    OSBYTE
	LDA	#$8E            ; Enter language ROM
        LDX     XSAVE
        JMP     OSBYTE

_RESTOR	PLA                     ; restore Y and A registers
	TAY
	PLA
	RTS

L80B0	CMP	#9              ; *HELP instruction expansion
	BEQ	L80B5
	RTS

L80B5	PHA                     ; save A and Y registers on stack
	TYA
	PHA
	JSR	OSNEWL
	LDA	#<TITLE         ; write title
	STA	$12
	JSR	WRSTR
	LDA	#' '
	JSR	OSWRCH          ; space
	LDA	#<VERS          ; version
	STA	$12
	JSR	WRSTR
	JSR	OSNEWL
	PLA                     ; restore A and Y
	TAY
	PLA
	RTS

;	LANGUAGE ENTRY

LANGENT                         ; Z80 code follows

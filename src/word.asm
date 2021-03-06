;; ;	(EXPECT)

;; On exit,
;;  C=0 if a carriage return terminated input.
;;  C=1 if an ESCAPE condition terminated input.
;;  Y contains line length, including carriage return if used

;;; (addr\count .. )

_OSWORD_PBLOCK:         ds 5

_NF_PEXPEC:
        db $88,'(EXPECT',$A9
        dw _LF_PEXPEC
PEXPEC: dw $+2
        call OSNEWL
        ld ix, _OSWORD_PBLOCK

        pop bc                  ; number of characters to read
        ld (ix+2), c

        pop bc                  ; address to write input
        ld (ix+0), c
        ld (ix+1), b

        ld (ix+3), $20          ; min ASCII value
        ld (ix+4), $FF          ; max ASCII value

        ld hl, _OSWORD_PBLOCK
        ld a, $0
        call OSWORD
        ld l, h                 ; h contains number of characters read
        ld h, 0
        push hl
        jp NEXT


;;;  EXPECT
;;;     : EXPECT OVER SWAP (EXPECT) + 0 SWAP ! EXIT ;
_NF_EXPECT:
        db $86,'EXPEC',$d4
        dw _LF_EXPECT
EXPECT: dw DOCOL
        dw OVER
        dw SWAP
        dw PEXPEC
        dw PLUS
        dw ZERO
        dw SWAP
        dw STORE
        dw EXIT


;; Stack Action: (addr\c ... addr\n1\n2\n3)
;; Uses/Leaves: 2 4
;; Description: The text-scanning primitive used by
;; WORD . The text starting at the address addr is
;; searched, ignoring leading occurrences of the
;; delimiter c, until the first non-delimiter character is
;; found. The offset from addr to this character is left
;; as n1. The search continues from this point until the
;; first delimiter after the text is found. The offsets
;; from addr to this delimiter and to the first character
;; not included in the scan are left as n2 and n3
;; respectively. The search will, regardless of the value
;; of c, stop on encountering an ASCII null, which is
;; regarded as an unconditional delimiter. The null is
;; never included in the scan.


;;;  ENCLOSE
_NF_ENCL:
        db $87,'ENCLOS',$c5
        dw _LF_ENCL
ENCL:   dw $+2

        pop de                  ; e is delimiter
        pop hl                  ; addr
        push hl

        ld bc, -1               ; current offset counter
        dec hl

_ENCL_SKIP_INITIAL_DELIMITER:
        inc hl
        inc bc
        ld a, (hl)
        cp e
        jr z, _ENCL_SKIP_INITIAL_DELIMITER

        push bc                 ; n1

_ENCL_MAIN_LOOP:
        ld a, (hl)
        cp 0
        jr nz, _ENCL_NOT_NULL

        pop de
        ld a, e
        cp c
        jr nz, _ENCL_RET_N2_UNCH

        ld a, d
        cp b
        jr nz, _ENCL_RET_N2_UNCH

        push de
        inc bc
        push bc
        dec bc
        push bc
        jp NEXT

_ENCL_RET_N2_UNCH:
        push de
        push bc
        push bc
        jp NEXT

_ENCL_NOT_NULL:
        inc bc
        inc hl
        cp e
        jr nz, _ENCL_MAIN_LOOP

        dec bc
        push bc
        inc bc
        push bc

        jp NEXT

;	(WORD)  ( C -- ADR LEN )
        ;; Description: Scans the input buffer, ignoring leading
        ;; occurrences of the delimiter character c, for the next
        ;; word. The start address and length of the text up to
        ;; the terminating delimiter are left. No text is moved.
        ;; See WORD


;;  (WORD)
;;     BLK @                               \ if 0, input from terminal, otherwise mass storage
;;     ?DUP                                \ dup if non-zero
;;     0BRANCH 8                           \ otherwise branch to TIB@
;;     BLOCK                               \ load block into mass storage buffer
;;     BRANCH 6                            \ branch to >IN
;;     TIB @                               \ get start of terminal input buffer
;;     >IN @                               \ get offset into input buffer
;;     +                                   \ get position within input buffer
;;     SWAP                                \ put delimiter char on top
;;     ENCLOSE                             \ scan text in buffer with delimiter on top of stack
;;     >IN +!                              \ update input offset with offset to first char not incl from ENCLOSE
;;     OVER -                              \ get match string length (addr\n1\n2 .. addr\n1\length
;;     ROT ROT +                           \ (addr\n1\length .. length\addrstart)
;;     SWAP                                \ (addrstart\length)
;; ;
;;;  (WORD)
;;;     : (WORD) BLK @ ?DUP 0BRANCH LIT 8 BLOCK BRANCH LIT 6 TIB @ >IN @ + SWAP ENCLOSE >IN +! OVER - ROT ROT + SWAP EXIT ;
_NF_PWORD:
        db $86,'(WORD',$a9
        dw _LF_PWORD
PWORD:  dw DOCOL
        ;; dw BLK
        ;; dw AT
        ;; dw QDUP
        ;; dw ZBRAN
        ;; dw $8
        ;; dw BLOCK
        ;; dw BRAN
        ;; dw $6
        dw TIB
        dw AT
        dw INN
        dw AT
        dw PLUS
        dw SWAP
        dw ENCL
        dw INN
        dw PSTOR
        dw OVER
        dw SUBB
        dw ROT
        dw ROT
        dw PLUS
        dw SWAP
        dw EXIT

;; ;	1WORD
;; ;;; : 1WORD (WORD) WDSZ MIN WBFR C! WBFR COUNT 1+ CMOVE WBFR ;
_NF_ONEWRD:
	db	$85,'1WOR',$C4
	dw	_LF_ONEWRD
ONEWRD:	dw	DOCOL
	dw	PWORD
	dw	WDSZ
	dw	MIN
	dw	WBFR
	dw	CSTOR
	dw	WBFR
	dw	COUNT
	dw	ONEP
	dw	CMOVE
	dw	WBFR
	dw	EXIT


;;;  WORD
;;;     : WORD 1WORD DUP 1+ C@ 0= 0BRANCH 8 0 OVER C! EXIT ;
_NF_WORD:
        db $84,'WOR',$c4
        dw _LF_WORD
WORD:   dw DOCOL
        dw ONEWRD
        dw DUPP
        dw ONEP
        dw CAT
        dw ZEQU
        dw ZBRAN
        dw $8
        dw ZERO
        dw OVER
        dw CSTOR
        dw EXIT

;;;  TRAVERSE
;; Stack Action: (addr1\n ... addr2)
;; Uses/Leaves: 2 1
;; Status:
;; Description:     Moves across the name field of a
;;         dictionary entry. If n=l, addr1 should be the address
;;         of the name length byte i.e. the NFA of the word! and
;;         the movement is towards high memory. If n= -1, addr1
;;         should be the last letter of the name and the movement
;;         is towards low memory. The addr2 that is left is the
;;         address of the other end of the name.
_NF_TRAV:
        db $88,'TRAVERS',$c5
        dw _LF_TRAV
TRAV:   dw $+2
        pop de
        pop hl
        ld a, $7F
_TRAVLOOP:
        add hl, de
        cp (hl)
        jp p, _TRAVLOOP
        push hl
        jp NEXT


;;;  ID.
;;;     : ID. PAD BL LIT ?'_'? FILL DUP PFA LFA OVER - PAD SWAP CMOVE PAD COUNT LIT 31 AND TYPE SPACE EXIT ;
_NF_IDDOT:
        db $83,'ID',$ae
        dw _LF_IDDOT
IDDOT:  dw DOCOL
        dw PAD
        dw BLL
        dw LIT
        dw '_'          ; ???
        dw FILL
        dw DUPP
        dw PFA
        dw LFA
        dw OVER
        dw SUBB
        dw PAD
        dw SWAP
        dw CMOVE
        dw PAD
        dw COUNT
        dw LIT
        dw $1f
        dw ANDD
        dw TYPE
        dw SPACE
        dw EXIT


;;;  VLIST
;;;     : VLIST LIT 128 OUT ! CONTEXT @ @ OUT @ C/L > 0BRANCH 10 CR 0 OUT ! DUP ID. SPACE SPACE PFA LFA @ DUP ?TAB 0BRANCH 30 ?TAB NOT 0BRANCH -6 KEY BL = 0BRANCH 8 -1 BRANCH 4 0 AND 0= 0BRANCH -74 DROP EXIT ;
_NF_VLIST:
        db $85,'VLIS',$d4
        dw _LF_VLIST
VLIST:  dw DOCOL
        dw LIT
        dw $80
        dw OUT
        dw STORE
        dw CONT
        dw AT
        dw AT
_VLIST_LOOP:
        dw OUT
        dw AT
        dw CSLL
        dw GREAT
        dw ZBRAN
        dw _VLIST_NO_CR - $
        dw CRR
        dw ZERO
        dw OUT
        dw STORE
_VLIST_NO_CR:
        dw DUPP
        dw IDDOT
        dw SPACE
        dw SPACE
        dw PFA
        dw LFA
        dw AT
        dw DUPP
        dw QTAB
        dw ZBRAN
        dw _VLIST_NO_TAB - $
_VLIST_TAB_WAIT:
        dw QTAB
        dw NOT
        dw ZBRAN
        dw _VLIST_TAB_WAIT - $
        dw KEY
        dw BLL
        dw EQUAL
        dw ZBRAN
        dw _VLIST_NOT_SPACE - $
        dw TRUE
        dw BRAN
        dw _VLIST_SPACE - $
_VLIST_NOT_SPACE:
        dw ZERO
_VLIST_SPACE:
        dw ANDD
_VLIST_NO_TAB:
        dw ZEQU
        dw ZBRAN
        dw _VLIST_LOOP - $
        dw DROP
        dw EXIT


;;;  VOCABULARY
;;;     : VOCABULARY CREATE $A081 , CURRENT @ CFA , HERE VOC-LINK @ , VOC-LINK ! (;CODE) ;
_NF_VOC:
        db $8a,'VOCABULAR',$d9
        dw _LF_VOC
VOC:    dw DOCOL
        dw CREA
        dw LIT
        dw $A081
        dw COMMA
        dw CURR
        dw AT
        dw CFA
        dw COMMA
        dw HERE
        dw VOCL
        dw AT
        dw COMMA
        dw VOCL
        dw STORE
        dw PSCOD
DOVOC:  call DODOE
	dw TWOP
	dw CONT
	dw STORE
	dw EXIT


;;;  DEFINITIONS
;;;     : DEFINITIONS CONTEXT @ CURRENT ! ;
_NF_DEFIN:
        db $8b,'DEFINITION',$d3
        dw _LF_DEFIN
DEFIN:  dw DOCOL
        dw CONT
        dw AT
        dw CURR
        dw STORE
        dw EXIT

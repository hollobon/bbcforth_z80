;; ;	(EXPECT)

;; On exit,
;;  C=0 if a carriage return terminated input.
;;  C=1 if an ESCAPE condition terminated input.
;;  Y contains line length, including carriage return if used

;;; (addr\count .. )

_OSWORD_PBLOCK:         ds 5

L8EC8:  db $88,'(EXPECT',$A9
        dw $0                   ; LF
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
L8EFC:
        db $86,'EXPEC',$d4
        dw $0           ; LFA
EXPECT: dw DOCOL
        dw OVER
        dw SWAP
        dw PEXPEC
        dw PLUS
        dw ZERO
        dw SWAP
        dw STORE
        dw EXIT


;;;  ENCLOSE
L83B4:
        db $87,'ENCLOS',$c5
        dw $0           ; LFA
ENCL:   dw $+2
        
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
;; L8FE5:
;;         db $86,'(WORD',$a9
;;         dw $0           ; LFA
;; PWORD:  dw DOCOL
;;         dw BLK
;;         dw AT
;;         dw QDUP
;;         dw ZBRAN
;;         dw $8
;;         dw BLOCK
;;         dw BRAN
;;         dw $6
;;         dw TIB
;;         dw AT
;;         dw INN
;;         dw AT
;;         dw PLUS
;;         dw SWAP
;;         dw ENCL
;;         dw INN
;;         dw PSTOR
;;         dw OVER
;;         dw SUBB
;;         dw ROT
;;         dw ROT
;;         dw PLUS
;;         dw SWAP
;;         dw EXIT

;; ;	1WORD
;; ;;; : 1WORD (WORD) WDSZ MIN WBFR C! WBFR COUNT 1+ CMOVE WBFR ;
;; L9036:	db	$85,'1WOR',$C4
;; 	dw	L902B
;; ONEWRD:	dw	DOCOL
;; 	dw	PWORD
;; 	dw	WDSZ
;; 	dw	MIN
;; 	dw	WBFR
;; 	dw	CSTOR
;; 	dw	WBFR
;; 	dw	COUNT
;; 	dw	ONEP
;; 	dw	CMOVE
;; 	dw	WBFR
;; 	dw	EXIT

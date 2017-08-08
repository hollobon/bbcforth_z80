;; ;; UP
;; _NF_AUP:
;; 	db $82,'U',$d0
;; 	dw _LF_AUP
;; AUP:	dw DOCON
;; 	dw UP

;; 2
_NF_TWO:
	db $81,'',$b2
	dw _LF_TWO
TWO:	dw DOCON
	dw 2

;; B/BUF
_NF_BBUF:
	db $85,'B/BU',$c6
	dw _LF_BBUF
BBUF:	dw DOCON
	dw BLKSIZ

        ;; ;; POP
;; _NF_APOP:
;; 	db $83,'PO',$d0
;; 	dw _LF_APOP
;; APOP:	dw DOCON
;; 	dw POP

;; -2
_NF_NEGTWO:
	db $82,'-',$b2
	dw _LF_NEGTWO
NEGTWO:	dw DOCON
	dw -2

;; -1
_NF_TRUE:
	db $82,'-',$b1
	dw _LF_TRUE
TRUE:	dw DOCON
	dw -1

;; WDSZ
_NF_WDSZ:
	db $84,'WDS',$da
	dw _LF_WDSZ
WDSZ:	dw DOCON
	dw WBSIZ

;; C/L
_NF_CSLL:
	db $83,'C/',$cc
	dw _LF_CSLL
CSLL:	dw DOCON
	dw 64

;; ;; CS
;; _NF_LA9FD:
;; 	db $82,'C',$d3
;; 	dw _LF_LA9FD
;; LA9FD:	dw DOCON
;; 	dw 144

;; N
_NF_ANN:
	db $81,'',$ce
	dw _LF_ANN
ANN:	dw DOCON
	dw N

;; PAD
_NF_PAD:
	db $83,'PA',$c4
	dw _LF_PAD
PAD:	dw DOCON
	dw PADD

;; S/FILE
_NF_XSFIL:
	db $86,'S/FIL',$c5
	dw _LF_XSFIL
XSFIL:	dw DOCON
	dw 9

;; NEXT
_NF_ANEXT:
	db $84,'NEX',$d4
	dw _LF_ANEXT
ANEXT:	dw DOCON
	dw NEXT

;; MAXFILES
_NF_XMAXFI:
	db $88,'MAXFILE',$d3
	dw _LF_XMAXFI
XMAXFI:	dw DOCON
	dw 20

;; MINBUF
_NF_XMINBU:
	db $86,'MINBU',$c6
	dw _LF_XMINBU
XMINBU:	dw DOCON
	dw NOBUF

;; ;; SETUP
;; _NF_ASETU:
;; 	db $85,'SETU',$d0
;; 	dw _LF_ASETU
;; ASETU:	dw DOCON
;; 	dw SETUP

;; PUSH0A
;; _NF_APUSH0:
;; 	db $86,'PUSH0',$c1
;; 	dw _LF_APUSH0
;; APUSH0:	dw DOCON
;; 	dw L842B

;; 1
_NF_ONE:
	db $81,'',$b1
	dw _LF_ONE
ONE:	dw DOCON
	dw 1

;; ;; POPTWO
;; _NF_APOPTW:
;; 	db $86,'POPTW',$cf
;; 	dw _LF_APOPTW
;; APOPTW:	dw DOCON
;; 	dw POPTWO

;; B/SCR
_NF_BSCR:
	db $85,'B/SC',$d2
	dw _LF_BSCR
BSCR:	dw DOCON
	dw 1

;; ;; IP
;; _NF_AIP:
;; 	db $82,'I',$d0
;; 	dw _LF_AIP
;; AIP:	dw DOCON
;; 	dw IP

;; ;; VS
;; _NF_LA9F4:
;; 	db $82,'V',$d3
;; 	dw _LF_LA9F4
;; LA9F4:	dw DOCON
;; 	dw 80

;; LIMIT
_NF_XLIMI:
	db $85,'LIMI',$d4
	dw _LF_XLIMI
XLIMI:	dw DOCON
	dw EM

;; ;; PUSH
;; _NF_APUSH:
;; 	db $84,'PUS',$c8
;; 	dw _LF_APUSH
;; APUSH:	dw DOCON
;; 	dw PUSH

;; ;; PUT
;; _NF_APUT:
;; 	db $83,'PU',$d4
;; 	dw _LF_APUT
;; APUT:	dw DOCON
;; 	dw PUT

;; ;; XSAVE
;; _NF_XSAV:
;; 	db $85,'XSAV',$c5
;; 	dw _LF_XSAV
;; XSAV:	dw DOCON
;; 	dw XSAVE

;; BUFSZ
_NF_XBUFS:
	db $85,'BUFS',$da
	dw _LF_XBUFS
XBUFS:	dw DOCON
	dw HDBT

;; ;; 0=
;; _NF_LAA06:
;; 	db $82,'0',$bd
;; 	dw _LF_LAA06
;; LAA06:	dw DOCON
;; 	dw 208

;; 0
_NF_ZERO:
	db $81,'',$b0
	dw _LF_ZERO
ZERO:	dw DOCON
	dw 0

;; WBFR
_NF_WBFR:
	db $84,'WBF',$d2
	dw _LF_WBFR
WBFR:	dw DOCON
	dw WORDBU

;; ;; 0<
;; _NF_LA9EB:
;; 	db $82,'0',$bc
;; 	dw _LF_LA9EB
;; LA9EB:	dw DOCON
;; 	dw 16

;; FIRST
_NF_XFIRS:
	db $85,'FIRS',$d4
	dw _LF_XFIRS
XFIRS:	dw DOCON
	dw BUF1

;; ;; W
;; _NF_AWW:
;; 	db $81,'',$d7
;; 	dw _LF_AWW
;; AWW:	dw DOCON
;; 	dw W

;; BL
_NF_BLL:
	db $82,'B',$cc
	dw _LF_BLL
BLL:	dw DOCON
	dw 32

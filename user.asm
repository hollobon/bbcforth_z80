;; HLD
_NF_HLD:
	db $83,'HL',$c4
	dw _LF_HLD
HLD:	dw DOUSE
	dw 48

;; OUT
_NF_OUT:
	db $83,'OU',$d4
	dw _LF_OUT
OUT:	dw DOUSE
	dw 26

;; SCR
_NF_SCR:
	db $83,'SC',$d2
	dw _LF_SCR
SCR:	dw DOUSE
	dw 28

;; WARNING
_NF_WARN:
	db $87,'WARNIN',$c7
	dw _LF_WARN
WARN:	dw DOUSE
	dw 14

;; CONTEXT
_NF_CONT:
	db $87,'CONTEX',$d4
	dw _LF_CONT
CONT:	dw DOUSE
	dw 32

;; DPL
_NF_DPL:
	db $83,'DP',$cc
	dw _LF_DPL
DPL:	dw DOUSE
	dw 40

;; DP
_NF_DP:
	db $82,'D',$d0
	dw _LF_DP
DP:	dw DOUSE
	dw 18

;; VOC-LINK
_NF_VOCL:
	db $88,'VOC-LIN',$cb
	dw _LF_VOCL
VOCL:	dw DOUSE
	dw 20

;; CURRENT
_NF_CURR:
	db $87,'CURREN',$d4
	dw _LF_CURR
CURR:	dw DOUSE
	dw 34

;; >IN
_NF_INN:
	db $83,'>I',$ce
	dw _LF_INN
INN:	dw DOUSE
	dw 24

;; TIB
_NF_TIB:
	db $83,'TI',$c2
	dw _LF_TIB
TIB:	dw DOUSE
	dw 10

;; OFFSET
_NF_OFFSE:
	db $86,'OFFSE',$d4
	dw _LF_OFFSE
OFFSE:	dw DOUSE
	dw 30

;; S0
_NF_SZERO:
	db $82,'S',$b0
	dw _LF_SZERO
SZERO:	dw DOUSE
	dw 6

;; R#
_NF_RNUM:
	db $82,'R',$a3
	dw _LF_RNUM
RNUM:	dw DOUSE
	dw 46

;; CSP
_NF_CSP:
	db $83,'CS',$d0
	dw _LF_CSP
CSP:	dw DOUSE
	dw 44

;; STATE
_NF_STATE:
	db $85,'STAT',$c5
	dw _LF_STATE
STATE:	dw DOUSE
	dw 36

;; BASE
_NF_BASE:
	db $84,'BAS',$c5
	dw _LF_BASE
BASE:	dw DOUSE
	dw 38

;; R0
_NF_RZERO:
	db $82,'R',$b0
	dw _LF_RZERO
RZERO:	dw DOUSE
	dw 8

;; FENCE
_NF_FENCE:
	db $85,'FENC',$c5
	dw _LF_FENCE
FENCE:	dw DOUSE
	dw 16

;; WIDTH
_NF_WIDTH:
	db $85,'WIDT',$c8
	dw _LF_WIDTH
WIDTH:	dw DOUSE
	dw 12

;; BLK
_NF_BLK:
	db $83,'BL',$cb
	dw _LF_BLK
BLK:	dw DOUSE
	dw 22


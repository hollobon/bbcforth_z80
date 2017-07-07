;	S0

L8A0C:	db	$82,'S',$B0
	dw	$0 ;L89F8
SZERO:	dw	DOUSE
	db	6

;	R0

L8A14:	db	$82,'R',$B0
	dw	L8A0C
RZERO:	dw	DOUSE
	db	8

;	TIB

L8A1C:	db	$83,'TI',$C2
	dw	L8A14
TIB:	dw	DOUSE
	db	$A

;	WIDTH

L8A25:	db	$85,'WIDT',$C8
	dw	L8A1C
WIDTH:	dw	DOUSE
	db	$C

;	WARNING

L8A30:	db	$87,'WARNIN',$C7
	dw	L8A25
WARN:	dw	DOUSE
	db	$E

;	FENCE

L8A3D:	db	$85,'FENC',$C5
	dw	L8A30
FENCE:	dw	DOUSE
	db	$10

;	DP

L8A48:	db	$82,'D',$D0
	dw	L8A3D
DP:	dw	DOUSE
	db	$12

;	VOC-LINK

L8A50:	db	$88,'VOC-LIN',$CB
	dw	L8A48
VOCL:	dw	DOUSE
	db	$14

;	BLK

L8A5E:	db	$83,'BL',$CB
	dw	L8A50
BLK:	dw	DOUSE
	db	$16

;	>IN

L8A67:	db	$83,'>I',$CE
	dw	L8A5E
INN:	dw	DOUSE
	db	$18

;	QOUT

L8A70:	db	$83,'OU',$D4
	dw	L8A67
OUT:	dw	DOUSE
	db	$1A

;	SCR

L8A79:	db	$83,'SC',$D2
	dw	L8A70
SCR:	dw	DOUSE
	db	$1C

;	OFFSET

L8A82:	db	$86,'OFFSE',$D4
	dw	L8A79
OFFSE:	dw	DOUSE
	db	$1E

;	CONTEXT

L8A8E:	db	$87,'CONTEX',$D4
	dw	L8A82
CONT:	dw	DOUSE
	db	$20

;	CURRENT

L8A9B:	db	$87,'CURREN',$D4
	dw	L8A8E
CURR:	dw	DOUSE
	db	$22

;	STATE

L8AA8:	db	$85,'STAT',$C5
	dw	L8A9B
STATE:	dw	DOUSE
	db	$24

;	BASE

L8AB3:	db	$84,'BAS',$C5
	dw	L8AA8
BASE:	dw	DOUSE
	db	$26

;	DPL

L8ABD:	db	$83,'DP',$CC
	dw	L8AB3
DPL:	dw	DOUSE
	db	$28

;	CSP

L8AC6:	db	$83,'CS',$D0
	dw	L8ABD
CSP:	dw	DOUSE
	db	$2C

;	R#

L8ACF:	db	$82,'R',$A3
	dw	L8AC6
RNUM:	dw	DOUSE
	db	$2E

;	HLD

L8AD7:	db	$83,'HL',$C4
	dw	L8ACF
HLD:	dw	DOUSE
	db	$30

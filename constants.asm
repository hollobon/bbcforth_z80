;	-2

L8999:	db	$82,'-',$B2
	dw	$0 ;L897D
NEGTWO:	dw	DOCON
	dw	-2

;	-1

L89A2:	db	$82,'-',$B1
	dw	L8999
TRUE:	dw	DOCON
	dw	-1

;	0

L89AB:	db	$81,$B0
	dw	L89A2
ZERO:	dw	DOCON
	dw	0

;	1

L89B3:	db	$81,$B1
	dw	L89AB
ONE:	dw	DOCON
	dw	1

;	2

L89BB:	db	$81,$B2
	dw	L89B3
TWO:	dw	DOCON
	dw	2

;	BL

L89C3:	db	$82,'B',$CC
	dw	L89BB
BLL:	dw	DOCON
	dw	$20

;	C/L

L89CC:	db	$83,'C/',$CC
	dw	L89C3
CSLL:	dw	DOCON
	dw	64

;	PAD

L89D6:	db	$83,'PA',$C4
	dw	L89CC
PAD:	dw	DOCON
	dw	PADD

;	B/BUFp

L89E0:	db	$85,'B/BU',$C6
	dw	$0 ;LA01C-REL
BBUF:	dw	DOCON
	dw	BLKSIZ

;	B/SCR

L89EC:	db	$85,'B/SC',$D2
	dw	L89E0
BSCR:	dw	DOCON
	dw	1

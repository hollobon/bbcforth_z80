;	MM

;; LB146:	db	$82,'M',$CD
;; 	dw	LB107
;; MM:	dw	DOCOL
;; 	dw	TWOP
;; 	dw	SWAP
;; 	dw	DUPP
;; 	dw	ROT
;; 	dw	DUPP
;; 	dw	ROT
;; 	dw	OVER
;; 	dw	CAT
;; 	dw	ONEP
;; 	dw	CMOVE
;; 	dw	CAT
;; 	dw	ONEP
;; 	dw	PLUS
;; 	dw	EXIT

;; ;	M1

;; LB169:	db	$82,'M',$B1
;; 	dw	LB146
;; M1:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	11,'Stack empty'
;; 	dw	EXIT

;; ;	M2

;; LB180:	db	$82,'M',$B2
;; 	dw	LB169
;; M2:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	15,'Dictionary full'
;; 	dw	EXIT

;; ;	M3

;; LB19B:	db	$82,'M',$B3
;; 	dw	LB180
;; M3:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	26,'Has incorrect address mode'
;; 	dw	EXIT

;; ;	M4

;; LB1C1:	db	$82,'M',$B4
;; 	dw	LB19B
;; M4:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	12,'Isn',$27,'t unique'
;; 	dw	EXIT

;; ;	M5

;; LB1D9:	db	$82,'M',$B5
;; 	dw	LB1C1
;; M5:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	29,'Parameter outside valid range'
;; 	dw	EXIT

;; ;	M6

;; LB202:	db	$82,'M',$B6
;; 	dw	LB1D9
;; M6:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	26,'Screen number out of range'
;; 	dw	EXIT

;; ;	M7

;; LB228:	db	$82,'M',$B7
;; 	dw	LB202
;; M7:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	10,'Stack full'
;; 	dw	EXIT

;; ;	M8

;; LB23E:	db	$82,'M',$B8
;; 	dw	LB228
;; M8:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	25,'Can',$27,'t open or extend file'
;; 	dw	EXIT

;; ;	M9

;; LB263:	db	$82,'M',$B9
;; 	dw	LB23E
;; M9:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	24,'Read/Write not completed'
;; 	dw	EXIT

;; ;	M10

;; LB287:	db	$83,'M1',$B0
;; 	dw	LB263
;; M10:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	26,'Can',$27,'t redefine end-of-line'
;; 	dw	EXIT

;; ;	M11

;; LB2AE:	db	$83,'M1',$B1
;; 	dw	LB287
;; M11:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	20,'Can',$27,'t divide by zero'
;; 	dw	EXIT

;; ;	M12

;; LB2CF:	db	$83,'M1',$B2
;; 	dw	LB2AE
;; M12:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	26,'Undefined execution vector'
;; 	dw	EXIT

;; ;	M13

;; LB2F6:	db	$83,'M1',$B3
;; 	dw	LB2CF
;; M13:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	15,'Branch too long'
;; 	dw	EXIT

;; ;	M14

;; LB312:	db	$83,'M1',$B4
;; 	dw	LB2F6
;; M14:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	28,'Incorrect CURRENT vocabulary'
;; 	dw	EXIT

;; ;	M15

;; LB33B:	db	$83,'M1',$B5
;; 	dw	LB312
;; M15:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	1,' '
;; 	dw	EXIT

;; ;	M16

;; LB349:	db	$83,'M1',$B6
;; 	dw	LB33B
;; M16:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	1,' '
;; 	dw	EXIT

;; ;	M17

;; LB357:	db	$83,'M1',$B7
;; 	dw	LB349
;; M17:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	16,'Compilation only'
;; 	dw	EXIT

;; ;	M18

;; LB374:	db	$83,'M1',$B8
;; 	dw	LB357
;; M18:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	14,'Execution only'
;; 	dw	EXIT

;; ;	M19

;; LB38F:	db	$83,'M1',$B9
;; 	dw	LB374
;; M19:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	23,'Conditionals not paired'
;; 	dw	EXIT

;; ;	M20

;; LB3B3:	db	$83,'M2',$B0
;; 	dw	LB38F
;; M20:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	23,'Definition not finished'
;; 	dw	EXIT

;; ;	M21

;; LB3D7:	db	$83,'M2',$B1
;; 	dw	LB3B3
;; M21:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	23,'In protected dictionary'
;; 	dw	EXIT

;; ;	M22

;; LB3FB:	db	$83,'M2',$B2
;; 	dw	LB3D7
;; M22:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	21,'Use only when LOADing'
;; 	dw	EXIT

;; ;	M23

;; LB41D:	db	$83,'M2',$B3
;; 	dw	LB3FB
;; M23:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	26,'Off current editing screen'
;; 	dw	EXIT

;; ;	M24

;; LB444:	db	$83,'M2',$B4
;; 	dw	LB41D
;; M24:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	25,'NOT in CURRENT vocabulary'
;; 	dw	EXIT

;; ;	M25

;; LB46A:	db	$83,'M2',$B5
;; 	dw	LB444
;; M25:	dw	DOCOL
;; 	dw	PDOTQ
;; 	db	7,'No room'
;; 	dw	EXIT


MSG_TABLE:
        dw	1
	db	11,'Stack empty'
	db	15,'Dictionary full'
	db	26,'Has incorrect address mode'
	db	12,'Isn',$27,'t unique'
	db	29,'Parameter outside valid range'
	db	26,'Screen number out of range'
	db	10,'Stack full'
	db	25,'Can',$27,'t open or extend file'
	db	24,'Read/Write not completed'
	db	26,'Can',$27,'t redefine end-of-line'
	db	20,'Can',$27,'t divide by zero'
	db	26,'Undefined execution vector'
	db	15,'Branch too long'
	db	28,'Incorrect CURRENT vocabulary'
	db	1,' '
	db	1,' '
	db	16,'Compilation only'
	db	14,'Execution only'
	db	23,'Conditionals not paired'
	db	23,'Definition not finished'
	db	23,'In protected dictionary'
	db	21,'Use only when LOADing'
	db	26,'Off current editing screen'
	db	25,'NOT in CURRENT vocabulary'
	db	7,'No room'

#=================================================================================================================#
#			    			POSTSCRIPT CNC MARSBOT			    	  		  #		    			             		          
#                                                     @Copyright						  #
#=================================================================================================================#


# Mars bot
.eqv HEADING 0xffff8010 
.eqv MOVING 0xffff8050
.eqv LEAVETRACK 0xffff8020
.eqv IN_KEYBOARD 0xFFFF0012
.eqv OUT_KEYBOARD 0xFFFF0014

.data
start_again_msg:	.asciiz "Do you want to start again"
# postscript-DCE => numpad 0
script1:  .asciiz  "90,2000,0;180,3000,0;180,5790,1;80,500,1;70,500,1;60,500,1;50,500,1;40,500,1;30,500,1;20,500,1;10,500,1;0,500,1;350,500,1;340,500,1;330,500,1;320,500,1;310,500,1;300,500,1;290,500,1;280,490,1;90,2000,0;90,4500,0;270,500,1;260,500,1;250,500,1;240,500,1;230,500,1;220,500,1;210,500,1;200,500,1;190,500,1;180,500,1;170,500,1;160,500,1;150,500,1;140,500,1;130,500,1;120,500,1;110,500,1;100,500,1;90,900,1;90,4500,0;270,2000,1;0,5800,1;90,2000,1;180,2900,0;270,2000,1;90,3000,0;"

# postscript-BKHN => numpad 4
script2:  .asciiz  "90,2000,0;180,3000,0;180,2800,1;90,1000,1;40,600,1;0,500,1;320,600,1;270,1000,1;0,1400,0;90,1000,1;140,600,1;180,500,1;220,550,1;90,1000,0;0,1400,1;180,1400,0;180,1400,1;0,1400,0;45,1900,1;225,1850,0;135,1900,1;90,1000,0;0,2800,1;180,1400,0;90,1400,1;0,1400,1;180,1400,0;180,1400,1;90,1000,0;0,2800,1;150,3200,1;0,2800,1;270,8500,0;180,2800,0;"

# postscript-NDTANH => numpad 8
script3:  .asciiz  "90,2000,0;180,3000,0;90,1500,0;180,2800,1;0,2800,0;150,3200,1;0,2800,1;90,1000,0;180,2900,1;80,250,1;70,250,1;60,250,1;50,250,1;40,250,1;30,250,1;20,250,1;10,250,1;0,250,1;350,250,1;340,250,1;330,250,1;320,250,1;310,250,1;300,250,1;290,250,1;280,245,1;90,2000,0;90,1500,1;270,750,0;180,2800,1;0,2900,0;90,2000,0;200,3000,1;20,3000,0;160,3000,1;340,1500,0;270,1000,1;20,1500,0;90,1500,0;180,2800,1;0,2800,0;150,3200,1;0,2800,1;90,1000,0;180,2800,1;0,1400,0;90,1000,1;180,1400,1;0,1400,0;0,1400,1;90,1000,0;"

.text
.globl MAIN
MAIN:
	jal	START
	nop
# <--xu ly tren keymatrix-->
START:
	jal	INIT
	nop
	jal	GLOBAL
	nop
	jal	PROCESS
	nop
	jal	TERMINATE
	nop
GLOBAL:
	addi	$s3, $ra, 8
	jr	$ra	
INIT: 
	li 	$t3, IN_KEYBOARD
	li 	$t4, OUT_KEYBOARD
	addi 	$t6, $zero, 0
	addi 	$t7, $zero, 0
	NUM_0:
		li 	$t5, 0x01 
		sb 	$t5, 0($t3) 
		lb 	$a0, 0($t4) 
		bne 	$a0, 0x11, NUM_4
		nop
		la	$a1, script1
		jr	$ra
	NUM_4:
		li 	$t5, 0x02
		sb 	$t5, 0($t3)
		lb 	$a0, 0($t4)
		bne	$a0, 0x12, NUM_8
		nop
		la 	$a1, script2
		jr	$ra
	NUM_8:
		li 	$t5, 0X04
		sb 	$t5, 0($t3)
		lb 	$a0, 0($t4)
		bne 	$a0, 0x14, INIT
		nop
		la	$a1, script3
		jr	$ra

PROCESS:
	li 	$at, MOVING 
 	addi 	$k0, $zero,1 
 	sb 	$k0, 0($at) 
	GET_DATA: 
		addi	$t0, $zero, 0 
		addi	$t1, $zero, 0
 		GET_ROTATE:				# ?????c g??c d???ch chuy???n 
 			add 	$t7, $a1, $t6 
			lb 	$t5, 0($t7)  
			beq 	$t5, 0, END 		# ???? ?????c h???t pscript[i]
			nop	
 			beq	$t5, 44, GET_TIME 	# Xu???t hi???n d???u ph???y => Chuy???n ?????n th???i gian 
 			nop
 			mul 	$t0, $t0, 10 
 			addi	$t5, $t5, -48 		
 			add 	$t0, $t0, $t5  		
 			addi 	$t6, $t6, 1 
 			j 	GET_ROTATE 		# Ti???n h??nh l???p ????? t??nh to??n gi?? tr??? g??c di chuy???n 
 			nop
 		GET_TIME: 				# ?????c th???i gian d???ch chuy???n 
 			add 	$a0, $t0, $zero
			jal 	ROTATE			# Load g??c d???ch chuy???n 
			nop
 			addi	$t6, $t6, 1
 			add 	$t7, $a1, $t6 		
			lb 	$t5, 0($t7) 
			beq 	$t5, 44, GET_TRACK	# Xu???t hi???n d???u ph???y => Chuy???n ?????n gi?? tr??? tracking 
			nop
			mul 	$t1, $t1, 10
 			addi 	$t5, $t5, -48
 			add 	$t1, $t1, $t5
 			j 	GET_TIME 		# Ti???n h??nh l???p ????? t??nh to??n gi?? tr??? g??c di chuy???n
 			nop
 		GET_TRACK:
 			jal 	UNTRACK			# C??? ?????nh ??i???m ???????c v??? tr?????c ???? 
 			nop
 			addi 	$t6, $t6, 1 
 			add 	$t7, $a1, $t6
			lb 	$t5, 0($t7) 
 			addi	$t5, $t5, -48
 			beq 	$t5, 1, CUT		# N???u c?? tracking ~ Marsbot c???t
 			nop
 			j   	NOT_CUT 			# N???u kh??ng th?? kh??ng c???t 
 			nop
 	CUT:
		jal	TRACK		# C???t 
		nop
		j	SLEEP		# Ngh??? 
		nop
	NOT_CUT:
		jal UNTRACK		# Kh??ng c???t 
		nop
		j	SLEEP		# Ngh??? 
		nop
	SLEEP:
		li	$v0, 32 	
 		move 	$a0, $t1	# Th???i gian v??? ???????ng ($t1)
		syscall
 		addi 	$t6, $t6, 2 	
 		j 	PROCESS		# Ti???p t???c v??? 
 		nop
	TRACK: 
		li 	$at, LEAVETRACK #  L??u v??o LEAVETRACK = 1
		li 	$k0, 1
		sb 	$k0, 0($at) 
 		jr 	$ra

	UNTRACK:
		li 	$at, LEAVETRACK #  L??u v??o LEAVETRACK = 0
 		sb 	$0, 0($at) 
 		jr 	$ra

	ROTATE: 
		li 	$at, HEADING 	# 
 		sw 	$a0, 0($at) 
 		jr 	$ra
	END: 
		li 	$at, MOVING	# D???ng v?? k???t th???c ch????ng tr??nh
 		sb 	$0, 0($at)
 		add	$at, $zero, 0
 		jr	$s3
TERMINATE:
	li	$v0, 50		# Ki???m tra xem c?? c???n ch???y l???i kh??ng 
	la	$a0, start_again_msg
	syscall
	beq	$a0, 0, START
	nop
	li 	$v0, 10
	syscall

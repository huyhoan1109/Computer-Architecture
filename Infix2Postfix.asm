#=================================================================================================================#
#			    	Tranforming infix expression to postfix expression  			    	  #		    			             
#       				  Author: Nguyen Huy Hoan (25-6-2022)       				  #			          
#                                                     @Copyright						  #
# Function:													  #
# - Prompting infix expression											  #
# - Print out postix expression											  #
# - Print the result of expression										  #
# - Supported arithmetic operators: Addition , Subtraction, Multiplication , Division, Modulus, Exponentiation	  #
# - Special checking:												  #
#	+ Interval of [0, 99]											  #
#	+ Dividing for 0											  #
# 	+ Exponentiation of 0											  #
#	+ Allow to input is variable										  #
# 	+ Parentheses checking											  #
#=================================================================================================================#

# Idea (By using stack)
# 	I:	Scan input from left to right
#	II:	If scanned char is an operator then output it
# 	III:	Else:
#		1. If the precedence of the scanned operator is greater than 
#                  the precedence of the operator in the stack
#                  (or the stack is empty or the stack contains a ‘(‘ ) then push it.
# 		2. If meet '^' then it will be pushed immediately since it has highest precedence
#		3. Else pop all operators from stack has higher or equal in precedence
#		   with the scanned operators, after that push the scanned operators
#		4. If scanned char is '(' => Push
#		5. If scanned char is ')' => Pop and output until meet ')' then discard both parenthesis
#		6. Repeat until all end

# Data
.data
# Variable
input:		.space 1000	# Input raw infix
infix:		.space 1000	# Infix without space 
postfix_:	.space 1000	# Postfix 
postfix:	.space 1000	# Postfix without space 
stack:		.space 1000	# Stack save values
# Message
msg_read_infix:		.asciiz "Input expression: "
msg_print_infix:	.asciiz "Infix expression: "
msg_print_postfix:	.asciiz "Postfix expression: "
msg_print_result:	.asciiz "Expression's result: "
msg_enter:		.asciiz "\n"
start_again_msg:	.asciiz "Do you want to start again?"
close_msg:		.asciiz "Thank you for using our service (^v^)!"
no_in_msg:		.asciiz	"No input available! Do you want to retry?"
msg_error1:		.asciiz "Input number isn't in the interval of [0, 99]!"
msg_error2:		.asciiz "Division can't have 0 as a divisor!"
msg_error3:		.asciiz "Invalid expression! Check it again!"
msg_error4:		.asciiz "Input now must be a number!"
msg_error5:		.asciiz "Too much charaters -> Can't process!"
msg_error6:		.asciiz "Unable to calculate!"
msg_enter_value:	.asciiz "Value of input variable [0, 99] (0 is default): "

# Code
.text
.globl main
main:
	jal	start
	nop	
	
start:
	jal	global_j
	nop
	jal 	input_infix
	nop
	jal	global_j
	nop
	jal     process_infix
	nop
	jal	global_j
	nop
	jal     process_postfix
	nop
	jal	printf
	nop	
	
# function available  
    
global_j:
	addi	$t9, $ra, 8
	jr	$ra
	
error_internal:
        li	$v0, 55
	la	$a0, msg_error1
	la	$a1, 0
	syscall
	j 	start			# If error than request user to input again
	nop

invalid_divisor:	
	li	$v0, 55
	la	$a0, msg_error2
	syscall
	j	start
	nop	
		
error_exp:
	li	$v0, 55
	la	$a0, msg_error3
	la	$a1, 0
	syscall
	j	start			# If error than request user to input again
	nop
		
error_mxstr:
	li	$v0, 55
	la	$a0, msg_error5
	la	$a1, 0
	syscall
	j	start			# If error than request user to input again
	nop
		
error_na:
	li	$v0, 55
	la	$a0, msg_error6
	la	$a1, 0
	syscall
	j	start				# If error than request user to input again
	nop
		
terminate:
	li	$v0, 4
	la	$a0, close_msg
	syscall
	li	$v0, 10
	syscall	
	
no_input_val:
	li	$v0, 50
	la	$a0, no_in_msg
	syscall
	beqz	$a0, start
	nop
	j	terminate
	nop

init_array:
	sb	$0,  input($t0)
	sb	$0,  infix($t0)
	sb	$0,  postfix_($t0)
	sb	$0,  postfix($t0)
	sb	$0,  stack($t0)
	addi	$t0, $t0, 1
	blt	$t0, 1000, init_array
	nop
	jr	$ra	
			
input_infix:
	jal	init_array
	nop
        # Input data from keyboard		
	li	$v0, 54
	la	$a0, msg_read_infix
	la	$a1, input
	la 	$a2, 100
	syscall
	# print input
	beq	$a1, -4, error_mxstr
	nop
	beq	$a1, -3, no_input_val
	nop
	beq	$a1, -2, terminate
	nop
	li	$v0, 4
	la	$a0, msg_print_infix
	syscall
	li	$v0, 4
	la	$a0, input
	syscall	
	j	end_input
	nop
	
	end_input:
		# Infix, Postfix, and Stack Params init
		li	$s0, 0		# Counter for infix
		li	$s1, 0		# Counter for postfix
		li	$s2, -1		# Count for Stack
	
		# Infix counter	
		li	$s4, 0		
		li	$s5, 0		

		# Postfix counter
		li	$s6, 0		
		li	$s7, 0		

		# Parenthesis counter
		li	$a3, 0
		
		# Init temp register
		li	$t0, 0
		li	$t1, 0
		li	$t2, 0
		li	$t3, 0
		li	$t4, 0
		li 	$t5, 0
		li 	$t6, 0
		li	$t7, 0
		li	$t8, 0
		
	exit:
		# Return to the base program
		jr	$t9 
	
process_infix:

	remove_space:		
        	lb	$t5, input($s4)				# Scanning the input input
		addi	$s4, $s4, 1				# i += 1
		beq	$t5, ' ', remove_space			# Check whether input[i] = ' ' or not
		nop
		beq	$t5, 0, iterate_infix			# If EOF then begin to iterate 
		nop
		sb	$t5, infix($s5)				# Store infix value 
		addi	$s5, $s5, 1				
		j	remove_space
		nop
		
	iterate_infix:		
        	lb	$t0, infix($s0)				# Iterating values in modified infix
		beq	$t0, 0, end_iterate_infix		# If done reading then stop iterating
		nop						
		beq	$t0, '\n', end_iterate_infix		# If done reading then stop iterating
		nop	
		# If $t0 is an operand then take it into account to push					
		beq	$t0, '+', consider_plus		
		nop
		beq	$t0, '-', consider_minus
		nop
		beq	$t0, '*', consider_mul_div
		nop
		beq	$t0, '/', consider_mul_div
		nop
		beq	$t0, ':', consider_mul_div
		nop
		beq	$t0, '%', consider_mod
		nop
		beq	$t0, '^', consider_exp		
		nop
		beq	$t0, '(', consider_lpar			
		nop
		beq	$t0, ')', consider_rpar
		nop		
		
		# If $t0 is operators then put into postfix
		addi 	$t8, $t8, 1
		sb	$t0, postfix_($s1) # save byte into postfix		
		addi	$s1, $s1, 1
		# Process whether the number is in [10, 99]
		addi	$s0, $s0, 1
		lb	$t2, infix($s0)
		
		sge	$k0, $t2, 48
		sle	$k1, $t2, 57
		and	$k0, $k0, $k1
		beq	$k0, 1, continue	
		nop
		
		# Add space to show that a number has been added
		li	$s3, ' '		
		sb	$s3, postfix_($s1)
		addi	$s1, $s1, 1
		j	iterate_infix
		nop
							
	continue: 		
        	addi	$t3, $s0, 1			# Continue to read following values 
		lb	$t4, infix($t3)			
		
		sge	$k0, $t4, 48
		sle	$k1, $t4, 57
		and	$k0, $k0, $k1
		beq	$k0, 1, error_internal		# If there're a number then the number must has more than 3 digits => Overflow
		nop
		
		sb	$t2, postfix_($s1)  		# Else load value into the postfix
		addi	$s1, $s1, 1
		addi	$s0, $s0, 1
		li	$s3, ' '		
		sb	$s3, postfix_($s1)
		addi	$s1, $s1, 1
		j 	iterate_infix			# Continue to read the input
		nop
	
	# Check the component after the operators (must not null) 
	check_before:
		addi 	$v0, $s0, -1
		lb	$v1, infix($v0)
		beq	$v1, '(', error_exp
		jr	$ra
	check_after:
		addi 	$v0, $s0, 1
		lb	$v1, infix($v0)
		beq	$v1, '\n', error_exp     	# End of line ~ null
		nop
		beq	$v1, '*', error_exp		# If there is an operator after operator (Except '+')=> Wrong format
		nop
		beq	$v1, '/', error_exp
		nop
		beq	$v1, ':', error_exp		
		nop
		beq	$v1, '-', error_exp
		nop
		beq	$v1, '%', error_exp
		nop
		beq	$v1, '^', error_exp
		nop
		sge	$k0, $v1, '0'
		sle	$k1, $v1, '9'
		and	$k0, $k0, $k1
		beqz	$k0, con_1
		nop
		return_after:
			beq	$s2, -1, push_op_to_stack	# If stack is empty 
			nop					# or ( in stack then push operand to stack
			lb	$t1, stack($s2)
			beq	$t1, '(', push_op_to_stack
			nop
			jr	$ra	
		con_1:	#Variable A -> Z
			sge	$k0, $v1, 65			
			sle	$k1, $v1, 90
			and	$k0, $k0, $k1
			beqz	$k0, con_2
			nop
			j	return_after
			nop
		con_2:	#Variable a -> z
			sge	$k0, $v1, 97			
			sle	$k1, $v1, 122
			and	$k0, $k0, $k1
			beqz	$k0, con_3
			nop
			j	return_after
			nop
		con_3:	
			seq	$k0, $v1, '('		
			seq	$k1, $v1, ')'
			or	$k0, $k0, $k1
			beqz	$k0 error_exp
			nop
			j	return_after
			nop	
	consider_plus:
		jal	check_before
		nop	
		jal	check_after
		nop
		sb	$t1, postfix_($s1)		
		addi	$s1, $s1, 1
		addi	$s2, $s2, -1
		li	$s3, ' '		
		sb	$s3, postfix_($s1)
		addi	$s1, $s1, 1
	        j	consider_plus	
	        nop
	
	consider_minus:
		beq	$s0, 0, error_exp	     	# - must not stand first in expression, neither after other operators
		nop
		jal	check_before
		nop		
		jal	check_after
		nop
		sb	$t1, postfix_($s1)		
		addi	$s1, $s1, 1
		addi	$s2, $s2, -1
		li	$s3, ' '		
		sb	$s3, postfix_($s1)
		addi	$s1, $s1, 1
	        j	consider_minus	
	        nop
	        
	# Operator '*' va '/' have same precedence
	consider_mul_div:
		beq	$s0, 0, error_exp	     	# * and / can't stand first in expression
		nop
		jal	check_before
		nop			
		jal	check_after
		nop			
		beq	$t1, '+', push_op_to_stack
		nop
		beq	$t1, '-', push_op_to_stack
		nop	
		sb	$t1, postfix_($s1)
		addi	$s2, $s2, -1
		addi	$s1, $s1, 1
		li	$s3, ' '		
		sb	$s3, postfix_($s1)
		addi	$s1, $s1, 1
		j	consider_mul_div
		nop
		
	consider_mod:
		beq	$s0, 0, error_exp	     	# '%' can't stand first in expression
		nop
		jal	check_before
		nop	
		jal	check_after
		nop				
		beq	$t1, '+', push_op_to_stack
		nop
		beq	$t1, '-', push_op_to_stack
		nop
		beq	$t1, '*', push_op_to_stack
		nop
		beq	$t1, '/', push_op_to_stack
		nop
		beq	$t1, ':', push_op_to_stack
		nop
		sb	$t1, postfix_($s1)
		addi	$s2, $s2, -1
		addi	$s1, $s1, 1
		li	$s3, ' '		
		sb	$s3, postfix_($s1)
		addi	$s1, $s1, 1
		j	consider_mod
		nop
	consider_exp:
		beq	$s0, 0, error_exp		# '^' can't stand first in expression	     	
		nop
		jal	check_before
		nop	
		jal	check_after
		nop	
		li	$s3, ' '		
		sb	$s3, postfix_($s1)
		addi	$s1, $s1, 1
		j	push_op_to_stack
		nop
			
	consider_rpar:		
        	addi	$a3, $a3, -1
        	blt	$a3, 0, error_exp			# If $a3 < 0 (May be ')' appeared before '(' ) => Wrong format 
        	nop	
		loop_rpar:		
        		beq	$s2, -1, push_op_to_stack	# If stack is empty, push opertors to stack
			nop
			lb	$t1, stack($s2)			# Else store values into postfix
			sb	$t1, postfix_($s1)		
			addi	$s2, $s2, -1
			addi	$s1, $s1, 1
			beq	$t1, '(', push_op_to_stack	# If meet '(' then push operand to stack
			li	$s3, ' '		
			sb	$s3, postfix_($s1)
			addi	$s1, $s1, 1
			j	loop_rpar			# Or continue to count store values
			nop	

	consider_lpar:		
        	addi	$a3, $a3, 1			 
		addi	$t3, $s0, 1			
		lb	$t4, infix($t3)			# If number is less than 0 => error
		beq	$t4, '-', error_internal
		nop
		j	push_op_to_stack		# Else continue to push
		nop				
			
	push_op_to_stack:	
		addi	$s2, $s2, 1			# Store into stack and countinue to iterating
		sb	$t0, stack($s2)			
		addi	$s0, $s0, 1
		j 	iterate_infix
		nop

	end_iterate_infix:	
		beq	$s2, -1, remove_parentheses	# Remove paranthesis from the stack to store in postfix
		nop
		lb	$t0, stack($s2)
		sb	$t0, postfix_($s1)
		addi	$s2, $s2, -1
		addi	$s1, $s1, 1
		j	end_iterate_infix
		nop

	remove_parentheses:	
		lb	$t5, postfix_($s6)
		addi	$s6, $s6, 1
		beq	$t5, '(', remove_parentheses
		nop
		beq	$t5, ')', remove_parentheses
		nop
		beq	$t5, 0, end_process_infix	
		nop
		sb	$t5, postfix($s7)
		addi	$s7, $s7, 1
		j	remove_parentheses
		nop
	end_process_infix:
		bne	$a3, 0, error_exp		# Error since parenthesis must be in same number of close and open bracket
		nop
		jr 	$t9
		
process_postfix:
	# Print out postfix
	print_postfix:
		li	$v0, 4
		la	$a0, msg_print_postfix			 
		syscall
		li 	$v0, 4
		la 	$a0, postfix
		syscall
		li	$v0, 4
		la	$a0, msg_enter
		syscall
		j	calculate_postfix
		nop

	calculate_postfix:	
        	li	$s1, 0		# postfix counter set
		li	$s2, 1		# Exponential counter
		li	$t5, 1		# Exponential helpering variable

		iterate_postfix: 	
        		lb	$t0, postfix($s1)
			beq	$t0, 0, end_process_postfix
			nop
			beq	$t0, ' ', eliminate_space
			nop		
			
			sge	$k0, $t0, 48			# Check whether it a number in [0, 99]
			sle	$k1, $t0, 57
			and	$k0, $k0, $k1
			beq	$k0, 1, continue_
			nop
			
			sge	$k0, $t0, 65			#If meet a variable then input it's value
			beq	$k0, 1, var_con1
			nop
			
			operand:	
				lw	$t6, -8($sp)		# Load from the stack
				lw	$t7, -4($sp)
				addi	$sp, $sp, -8	
				beq	$t0, '+', add_		
				nop
				beq	$t0, '-', sub_
				nop
				beq	$t0, '/', div_
				nop
				beq	$t0, ':', div_
				nop
				beq	$t0, '*', mul_
				nop
				beq	$t0, '%', mod_
				nop
				beq	$t0, '^', exp_
				nop 
				addi 	$s1, $s1, 1
				j	iterate_postfix
				nop	
	
			var_con1: # Variable stand for 'A' -> 'Z' 
	        		addi	$v1, $0, 1
				sle	$k0, $t0, 90 
				beq	$k0, 0, var_con2
				nop
				li	$v0, 51
				la	$a0, msg_enter_value
				syscall
				beq	$a1, -1, error_char
				nop
				blt 	$a0, 0, not_in_interval
				nop
				bgt 	$a0, 99, not_in_interval
				nop		   
				sw	$a0, 0($sp)	# => Push the number in the stack
				addi	$sp, $sp, 4
				addi	$s1, $s1, 1
				j	iterate_postfix
				nop
			
			var_con2:	
				sge	$k0, $t0, 97
				beq	$k0, 1, var_con3
				nop
				j	operand
				nop
		
			var_con3: # Variable stand for 'a' -> 'z'
				addi 	$v1, $0, 3
				sle	$k0, $t0, 122
				beq	$k0, 0, operand
				nop
				li	$v0, 51
				la	$a0, msg_enter_value
				syscall	 
				beq	$a1, -1, error_char
				nop
				blt 	$a0, 0, not_in_interval
				nop
				bgt 	$a0, 99, not_in_interval
				nop
				sw	$a0, 0($sp)	# => Push the number in the stack
				addi	$sp, $sp, 4
				addi	$s1, $s1, 1
				j	iterate_postfix
				nop
				
			error_char: 
				li	$v0, 55
				la	$a0, msg_error4
				la 	$a1, 0
				syscall
				beq	$v1, 1, var_con1
				nop
				beq	$v1, 3, var_con3
				nop
				
			not_in_interval:
				li	$v0, 55
				la	$a0, msg_error1
				la 	$a1, 0
				syscall
				beq	$v1, 1, var_con1
				nop
				beq	$v1, 3, var_con3
				nop
				
		eliminate_space:		
			addi	$s1, $s1, 1
			j	iterate_postfix
			nop

		continue_:		
			addi	$s1, $s1, 1
			lb	$t2, postfix($s1)
		
			sge	$k0, $t2, 48
			sle	$k1, $t2, 57
			and	$k0, $k0, $k1
			beq	$k0, 1, push_number_to_stack
			nop	
		
			addi	$t0, $t0, -48			
			sw	$t0, 0($sp)
			addi	$sp, $sp, 4
			j	iterate_postfix
			nop	
			
		push_number_to_stack:		
			addi	$t0, $t0, -48
			addi	$t2, $t2, -48
			mul	$t3, $t0, 10
			add	$t3, $t3, $t2			
			sw	$t3, 0($sp)
			addi 	$sp, $sp, 4
			addi	$s1, $s1, 1
			j	iterate_postfix
			nop	
			
		add_:			
			add	$t6, $t6, $t7
			sw	$t6, 0($sp)
			addi	$sp, $sp, 4
			addi	$s1, $s1, 1
			addi	$t8, $t8, -1
			j	iterate_postfix
			nop
	
		sub_:			
			sub	$t6, $t6, $t7
			sw	$t6, 0($sp)
			addi	$sp, $sp, 4
			addi	$s1, $s1, 1
			addi	$t8, $t8, -1
			j	iterate_postfix
			nop
			
		div_:			
			beq	$t7, 0, invalid_divisor	# kiem tra so bi chia khac 0
			nop
			div	$t6, $t6, $t7
			sw	$t6, 0($sp)
			addi	$sp, $sp, 4
			addi	$s1, $s1, 1
			addi	$t8, $t8, -1
			j	iterate_postfix
			nop
			
		mod_:
			beq	$t7, 0, invalid_divisor	# kiem tra so bi chia khac 0
			nop
			div	$v1, $t6, $t7
			mul     $v1, $v1, $t7
			sub 	$t6, $t6, $v1 
			sw	$t6, 0($sp)
			addi	$sp, $sp, 4
			addi	$s1, $s1, 1
			addi	$t8, $t8, -1
			j	iterate_postfix
			nop
				
		mul_:			
			mul	$t6, $t6, $t7
			sw	$t6, 0($sp)
			addi	$sp, $sp, 4
			addi	$s1, $s1, 1
			addi	$t8, $t8, -1
			j	iterate_postfix
			nop
			
		exp_:			
			beq	$t7, 0, zero_power		# check so mu = 0
			nop	
			mul	$t5, $t5, $t6
			slt	$s3, $s2, $t7
			addi	$s2, $s2, 1
			beq	$s3, 1, exp_
			nop
			sw	$t5, 0($sp)
			addi	$sp, $sp, 4
			addi	$s1, $s1, 1
			addi	$t8, $t8, -1
			j 	iterate_postfix
                	nop
                	
		zero_power:		
			li	$t4, 1
			sw	$t4, 0($sp)
			addi	$sp, $sp, 4
			addi	$s1, $s1, 1
			addi	$t8, $t8, -1
			j	iterate_postfix
                	nop
                	
        	end_process_postfix:
                	jr	$t9
                
printf:	
	bne	$t8, 1, error_na
	nop
	li	$v0, 4
	la	$a0, msg_print_result
	syscall  
	li	$v0, 1
	lw	$t4, -4($sp)
	move	$a0, $t4
	syscall
	li	$v0, 4
	la	$a0, msg_enter
	syscall
	li	$v0, 50
	la	$a0, start_again_msg
	syscall
	bnez	$a0, terminate
	nop 
	j	start
	nop
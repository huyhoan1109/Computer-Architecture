#=================================================================================================================#
#			    			POSTSCRIPT CNC MARSBOT			    	  		  #		    			             
#       				  Author: Nguyen Huy Hoan (27-6-2022)       			          #			          
#                                                     @Copyright						  #
#=================================================================================================================#

.data
     prompt: .asciiz "Enter array: " 
     .align 4
     table : .asciiz "Integer\tPower\tSquare\tHexadecimal\n"
     .align 4
     error_msg: .asciiz "Error! Input is wrong"
     .align 4
     line: .asciiz "\n"
     tab: .asciiz "\t"
     tmp: .space 20                   # Lưu dữ liệu dùng gián tiếp
     array: .space 12                 # Tạo mảng lưu dữ liệu kiểu số sau khi chuyển đổi (mỗi i có 4 byte) 
     ans1: .space 12                  # Tạo mảng lưu kết quả thứ nhất 
     ans2: .space 12                  # Tạo mảng lưu kết quả thứ hai  
     hex1: .space 12                  # Lưu chuỗi hex đầu tiên 
     hex2: .space 12                  # Lưu chuỗi hex thứ hai 
     hex3: .space 12                  # Lưu chuỗi hex thứ ba 
     ans3: .word hex1, hex2, hex3     # Tạo mảng lưu kết quả thứ ba 
           .word 0  

.text
     .globl main                      # Chương trình chính 
     
     main:
          li $t0, 0                   # Khởi tạo giá trị cho t0  ~ i = 0
          jal save_global_jump
          jal store_func              # Chuyển sang thủ tục store 
          nop
          jal save_global_jump
          jal cal_ans1                # Tính toán kết quả của ans1
          nop
          jal save_global_jump
          jal cal_ans2                # Tính toán kết quả của ans2
          nop
          jal save_global_jump
          jal cal_ans3                # Tính toán kết quả của ans3
          nop
          jal save_global_jump
          jal show_table
          nop
          jal save_global_jump
          jal print_func              # In ra kết quả cuối cùng 
          nop
          li $v0, 10                  # Kết thúc chương trình
          syscall 
          
    init_temp:                        # Thủ tục khởi tạo dữ liệu ban đầu 
          li $t1, 0                   # t1 = 0 ~ j
          li $t2, 0
          li $t3, 0
          li $t4, 0
          li $t5, 0
          li $t6, 0
          sw $zero, tmp
          jr $ra
          
    save_global_jump:                 # Thủ tục lưu bước nhảy chương trình chính 
          add $s0, $ra, 8             # Do coi như 2 lần nhảy nên sẽ con trỏ register sẽ += 8
          jr $ra
          
    error:                            # Báo lỗi 
          li $v0, 4  
          la $a0, error_msg           
          syscall                     # Hiện thông báo 
          la $a0, line
          syscall
          li $s2, 1 
          jr $s0                            
          
    store_func:   
          beq $t0, 12, done_store
          li $v0, 4                   # Promting
          la $a0, prompt
          syscall 
          li $v0, 8                   # Lấy dữ liệu từ bàn phím 
          la $a0, tmp                 # Lưu dữ liệu vào tmp 
          li $a1, 20                  # Chiều dài tối đa của dữ liệu  
          syscall
          
          atoi:                       # Quá trình chuyển chữ sang số 
             lb $t2, tmp($t1)         # Đọc chữ có thứ tự thứ j   
             beq $t2, '\n', store     # Nếu gặp phải ký tự xuống dòng => đọc xong và tiến hành lưu còn không tiếp tục 
             sgeu $t4, $t2, '0'       # Kiểm tra khoảng giá trị xem char thứ j có phải số không 
             sleu $t5, $t2, '9'  
             and $t6, $t4, $t5  
             beqz $t6, error          # Có thì tiến hành chuyển đổi không thì báo lỗi 
             mul $t3, $t3, 10         # Tiến hành chuyển từ chữ sang số theo mã Ascii
             addi $t2, $t2, -48       # Do '0' - 0 = 48 và tượng tự các số khác 
             add $t3, $t3, $t2      
             add $t1, $t1, 1          # Tăng giá trị của j
             beq $t1, 20, store_func  # Đọc hết các giá trị có thể 
             j atoi
             
          store:                      # Lưu số sau khi vừa được chuyển đổi vào được lưu ở $t3
             sw $t3, array($t0)       # array[i] = $t3
             addi $t0, $t0, 4         # $t0 += 4 ~ i += 1 
             jal init_temp            # Khởi tạo lại dữ liêu từ đầu cho vòng lặp sau 
             j store_func             # Thực hiện tiếp vòng lặp   

          done_store:
             li $t0, 0                # Reset lại dữ liệu cho $t0 
             jr $s0
             
    cal_ans1:
          beq $s2, 1, exit            # Nếu đã có lỗi trong lúc nhập thì tự động thoát ra 
          lw $t1, array($t0)          # Load du lieu tu array[i]
          li $t2, 1                   # $t2 = 1
          sllv $t3, $t2, $t1          # $t3 = 2 ^ array[i]
          sw $t3, ans1($t0)           # ans1[i] = $t3
          addi $t0, $t0, 4            # i += 1 (t0 += 4)
          blt $t0, 12, cal_ans1       # Neu i = 3 (t0 = 12) thi thoat khoi vong lap
          li $t0, 0
          jal init_temp               # Reset lại dữ liệu 
          jr $s0
          
    cal_ans2:
          beq $s2, 1, exit            # Nếu đã có lỗi trong lúc nhập thì tự động thoát ra 
          lw $t1, array($t0)          # Load du lieu tu array[i]
          mul $t2, $t1, $t1           # $t2 = array[i] ^ 2
          sw $t2, ans2($t0)           # ans2[i] = $t2
          addi $t0, $t0, 4            # i += 1 (t0 += 4)
          blt $t0, 12, cal_ans2       # Neu i = 0 (t0 = 12) thi thoat ra khoi vong lap
          li $t0, 0
          jal init_temp               # Reset lại dữ liệu 
          jr $s0
          
    cal_ans3:
          beq $s2, 1, exit            # Nếu đã có lỗi trong lúc nhập thì tự động thoát ra 
          jal init_temp               # Init dữ liệu
          lw $t1, array($t0)          # $t1 = array[i] 
          la $t2, tmp                 # Gọi tmp 
          li $t3, 0                   # $t3 để đo đô dài của chuỗi 
          
          loop_div:
             beq $t1, 0, ans3_i       # $t1 ~ array[i] = 0 => Tiến hành lưu 
             div $t4, $t1, 16         # $t4 = $t1 // 16 
             mul $t5, $t4, 16         # $t5 = 16 * $t4 
             sub $t6, $t1, $t5        # $t6 là số dư của phép chia $t1 và 16
             bleu $t6, 9, small_hex   # Kiểm tra số du 
             addi $t6, $t6, 55        # Nếu $t6 >= 10 (thuộc 'A' -> 'F') 
             j itos                   # Chuyển đổi sang string (*)
             small_hex:
                 addi $t6, $t6, 48    # Nếu 0 <= $t6 <= 9  => +48
                 j itos               # Tương tự như trên (*)
          
          itos:
             sb $t6, 0($t2)           # Lưu dữ liệu vào tmp để tiến hành reverse sau vs tmp[k] = $t6
             move $t1, $t4            # Cập nhật $t1 để tiến hành chia tiếp lần sau 
             addi $t2, $t2, 1         # k += 1 ($t2 += 1)
             addi $t3, $t3, 1         # Cập nhật độ dài của tmp 
             j loop_div               # Lặp lại vòng lặp 
          
          ans3_i:
             lw $s1, ans3($t0)        # String thứ i của ans3   
             addi $t1, $zero, '0'     # $t1 = '0'
             addi $t4, $zero, 'x'     # $t4 = 'x'
             sb $t1, 0($s1)           # ans[i][0] = '0'
             sb $t4, 1($s1)           # ans[i][1] = 'x'
             addi $s1, $s1, 2         
             loop_re: 
                addi $t3, $t3, -1     # Dựa vào $t2 và $t3 => Dịch chuyển con trỏ từ cuối string tmp 
                addi $t2, $t2, -1
                lb $t6, 0($t2)        # => ans3[i][j] = tmp[$t2] 
                sb $t6, 0($s1)        # => ans3[i] là reverse string của tmp và chính là số hexadecimal của array[i]
                addi $s1, $s1, 1      # j += 1
                beqz $t3, ans3_i_end  # $t3 = 0 => Kết thúc vòng lặp vs ans3[i]
                j loop_re             # Tiếp tục vòng lặp nếu cần 
          
          ans3_i_end:
             addi $t0, $t0, 4         # $t0 += 4 ~ (i += 1)
             beq $t0, 12, comp_ans3   # Neu i = 0 (t0 = 12) thi thoat ra khoi vong lap
             j cal_ans3               # Tiếp tục vòng lặp 
          
          comp_ans3:
             li $t0, 0                # Reset lại dữ liệu cho $t0 
             jr $s0
    
    show_table:
          beq $s2, 1, exit 
          li $v0, 4
          la $a0, table               # In string table 
          syscall
          jr $s0
          
    print_func:
          beq $s2, 1, exit 
          li $v0, 36                  # In so
          lw $a0, array($t0)          # Load array[i]
          syscall
          li $v0, 4                   
          la $a0, tab                 # In tab
          syscall
          
          li $v0, 36                  # In so
          lw $a0, ans1($t0)           # Load ans[i]
          syscall
          li $v0, 4
          la $a0, tab                 # In tab
          syscall
          
          li $v0, 36                  # In so
          lw $a0, ans2($t0)           # Load ans2[i] 
          syscall 
          li $v0, 4
          la $a0, tab                 # In tab
          syscall
          
          li $v0, 4                   # In ...
          lw $a0, ans3($t0)           # In ans3[i]
          syscall
          li $v0, 4              
          la $a0, line                # Xuong dong
          syscall
          
          addi $t0, $t0, 4            # i += 1 (t0 += 4)
          blt $t0, 12, print_func     # Thoat neu i = 3 (t0 = 12)
          jr $s0 
                               
    exit:
          jr $s0 
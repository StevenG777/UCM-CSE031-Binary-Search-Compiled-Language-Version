.data 

original_list: .space 100 
sorted_list: .space 100

str0: .asciiz "Enter size of list (between 1 and 25): "
str1: .asciiz "Enter one list element: "
str2: .asciiz "Content of original list: "
str3: .asciiz "Enter a key to search for: "
str4: .asciiz "Content of sorted list: "
strYes: .asciiz "Key found!"
strNo: .asciiz "Key not found!"
str_space: .asciiz " "                 # To display the new sentence on next line (Used in printList)
str_line:   .asciiz "\n"               # To display each integer between a space (Used in printList)



.text 

#This is the main program.
#It first asks user to enter the size of a list.
#It then asks user to input the elements of the list, one at a time.
#It then calls printList to print out content of the list.
#It then calls inSort to perform insertion sort
#It then asks user to enter a search key and calls bSearch on the sorted list.
#It then prints out search result based on return value of bSearch
main: 
	addi $sp, $sp -8
	sw $ra, 0($sp)
	li $v0, 4 
	la $a0, str0 
	syscall 
	li $v0, 5	#read size of list from user
	syscall
	move $s0, $v0
	move $t0, $0
	la $s1, original_list
loop_in:
	li $v0, 4 
	la $a0, str1 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5	#read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loop_in
	move $a0, $s1
	move $a1, $s0
	
	jal inSort	#Call inSort to perform insertion sort in original list
	
	sw $v0, 4($sp)
	li $v0, 4 
	la $a0, str2 
	syscall 
	la $a0, original_list
	move $a1, $s0
	jal printList	#Print original list
	li $v0, 4 
	la $a0, str4 
	syscall 
	lw $a0, 4($sp)
	jal printList	#Print sorted list
	
	li $v0, 4 
	la $a0, str3 
	syscall 
	li $v0, 5	#read search key from user
	syscall
	move $a3, $v0
	lw $a0, 4($sp)
	jal bSearch	#call bSearch to perform binary search
	
	beq $v0, $0, notFound
	li $v0, 4 
	la $a0, strYes 
	syscall 
	j end
	
notFound:
	li $v0, 4 
	la $a0, strNo 
	syscall 
end:
	lw $ra, 0($sp)
	addi $sp, $sp 8
	li $v0, 10 
	syscall
	
	
#printList takes in a list and its size as arguments. 
#It prints all the elements in one line.
printList:
	#Your implementation of printList here	
	
	# a0: $s1 (Address of Original_List/Sorted_List Data memory)
	# a1: $s0 (Size of array/n)
	# t0: i
	
		move $t0, $0                  # i = 0
	
	print:
		move $t2, $a0                 # Make a temporary copy from argument list
		sll $t1, $t0, 2               # increment_original = i * 4
		add $t1, $t1, $a0             # increment_original += address of argument list
		li $v0, 1                     # Print integer
		lw $a0, 0($t1)                # load argument_list[i]
		syscall
		li $v0, 4
		la $a0, str_space
		syscall                       # System call function 
		move $a0, $t2                 # Restore argument list from t2 (Look at 95)
		addi $t0, $t0, 1              # i++
		slt $t1, $t0, $a1	      # if(i < n) -> printList
		bne $t1, $0, print
		
		li $v0, 4
		la $a0, str_line
		syscall            
	
		jr $ra                        # Jump to return address
	
	
#inSort takes in a list and it size as arguments. 
#It performs INSERTION sort in ascending order and returns a new sorted list
#You may use the pre-defined sorted_list to store the result
inSort:
	#Your implementation of inSort here
	
	# a0: $s1 (Address of Original_List Data memory)
	# a1: $s0 (Size of array/n)
	# t0: i
	# t1: j
	# s2: Sorted List
	move $t0, $0                          # i = 0
	
	convert:                              # do:
		la $s2, sorted_list           # Load Sorted_list address
		sll $t1, $t0, 2               # increment_original = i * 4
		move $t2, $t1                 # increment_sorted = increment_original
		add $t1, $t1, $a0             # increment_original += address of original list
		add $t2, $t2, $s2             # increment_sorted += address of sorted list
		lw $t3, 0($t1)                # sort_list[i] = original_list[i]
		sw $t3, 0($t2)
		addi $t0, $t0, 1              # i++
		bne $t0, $s0, convert         # while(i < n);
		
	        addi $t0, $zero, 1            # for(i = 1; i < n;
	        
	I_Loop:
		beq  $t0, $a1, I_Loop_Exit
		move $t1, $t0                 # j = i
		
	J_Loop: 
		addi $t2, $zero, 0            # t2 = 0
		beq $t1, $t2, J_Loop_Exit     # while(j > 0 && arr[j-1] > arr[j])
		sll $t2, $t1, 2               # t2 = t1 * 4 
		add $t2, $t2, $s2             # t2 = t2 + address of sorted_list
		lw $t3, -4($t2)               # t3 = arr[j-1]
		lw $t4, 0($t2)                # t4 = arr[j]
		slt $t2, $t3, $t4             # if(arr[j-1] < arr[j]). if it's true, left the J loop 
		bne $t2, $0, J_Loop_Exit       
		
		sll $t2, $t1, 2               # arr[j]
		add $t2, $t2, $s2
		lw $t3, 0($t2)                # temp1 = arr[j]             
		lw $t4, -4($t2)               # temp2 = arr[j-1]
		sw $t4, 0($t2)                # arr[j] = arr[j-1]/ temp2
		sw $t3, -4($t2)               # arr[j-1] = arr[j]/ temp1
		addi $t1, $t1, -1             # j--
		j J_Loop
	
	J_Loop_Exit:
		addi $t0, $t0, 1               # for i++)
		j I_Loop                      # Jump to I_Loop
		
	I_Loop_Exit:
		move $v0, $s2
		jr $ra                       # Jump to Address
		
	
	
#bSearch takes in a list, its size, and a search key as arguments.
#It performs binary search RECURSIVELY to look for the search key.
#It will return a 1 if the key is found, or a 0 otherwise.
#Note: you MUST NOT use iterative approach in this function.
bSearch:
	#Your implementation of bSearch here
	# a0: $s1 (Address of Sorted_List Data memory)
	# a1: $s0 (Size of array/n)
	# a3: key number
	
	addi $sp, $sp, -4             # decrement the stack pointer
	sw $ra, 0($sp)                # Back up the return address
	
	bne $s3, $zero, binaryRecur   # if s3 != 0, then go to binaryRecur immediately
	add $s0, $zero, $zero         # Set s0 as leftmost index as 0
	addi $s3, $zero, 1            # Sets s3 to 1 so s0 is never set to zero again
	
	binaryRecur:
	bgt $s0, $a1, returnZero      # if left index is greater than right index, go to returnZero
	add $t1, $a1, $s0             # t1 = Right index + Left index
	addi $t3, $zero, 2            # t3 = 2 (multiplier)
	div $t1, $t1, $t3             # t1 = t1/t3 = (right + left)/2
	addi $t3, $zero, 4            # t3 = 4
	mul $t3, $t3, $t1             # t3 = t1 * t3 = ((right + left)/2) * 4
	add $t0, $t3, $a0             # t0 = t3 + Sort_list address. Store the corresponding address in the t0
	lw $t2, 0($t0)                # load the word in t0 to t2
	beq $t2, $a3, returnFound     # if integer in middle index in sorted_list = keyword, return found. If not, go to the next line
	bgt $t2, $a3, Left            # if integer in middle index in sorted_list > keyword/ keyword < integer in sort_list
		                      # We focus on the left part of the list (Left Label). 
		                      # Otherwise, we focus on the right part of the list (Right Label)
	
	Right:
	addi $s0, $t1, 1              # add 1 to the left index, because we know that the mid index integer != keyword already 
	j binaryRecur                 # go back the binaryRecur to test if the mid index of the word list = keyword
	
	Left:
	addi $a1, $t1, -1             # subtract 1 to the right index, , because we know that the mid index integer != keyword already
	j binaryRecur                 # go back the binaryRecur to test if the mid index of the word list = keyword
	
	returnFound:
	addi $v0, $zero, 1            # Return 1
	j Return                      # jump to Return
	
	returnZero:
	addi $v0, $zero, 0            # Return 0
	j Return                      # jump to Return
	
	Return:
	sw $ra, 0($sp)                # restore the return address
	addi $sp, $sp, 4              # restore the stack pointer
	jr $ra                        # jump to the return address

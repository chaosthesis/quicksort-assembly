.globl main
.data
          .align 5  # names start on a 16-byte boundary
dataName: .asciiz "Joe"
          .align 5
          .asciiz "Jenny"
          .align 5
          .asciiz "Jill"
          .align 5
          .asciiz "John"
          .align 5
          .asciiz "Jeff"
          .align 5
          .asciiz "Joyce"
          .align 5
          .asciiz "Jerry"
          .align 5
          .asciiz "Janice"
          .align 5
          .asciiz "Jake"
          .align 5
          .asciiz "Jonna"
          .align 5
          .asciiz "Jack"
          .align 5
          .asciiz "Jocelyn"
          .align 5
          .asciiz "Jessie"
          .align 5
          .asciiz "Jess"
          .align 5
          .asciiz "Janet"
          .align 5
          .asciiz "Jane"
          .align 2  # addresses start on a word(4-byte) boundary
dataAddr: .space 64 # 16 pointers to strings: 16*4 = 64
dataMsg1: .asciiz "Initial array:\n"
dataMsg2: .asciiz "Sorted array:\n"
dataSpce: .asciiz " "
dataBktL: .asciiz "["
dataBktR: .asciiz " ]\n"

.text
main:
  la $s1, dataAddr # $s1 = array address
  la $s2, dataName # $s2 = names address
  li $t0, 0
  li $s0, 16       # int size = 16
initLoop:          # const char * data[] = {"Joe", "Jenny", ...}
  bge  $t0, $s0, initExit
  sw   $s2, 0($s1)
  addi $s1, $s1, 4
  addi $s2, $s2, 32
  addi $t0, $t0, 1
  j    initLoop
initExit:
  la $a0, dataMsg1
  li $v0, 4
  syscall          # printf("Initial array:\n");
  la $a0, dataAddr
  jal print_array  # print_array(data, size);

  la $a0, dataAddr
  li $s1, 16       # size = 16
  move $a1, $s1
  jal quick_sort   # quick_sort(data, size);

  la $a0, dataMsg2
  li $v0, 4
  syscall          # printf("Sorted array:\n");
  la $a0, dataAddr
  jal print_array  # print_array(data, size);
	li $v0, 10
	syscall          # exit(0);

str_lt:
compareLoop:
  lb $t0, 0($a0)               # load *x
  beq $t0, $zero, compareExit  # break if *x!='\0'
  lb $t1, 0($a1)               # load *y
  beq $t1, $zero, compareExit  # break if *y!='\0'
  blt $t0, $t1, lessThan       # if (*x < *y) return 1;
  blt $t1, $t0, greaterThan    # if (*y < *x) return 0;
  addi $a0, $a0, 1             # x++
  addi $a1, $a1, 1             # y++
	j compareLoop
lessThan:
  li $a0, 1
	jr $ra
greaterThan:
  li $a0, 0
	jr $ra
compareExit:
	beq $t1, $zero, greaterThan  # if (*y == '\0') return 0;
  j lessThan

swap_str_ptrs:
	lw $t0, 0($a0)
	lw $t1, 0($a1)
	sw $t0, 0($a1)
	sw $t1, 0($a0)
	jr $ra

quick_sort:
	addi $sp, $sp, -24
	sw $ra, 20($sp)
	sw $s4, 16($sp)
	sw $s3, 12($sp)
	sw $s2, 8($sp)
	sw $s1, 4($sp)
	sw $s0, 0($sp)
	
  ble $a1, 1, quick_sort_exit  # if (len <= 1) return;
	addi $s2, $a1, -1            # s2 = len - 1
	move $s3, $a0                # s3 = const char *a[]
	sll $t0, $s2, 2
	add $s4, $s3, $t0            # s4 = a + (len - 1)
	li $s0, 0                    # s0 = pivot
	li $s1, 0                    # s1 = i
partitionLoop:
	bge $s1, $s2, partitionExit
	sll $t0, $s1, 2
	add $a0, $s3, $t0     # a0 = a + i
	move $a1, $s4         # a1 = a + len - 1
	lw $a0, ($a0)         # a0 = a[i]
	lw $a1, ($a1)         # a1 = a[len - 1]
	jal str_lt

	beqz $a0, ifNotStrLt
	sll $t0, $s1, 2
	add $a0, $s3, $t0     # a + i
	sll $t0, $s0, 2
	add $a1, $s3, $t0     # a + pivot
	jal swap_str_ptrs     # swap_str_ptrs(&a[i], &a[pivot]);
	addi $s0, $s0, 1      # pivot++
ifNotStrLt:
	addi $s1, $s1, 1      # i++
	j partitionLoop
partitionExit:
	sll $t0, $s0, 2
	add $a0, $s3, $t0     # a + pivot
	move $a1, $s4         # a + len - 1
	jal swap_str_ptrs     # swap_str_ptrs(&a[pivot], &a[len - 1]);
	
	move $a0, $s3
	move $a1, $s0
	jal quick_sort        # quick_sort(a, pivot);
	
	addi $t0, $s0, 1
	sll $t0, $t0, 2
	add $a0, $s3, $t0     # a + pivot + 1
	sub $a1, $s2, $s0     # len - 1 - pivot
	jal quick_sort        # quick_sort(a + pivot + 1, len - pivot - 1);
quick_sort_exit:
	lw $ra, 20($sp)
	lw $s4, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 24
	jr $ra

print_array:
  la $a0, dataBktL
  li $v0, 4
  syscall  # printf("[");
  la $s1, dataAddr
  li $t0, 0
printLoop:
  bge $t0, $s0, printExit
  la $a0, dataSpce
  li $v0, 4
  syscall  # printf(" %s", a[i]);
  lw $a0, 0($s1)
  li $v0, 4
  syscall
  addi $s1, $s1, 4
  addi $t0, $t0, 1
  j    printLoop
printExit:
  la $a0, dataBktR
  li $v0, 4
  syscall  # printf("]\n");
  jr $ra

.data
SYSREAD = 0
STDIN = 0
SYSWRITE = 1
STDOUT = 1
SYSEXIT = 60
EXIT_SUCCESS = 0
BUFLEN = 512
ASCII_ZERO = 0x30
ASCII_NINE = 0x39
ERROR: .ascii "Wprowadz prawidlowa liczbe!\n"
err_len=.-ERROR
tekst1: .ascii "Wprowadz podstawe:\n"
tekst1_len = .-tekst1
tekst2: .ascii "Wprowadz potege:\n"
tekst2_len = .-tekst2
tekstpotegowanie: .ascii "Zwykłe potegowanie przez mnozenie: \n"
tekstpot_len= .-tekstpotegowanie
tekstszybkiepotegowanie: .ascii "Szybkie potegowanie: \n"
tekstsz_len = .-tekstszybkiepotegowanie

.bss
.comm textin1, 512
.comm textout, 512
.comm textoutfast, 512
.comm textin2, 512
.comm test, 512

.text
.globl _start
_start:

mov $SYSWRITE, %rax
mov $STDOUT, %rdi
mov $tekstpotegowanie, %rsi
mov $tekstpot_len, %rdx 
syscall

mov $SYSWRITE, %rax
mov $STDOUT, %rdi
mov $tekst1, %rsi
mov $tekst1_len, %rdx 
syscall

mov $SYSREAD, %rax
mov $STDIN, %rdi
mov $textin1, %rsi
mov $BUFLEN, %rdx
syscall

sub $2, %rax
mov %rax, %r14
mov %rax, %rbx  # string reprezentujacy podstawe do potegowania

mov $SYSWRITE, %rax
mov $STDOUT, %rdi
mov $tekst2, %rsi
mov $tekst2_len, %rdx 
syscall

mov $SYSREAD, %rax
mov $STDIN, %rdi
mov $textin2, %rsi
mov $BUFLEN, %rdx
syscall

sub $2, %rax
mov %rax, %r15
mov %rax, %rcx  # string reprezentujacy potege

#sprawdzenie czy podstawa jest liczba
check_if_number1:
mov textin1(, %rbx, 1), %al
cmp $ASCII_ZERO, %al
jge less_than_9_1
jmp error_msg

less_than_9_1:
cmp $ASCII_NINE, %al
jle next_number1
jmp error_msg

next_number1:
dec %rbx
cmp $0, %rbx
jge check_if_number1

mov %r14, %rbx
xor %rax, %rax

xor %r8, %r8 	# zdekodowana podstawa
mov $1, %r9		# mnoznik
mov $10, %r10       # system dzisietny

decode_number1:
mov textin1(, %rbx, 1), %al
sub $ASCII_ZERO, %al
mul %r9
add %rax, %r8
mov %r9, %rax
mul %r10
mov %rax, %r9
dec %rbx
xor %rax, %rax
cmp $0, %rbx
jge decode_number1

#########################
#sprawdzenie czy potega jest liczba
check_if_number2:
mov textin2(, %rcx, 1), %al
cmp $ASCII_ZERO, %al
jge less_than_9_2
jmp error_msg

less_than_9_2:
cmp $ASCII_NINE, %al
jle next_number2
jmp error_msg

next_number2:
dec %rcx
cmp $0, %rcx
jge check_if_number2

mov %r15, %rcx
xor %rax, %rax

xor %r11, %r11 	# zdekodowana potega
mov $1, %r9		# mnoznik

decode_number2:
mov textin2(, %rcx, 1), %al
sub $ASCII_ZERO, %al
mul %r9
add %rax, %r11
mov %r9, %rax
mul %r10
mov %rax, %r9
dec %rcx
xor %rax, %rax
cmp $0, %rcx
jge decode_number2

#######################
mov %r8, %rax
xor %r9,%r9
mov %r8, %r9
xor %r14,%r14
mov %r11,%r14
dec %r11
dec %r11

#petla potegowania
power_loop:
sub $1, %r11
mul %r8
cmp $0, %r11
jge power_loop

mov %rax, %rbx  # w rbx wynik potegowania
mov $0, %r12 	# dlugosc ciagu do konwersji

power_length:
div %r10
xor %rdx, %rdx
inc %r12
cmp $0, %rax
jg power_length

mov %rbx, %rax
inc %r12
mov $'\n', %dl
mov %dl, textout(, %r12, 1)
dec %r12
xor %rdx, %rdx

encode_number:
div %r10
add $ASCII_ZERO, %dl
mov %dl, textout(, %r12, 1)
xor %rdx, %rdx
dec %r12
cmp $0, %r12
jg encode_number

#zwykle potegowanie
mov $SYSWRITE, %rax
mov $STDOUT, %rdi
mov $tekstpotegowanie, %rsi
mov $tekstpot_len, %rdx
syscall

#wynik
mov $SYSWRITE, %rax
mov $STDOUT, %rdi
mov $textout, %rsi
mov $BUFLEN, %rdx
syscall

#szybkie potegowanie:
mov $SYSWRITE, %rax
mov $STDOUT, %rdi
mov $tekstszybkiepotegowanie, %rsi
mov $tekstsz_len, %rdx
syscall

#######################
mov %r14,%r11

mov %r9,%r8
xor %r15, %r15 

#spr czy parzysta
shr %r14
adc $0, %r15
cmp $1, %r15
jge nieparzysta
jmp parzysta

#nieparzysta
nieparzysta:
dec %r11
mov $2, %r13
mov %r11, %rax
xor %rdx, %rdx
div %r13
mov %rax, %r11
mov $1,%rax
jmp fastpower_loop

#potega parzysta
parzysta:
mov $2, %r13
mov %r11, %rax
xor %rdx, %rdx
div %r13
mov %rax, %r11
mov $1,%rax
jmp fast_power_loop2

#petla potegowania mnozymy n/2 razy
fastpower_loop:
dec %r11
mul %r8
cmp $0, %r11
jg fastpower_loop
#podnosimy ^2
mov %rax, %r13
mul %r13
mul %r8
jmp konwersja

#petla dla parzystych
fast_power_loop2:
dec %r11
mul %r8
cmp $0, %r11
jg fast_power_loop2
#mov %rax,%r13
mul %rax

konwersja:

mov %rax, %rbx  # w rbx wynik potegowania

mov $0, %r12 	# dlugosc ciagu do konwersji

fastpower_length:
div %r10
xor %rdx, %rdx
inc %r12
cmp $0, %rax
jg fastpower_length

mov %rbx, %rax
inc %r12
mov $'\n', %dl
mov %dl, textoutfast(, %r12, 1)
dec %r12
xor %rdx, %rdx

encode_number2:
div %r10
add $ASCII_ZERO, %dl
mov %dl, textoutfast(, %r12, 1)
xor %rdx, %rdx
dec %r12
cmp $0, %r12
jg encode_number2

#wynik
mov $SYSWRITE, %rax
mov $STDOUT, %rdi
mov $textoutfast, %rsi
mov $BUFLEN, %rdx
syscall

jmp end_label
xor %rsi, %rsi

error_msg:
mov $SYSWRITE, %rax
mov $STDOUT, %rdi
mov $ERROR, %rsi
mov $err_len, %rdx
syscall

end_label:
mov $SYSEXIT, %rax
mov $EXIT_SUCCESS, %rdi
syscall

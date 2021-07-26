   1               		.file	"main.c"
   2               	__SP_H__ = 0x3e
   3               	__SP_L__ = 0x3d
   4               	__SREG__ = 0x3f
   5               	__tmp_reg__ = 0
   6               	__zero_reg__ = 1
   7               		.text
   8               	.Ltext0:
   9               		.cfi_sections	.debug_frame
  10               		.section	.text.__vector_11,"ax",@progbits
  11               	.global	__vector_11
  13               	__vector_11:
  14               	.LFB6:
  15               		.file 1 "main.c"
   1:main.c        **** #define F_CPU 16000000L
   2:main.c        **** //#define __AVR_ATmega168__
   3:main.c        **** 
   4:main.c        **** #include <inttypes.h>
   5:main.c        **** #include <avr/io.h>
   6:main.c        **** #include <avr/interrupt.h>
   7:main.c        **** #include <avr/sleep.h>
   8:main.c        **** #include <util/delay.h>
   9:main.c        **** 
  10:main.c        **** #include <drivers/indicator.h>
  11:main.c        **** 
  12:main.c        **** 
  13:main.c        **** 
  14:main.c        **** #define TIM1_OCR_PRESC      ( 15 ) // 1,0s for presc 1024
  15:main.c        **** 
  16:main.c        **** 
  17:main.c        **** static uint16_t  timer_counter = 0;
  18:main.c        **** 
  19:main.c        **** 
  20:main.c        **** 
  21:main.c        **** ISR (TIMER1_COMPA_vect)
  22:main.c        **** {
  16               		.loc 1 22 1 view -0
  17               		.cfi_startproc
  18 0000 8F93 8FB7 		__gcc_isr 1
  18      8F93 
  19 0006 9F93      		push r25
  20               	.LCFI0:
  21               		.cfi_def_cfa_offset 3
  22               		.cfi_offset 25, -2
  23               	/* prologue: Signal */
  24               	/* frame size = 0 */
  25               	/* stack size = 1...5 */
  26               	.L__stack_usage = 1 + __gcc_isr.n_pushed
  23:main.c        ****    timer_counter ++;
  27               		.loc 1 23 4 view .LVU1
  28               		.loc 1 23 18 is_stmt 0 view .LVU2
  29 0008 8091 0000 		lds r24,timer_counter
  30 000c 9091 0000 		lds r25,timer_counter+1
  31 0010 0196      		adiw r24,1
  32 0012 9093 0000 		sts timer_counter+1,r25
  33 0016 8093 0000 		sts timer_counter,r24
  34               	/* epilogue start */
  24:main.c        **** }
  35               		.loc 1 24 1 view .LVU3
  36 001a 9F91      		pop r25
  37 001c 8F91 8FBF 		__gcc_isr 2
  37      8F91 
  38 0022 1895      		reti
  39               		__gcc_isr 0,r24
  40               		.cfi_endproc
  41               	.LFE6:
  43               		.section	.text.tim1_init,"ax",@progbits
  44               	.global	tim1_init
  46               	tim1_init:
  47               	.LFB7:
  25:main.c        **** 
  26:main.c        **** 
  27:main.c        **** 
  28:main.c        **** void
  29:main.c        **** tim1_init( void )
  30:main.c        **** {
  48               		.loc 1 30 1 is_stmt 1 view -0
  49               		.cfi_startproc
  50               	/* prologue: function */
  51               	/* frame size = 0 */
  52               	/* stack size = 0 */
  53               	.L__stack_usage = 0
  31:main.c        ****    //
  32:main.c        ****    // Ftim = Fcpu / 1024
  33:main.c        ****    // CTC mode
  34:main.c        ****    //
  35:main.c        ****    TCCR1B = ( 1<<WGM12 );
  54               		.loc 1 35 4 view .LVU5
  55               		.loc 1 35 11 is_stmt 0 view .LVU6
  56 0000 E1E8      		ldi r30,lo8(-127)
  57 0002 F0E0      		ldi r31,0
  58 0004 88E0      		ldi r24,lo8(8)
  59 0006 8083      		st Z,r24
  36:main.c        **** 
  37:main.c        ****    OCR1AH = TIM1_OCR_PRESC >> 8;
  60               		.loc 1 37 4 is_stmt 1 view .LVU7
  61               		.loc 1 37 11 is_stmt 0 view .LVU8
  62 0008 1092 8900 		sts 137,__zero_reg__
  38:main.c        ****    OCR1AL = TIM1_OCR_PRESC & 0xff;
  63               		.loc 1 38 4 is_stmt 1 view .LVU9
  64               		.loc 1 38 11 is_stmt 0 view .LVU10
  65 000c 8FE0      		ldi r24,lo8(15)
  66 000e 8093 8800 		sts 136,r24
  39:main.c        **** 
  40:main.c        ****    TCCR1B |= ( 1<<CS12 ) | ( 0<<CS11 ) | ( 1<<CS10 );
  67               		.loc 1 40 4 is_stmt 1 view .LVU11
  68               		.loc 1 40 11 is_stmt 0 view .LVU12
  69 0012 8081      		ld r24,Z
  70 0014 8560      		ori r24,lo8(5)
  71 0016 8083      		st Z,r24
  41:main.c        ****    TIMSK1 |= ( 1<<OCIE1A );
  72               		.loc 1 41 4 is_stmt 1 view .LVU13
  73               		.loc 1 41 11 is_stmt 0 view .LVU14
  74 0018 EFE6      		ldi r30,lo8(111)
  75 001a F0E0      		ldi r31,0
  76 001c 8081      		ld r24,Z
  77 001e 8260      		ori r24,lo8(2)
  78 0020 8083      		st Z,r24
  79               	/* epilogue start */
  42:main.c        **** }
  80               		.loc 1 42 1 view .LVU15
  81 0022 0895      		ret
  82               		.cfi_endproc
  83               	.LFE7:
  85               		.section	.text.ADC_Init,"ax",@progbits
  86               	.global	ADC_Init
  88               	ADC_Init:
  89               	.LFB8:
  43:main.c        **** 
  44:main.c        **** 
  45:main.c        **** void
  46:main.c        **** ADC_Init( void )
  47:main.c        **** {
  90               		.loc 1 47 1 is_stmt 1 view -0
  91               		.cfi_startproc
  92               	/* prologue: function */
  93               	/* frame size = 0 */
  94               	/* stack size = 0 */
  95               	.L__stack_usage = 0
  48:main.c        **** 	ADCSRA |= (1 << ADEN);										//we allow the ADC to work
  96               		.loc 1 48 2 view .LVU17
  97               		.loc 1 48 9 is_stmt 0 view .LVU18
  98 0000 EAE7      		ldi r30,lo8(122)
  99 0002 F0E0      		ldi r31,0
 100 0004 8081      		ld r24,Z
 101 0006 8068      		ori r24,lo8(-128)
 102 0008 8083      		st Z,r24
  49:main.c        **** 
  50:main.c        **** 	ADCSRA |= (1 << ADPS0) | (1 << ADPS1) | (1 << ADPS2);		//frequency of discrediting = 125k Hz
 103               		.loc 1 50 2 is_stmt 1 view .LVU19
 104               		.loc 1 50 9 is_stmt 0 view .LVU20
 105 000a 8081      		ld r24,Z
 106 000c 8760      		ori r24,lo8(7)
 107 000e 8083      		st Z,r24
  51:main.c        **** 
  52:main.c        **** 	ADMUX &= ~((1 << REFS1) | (1 << REFS0));
 108               		.loc 1 52 2 is_stmt 1 view .LVU21
 109               		.loc 1 52 8 is_stmt 0 view .LVU22
 110 0010 ECE7      		ldi r30,lo8(124)
 111 0012 F0E0      		ldi r31,0
 112 0014 8081      		ld r24,Z
 113 0016 8F73      		andi r24,lo8(63)
 114 0018 8083      		st Z,r24
  53:main.c        **** 
  54:main.c        **** 	ADMUX &= ~(1 << ADLAR); 									//right-hand alignment
 115               		.loc 1 54 2 is_stmt 1 view .LVU23
 116               		.loc 1 54 8 is_stmt 0 view .LVU24
 117 001a 8081      		ld r24,Z
 118 001c 8F7D      		andi r24,lo8(-33)
 119 001e 8083      		st Z,r24
  55:main.c        **** 
  56:main.c        **** 	ADMUX &= ~((1 << MUX3) | (1 << MUX2) | (1 << MUX0));
 120               		.loc 1 56 2 is_stmt 1 view .LVU25
 121               		.loc 1 56 8 is_stmt 0 view .LVU26
 122 0020 8081      		ld r24,Z
 123 0022 827F      		andi r24,lo8(-14)
 124 0024 8083      		st Z,r24
  57:main.c        **** 	ADMUX |= (1 << MUX1);										//use ADC2
 125               		.loc 1 57 2 is_stmt 1 view .LVU27
 126               		.loc 1 57 8 is_stmt 0 view .LVU28
 127 0026 8081      		ld r24,Z
 128 0028 8260      		ori r24,lo8(2)
 129 002a 8083      		st Z,r24
 130               	/* epilogue start */
  58:main.c        **** }
 131               		.loc 1 58 1 view .LVU29
 132 002c 0895      		ret
 133               		.cfi_endproc
 134               	.LFE8:
 136               		.section	.text.ADC_convert,"ax",@progbits
 137               	.global	ADC_convert
 139               	ADC_convert:
 140               	.LFB9:
  59:main.c        **** 
  60:main.c        **** unsigned int
  61:main.c        **** ADC_convert (void)
  62:main.c        **** {
 141               		.loc 1 62 1 is_stmt 1 view -0
 142               		.cfi_startproc
 143               	/* prologue: function */
 144               	/* frame size = 0 */
 145               	/* stack size = 0 */
 146               	.L__stack_usage = 0
  63:main.c        **** 	ADCSRA |= (1 << ADSC);										//launch ADC
 147               		.loc 1 63 2 view .LVU31
 148               		.loc 1 63 9 is_stmt 0 view .LVU32
 149 0000 8091 7A00 		lds r24,122
 150 0004 8064      		ori r24,lo8(64)
 151 0006 8093 7A00 		sts 122,r24
  64:main.c        **** 	while((ADCSRA & (1<<ADSC)));
 152               		.loc 1 64 2 is_stmt 1 view .LVU33
 153               	.L5:
 154               		.loc 1 64 29 discriminator 1 view .LVU34
 155               		.loc 1 64 9 is_stmt 0 discriminator 1 view .LVU35
 156 000a 8091 7A00 		lds r24,122
 157               		.loc 1 64 7 discriminator 1 view .LVU36
 158 000e 86FD      		sbrc r24,6
 159 0010 00C0      		rjmp .L5
  65:main.c        **** 
  66:main.c        **** 	return (unsigned int) ADC;
 160               		.loc 1 66 2 is_stmt 1 view .LVU37
 161               		.loc 1 66 9 is_stmt 0 view .LVU38
 162 0012 8091 7800 		lds r24,120
 163 0016 9091 7900 		lds r25,120+1
 164               	/* epilogue start */
  67:main.c        **** }
 165               		.loc 1 67 1 view .LVU39
 166 001a 0895      		ret
 167               		.cfi_endproc
 168               	.LFE9:
 170               		.section	.text.startup.main,"ax",@progbits
 171               	.global	main
 173               	main:
 174               	.LFB10:
  68:main.c        **** 
  69:main.c        **** 
  70:main.c        **** int main( void )
  71:main.c        **** {
 175               		.loc 1 71 1 is_stmt 1 view -0
 176               		.cfi_startproc
 177               	/* prologue: function */
 178               	/* frame size = 0 */
 179               	/* stack size = 0 */
 180               	.L__stack_usage = 0
  72:main.c        **** 	DDRD |= (1 << 5) | (1 << 6) | (1 << 7);						//test ADC
 181               		.loc 1 72 2 view .LVU41
 182               		.loc 1 72 7 is_stmt 0 view .LVU42
 183 0000 8AB1      		in r24,0xa
 184 0002 806E      		ori r24,lo8(-32)
 185 0004 8AB9      		out 0xa,r24
  73:main.c        **** 	PORTD &= ~( (1 << 5) | (1 << 6) | (1 << 7) );
 186               		.loc 1 73 2 is_stmt 1 view .LVU43
 187               		.loc 1 73 8 is_stmt 0 view .LVU44
 188 0006 8BB1      		in r24,0xb
 189 0008 8F71      		andi r24,lo8(31)
 190 000a 8BB9      		out 0xb,r24
  74:main.c        **** 
  75:main.c        **** 	DDRC &= ~(1 << 2);											//working ADC port
 191               		.loc 1 75 2 is_stmt 1 view .LVU45
 192               		.loc 1 75 7 is_stmt 0 view .LVU46
 193 000c 3A98      		cbi 0x7,2
  76:main.c        **** 
  77:main.c        **** 	unsigned int adc_value;
 194               		.loc 1 77 2 is_stmt 1 view .LVU47
  78:main.c        **** 
  79:main.c        **** 
  80:main.c        **** //    uint16_t  timer = 0;
  81:main.c        **** //    char message[6][5] = {"FAUL", "HEAT", "COLD", "1234", " HI ", " LO "};
  82:main.c        **** //    char word[4];
  83:main.c        **** //    int8_t  j = 0;
  84:main.c        **** 
  85:main.c        **** 
  86:main.c        **** 
  87:main.c        ****     ind_init();
 195               		.loc 1 87 5 view .LVU48
 196 000e 0E94 0000 		call ind_init
 197               	.LVL0:
  88:main.c        ****     tim1_init();
 198               		.loc 1 88 5 view .LVU49
 199 0012 0E94 0000 		call tim1_init
 200               	.LVL1:
  89:main.c        ****     ADC_Init();
 201               		.loc 1 89 5 view .LVU50
 202 0016 0E94 0000 		call ADC_Init
 203               	.LVL2:
  90:main.c        **** 
  91:main.c        ****     sei();
 204               		.loc 1 91 5 view .LVU51
 205               	/* #APP */
 206               	 ;  91 "main.c" 1
 207 001a 7894      		sei
 208               	 ;  0 "" 2
 209               	/* #NOAPP */
 210               	.L8:
  92:main.c        **** 
  93:main.c        ****     while( 1 )
 211               		.loc 1 93 5 view .LVU52
  94:main.c        ****     {
  95:main.c        ****     	/*
  96:main.c        ****             for( int8_t i = 0; i < 4; i++ )
  97:main.c        ****             {
  98:main.c        ****                 word[i] = message[j][i];
  99:main.c        ****             }
 100:main.c        **** 
 101:main.c        **** 
 102:main.c        ****             if( timer_counter - timer >= 2000 )
 103:main.c        ****             {
 104:main.c        **** 
 105:main.c        ****                 timer = timer_counter;
 106:main.c        **** 
 107:main.c        ****                 j += 1;
 108:main.c        **** 
 109:main.c        ****                 if( j > 6 )
 110:main.c        ****                 {
 111:main.c        ****                     j = 0;
 112:main.c        ****                 }
 113:main.c        ****             }
 114:main.c        **** 
 115:main.c        ****             ind_print_string(word);
 116:main.c        **** //            led_timer();
 117:main.c        **** 
 118:main.c        ****     	 */
 119:main.c        ****     	adc_value = ADC_convert();
 212               		.loc 1 119 6 view .LVU53
 213               		.loc 1 119 18 is_stmt 0 view .LVU54
 214 001c 0E94 0000 		call ADC_convert
 215               	.LVL3:
 120:main.c        **** 
 121:main.c        **** 		if (adc_value > 307)
 216               		.loc 1 121 3 is_stmt 1 view .LVU55
 217               		.loc 1 121 6 is_stmt 0 view .LVU56
 218 0020 8433      		cpi r24,52
 219 0022 21E0      		ldi r18,1
 220 0024 9207      		cpc r25,r18
 221 0026 00F0      		brlo .L9
 122:main.c        **** 		{
 123:main.c        **** 			PORTD |= (1 << 5);
 222               		.loc 1 123 4 is_stmt 1 view .LVU57
 223               		.loc 1 123 10 is_stmt 0 view .LVU58
 224 0028 5D9A      		sbi 0xb,5
 124:main.c        **** 			PORTD &= ~((1 << 6) | (1 << 7));
 225               		.loc 1 124 4 is_stmt 1 view .LVU59
 226               		.loc 1 124 10 is_stmt 0 view .LVU60
 227 002a 8BB1      		in r24,0xb
 228               	.LVL4:
 229               		.loc 1 124 10 view .LVU61
 230 002c 8F73      		andi r24,lo8(63)
 231               	.L12:
 125:main.c        **** 		}
 126:main.c        **** 		else
 127:main.c        **** 		if (adc_value <= 307 && adc_value >= 266)
 128:main.c        **** 		{
 129:main.c        **** 			PORTD |= (1 << 6);
 130:main.c        **** 			PORTD &= ~((1 << 5) | (1 << 7));
 131:main.c        **** 		}
 132:main.c        **** 		else
 133:main.c        **** 		if (adc_value < 266)
 134:main.c        **** 		{
 135:main.c        **** 			PORTD |= (1 << 7);
 136:main.c        **** 			PORTD &= ~((1 << 5) | (1 << 6));
 232               		.loc 1 136 10 view .LVU62
 233 002e 8BB9      		out 0xb,r24
 234 0030 00C0      		rjmp .L8
 235               	.LVL5:
 236               	.L9:
 127:main.c        **** 		{
 237               		.loc 1 127 3 is_stmt 1 view .LVU63
 127:main.c        **** 		{
 238               		.loc 1 127 24 is_stmt 0 view .LVU64
 239 0032 8A50      		subi r24,10
 240 0034 9140      		sbci r25,1
 241               	.LVL6:
 127:main.c        **** 		{
 242               		.loc 1 127 6 view .LVU65
 243 0036 8A97      		sbiw r24,42
 244 0038 00F4      		brsh .L11
 129:main.c        **** 			PORTD &= ~((1 << 5) | (1 << 7));
 245               		.loc 1 129 4 is_stmt 1 view .LVU66
 129:main.c        **** 			PORTD &= ~((1 << 5) | (1 << 7));
 246               		.loc 1 129 10 is_stmt 0 view .LVU67
 247 003a 5E9A      		sbi 0xb,6
 130:main.c        **** 		}
 248               		.loc 1 130 4 is_stmt 1 view .LVU68
 130:main.c        **** 		}
 249               		.loc 1 130 10 is_stmt 0 view .LVU69
 250 003c 8BB1      		in r24,0xb
 251               	.LVL7:
 130:main.c        **** 		}
 252               		.loc 1 130 10 view .LVU70
 253 003e 8F75      		andi r24,lo8(95)
 254 0040 00C0      		rjmp .L12
 255               	.LVL8:
 256               	.L11:
 133:main.c        **** 		{
 257               		.loc 1 133 3 is_stmt 1 view .LVU71
 135:main.c        **** 			PORTD &= ~((1 << 5) | (1 << 6));
 258               		.loc 1 135 4 view .LVU72
 135:main.c        **** 			PORTD &= ~((1 << 5) | (1 << 6));
 259               		.loc 1 135 10 is_stmt 0 view .LVU73
 260 0042 5F9A      		sbi 0xb,7
 261               		.loc 1 136 4 is_stmt 1 view .LVU74
 262               		.loc 1 136 10 is_stmt 0 view .LVU75
 263 0044 8BB1      		in r24,0xb
 264               	.LVL9:
 265               		.loc 1 136 10 view .LVU76
 266 0046 8F79      		andi r24,lo8(-97)
 267 0048 00C0      		rjmp .L12
 268               		.cfi_endproc
 269               	.LFE10:
 271               		.section	.bss.timer_counter,"aw",@nobits
 274               	timer_counter:
 275 0000 0000      		.zero	2
 276               		.text
 277               	.Letext0:
 278               		.file 2 "c:\\bin\\avr-gcc-8.3.0-x64-mingw\\lib\\gcc\\avr\\8.3.0\\include\\stdint-gcc.h"
 279               		.file 3 "./drivers/indicator.h"
DEFINED SYMBOLS
                            *ABS*:0000000000000000 main.c
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccbgUqo1.s:2      *ABS*:000000000000003e __SP_H__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccbgUqo1.s:3      *ABS*:000000000000003d __SP_L__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccbgUqo1.s:4      *ABS*:000000000000003f __SREG__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccbgUqo1.s:5      *ABS*:0000000000000000 __tmp_reg__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccbgUqo1.s:6      *ABS*:0000000000000001 __zero_reg__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccbgUqo1.s:13     .text.__vector_11:0000000000000000 __vector_11
                            *ABS*:0000000000000002 __gcc_isr.n_pushed.001
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccbgUqo1.s:274    .bss.timer_counter:0000000000000000 timer_counter
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccbgUqo1.s:46     .text.tim1_init:0000000000000000 tim1_init
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccbgUqo1.s:88     .text.ADC_Init:0000000000000000 ADC_Init
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccbgUqo1.s:139    .text.ADC_convert:0000000000000000 ADC_convert
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccbgUqo1.s:173    .text.startup.main:0000000000000000 main

UNDEFINED SYMBOLS
ind_init
__do_clear_bss

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
  85               		.section	.text.startup.main,"ax",@progbits
  86               	.global	main
  88               	main:
  89               	.LFB8:
  43:main.c        **** 
  44:main.c        **** 
  45:main.c        **** 
  46:main.c        **** int main( void )
  47:main.c        **** {
  90               		.loc 1 47 1 is_stmt 1 view -0
  91               		.cfi_startproc
  92               	/* prologue: function */
  93               	/* frame size = 0 */
  94               	/* stack size = 0 */
  95               	.L__stack_usage = 0
  48:main.c        **** 	DDRD |= (1 << 5) | (1 << 6) | (1 << 7);						//test ADC
  96               		.loc 1 48 2 view .LVU17
  97               		.loc 1 48 7 is_stmt 0 view .LVU18
  98 0000 8AB1      		in r24,0xa
  99 0002 806E      		ori r24,lo8(-32)
 100 0004 8AB9      		out 0xa,r24
  49:main.c        **** 	PORTD &= ~( (1 << 5) | (1 << 6) | (1 << 7) );
 101               		.loc 1 49 2 is_stmt 1 view .LVU19
 102               		.loc 1 49 8 is_stmt 0 view .LVU20
 103 0006 8BB1      		in r24,0xb
 104 0008 8F71      		andi r24,lo8(31)
 105 000a 8BB9      		out 0xb,r24
  50:main.c        **** 
  51:main.c        **** 	DDRC &= ~(1 << 2);											//working ADC port
 106               		.loc 1 51 2 is_stmt 1 view .LVU21
 107               		.loc 1 51 7 is_stmt 0 view .LVU22
 108 000c 3A98      		cbi 0x7,2
  52:main.c        **** 
  53:main.c        **** 	ADCSRA |= (1 << ADEN);										//we allow the ADC to work
 109               		.loc 1 53 2 is_stmt 1 view .LVU23
 110               		.loc 1 53 9 is_stmt 0 view .LVU24
 111 000e 8091 7A00 		lds r24,122
 112 0012 8068      		ori r24,lo8(-128)
 113 0014 8093 7A00 		sts 122,r24
  54:main.c        **** 	ADCSRA |= (1 << ACSR);										//continuous transformation   //?ADFR
 114               		.loc 1 54 2 is_stmt 1 view .LVU25
 115               		.loc 1 54 18 is_stmt 0 view .LVU26
 116 0018 90B7      		in r25,0x30
 117               		.loc 1 54 9 view .LVU27
 118 001a 8091 7A00 		lds r24,122
 119               		.loc 1 54 15 view .LVU28
 120 001e 21E0      		ldi r18,lo8(1)
 121 0020 30E0      		ldi r19,0
 122 0022 00C0      		rjmp 2f
 123               		1:
 124 0024 220F      		lsl r18
 125               		2:
 126 0026 9A95      		dec r25
 127 0028 02F4      		brpl 1b
 128               		.loc 1 54 9 view .LVU29
 129 002a 822B      		or r24,r18
 130 002c 8093 7A00 		sts 122,r24
  55:main.c        **** 	ADCSRA |= (1 << ADPS0) | (1 << ADPS1) | (1 << ADPS2);		//frequency of discrediting = 125k Hz
 131               		.loc 1 55 2 is_stmt 1 view .LVU30
 132               		.loc 1 55 9 is_stmt 0 view .LVU31
 133 0030 8091 7A00 		lds r24,122
 134 0034 8760      		ori r24,lo8(7)
 135 0036 8093 7A00 		sts 122,r24
  56:main.c        **** 
  57:main.c        **** 	ADMUX |= (1 << REFS1) | (1 << REFS0);						//Internal 2.56 V reference
 136               		.loc 1 57 2 is_stmt 1 view .LVU32
 137               		.loc 1 57 8 is_stmt 0 view .LVU33
 138 003a 8091 7C00 		lds r24,124
 139 003e 806C      		ori r24,lo8(-64)
 140 0040 8093 7C00 		sts 124,r24
  58:main.c        **** 	ADMUX &= ~(1 << ADLAR); 									//right-hand alignment
 141               		.loc 1 58 2 is_stmt 1 view .LVU34
 142               		.loc 1 58 8 is_stmt 0 view .LVU35
 143 0044 8091 7C00 		lds r24,124
 144 0048 8F7D      		andi r24,lo8(-33)
 145 004a 8093 7C00 		sts 124,r24
  59:main.c        **** 
  60:main.c        **** 	ADMUX &= ~((1 << MUX3) | (1 << MUX2) | (1 << MUX0));
 146               		.loc 1 60 2 is_stmt 1 view .LVU36
 147               		.loc 1 60 8 is_stmt 0 view .LVU37
 148 004e 8091 7C00 		lds r24,124
 149 0052 827F      		andi r24,lo8(-14)
 150 0054 8093 7C00 		sts 124,r24
  61:main.c        **** 	ADMUX |= (1 << MUX1);										//use ADC2
 151               		.loc 1 61 2 is_stmt 1 view .LVU38
 152               		.loc 1 61 8 is_stmt 0 view .LVU39
 153 0058 8091 7C00 		lds r24,124
 154 005c 8260      		ori r24,lo8(2)
 155 005e 8093 7C00 		sts 124,r24
  62:main.c        **** 
  63:main.c        **** 	ADCSRA |= (1 << ADSC);										//launch ADC
 156               		.loc 1 63 2 is_stmt 1 view .LVU40
 157               		.loc 1 63 9 is_stmt 0 view .LVU41
 158 0062 8091 7A00 		lds r24,122
 159 0066 8064      		ori r24,lo8(64)
 160 0068 8093 7A00 		sts 122,r24
  64:main.c        **** 
  65:main.c        **** //    uint16_t  timer = 0;
  66:main.c        **** //    char message[6][5] = {"FAUL", "HEAT", "COLD", "1234", " HI ", " LO "};
  67:main.c        **** //    char word[4];
  68:main.c        **** //    int8_t  j = 0;
  69:main.c        **** 
  70:main.c        **** 
  71:main.c        **** 
  72:main.c        ****     ind_init();
 161               		.loc 1 72 5 is_stmt 1 view .LVU42
 162 006c 0E94 0000 		call ind_init
 163               	.LVL0:
  73:main.c        ****     tim1_init();
 164               		.loc 1 73 5 view .LVU43
 165 0070 0E94 0000 		call tim1_init
 166               	.LVL1:
  74:main.c        **** 
  75:main.c        ****     sei();
 167               		.loc 1 75 5 view .LVU44
 168               	/* #APP */
 169               	 ;  75 "main.c" 1
 170 0074 7894      		sei
 171               	 ;  0 "" 2
 172               	/* #NOAPP */
 173               	.L4:
  76:main.c        **** 
  77:main.c        ****     while( 1 )
 174               		.loc 1 77 5 view .LVU45
  78:main.c        ****     {
  79:main.c        ****     	/*
  80:main.c        ****             for( int8_t i = 0; i < 4; i++ )
  81:main.c        ****             {
  82:main.c        ****                 word[i] = message[j][i];
  83:main.c        ****             }
  84:main.c        **** 
  85:main.c        **** 
  86:main.c        ****             if( timer_counter - timer >= 2000 )
  87:main.c        ****             {
  88:main.c        **** 
  89:main.c        ****                 timer = timer_counter;
  90:main.c        **** 
  91:main.c        ****                 j += 1;
  92:main.c        **** 
  93:main.c        ****                 if( j > 6 )
  94:main.c        ****                 {
  95:main.c        ****                     j = 0;
  96:main.c        ****                 }
  97:main.c        ****             }
  98:main.c        **** 
  99:main.c        ****             ind_print_string(word);
 100:main.c        **** //            led_timer();
 101:main.c        **** 
 102:main.c        ****     	 */
 103:main.c        ****     	if (ADCSRA & (1 << 4))
 175               		.loc 1 103 6 view .LVU46
 176               		.loc 1 103 10 is_stmt 0 view .LVU47
 177 0076 8091 7A00 		lds r24,122
 178               		.loc 1 103 9 view .LVU48
 179 007a 84FF      		sbrs r24,4
 180 007c 00C0      		rjmp .L4
 104:main.c        ****     	{
 105:main.c        ****     		if (ADC >= 600)
 181               		.loc 1 105 7 is_stmt 1 view .LVU49
 182               		.loc 1 105 11 is_stmt 0 view .LVU50
 183 007e 8091 7800 		lds r24,120
 184 0082 9091 7900 		lds r25,120+1
 185               		.loc 1 105 10 view .LVU51
 186 0086 8835      		cpi r24,88
 187 0088 9240      		sbci r25,2
 188 008a 00F0      		brlo .L5
 106:main.c        ****     		{
 107:main.c        ****     			PORTD |= (1 << 5);
 189               		.loc 1 107 8 is_stmt 1 view .LVU52
 190               		.loc 1 107 14 is_stmt 0 view .LVU53
 191 008c 5D9A      		sbi 0xb,5
 108:main.c        ****     			PORTD &= ~((1 << 6) | (1 << 7));
 192               		.loc 1 108 8 is_stmt 1 view .LVU54
 193               		.loc 1 108 14 is_stmt 0 view .LVU55
 194 008e 8BB1      		in r24,0xb
 195 0090 8F73      		andi r24,lo8(63)
 196 0092 8BB9      		out 0xb,r24
 197               	.L5:
 109:main.c        ****     		}
 110:main.c        ****     		if (ADC >= 600 && ADC < 520)
 198               		.loc 1 110 7 is_stmt 1 view .LVU56
 199               		.loc 1 110 11 is_stmt 0 view .LVU57
 200 0094 8091 7800 		lds r24,120
 201 0098 9091 7900 		lds r25,120+1
 202               		.loc 1 110 10 view .LVU58
 203 009c 8835      		cpi r24,88
 204 009e 9240      		sbci r25,2
 205 00a0 00F0      		brlo .L6
 206               		.loc 1 110 25 discriminator 1 view .LVU59
 207 00a2 8091 7800 		lds r24,120
 208 00a6 9091 7900 		lds r25,120+1
 209               		.loc 1 110 22 discriminator 1 view .LVU60
 210 00aa 8830      		cpi r24,8
 211 00ac 9240      		sbci r25,2
 212 00ae 00F4      		brsh .L6
 111:main.c        ****     		{
 112:main.c        ****     			PORTD |= (1 << 6);
 213               		.loc 1 112 8 is_stmt 1 view .LVU61
 214               		.loc 1 112 14 is_stmt 0 view .LVU62
 215 00b0 5E9A      		sbi 0xb,6
 113:main.c        ****     			PORTD &= ~((1 << 5) | (1 << 7));
 216               		.loc 1 113 8 is_stmt 1 view .LVU63
 217               		.loc 1 113 14 is_stmt 0 view .LVU64
 218 00b2 8BB1      		in r24,0xb
 219 00b4 8F75      		andi r24,lo8(95)
 220 00b6 8BB9      		out 0xb,r24
 221               	.L6:
 114:main.c        ****     		}
 115:main.c        ****     		if (ADC < 520)
 222               		.loc 1 115 7 is_stmt 1 view .LVU65
 223               		.loc 1 115 11 is_stmt 0 view .LVU66
 224 00b8 8091 7800 		lds r24,120
 225 00bc 9091 7900 		lds r25,120+1
 226               		.loc 1 115 10 view .LVU67
 227 00c0 8830      		cpi r24,8
 228 00c2 9240      		sbci r25,2
 229 00c4 00F4      		brsh .L7
 116:main.c        ****     		{
 117:main.c        ****     			PORTD |= (1 << 7);
 230               		.loc 1 117 8 is_stmt 1 view .LVU68
 231               		.loc 1 117 14 is_stmt 0 view .LVU69
 232 00c6 5F9A      		sbi 0xb,7
 118:main.c        ****     			PORTD &= ~((1 << 5) | (1 << 6));
 233               		.loc 1 118 8 is_stmt 1 view .LVU70
 234               		.loc 1 118 14 is_stmt 0 view .LVU71
 235 00c8 8BB1      		in r24,0xb
 236 00ca 8F79      		andi r24,lo8(-97)
 237 00cc 8BB9      		out 0xb,r24
 238               	.L7:
 119:main.c        ****     		}
 120:main.c        **** 
 121:main.c        ****     		ADCSRA |= (1 << 4);
 239               		.loc 1 121 7 is_stmt 1 view .LVU72
 240               		.loc 1 121 14 is_stmt 0 view .LVU73
 241 00ce 8091 7A00 		lds r24,122
 242 00d2 8061      		ori r24,lo8(16)
 243 00d4 8093 7A00 		sts 122,r24
 244 00d8 00C0      		rjmp .L4
 245               		.cfi_endproc
 246               	.LFE8:
 248               		.section	.bss.timer_counter,"aw",@nobits
 251               	timer_counter:
 252 0000 0000      		.zero	2
 253               		.text
 254               	.Letext0:
 255               		.file 2 "c:\\bin\\avr-gcc-8.3.0-x64-mingw\\lib\\gcc\\avr\\8.3.0\\include\\stdint-gcc.h"
 256               		.file 3 "./drivers/indicator.h"
DEFINED SYMBOLS
                            *ABS*:0000000000000000 main.c
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccMKaxVx.s:2      *ABS*:000000000000003e __SP_H__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccMKaxVx.s:3      *ABS*:000000000000003d __SP_L__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccMKaxVx.s:4      *ABS*:000000000000003f __SREG__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccMKaxVx.s:5      *ABS*:0000000000000000 __tmp_reg__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccMKaxVx.s:6      *ABS*:0000000000000001 __zero_reg__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccMKaxVx.s:13     .text.__vector_11:0000000000000000 __vector_11
                            *ABS*:0000000000000002 __gcc_isr.n_pushed.001
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccMKaxVx.s:251    .bss.timer_counter:0000000000000000 timer_counter
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccMKaxVx.s:46     .text.tim1_init:0000000000000000 tim1_init
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccMKaxVx.s:88     .text.startup.main:0000000000000000 main

UNDEFINED SYMBOLS
ind_init
__do_clear_bss

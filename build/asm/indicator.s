   1               		.file	"indicator.c"
   2               	__SP_H__ = 0x3e
   3               	__SP_L__ = 0x3d
   4               	__SREG__ = 0x3f
   5               	__tmp_reg__ = 0
   6               	__zero_reg__ = 1
   7               		.text
   8               	.Ltext0:
   9               		.cfi_sections	.debug_frame
  10               		.section	.text.clock_signal,"ax",@progbits
  12               	clock_signal:
  13               	.LFB5:
  14               		.file 1 "drivers/indicator.c"
   1:drivers/indicator.c **** 
   2:drivers/indicator.c **** #include <inttypes.h>
   3:drivers/indicator.c **** #include <avr/io.h>
   4:drivers/indicator.c **** #include <avr/interrupt.h>
   5:drivers/indicator.c **** 
   6:drivers/indicator.c **** #include "indicator.h"
   7:drivers/indicator.c **** 
   8:drivers/indicator.c **** 
   9:drivers/indicator.c **** #define IND_PORT                    PORTD
  10:drivers/indicator.c **** 
  11:drivers/indicator.c **** #define CLK                         PD2  // clock
  12:drivers/indicator.c **** #define DAT0                        PD3  // data
  13:drivers/indicator.c **** #define WRT                         PD4  // Enter
  14:drivers/indicator.c **** 
  15:drivers/indicator.c **** #define IND_PORTIN                  PIND
  16:drivers/indicator.c **** 
  17:drivers/indicator.c **** static const uint8_t ind_ascii_table[/* 65 */] =
  18:drivers/indicator.c **** {
  19:drivers/indicator.c ****         0xff /*   */, 0x79 /* ! */, 0xdd /* " */, 0x9d /* # */,
  20:drivers/indicator.c ****         0x93 /* $ */, 0xad /* % */, 0xe3 /* & */, 0xfd /* ' */,
  21:drivers/indicator.c ****         0xc6 /* ( */, 0xf0 /* ) */, 0x9c /* * */, 0xb9 /* + */,
  22:drivers/indicator.c ****         0x7f /* , */, 0xbf /* - */, 0x7f /* . */, 0xad /* / */,
  23:drivers/indicator.c ****         0xc0 /* 0 */, 0xf9 /* 1 */, 0xa4 /* 2 */, 0xb0 /* 3 */,
  24:drivers/indicator.c ****         0x99 /* 4 */, 0x92 /* 5 */, 0x82 /* 6 */, 0xf8 /* 7 */,
  25:drivers/indicator.c ****         0x80 /* 8 */, 0x90 /* 9 */,
  26:drivers/indicator.c **** 
  27:drivers/indicator.c ****         0x00 /* : */, 0x00 /* ; */, 0x00 /* < */, 0xb7 /* = */,
  28:drivers/indicator.c ****         0x00 /* > */, 0x3c /* ? */, 0x30 /* @ */,
  29:drivers/indicator.c **** 
  30:drivers/indicator.c ****         0x88 /* A */, 0x83 /* B */, 0xc6 /* C */, 0xa1 /* d */,
  31:drivers/indicator.c ****         0x86 /* E */, 0x8e /* F */, 0xc3 /* G */, 0x89 /* H */,
  32:drivers/indicator.c ****         0xcf /* I */, 0xe1 /* J */, 0x8a /* K */, 0xc7 /* L */,
  33:drivers/indicator.c ****         0x8d /* M */, 0xab /* N */, 0xc0 /* O */, 0x8c /* P */,
  34:drivers/indicator.c ****         0x98 /* Q */, 0xaf /* R */, 0x92 /* S */, 0x87 /* T */,
  35:drivers/indicator.c ****         0xc1 /* U */, 0xe1 /* V */, 0xff /* W */, 0xb6 /* X */,
  36:drivers/indicator.c ****         0x91 /* Y */, 0xb7 /* Z */,
  37:drivers/indicator.c **** 
  38:drivers/indicator.c ****         0xa7 /* [ */, 0x9b /* \ */, 0xb3 /* ] */, 0xfe /* ^ */,
  39:drivers/indicator.c ****         0xf7 /* _ */, 0x9f /* ` */,
  40:drivers/indicator.c **** };
  41:drivers/indicator.c **** 
  42:drivers/indicator.c **** static uint8_t  indicator_data[4];
  43:drivers/indicator.c **** static uint8_t  ind_led_state;
  44:drivers/indicator.c **** 
  45:drivers/indicator.c **** 
  46:drivers/indicator.c **** 
  47:drivers/indicator.c **** /*
  48:drivers/indicator.c ****  * return 1 if button pressed, 0 if button state don`t pressed
  49:drivers/indicator.c ****  */
  50:drivers/indicator.c **** 
  51:drivers/indicator.c **** 
  52:drivers/indicator.c **** uint8_t
  53:drivers/indicator.c **** button_state_get( void )
  54:drivers/indicator.c **** {
  55:drivers/indicator.c **** 	uint8_t btn_state;
  56:drivers/indicator.c **** 
  57:drivers/indicator.c **** 	btn_state = (PIND & (1 << 3)) ? 1 : 0;
  58:drivers/indicator.c **** 
  59:drivers/indicator.c **** 	return btn_state;
  60:drivers/indicator.c **** 
  61:drivers/indicator.c **** }
  62:drivers/indicator.c **** 
  63:drivers/indicator.c **** void
  64:drivers/indicator.c **** ind_led_set( uint8_t led, int8_t state )
  65:drivers/indicator.c **** {
  66:drivers/indicator.c ****     if ( state )
  67:drivers/indicator.c ****         ind_led_state |= (1 << led);
  68:drivers/indicator.c ****     else
  69:drivers/indicator.c ****         ind_led_state &= ~(1 << led);
  70:drivers/indicator.c **** }
  71:drivers/indicator.c **** 
  72:drivers/indicator.c **** 
  73:drivers/indicator.c **** void
  74:drivers/indicator.c **** ind_print_string( char * number )
  75:drivers/indicator.c **** {
  76:drivers/indicator.c **** 
  77:drivers/indicator.c ****     for ( int8_t i = 0; i < 4; i++ )
  78:drivers/indicator.c ****     {
  79:drivers/indicator.c ****         indicator_data[i] = ind_ascii_table[ number [i] - 32];
  80:drivers/indicator.c ****     }
  81:drivers/indicator.c **** 
  82:drivers/indicator.c **** }
  83:drivers/indicator.c **** 
  84:drivers/indicator.c **** 
  85:drivers/indicator.c **** static int8_t
  86:drivers/indicator.c **** ind_number_step_get( int16_t x )
  87:drivers/indicator.c **** {
  88:drivers/indicator.c ****     int8_t  step = 3;
  89:drivers/indicator.c **** 
  90:drivers/indicator.c ****     if( x < 1000 )
  91:drivers/indicator.c ****         step = 3;
  92:drivers/indicator.c ****     if( x < 100 )
  93:drivers/indicator.c ****         step = 2;
  94:drivers/indicator.c ****     if( x < 10 )
  95:drivers/indicator.c ****         step = 1;
  96:drivers/indicator.c **** 
  97:drivers/indicator.c ****     return step;
  98:drivers/indicator.c **** }
  99:drivers/indicator.c **** 
 100:drivers/indicator.c **** 
 101:drivers/indicator.c **** void
 102:drivers/indicator.c **** ind_print_dec( uint16_t number )
 103:drivers/indicator.c **** {
 104:drivers/indicator.c ****     uint8_t  string[4];
 105:drivers/indicator.c ****     uint8_t step;
 106:drivers/indicator.c **** 
 107:drivers/indicator.c ****     string[0] = number / 1000;
 108:drivers/indicator.c ****     string[1] = number % 1000 / 100;
 109:drivers/indicator.c ****     string[2] = number % 100 / 10;
 110:drivers/indicator.c ****     string[3] = number % 10;
 111:drivers/indicator.c **** 
 112:drivers/indicator.c ****     step = ind_number_step_get(number);
 113:drivers/indicator.c ****     step = 4 - step;
 114:drivers/indicator.c **** 
 115:drivers/indicator.c **** 
 116:drivers/indicator.c ****     for( int8_t i = 0; i < 4; i++ )
 117:drivers/indicator.c ****     {
 118:drivers/indicator.c ****         if( i < step )
 119:drivers/indicator.c ****         {
 120:drivers/indicator.c ****             string[i] = ind_ascii_table[0];
 121:drivers/indicator.c ****         }
 122:drivers/indicator.c ****         else
 123:drivers/indicator.c ****         {
 124:drivers/indicator.c ****             string[i] = ind_ascii_table[string[i]+16];
 125:drivers/indicator.c ****         }
 126:drivers/indicator.c **** 
 127:drivers/indicator.c **** 
 128:drivers/indicator.c ****  //       string[i] += 48;
 129:drivers/indicator.c ****     }
 130:drivers/indicator.c **** 
 131:drivers/indicator.c **** 
 132:drivers/indicator.c ****     for( int8_t i = 0; i < 4; i++ )
 133:drivers/indicator.c ****     {
 134:drivers/indicator.c ****         indicator_data[i] = string[i];
 135:drivers/indicator.c ****     }
 136:drivers/indicator.c **** }
 137:drivers/indicator.c **** 
 138:drivers/indicator.c **** 
 139:drivers/indicator.c **** static void
 140:drivers/indicator.c **** clock_signal(void)
 141:drivers/indicator.c **** {
  15               		.loc 1 141 1 view -0
  16               		.cfi_startproc
  17               	/* prologue: function */
  18               	/* frame size = 0 */
  19               	/* stack size = 0 */
  20               	.L__stack_usage = 0
 142:drivers/indicator.c **** 	   IND_PORT &= ~(1<<CLK);
  21               		.loc 1 142 5 view .LVU1
  22               		.loc 1 142 14 is_stmt 0 view .LVU2
  23 0000 5A98      		cbi 0xb,2
 143:drivers/indicator.c **** 	   __asm volatile("nop");
  24               		.loc 1 143 5 is_stmt 1 view .LVU3
  25               	/* #APP */
  26               	 ;  143 "drivers/indicator.c" 1
  27 0002 0000      		nop
  28               	 ;  0 "" 2
 144:drivers/indicator.c **** 	   __asm volatile("nop");
  29               		.loc 1 144 5 view .LVU4
  30               	 ;  144 "drivers/indicator.c" 1
  31 0004 0000      		nop
  32               	 ;  0 "" 2
 145:drivers/indicator.c **** 	   __asm volatile("nop");
  33               		.loc 1 145 5 view .LVU5
  34               	 ;  145 "drivers/indicator.c" 1
  35 0006 0000      		nop
  36               	 ;  0 "" 2
 146:drivers/indicator.c **** 	   __asm volatile("nop");
  37               		.loc 1 146 5 view .LVU6
  38               	 ;  146 "drivers/indicator.c" 1
  39 0008 0000      		nop
  40               	 ;  0 "" 2
 147:drivers/indicator.c **** 	   IND_PORT |= (1<<CLK);
  41               		.loc 1 147 5 view .LVU7
  42               		.loc 1 147 14 is_stmt 0 view .LVU8
  43               	/* #NOAPP */
  44 000a 5A9A      		sbi 0xb,2
  45               	/* epilogue start */
 148:drivers/indicator.c **** }
  46               		.loc 1 148 1 view .LVU9
  47 000c 0895      		ret
  48               		.cfi_endproc
  49               	.LFE5:
  51               		.section	.text.button_state_get,"ax",@progbits
  52               	.global	button_state_get
  54               	button_state_get:
  55               	.LFB0:
  54:drivers/indicator.c **** 	uint8_t btn_state;
  56               		.loc 1 54 1 is_stmt 1 view -0
  57               		.cfi_startproc
  58               	/* prologue: function */
  59               	/* frame size = 0 */
  60               	/* stack size = 0 */
  61               	.L__stack_usage = 0
  55:drivers/indicator.c **** 
  62               		.loc 1 55 2 view .LVU11
  57:drivers/indicator.c **** 
  63               		.loc 1 57 2 view .LVU12
  57:drivers/indicator.c **** 
  64               		.loc 1 57 15 is_stmt 0 view .LVU13
  65 0000 89B1      		in r24,0x9
  66               	.LVL0:
  59:drivers/indicator.c **** 
  67               		.loc 1 59 2 is_stmt 1 view .LVU14
  61:drivers/indicator.c **** 
  68               		.loc 1 61 1 is_stmt 0 view .LVU15
  69 0002 83FB      		bst r24,3
  70 0004 8827      		clr r24
  71 0006 80F9      		bld r24,0
  72               	.LVL1:
  73               	/* epilogue start */
  61:drivers/indicator.c **** 
  74               		.loc 1 61 1 view .LVU16
  75 0008 0895      		ret
  76               		.cfi_endproc
  77               	.LFE0:
  79               		.section	.text.ind_led_set,"ax",@progbits
  80               	.global	ind_led_set
  82               	ind_led_set:
  83               	.LVL2:
  84               	.LFB1:
  65:drivers/indicator.c ****     if ( state )
  85               		.loc 1 65 1 is_stmt 1 view -0
  86               		.cfi_startproc
  87               	/* prologue: function */
  88               	/* frame size = 0 */
  89               	/* stack size = 0 */
  90               	.L__stack_usage = 0
  66:drivers/indicator.c ****         ind_led_state |= (1 << led);
  91               		.loc 1 66 5 view .LVU18
  92 0000 21E0      		ldi r18,lo8(1)
  93 0002 30E0      		ldi r19,0
  94 0004 A901      		movw r20,r18
  95 0006 00C0      		rjmp 2f
  96               		1:
  97 0008 440F      		lsl r20
  98 000a 551F      		rol r21
  99               		2:
 100 000c 8A95      		dec r24
 101 000e 02F4      		brpl 1b
 102 0010 CA01      		movw r24,r20
 103               	.LVL3:
  66:drivers/indicator.c ****         ind_led_state |= (1 << led);
 104               		.loc 1 66 5 is_stmt 0 view .LVU19
 105 0012 2091 0000 		lds r18,ind_led_state
  66:drivers/indicator.c ****         ind_led_state |= (1 << led);
 106               		.loc 1 66 8 view .LVU20
 107 0016 6623      		tst r22
 108 0018 01F0      		breq .L4
  67:drivers/indicator.c ****     else
 109               		.loc 1 67 9 is_stmt 1 view .LVU21
  67:drivers/indicator.c ****     else
 110               		.loc 1 67 23 is_stmt 0 view .LVU22
 111 001a 822B      		or r24,r18
 112               	.L6:
  69:drivers/indicator.c **** }
 113               		.loc 1 69 23 view .LVU23
 114 001c 8093 0000 		sts ind_led_state,r24
 115               	/* epilogue start */
  70:drivers/indicator.c **** 
 116               		.loc 1 70 1 view .LVU24
 117 0020 0895      		ret
 118               	.L4:
  69:drivers/indicator.c **** }
 119               		.loc 1 69 9 is_stmt 1 view .LVU25
  69:drivers/indicator.c **** }
 120               		.loc 1 69 23 is_stmt 0 view .LVU26
 121 0022 8095      		com r24
 122 0024 8223      		and r24,r18
 123 0026 00C0      		rjmp .L6
 124               		.cfi_endproc
 125               	.LFE1:
 127               		.section	.text.ind_print_string,"ax",@progbits
 128               	.global	ind_print_string
 130               	ind_print_string:
 131               	.LVL4:
 132               	.LFB2:
  75:drivers/indicator.c **** 
 133               		.loc 1 75 1 is_stmt 1 view -0
 134               		.cfi_startproc
  75:drivers/indicator.c **** 
 135               		.loc 1 75 1 is_stmt 0 view .LVU28
 136 0000 CF93      		push r28
 137               	.LCFI0:
 138               		.cfi_def_cfa_offset 3
 139               		.cfi_offset 28, -2
 140 0002 DF93      		push r29
 141               	.LCFI1:
 142               		.cfi_def_cfa_offset 4
 143               		.cfi_offset 29, -3
 144               	/* prologue: function */
 145               	/* frame size = 0 */
 146               	/* stack size = 2 */
 147               	.L__stack_usage = 2
  77:drivers/indicator.c ****     {
 148               		.loc 1 77 5 is_stmt 1 view .LVU29
 149               	.LBB2:
  77:drivers/indicator.c ****     {
 150               		.loc 1 77 11 view .LVU30
 151               	.LVL5:
  77:drivers/indicator.c ****     {
 152               		.loc 1 77 11 is_stmt 0 view .LVU31
 153 0004 A0E0      		ldi r26,lo8(indicator_data)
 154 0006 B0E0      		ldi r27,hi8(indicator_data)
 155 0008 9C01      		movw r18,r24
 156 000a 2C5F      		subi r18,-4
 157 000c 3F4F      		sbci r19,-1
 158               	.LVL6:
 159               	.L8:
  79:drivers/indicator.c ****     }
 160               		.loc 1 79 9 is_stmt 1 discriminator 3 view .LVU32
  79:drivers/indicator.c ****     }
 161               		.loc 1 79 53 is_stmt 0 discriminator 3 view .LVU33
 162 000e EC01      		movw r28,r24
 163 0010 E991      		ld r30,Y+
 164 0012 CE01      		movw r24,r28
 165               	.LVL7:
  79:drivers/indicator.c ****     }
 166               		.loc 1 79 53 discriminator 3 view .LVU34
 167 0014 F0E0      		ldi r31,0
  79:drivers/indicator.c ****     }
 168               		.loc 1 79 44 discriminator 3 view .LVU35
 169 0016 E050      		subi r30,lo8(-(ind_ascii_table-32))
 170 0018 F040      		sbci r31,hi8(-(ind_ascii_table-32))
  79:drivers/indicator.c ****     }
 171               		.loc 1 79 27 discriminator 3 view .LVU36
 172 001a 4081      		ld r20,Z
 173 001c 4D93      		st X+,r20
 174               	.LVL8:
  77:drivers/indicator.c ****     {
 175               		.loc 1 77 5 discriminator 3 view .LVU37
 176 001e C217      		cp r28,r18
 177 0020 D307      		cpc r29,r19
 178 0022 01F4      		brne .L8
 179               	/* epilogue start */
 180               	.LBE2:
  82:drivers/indicator.c **** 
 181               		.loc 1 82 1 view .LVU38
 182 0024 DF91      		pop r29
 183 0026 CF91      		pop r28
 184 0028 0895      		ret
 185               		.cfi_endproc
 186               	.LFE2:
 188               		.section	.text.ind_print_dec,"ax",@progbits
 189               	.global	ind_print_dec
 191               	ind_print_dec:
 192               	.LVL9:
 193               	.LFB4:
 103:drivers/indicator.c ****     uint8_t  string[4];
 194               		.loc 1 103 1 is_stmt 1 view -0
 195               		.cfi_startproc
 103:drivers/indicator.c ****     uint8_t  string[4];
 196               		.loc 1 103 1 is_stmt 0 view .LVU40
 197 0000 A4E0      		ldi r26,lo8(4)
 198 0002 B0E0      		ldi r27,0
 199 0004 E0E0      		ldi r30,lo8(gs(1f))
 200 0006 F0E0      		ldi r31,hi8(gs(1f))
 201 0008 0C94 0000 		jmp __prologue_saves__+((18 - 2) * 2)
 202               	1:
 203               	.LCFI2:
 204               		.cfi_offset 28, -2
 205               		.cfi_offset 29, -3
 206               		.cfi_def_cfa 28, 8
 207               	/* prologue: function */
 208               	/* frame size = 4 */
 209               	/* stack size = 6 */
 210               	.L__stack_usage = 6
 211 000c 9C01      		movw r18,r24
 104:drivers/indicator.c ****     uint8_t step;
 212               		.loc 1 104 5 is_stmt 1 view .LVU41
 105:drivers/indicator.c **** 
 213               		.loc 1 105 5 view .LVU42
 107:drivers/indicator.c ****     string[1] = number % 1000 / 100;
 214               		.loc 1 107 5 view .LVU43
 107:drivers/indicator.c ****     string[1] = number % 1000 / 100;
 215               		.loc 1 107 24 is_stmt 0 view .LVU44
 216 000e 68EE      		ldi r22,lo8(-24)
 217 0010 73E0      		ldi r23,lo8(3)
 218 0012 0E94 0000 		call __udivmodhi4
 219               	.LVL10:
 107:drivers/indicator.c ****     string[1] = number % 1000 / 100;
 220               		.loc 1 107 15 view .LVU45
 221 0016 6983      		std Y+1,r22
 108:drivers/indicator.c ****     string[2] = number % 100 / 10;
 222               		.loc 1 108 5 is_stmt 1 view .LVU46
 108:drivers/indicator.c ****     string[2] = number % 100 / 10;
 223               		.loc 1 108 31 is_stmt 0 view .LVU47
 224 0018 E4E6      		ldi r30,lo8(100)
 225 001a F0E0      		ldi r31,0
 226 001c BF01      		movw r22,r30
 227 001e 0E94 0000 		call __udivmodhi4
 108:drivers/indicator.c ****     string[2] = number % 100 / 10;
 228               		.loc 1 108 15 view .LVU48
 229 0022 6A83      		std Y+2,r22
 109:drivers/indicator.c ****     string[3] = number % 10;
 230               		.loc 1 109 5 is_stmt 1 view .LVU49
 109:drivers/indicator.c ****     string[3] = number % 10;
 231               		.loc 1 109 24 is_stmt 0 view .LVU50
 232 0024 C901      		movw r24,r18
 233 0026 BF01      		movw r22,r30
 234 0028 0E94 0000 		call __udivmodhi4
 109:drivers/indicator.c ****     string[3] = number % 10;
 235               		.loc 1 109 30 view .LVU51
 236 002c EAE0      		ldi r30,lo8(10)
 237 002e F0E0      		ldi r31,0
 238 0030 BF01      		movw r22,r30
 239 0032 0E94 0000 		call __udivmodhi4
 109:drivers/indicator.c ****     string[3] = number % 10;
 240               		.loc 1 109 15 view .LVU52
 241 0036 6B83      		std Y+3,r22
 110:drivers/indicator.c **** 
 242               		.loc 1 110 5 is_stmt 1 view .LVU53
 110:drivers/indicator.c **** 
 243               		.loc 1 110 24 is_stmt 0 view .LVU54
 244 0038 C901      		movw r24,r18
 245 003a BF01      		movw r22,r30
 246 003c 0E94 0000 		call __udivmodhi4
 110:drivers/indicator.c **** 
 247               		.loc 1 110 15 view .LVU55
 248 0040 8C83      		std Y+4,r24
 112:drivers/indicator.c ****     step = 4 - step;
 249               		.loc 1 112 5 is_stmt 1 view .LVU56
 250               	.LVL11:
 251               	.LBB7:
 252               	.LBI7:
  86:drivers/indicator.c **** {
 253               		.loc 1 86 1 view .LVU57
 254               	.LBB8:
  88:drivers/indicator.c **** 
 255               		.loc 1 88 5 view .LVU58
  90:drivers/indicator.c ****         step = 3;
 256               		.loc 1 90 5 view .LVU59
  92:drivers/indicator.c ****         step = 2;
 257               		.loc 1 92 5 view .LVU60
  92:drivers/indicator.c ****         step = 2;
 258               		.loc 1 92 7 is_stmt 0 view .LVU61
 259 0042 83E0      		ldi r24,lo8(3)
 260 0044 2436      		cpi r18,100
 261 0046 3105      		cpc r19,__zero_reg__
 262 0048 04F4      		brge .L11
  93:drivers/indicator.c ****     if( x < 10 )
 263               		.loc 1 93 9 is_stmt 1 view .LVU62
 264               	.LVL12:
  94:drivers/indicator.c ****         step = 1;
 265               		.loc 1 94 5 view .LVU63
  95:drivers/indicator.c **** 
 266               		.loc 1 95 14 is_stmt 0 view .LVU64
 267 004a 81E0      		ldi r24,lo8(1)
  94:drivers/indicator.c ****         step = 1;
 268               		.loc 1 94 7 view .LVU65
 269 004c 2A30      		cpi r18,10
 270 004e 3105      		cpc r19,__zero_reg__
 271 0050 04F0      		brlt .L11
  93:drivers/indicator.c ****     if( x < 10 )
 272               		.loc 1 93 14 view .LVU66
 273 0052 82E0      		ldi r24,lo8(2)
 274               	.LVL13:
 275               	.L11:
  97:drivers/indicator.c **** }
 276               		.loc 1 97 5 is_stmt 1 view .LVU67
  97:drivers/indicator.c **** }
 277               		.loc 1 97 5 is_stmt 0 view .LVU68
 278               	.LBE8:
 279               	.LBE7:
 113:drivers/indicator.c **** 
 280               		.loc 1 113 5 is_stmt 1 view .LVU69
 113:drivers/indicator.c **** 
 281               		.loc 1 113 10 is_stmt 0 view .LVU70
 282 0054 24E0      		ldi r18,lo8(4)
 283               	.LVL14:
 113:drivers/indicator.c **** 
 284               		.loc 1 113 10 view .LVU71
 285 0056 281B      		sub r18,r24
 286               	.LVL15:
 116:drivers/indicator.c ****     {
 287               		.loc 1 116 5 is_stmt 1 view .LVU72
 288               	.LBB9:
 116:drivers/indicator.c ****     {
 289               		.loc 1 116 10 view .LVU73
 116:drivers/indicator.c ****     {
 290               		.loc 1 116 10 is_stmt 0 view .LVU74
 291               	.LBE9:
 113:drivers/indicator.c **** 
 292               		.loc 1 113 10 view .LVU75
 293 0058 90E0      		ldi r25,0
 294 005a 80E0      		ldi r24,0
 295               	.LBB10:
 118:drivers/indicator.c ****         {
 296               		.loc 1 118 15 view .LVU76
 297 005c 30E0      		ldi r19,0
 120:drivers/indicator.c ****         }
 298               		.loc 1 120 23 view .LVU77
 299 005e 4FEF      		ldi r20,lo8(-1)
 300               	.LVL16:
 301               	.L14:
 118:drivers/indicator.c ****         {
 302               		.loc 1 118 9 is_stmt 1 view .LVU78
 118:drivers/indicator.c ****         {
 303               		.loc 1 118 11 is_stmt 0 view .LVU79
 304 0060 8217      		cp r24,r18
 305 0062 9307      		cpc r25,r19
 306 0064 04F4      		brge .L12
 120:drivers/indicator.c ****         }
 307               		.loc 1 120 13 is_stmt 1 view .LVU80
 120:drivers/indicator.c ****         }
 308               		.loc 1 120 23 is_stmt 0 view .LVU81
 309 0066 E1E0      		ldi r30,lo8(1)
 310 0068 F0E0      		ldi r31,0
 311 006a EC0F      		add r30,r28
 312 006c FD1F      		adc r31,r29
 313 006e E80F      		add r30,r24
 314 0070 F91F      		adc r31,r25
 315 0072 4083      		st Z,r20
 316               	.L13:
 317               	.LVL17:
 120:drivers/indicator.c ****         }
 318               		.loc 1 120 23 view .LVU82
 319 0074 0196      		adiw r24,1
 320               	.LVL18:
 116:drivers/indicator.c ****     {
 321               		.loc 1 116 5 discriminator 2 view .LVU83
 322 0076 8430      		cpi r24,4
 323 0078 9105      		cpc r25,__zero_reg__
 324 007a 01F4      		brne .L14
 325               	.LVL19:
 116:drivers/indicator.c ****     {
 326               		.loc 1 116 5 discriminator 2 view .LVU84
 327               	.LBE10:
 328               	.LBB11:
 134:drivers/indicator.c ****     }
 329               		.loc 1 134 9 is_stmt 1 view .LVU85
 134:drivers/indicator.c ****     }
 330               		.loc 1 134 27 is_stmt 0 view .LVU86
 331 007c 8981      		ldd r24,Y+1
 332               	.LVL20:
 134:drivers/indicator.c ****     }
 333               		.loc 1 134 27 view .LVU87
 334 007e 8093 0000 		sts indicator_data,r24
 335               	.LVL21:
 134:drivers/indicator.c ****     }
 336               		.loc 1 134 9 is_stmt 1 view .LVU88
 134:drivers/indicator.c ****     }
 337               		.loc 1 134 27 is_stmt 0 view .LVU89
 338 0082 8A81      		ldd r24,Y+2
 339 0084 8093 0000 		sts indicator_data+1,r24
 340               	.LVL22:
 134:drivers/indicator.c ****     }
 341               		.loc 1 134 9 is_stmt 1 view .LVU90
 134:drivers/indicator.c ****     }
 342               		.loc 1 134 27 is_stmt 0 view .LVU91
 343 0088 8B81      		ldd r24,Y+3
 344 008a 8093 0000 		sts indicator_data+2,r24
 345               	.LVL23:
 134:drivers/indicator.c ****     }
 346               		.loc 1 134 9 is_stmt 1 view .LVU92
 134:drivers/indicator.c ****     }
 347               		.loc 1 134 27 is_stmt 0 view .LVU93
 348 008e 8C81      		ldd r24,Y+4
 349 0090 8093 0000 		sts indicator_data+3,r24
 350               	.LVL24:
 351               	/* epilogue start */
 134:drivers/indicator.c ****     }
 352               		.loc 1 134 27 view .LVU94
 353               	.LBE11:
 136:drivers/indicator.c **** 
 354               		.loc 1 136 1 view .LVU95
 355 0094 2496      		adiw r28,4
 356 0096 E2E0      		ldi r30, lo8(2)
 357 0098 0C94 0000 		jmp __epilogue_restores__ + ((18 - 2) * 2)
 358               	.LVL25:
 359               	.L12:
 360               	.LBB12:
 124:drivers/indicator.c ****         }
 361               		.loc 1 124 13 is_stmt 1 view .LVU96
 362 009c A1E0      		ldi r26,lo8(1)
 363 009e B0E0      		ldi r27,0
 364 00a0 AC0F      		add r26,r28
 365 00a2 BD1F      		adc r27,r29
 366 00a4 A80F      		add r26,r24
 367 00a6 B91F      		adc r27,r25
 124:drivers/indicator.c ****         }
 368               		.loc 1 124 47 is_stmt 0 view .LVU97
 369 00a8 EC91      		ld r30,X
 370 00aa F0E0      		ldi r31,0
 124:drivers/indicator.c ****         }
 371               		.loc 1 124 40 view .LVU98
 372 00ac E050      		subi r30,lo8(-(ind_ascii_table))
 373 00ae F040      		sbci r31,hi8(-(ind_ascii_table))
 124:drivers/indicator.c ****         }
 374               		.loc 1 124 23 view .LVU99
 375 00b0 5089      		ldd r21,Z+16
 376 00b2 5C93      		st X,r21
 377 00b4 00C0      		rjmp .L13
 378               	.LBE12:
 379               		.cfi_endproc
 380               	.LFE4:
 382               		.section	.text.ind_init,"ax",@progbits
 383               	.global	ind_init
 385               	ind_init:
 386               	.LFB8:
 149:drivers/indicator.c **** 
 150:drivers/indicator.c **** 
 151:drivers/indicator.c **** static void
 152:drivers/indicator.c **** latch_enable(void)
 153:drivers/indicator.c **** {
 154:drivers/indicator.c **** 	   IND_PORT |= (1<<WRT);
 155:drivers/indicator.c **** 	   __asm volatile("nop");
 156:drivers/indicator.c **** 	   __asm volatile("nop");
 157:drivers/indicator.c **** 	   __asm volatile("nop");
 158:drivers/indicator.c **** 	   __asm volatile("nop");
 159:drivers/indicator.c **** 	   IND_PORT &= ~(1<<WRT);
 160:drivers/indicator.c **** }
 161:drivers/indicator.c **** 
 162:drivers/indicator.c **** 
 163:drivers/indicator.c **** 
 164:drivers/indicator.c **** 
 165:drivers/indicator.c **** 
 166:drivers/indicator.c **** 
 167:drivers/indicator.c **** 
 168:drivers/indicator.c **** static void
 169:drivers/indicator.c **** indicator_data_send( void )
 170:drivers/indicator.c **** {
 171:drivers/indicator.c **** 
 172:drivers/indicator.c **** 	DDRD |= (1 << DAT0);
 173:drivers/indicator.c **** 
 174:drivers/indicator.c ****     static int8_t  digit;
 175:drivers/indicator.c ****     uint8_t  control_shift_reg = 0;
 176:drivers/indicator.c **** 
 177:drivers/indicator.c **** 
 178:drivers/indicator.c ****     control_shift_reg = (1 << digit);
 179:drivers/indicator.c ****     control_shift_reg |= ind_led_state;
 180:drivers/indicator.c **** 
 181:drivers/indicator.c ****     control_shift_reg = ~control_shift_reg;
 182:drivers/indicator.c **** 
 183:drivers/indicator.c ****      int8_t i;
 184:drivers/indicator.c **** 
 185:drivers/indicator.c **** 
 186:drivers/indicator.c ****     // Loading data into the second shift register
 187:drivers/indicator.c ****     for( i = 0 ; i < 4 ; i++ )
 188:drivers/indicator.c ****     {
 189:drivers/indicator.c ****     	IND_PORT = ( (control_shift_reg << i) & (0x80) ) ? IND_PORT | (1<<DAT0) : IND_PORT & ~(1<<DAT0
 190:drivers/indicator.c ****     	clock_signal();
 191:drivers/indicator.c ****     }
 192:drivers/indicator.c **** 
 193:drivers/indicator.c ****     for( i = 4 ; i < 8 ; i++ )
 194:drivers/indicator.c ****     {
 195:drivers/indicator.c ****     	IND_PORT = ( (control_shift_reg << i) & (0x80) ) ? IND_PORT | (1<<DAT0) : IND_PORT & ~(1<<DAT0
 196:drivers/indicator.c ****     	clock_signal();
 197:drivers/indicator.c ****     }
 198:drivers/indicator.c **** 
 199:drivers/indicator.c **** 
 200:drivers/indicator.c ****     // Loading data into the first shift register
 201:drivers/indicator.c ****     for(  i = 0 ; i < 8 ; i++ )
 202:drivers/indicator.c ****     {
 203:drivers/indicator.c ****     	IND_PORT = ( (indicator_data[digit] << i) & (0x80) ) ? IND_PORT | (1<<DAT0) : IND_PORT & ~(1<<
 204:drivers/indicator.c ****     	clock_signal();
 205:drivers/indicator.c ****     }
 206:drivers/indicator.c **** 
 207:drivers/indicator.c ****     latch_enable(); // Data finally submitted
 208:drivers/indicator.c **** 
 209:drivers/indicator.c ****     for( i = 0 ; i < 8 ; i++ )
 210:drivers/indicator.c ****     {
 211:drivers/indicator.c ****     	DDRD &= ~(1 << DAT0);
 212:drivers/indicator.c **** 
 213:drivers/indicator.c ****     	IND_PORT |= (1 << DAT0);			//perevesti data0 na vihod
 214:drivers/indicator.c **** 
 215:drivers/indicator.c **** //    	if ( button_state_get() == 0 )
 216:drivers/indicator.c **** //    	{
 217:drivers/indicator.c **** //    		PORTC |= (1 << 2);
 218:drivers/indicator.c **** //
 219:drivers/indicator.c **** //    	}
 220:drivers/indicator.c **** 
 221:drivers/indicator.c ****     	IND_PORT &= ~(1<<DAT0); 			//perevesti data0 na vhod
 222:drivers/indicator.c **** 
 223:drivers/indicator.c ****     }
 224:drivers/indicator.c **** 
 225:drivers/indicator.c **** 
 226:drivers/indicator.c **** 
 227:drivers/indicator.c ****     /** DIGIT = 1 */
 228:drivers/indicator.c **** 
 229:drivers/indicator.c ****     if( ++digit >= 4 )
 230:drivers/indicator.c ****     {
 231:drivers/indicator.c ****         digit = 0;
 232:drivers/indicator.c ****     }
 233:drivers/indicator.c **** 
 234:drivers/indicator.c ****     /** DIGIT = 2 */
 235:drivers/indicator.c **** 
 236:drivers/indicator.c **** 
 237:drivers/indicator.c **** 
 238:drivers/indicator.c **** }
 239:drivers/indicator.c **** 
 240:drivers/indicator.c **** 
 241:drivers/indicator.c **** void
 242:drivers/indicator.c **** ind_init( void )
 243:drivers/indicator.c **** {
 387               		.loc 1 243 1 is_stmt 1 view -0
 388               		.cfi_startproc
 389               	/* prologue: function */
 390               	/* frame size = 0 */
 391               	/* stack size = 0 */
 392               	.L__stack_usage = 0
 244:drivers/indicator.c ****     DDRD |= (1 << CLK) | (1 << DAT0) | (1 << WRT); // output
 393               		.loc 1 244 5 view .LVU101
 394               		.loc 1 244 10 is_stmt 0 view .LVU102
 395 0000 8AB1      		in r24,0xa
 396 0002 8C61      		ori r24,lo8(28)
 397 0004 8AB9      		out 0xa,r24
 245:drivers/indicator.c **** 
 246:drivers/indicator.c ****     // TIM0 Initialization
 247:drivers/indicator.c ****     // Fcpu / 1024 = 15625 HZ
 248:drivers/indicator.c ****     TCCR0B = (1 << CS02) | (0 << CS01) | (0 << CS00);
 398               		.loc 1 248 5 is_stmt 1 view .LVU103
 399               		.loc 1 248 12 is_stmt 0 view .LVU104
 400 0006 84E0      		ldi r24,lo8(4)
 401 0008 85BD      		out 0x25,r24
 249:drivers/indicator.c **** 
 250:drivers/indicator.c ****     TIMSK0 |= ( 1<<0 );
 402               		.loc 1 250 5 is_stmt 1 view .LVU105
 403               		.loc 1 250 12 is_stmt 0 view .LVU106
 404 000a EEE6      		ldi r30,lo8(110)
 405 000c F0E0      		ldi r31,0
 406 000e 8081      		ld r24,Z
 407 0010 8160      		ori r24,lo8(1)
 408 0012 8083      		st Z,r24
 409               	/* epilogue start */
 251:drivers/indicator.c **** }
 410               		.loc 1 251 1 view .LVU107
 411 0014 0895      		ret
 412               		.cfi_endproc
 413               	.LFE8:
 415               		.section	.text.__vector_16,"ax",@progbits
 416               	.global	__vector_16
 418               	__vector_16:
 419               	.LFB9:
 252:drivers/indicator.c **** 
 253:drivers/indicator.c **** 
 254:drivers/indicator.c **** ISR (TIMER0_OVF_vect)
 255:drivers/indicator.c **** {
 420               		.loc 1 255 1 is_stmt 1 view -0
 421               		.cfi_startproc
 422 0000 1F92      		push r1
 423               	.LCFI3:
 424               		.cfi_def_cfa_offset 3
 425               		.cfi_offset 1, -2
 426 0002 0F92      		push r0
 427               	.LCFI4:
 428               		.cfi_def_cfa_offset 4
 429               		.cfi_offset 0, -3
 430 0004 0FB6      		in r0,__SREG__
 431 0006 0F92      		push r0
 432 0008 1124      		clr __zero_reg__
 433 000a 0F93      		push r16
 434               	.LCFI5:
 435               		.cfi_def_cfa_offset 5
 436               		.cfi_offset 16, -4
 437 000c 1F93      		push r17
 438               	.LCFI6:
 439               		.cfi_def_cfa_offset 6
 440               		.cfi_offset 17, -5
 441 000e 2F93      		push r18
 442               	.LCFI7:
 443               		.cfi_def_cfa_offset 7
 444               		.cfi_offset 18, -6
 445 0010 3F93      		push r19
 446               	.LCFI8:
 447               		.cfi_def_cfa_offset 8
 448               		.cfi_offset 19, -7
 449 0012 4F93      		push r20
 450               	.LCFI9:
 451               		.cfi_def_cfa_offset 9
 452               		.cfi_offset 20, -8
 453 0014 5F93      		push r21
 454               	.LCFI10:
 455               		.cfi_def_cfa_offset 10
 456               		.cfi_offset 21, -9
 457 0016 6F93      		push r22
 458               	.LCFI11:
 459               		.cfi_def_cfa_offset 11
 460               		.cfi_offset 22, -10
 461 0018 7F93      		push r23
 462               	.LCFI12:
 463               		.cfi_def_cfa_offset 12
 464               		.cfi_offset 23, -11
 465 001a 8F93      		push r24
 466               	.LCFI13:
 467               		.cfi_def_cfa_offset 13
 468               		.cfi_offset 24, -12
 469 001c 9F93      		push r25
 470               	.LCFI14:
 471               		.cfi_def_cfa_offset 14
 472               		.cfi_offset 25, -13
 473 001e AF93      		push r26
 474               	.LCFI15:
 475               		.cfi_def_cfa_offset 15
 476               		.cfi_offset 26, -14
 477 0020 BF93      		push r27
 478               	.LCFI16:
 479               		.cfi_def_cfa_offset 16
 480               		.cfi_offset 27, -15
 481 0022 CF93      		push r28
 482               	.LCFI17:
 483               		.cfi_def_cfa_offset 17
 484               		.cfi_offset 28, -16
 485 0024 DF93      		push r29
 486               	.LCFI18:
 487               		.cfi_def_cfa_offset 18
 488               		.cfi_offset 29, -17
 489 0026 EF93      		push r30
 490               	.LCFI19:
 491               		.cfi_def_cfa_offset 19
 492               		.cfi_offset 30, -18
 493 0028 FF93      		push r31
 494               	.LCFI20:
 495               		.cfi_def_cfa_offset 20
 496               		.cfi_offset 31, -19
 497               	/* prologue: Signal */
 498               	/* frame size = 0 */
 499               	/* stack size = 19 */
 500               	.L__stack_usage = 19
 256:drivers/indicator.c ****     indicator_data_send();
 501               		.loc 1 256 5 view .LVU109
 502               	.LBB17:
 503               	.LBI17:
 169:drivers/indicator.c **** {
 504               		.loc 1 169 1 view .LVU110
 505               	.LBB18:
 172:drivers/indicator.c **** 
 506               		.loc 1 172 2 view .LVU111
 172:drivers/indicator.c **** 
 507               		.loc 1 172 7 is_stmt 0 view .LVU112
 508 002a 539A      		sbi 0xa,3
 174:drivers/indicator.c ****     uint8_t  control_shift_reg = 0;
 509               		.loc 1 174 5 is_stmt 1 view .LVU113
 175:drivers/indicator.c **** 
 510               		.loc 1 175 5 view .LVU114
 511               	.LVL26:
 178:drivers/indicator.c ****     control_shift_reg |= ind_led_state;
 512               		.loc 1 178 5 view .LVU115
 178:drivers/indicator.c ****     control_shift_reg |= ind_led_state;
 513               		.loc 1 178 28 is_stmt 0 view .LVU116
 514 002c 8091 0000 		lds r24,digit.1092
 515 0030 01E0      		ldi r16,lo8(1)
 516 0032 10E0      		ldi r17,0
 517 0034 9801      		movw r18,r16
 518 0036 00C0      		rjmp 2f
 519               		1:
 520 0038 220F      		lsl r18
 521 003a 331F      		rol r19
 522               		2:
 523 003c 8A95      		dec r24
 524 003e 02F4      		brpl 1b
 525               	.LVL27:
 179:drivers/indicator.c **** 
 526               		.loc 1 179 5 is_stmt 1 view .LVU117
 179:drivers/indicator.c **** 
 527               		.loc 1 179 23 is_stmt 0 view .LVU118
 528 0040 0091 0000 		lds r16,ind_led_state
 529 0044 022B      		or r16,r18
 530               	.LVL28:
 181:drivers/indicator.c **** 
 531               		.loc 1 181 5 is_stmt 1 view .LVU119
 181:drivers/indicator.c **** 
 532               		.loc 1 181 23 is_stmt 0 view .LVU120
 533 0046 0095      		com r16
 534               	.LVL29:
 183:drivers/indicator.c **** 
 535               		.loc 1 183 6 is_stmt 1 view .LVU121
 187:drivers/indicator.c ****     {
 536               		.loc 1 187 5 view .LVU122
 181:drivers/indicator.c **** 
 537               		.loc 1 181 23 is_stmt 0 view .LVU123
 538 0048 D0E0      		ldi r29,0
 539 004a C0E0      		ldi r28,0
 189:drivers/indicator.c ****     	clock_signal();
 540               		.loc 1 189 38 view .LVU124
 541 004c 10E0      		ldi r17,0
 542               	.LVL30:
 543               	.L22:
 189:drivers/indicator.c ****     	clock_signal();
 544               		.loc 1 189 6 is_stmt 1 view .LVU125
 189:drivers/indicator.c ****     	clock_signal();
 545               		.loc 1 189 38 is_stmt 0 view .LVU126
 546 004e C801      		movw r24,r16
 547 0050 0C2E      		mov r0,r28
 548 0052 00C0      		rjmp 2f
 549               		1:
 550 0054 880F      		lsl r24
 551               		2:
 552 0056 0A94      		dec r0
 553 0058 02F4      		brpl 1b
 189:drivers/indicator.c ****     	clock_signal();
 554               		.loc 1 189 15 view .LVU127
 555 005a 87FF      		sbrs r24,7
 556 005c 00C0      		rjmp .L20
 189:drivers/indicator.c ****     	clock_signal();
 557               		.loc 1 189 57 view .LVU128
 558 005e 8BB1      		in r24,0xb
 189:drivers/indicator.c ****     	clock_signal();
 559               		.loc 1 189 15 view .LVU129
 560 0060 8860      		ori r24,lo8(8)
 561               	.L21:
 562 0062 8BB9      		out 0xb,r24
 190:drivers/indicator.c ****     }
 563               		.loc 1 190 6 is_stmt 1 view .LVU130
 564 0064 0E94 0000 		call clock_signal
 565               	.LVL31:
 190:drivers/indicator.c ****     }
 566               		.loc 1 190 6 is_stmt 0 view .LVU131
 567 0068 2196      		adiw r28,1
 568               	.LVL32:
 187:drivers/indicator.c ****     {
 569               		.loc 1 187 5 view .LVU132
 570 006a C430      		cpi r28,4
 571 006c D105      		cpc r29,__zero_reg__
 572 006e 01F4      		brne .L22
 573               	.LVL33:
 574               	.L25:
 195:drivers/indicator.c ****     	clock_signal();
 575               		.loc 1 195 6 is_stmt 1 view .LVU133
 195:drivers/indicator.c ****     	clock_signal();
 576               		.loc 1 195 38 is_stmt 0 view .LVU134
 577 0070 C801      		movw r24,r16
 578 0072 0C2E      		mov r0,r28
 579 0074 00C0      		rjmp 2f
 580               		1:
 581 0076 880F      		lsl r24
 582               		2:
 583 0078 0A94      		dec r0
 584 007a 02F4      		brpl 1b
 195:drivers/indicator.c ****     	clock_signal();
 585               		.loc 1 195 15 view .LVU135
 586 007c 87FF      		sbrs r24,7
 587 007e 00C0      		rjmp .L23
 195:drivers/indicator.c ****     	clock_signal();
 588               		.loc 1 195 57 view .LVU136
 589 0080 8BB1      		in r24,0xb
 195:drivers/indicator.c ****     	clock_signal();
 590               		.loc 1 195 15 view .LVU137
 591 0082 8860      		ori r24,lo8(8)
 592               	.L24:
 593 0084 8BB9      		out 0xb,r24
 196:drivers/indicator.c ****     }
 594               		.loc 1 196 6 is_stmt 1 view .LVU138
 595 0086 0E94 0000 		call clock_signal
 596               	.LVL34:
 196:drivers/indicator.c ****     }
 597               		.loc 1 196 6 is_stmt 0 view .LVU139
 598 008a 2196      		adiw r28,1
 599               	.LVL35:
 193:drivers/indicator.c ****     {
 600               		.loc 1 193 5 view .LVU140
 601 008c C830      		cpi r28,8
 602 008e D105      		cpc r29,__zero_reg__
 603 0090 01F4      		brne .L25
 604 0092 D0E0      		ldi r29,0
 605 0094 C0E0      		ldi r28,0
 606               	.LVL36:
 607               	.L28:
 203:drivers/indicator.c ****     	clock_signal();
 608               		.loc 1 203 6 is_stmt 1 view .LVU141
 203:drivers/indicator.c ****     	clock_signal();
 609               		.loc 1 203 34 is_stmt 0 view .LVU142
 610 0096 E091 0000 		lds r30,digit.1092
 611 009a 0E2E      		mov __tmp_reg__,r30
 612 009c 000C      		lsl r0
 613 009e FF0B      		sbc r31,r31
 614 00a0 E050      		subi r30,lo8(-(indicator_data))
 615 00a2 F040      		sbci r31,hi8(-(indicator_data))
 616 00a4 8081      		ld r24,Z
 203:drivers/indicator.c ****     	clock_signal();
 617               		.loc 1 203 42 view .LVU143
 618 00a6 0C2E      		mov r0,r28
 619 00a8 00C0      		rjmp 2f
 620               		1:
 621 00aa 880F      		lsl r24
 622               		2:
 623 00ac 0A94      		dec r0
 624 00ae 02F4      		brpl 1b
 203:drivers/indicator.c ****     	clock_signal();
 625               		.loc 1 203 15 view .LVU144
 626 00b0 87FF      		sbrs r24,7
 627 00b2 00C0      		rjmp .L26
 203:drivers/indicator.c ****     	clock_signal();
 628               		.loc 1 203 61 view .LVU145
 629 00b4 8BB1      		in r24,0xb
 203:drivers/indicator.c ****     	clock_signal();
 630               		.loc 1 203 15 view .LVU146
 631 00b6 8860      		ori r24,lo8(8)
 632               	.L27:
 633 00b8 8BB9      		out 0xb,r24
 204:drivers/indicator.c ****     }
 634               		.loc 1 204 6 is_stmt 1 view .LVU147
 635 00ba 0E94 0000 		call clock_signal
 636               	.LVL37:
 204:drivers/indicator.c ****     }
 637               		.loc 1 204 6 is_stmt 0 view .LVU148
 638 00be 2196      		adiw r28,1
 639               	.LVL38:
 201:drivers/indicator.c ****     {
 640               		.loc 1 201 5 view .LVU149
 641 00c0 C830      		cpi r28,8
 642 00c2 D105      		cpc r29,__zero_reg__
 643 00c4 01F4      		brne .L28
 207:drivers/indicator.c **** 
 644               		.loc 1 207 5 is_stmt 1 view .LVU150
 645               	.LBB19:
 646               	.LBI19:
 152:drivers/indicator.c **** {
 647               		.loc 1 152 1 view .LVU151
 648               	.LBB20:
 154:drivers/indicator.c **** 	   __asm volatile("nop");
 649               		.loc 1 154 5 view .LVU152
 154:drivers/indicator.c **** 	   __asm volatile("nop");
 650               		.loc 1 154 14 is_stmt 0 view .LVU153
 651 00c6 5C9A      		sbi 0xb,4
 155:drivers/indicator.c **** 	   __asm volatile("nop");
 652               		.loc 1 155 5 is_stmt 1 view .LVU154
 653               	/* #APP */
 654               	 ;  155 "drivers/indicator.c" 1
 655 00c8 0000      		nop
 656               	 ;  0 "" 2
 156:drivers/indicator.c **** 	   __asm volatile("nop");
 657               		.loc 1 156 5 view .LVU155
 658               	 ;  156 "drivers/indicator.c" 1
 659 00ca 0000      		nop
 660               	 ;  0 "" 2
 157:drivers/indicator.c **** 	   __asm volatile("nop");
 661               		.loc 1 157 5 view .LVU156
 662               	 ;  157 "drivers/indicator.c" 1
 663 00cc 0000      		nop
 664               	 ;  0 "" 2
 158:drivers/indicator.c **** 	   IND_PORT &= ~(1<<WRT);
 665               		.loc 1 158 5 view .LVU157
 666               	 ;  158 "drivers/indicator.c" 1
 667 00ce 0000      		nop
 668               	 ;  0 "" 2
 159:drivers/indicator.c **** }
 669               		.loc 1 159 5 view .LVU158
 159:drivers/indicator.c **** }
 670               		.loc 1 159 14 is_stmt 0 view .LVU159
 671               	/* #NOAPP */
 672 00d0 5C98      		cbi 0xb,4
 673               	.LVL39:
 159:drivers/indicator.c **** }
 674               		.loc 1 159 14 view .LVU160
 675 00d2 88E0      		ldi r24,lo8(8)
 676               	.LVL40:
 677               	.L29:
 159:drivers/indicator.c **** }
 678               		.loc 1 159 14 view .LVU161
 679               	.LBE20:
 680               	.LBE19:
 211:drivers/indicator.c **** 
 681               		.loc 1 211 6 is_stmt 1 view .LVU162
 211:drivers/indicator.c **** 
 682               		.loc 1 211 11 is_stmt 0 view .LVU163
 683 00d4 5398      		cbi 0xa,3
 213:drivers/indicator.c **** 
 684               		.loc 1 213 6 is_stmt 1 view .LVU164
 213:drivers/indicator.c **** 
 685               		.loc 1 213 15 is_stmt 0 view .LVU165
 686 00d6 5B9A      		sbi 0xb,3
 221:drivers/indicator.c **** 
 687               		.loc 1 221 6 is_stmt 1 view .LVU166
 221:drivers/indicator.c **** 
 688               		.loc 1 221 15 is_stmt 0 view .LVU167
 689 00d8 5B98      		cbi 0xb,3
 690               	.LVL41:
 221:drivers/indicator.c **** 
 691               		.loc 1 221 15 view .LVU168
 692 00da 8150      		subi r24,lo8(-(-1))
 693               	.LVL42:
 209:drivers/indicator.c ****     {
 694               		.loc 1 209 5 view .LVU169
 695 00dc 01F4      		brne .L29
 229:drivers/indicator.c ****     {
 696               		.loc 1 229 5 is_stmt 1 view .LVU170
 229:drivers/indicator.c ****     {
 697               		.loc 1 229 9 is_stmt 0 view .LVU171
 698 00de 8091 0000 		lds r24,digit.1092
 699               	.LVL43:
 229:drivers/indicator.c ****     {
 700               		.loc 1 229 9 view .LVU172
 701 00e2 8F5F      		subi r24,lo8(-(1))
 229:drivers/indicator.c ****     {
 702               		.loc 1 229 7 view .LVU173
 703 00e4 8430      		cpi r24,lo8(4)
 704 00e6 04F4      		brge .L30
 705 00e8 8093 0000 		sts digit.1092,r24
 706               	.LVL44:
 707               	.L19:
 708               	/* epilogue start */
 229:drivers/indicator.c ****     {
 709               		.loc 1 229 7 view .LVU174
 710               	.LBE18:
 711               	.LBE17:
 257:drivers/indicator.c **** }
 712               		.loc 1 257 1 view .LVU175
 713 00ec FF91      		pop r31
 714 00ee EF91      		pop r30
 715 00f0 DF91      		pop r29
 716 00f2 CF91      		pop r28
 717 00f4 BF91      		pop r27
 718 00f6 AF91      		pop r26
 719 00f8 9F91      		pop r25
 720 00fa 8F91      		pop r24
 721 00fc 7F91      		pop r23
 722 00fe 6F91      		pop r22
 723 0100 5F91      		pop r21
 724 0102 4F91      		pop r20
 725 0104 3F91      		pop r19
 726 0106 2F91      		pop r18
 727 0108 1F91      		pop r17
 728 010a 0F91      		pop r16
 729 010c 0F90      		pop r0
 730 010e 0FBE      		out __SREG__,r0
 731 0110 0F90      		pop r0
 732 0112 1F90      		pop r1
 733 0114 1895      		reti
 734               	.LVL45:
 735               	.L20:
 736               	.LBB22:
 737               	.LBB21:
 189:drivers/indicator.c ****     	clock_signal();
 738               		.loc 1 189 80 view .LVU176
 739 0116 8BB1      		in r24,0xb
 189:drivers/indicator.c ****     	clock_signal();
 740               		.loc 1 189 15 view .LVU177
 741 0118 877F      		andi r24,lo8(-9)
 742 011a 00C0      		rjmp .L21
 743               	.L23:
 195:drivers/indicator.c ****     	clock_signal();
 744               		.loc 1 195 80 view .LVU178
 745 011c 8BB1      		in r24,0xb
 195:drivers/indicator.c ****     	clock_signal();
 746               		.loc 1 195 15 view .LVU179
 747 011e 877F      		andi r24,lo8(-9)
 748 0120 00C0      		rjmp .L24
 749               	.L26:
 203:drivers/indicator.c ****     	clock_signal();
 750               		.loc 1 203 84 view .LVU180
 751 0122 8BB1      		in r24,0xb
 203:drivers/indicator.c ****     	clock_signal();
 752               		.loc 1 203 15 view .LVU181
 753 0124 877F      		andi r24,lo8(-9)
 754 0126 00C0      		rjmp .L27
 755               	.LVL46:
 756               	.L30:
 231:drivers/indicator.c ****     }
 757               		.loc 1 231 9 is_stmt 1 view .LVU182
 231:drivers/indicator.c ****     }
 758               		.loc 1 231 15 is_stmt 0 view .LVU183
 759 0128 1092 0000 		sts digit.1092,__zero_reg__
 760               	.LVL47:
 231:drivers/indicator.c ****     }
 761               		.loc 1 231 15 view .LVU184
 762               	.LBE21:
 763               	.LBE22:
 764               		.loc 1 257 1 view .LVU185
 765 012c 00C0      		rjmp .L19
 766               		.cfi_endproc
 767               	.LFE9:
 769               		.section	.bss.digit.1092,"aw",@nobits
 772               	digit.1092:
 773 0000 00        		.zero	1
 774               		.section	.bss.ind_led_state,"aw",@nobits
 777               	ind_led_state:
 778 0000 00        		.zero	1
 779               		.section	.bss.indicator_data,"aw",@nobits
 782               	indicator_data:
 783 0000 0000 0000 		.zero	4
 784               		.section	.rodata.ind_ascii_table,"a"
 787               	ind_ascii_table:
 788 0000 FF        		.byte	-1
 789 0001 79        		.byte	121
 790 0002 DD        		.byte	-35
 791 0003 9D        		.byte	-99
 792 0004 93        		.byte	-109
 793 0005 AD        		.byte	-83
 794 0006 E3        		.byte	-29
 795 0007 FD        		.byte	-3
 796 0008 C6        		.byte	-58
 797 0009 F0        		.byte	-16
 798 000a 9C        		.byte	-100
 799 000b B9        		.byte	-71
 800 000c 7F        		.byte	127
 801 000d BF        		.byte	-65
 802 000e 7F        		.byte	127
 803 000f AD        		.byte	-83
 804 0010 C0        		.byte	-64
 805 0011 F9        		.byte	-7
 806 0012 A4        		.byte	-92
 807 0013 B0        		.byte	-80
 808 0014 99        		.byte	-103
 809 0015 92        		.byte	-110
 810 0016 82        		.byte	-126
 811 0017 F8        		.byte	-8
 812 0018 80        		.byte	-128
 813 0019 90        		.byte	-112
 814 001a 00        		.byte	0
 815 001b 00        		.byte	0
 816 001c 00        		.byte	0
 817 001d B7        		.byte	-73
 818 001e 00        		.byte	0
 819 001f 3C        		.byte	60
 820 0020 30        		.byte	48
 821 0021 88        		.byte	-120
 822 0022 83        		.byte	-125
 823 0023 C6        		.byte	-58
 824 0024 A1        		.byte	-95
 825 0025 86        		.byte	-122
 826 0026 8E        		.byte	-114
 827 0027 C3        		.byte	-61
 828 0028 89        		.byte	-119
 829 0029 CF        		.byte	-49
 830 002a E1        		.byte	-31
 831 002b 8A        		.byte	-118
 832 002c C7        		.byte	-57
 833 002d 8D        		.byte	-115
 834 002e AB        		.byte	-85
 835 002f C0        		.byte	-64
 836 0030 8C        		.byte	-116
 837 0031 98        		.byte	-104
 838 0032 AF        		.byte	-81
 839 0033 92        		.byte	-110
 840 0034 87        		.byte	-121
 841 0035 C1        		.byte	-63
 842 0036 E1        		.byte	-31
 843 0037 FF        		.byte	-1
 844 0038 B6        		.byte	-74
 845 0039 91        		.byte	-111
 846 003a B7        		.byte	-73
 847 003b A7        		.byte	-89
 848 003c 9B        		.byte	-101
 849 003d B3        		.byte	-77
 850 003e FE        		.byte	-2
 851 003f F7        		.byte	-9
 852 0040 9F        		.byte	-97
 853               		.text
 854               	.Letext0:
 855               		.file 2 "c:\\bin\\avr-gcc-8.3.0-x64-mingw\\lib\\gcc\\avr\\8.3.0\\include\\stdint-gcc.h"
DEFINED SYMBOLS
                            *ABS*:0000000000000000 indicator.c
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:2      *ABS*:000000000000003e __SP_H__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:3      *ABS*:000000000000003d __SP_L__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:4      *ABS*:000000000000003f __SREG__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:5      *ABS*:0000000000000000 __tmp_reg__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:6      *ABS*:0000000000000001 __zero_reg__
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:12     .text.clock_signal:0000000000000000 clock_signal
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:54     .text.button_state_get:0000000000000000 button_state_get
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:82     .text.ind_led_set:0000000000000000 ind_led_set
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:777    .bss.ind_led_state:0000000000000000 ind_led_state
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:130    .text.ind_print_string:0000000000000000 ind_print_string
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:782    .bss.indicator_data:0000000000000000 indicator_data
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:787    .rodata.ind_ascii_table:0000000000000000 ind_ascii_table
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:191    .text.ind_print_dec:0000000000000000 ind_print_dec
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:385    .text.ind_init:0000000000000000 ind_init
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:418    .text.__vector_16:0000000000000000 __vector_16
C:\Users\YB38D~1.VIR\AppData\Local\Temp\ccH4lBMM.s:772    .bss.digit.1092:0000000000000000 digit.1092

UNDEFINED SYMBOLS
__prologue_saves__
__udivmodhi4
__epilogue_restores__
__do_copy_data
__do_clear_bss

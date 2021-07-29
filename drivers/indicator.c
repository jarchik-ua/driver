
#include <inttypes.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#include "indicator.h"
#include "Analog_to_digital_converter.h"

#define IND_PORT                    PORTD

#define CLK                         PD2  // clock
#define DAT0                        PD3  // data
#define WRT                         PD4  // Enter

#define IND_PORTIN                  PIND

static const uint8_t ind_ascii_table[/* 65 */] =
{
        0xff /*   */, 0x79 /* ! */, 0xdd /* " */, 0x9d /* # */,
        0x93 /* $ */, 0xad /* % */, 0xe3 /* & */, 0xfd /* ' */,
        0xc6 /* ( */, 0xf0 /* ) */, 0x9c /* * */, 0xb9 /* + */,
        0x7f /* , */, 0xbf /* - */, 0x7f /* . */, 0xad /* / */,
        0xc0 /* 0 */, 0xf9 /* 1 */, 0xa4 /* 2 */, 0xb0 /* 3 */,
        0x99 /* 4 */, 0x92 /* 5 */, 0x82 /* 6 */, 0xf8 /* 7 */,
        0x80 /* 8 */, 0x90 /* 9 */,

        0x00 /* : */, 0x00 /* ; */, 0x00 /* < */, 0xb7 /* = */,
        0x00 /* > */, 0x3c /* ? */, 0x30 /* @ */,

        0x88 /* A */, 0x83 /* B */, 0xc6 /* C */, 0xa1 /* d */,
        0x86 /* E */, 0x8e /* F */, 0xc3 /* G */, 0x89 /* H */,
        0xcf /* I */, 0xe1 /* J */, 0x8a /* K */, 0xc7 /* L */,
        0x8d /* M */, 0xab /* N */, 0xc0 /* O */, 0x8c /* P */,
        0x98 /* Q */, 0xaf /* R */, 0x92 /* S */, 0x87 /* T */,
        0xc1 /* U */, 0xe1 /* V */, 0xff /* W */, 0xb6 /* X */,
        0x91 /* Y */, 0xb7 /* Z */,

        0xa7 /* [ */, 0x9b /* \ */, 0xb3 /* ] */, 0xfe /* ^ */,
        0xf7 /* _ */, 0x9f /* ` */,
};



static uint8_t  indicator_data[4];
static uint8_t  ind_led_state;



/*
 * return 1 if button pressed, 0 if button state don`t pressed
 */


uint8_t
button_state_get( void )
{
	uint8_t btn_state;

	btn_state = (PIND & (1 << 3)) ? 1 : 0;

	return btn_state;

}

void
ind_led_set( uint8_t led, int8_t state )
{
    if ( state )
        ind_led_state |= (1 << led);
    else
        ind_led_state &= ~(1 << led);
}


void
ind_print_string( char * number )
{

    for ( int8_t i = 0; i < 4; i++ )
    {
        indicator_data[i] = ind_ascii_table[ number [i] - 32];
    }

}


static int8_t
ind_number_step_get( int16_t x )
{
    int8_t  step = 3;

    if( x < 1000 )
        step = 3;
    if( x < 100 )
        step = 2;
    if( x < 10 )
        step = 1;

    return step;
}


void
ind_print_dec( uint16_t number )
{
    uint8_t  string[4];
    uint8_t step;
    float voltage;

    string[0] = number / 1000;
    string[1] = number % 1000 / 100;
    string[2] = number % 100 / 10;
    string[3] = number % 10;

    step = ind_number_step_get(number);
    step = 4 - step;

    voltage = adc_value_get();	// * 4;

    for( int8_t i = 0; i < 4; i++ )
    {
//        if( i < step )
//        {
//            string[i] = ind_ascii_table[0];
//        }
//        else
//        {
//            string[i] = ind_ascii_table[string[i]+16];
//        }

    	if ( i == 1 && voltage < 10 )
    	{
    		string[i] = ind_ascii_table[string[i]+16];
    		string[i] &= ind_ascii_table[14];
    	}
    	else
    	if (i == 1)
    	{
    		string[i] = ind_ascii_table[string[i]+16];
    	}
    	else
    	if ( i == 2 && voltage >= 10 )
		{
    		string[i] = ind_ascii_table[string[i]+16];
    		string[i] &= ind_ascii_table[14];
		}
    	else
    	{
    		string[i] = ind_ascii_table[string[i]+16];
    	}


 //       string[i] += 48; //---
    }


    for( int8_t i = 0; i < 4; i++ )
    {
        indicator_data[i] = string[i];
    }
}


static void
clock_signal(void)
{
	   IND_PORT &= ~(1<<CLK);
	   __asm volatile("nop");
	   __asm volatile("nop");
	   __asm volatile("nop");
	   __asm volatile("nop");
	   IND_PORT |= (1<<CLK);
}


static void
latch_enable(void)
{
	   IND_PORT |= (1<<WRT);
	   __asm volatile("nop");
	   __asm volatile("nop");
	   __asm volatile("nop");
	   __asm volatile("nop");
	   IND_PORT &= ~(1<<WRT);
}







static void
indicator_data_send( void )
{

	DDRD |= (1 << DAT0);

    static int8_t  digit;
    uint8_t  control_shift_reg = 0;


    control_shift_reg = (1 << digit);
    control_shift_reg |= ind_led_state;

    control_shift_reg = ~control_shift_reg;

     int8_t i;


    // Loading data into the second shift register
    for( i = 0 ; i < 4 ; i++ )
    {
    	IND_PORT = ( (control_shift_reg << i) & (0x80) ) ? IND_PORT | (1<<DAT0) : IND_PORT & ~(1<<DAT0);
    	clock_signal();
    }

    for( i = 4 ; i < 8 ; i++ )
    {
    	IND_PORT = ( (control_shift_reg << i) & (0x80) ) ? IND_PORT | (1<<DAT0) : IND_PORT & ~(1<<DAT0);
    	clock_signal();
    }


    // Loading data into the first shift register
    for(  i = 0 ; i < 8 ; i++ )
    {
    	IND_PORT = ( (indicator_data[digit] << i) & (0x80) ) ? IND_PORT | (1<<DAT0) : IND_PORT & ~(1<<DAT0);
    	clock_signal();
    }

    latch_enable(); // Data finally submitted

    for( i = 0 ; i < 8 ; i++ )
    {
    	DDRD &= ~(1 << DAT0);

    	IND_PORT |= (1 << DAT0);			//perevesti data0 na vihod

//    	if ( button_state_get() == 0 )
//    	{
//    		PORTC |= (1 << 2);
//
//    	}

    	IND_PORT &= ~(1<<DAT0); 			//perevesti data0 na vhod

    }



    /** DIGIT = 1 */

    if( ++digit >= 4 )
    {
        digit = 0;
    }

    /** DIGIT = 2 */



}


void
ind_init( void )
{
    DDRD |= (1 << CLK) | (1 << DAT0) | (1 << WRT); // output

    // TIM0 Initialization
    // Fcpu / 1024 = 15625 HZ
    TCCR0B = (1 << CS02) | (0 << CS01) | (0 << CS00);

    TIMSK0 |= ( 1<<0 );
}


ISR (TIMER0_OVF_vect)
{
    indicator_data_send();
}




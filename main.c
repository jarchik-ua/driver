#define F_CPU 16000000L
//#define __AVR_ATmega168__

#include <inttypes.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <util/delay.h>

#include <drivers/indicator.h>
#include <drivers/Analog_to_digital_converter.h>


#define TIM1_OCR_PRESC      ( 15 ) // 1,0s for presc 1024


static uint16_t  timer_counter = 0;
unsigned int k1 = 100;

float Uvh_result;



ISR (TIMER1_COMPA_vect)
{
   timer_counter ++;
}



void
tim1_init( void )
{
   //
   // Ftim = Fcpu / 1024
   // CTC mode
   //
   TCCR1B = ( 1<<WGM12 );

   OCR1AH = TIM1_OCR_PRESC >> 8;
   OCR1AL = TIM1_OCR_PRESC & 0xff;

   TCCR1B |= ( 1<<CS12 ) | ( 0<<CS11 ) | ( 1<<CS10 );
   TIMSK1 |= ( 1<<OCIE1A );
}



int main( void )
{
	DDRD |= (1 << 5) | (1 << 6) | (1 << 7);						//test ADC
	PORTD &= ~( (1 << 5) | (1 << 6) | (1 << 7) );

	DDRC &= ~(1 << 2);											//working ADC port



//    uint16_t  timer = 0;
//    char message[6][5] = {"FAUL", "HEAT", "COLD", "1234", " HI ", " LO "};
//    char word[4];
//    int8_t  j = 0;



    ind_init();
    tim1_init();
    ADC_Init();

    sei();

    while( 1 )
    {

    	Uvh_result = Uvh_res();

    	if ( Uvh_result < 10 )
    	{
    		k1 = 100;
    	}
    	else
    	{
    		k1 = 10;
    	}

    	ind_print_dec ( Uvh_result * k1 );



    }

    return 0;
}

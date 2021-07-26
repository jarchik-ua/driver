#define F_CPU 16000000L
//#define __AVR_ATmega168__

#include <inttypes.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <util/delay.h>

#include <drivers/indicator.h>



#define TIM1_OCR_PRESC      ( 15 ) // 1,0s for presc 1024


static uint16_t  timer_counter = 0;



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

	ADCSRA |= (1 << ADEN);										//we allow the ADC to work
	ADCSRA |= (1 << ACSR);										//continuous transformation   //?ADFR
	ADCSRA |= (1 << ADPS0) | (1 << ADPS1) | (1 << ADPS2);		//frequency of discrediting = 125k Hz

	ADMUX |= (1 << REFS1) | (1 << REFS0);						//Internal 2.56 V reference
	ADMUX &= ~(1 << ADLAR); 									//right-hand alignment

	ADMUX &= ~((1 << MUX3) | (1 << MUX2) | (1 << MUX0));
	ADMUX |= (1 << MUX1);										//use ADC2

	ADCSRA |= (1 << ADSC);										//launch ADC

//    uint16_t  timer = 0;
//    char message[6][5] = {"FAUL", "HEAT", "COLD", "1234", " HI ", " LO "};
//    char word[4];
//    int8_t  j = 0;



    ind_init();
    tim1_init();

    sei();

    while( 1 )
    {
    	/*
            for( int8_t i = 0; i < 4; i++ )
            {
                word[i] = message[j][i];
            }


            if( timer_counter - timer >= 2000 )
            {

                timer = timer_counter;

                j += 1;

                if( j > 6 )
                {
                    j = 0;
                }
            }

            ind_print_string(word);
//            led_timer();

    	 */
    	if (ADCSRA & (1 << 4))
    	{
    		if (ADC >= 600)
    		{
    			PORTD |= (1 << 5);
    			PORTD &= ~((1 << 6) | (1 << 7));
    		}
    		if (ADC >= 600 && ADC < 520)
    		{
    			PORTD |= (1 << 6);
    			PORTD &= ~((1 << 5) | (1 << 7));
    		}
    		if (ADC < 520)
    		{
    			PORTD |= (1 << 7);
    			PORTD &= ~((1 << 5) | (1 << 6));
    		}

    		ADCSRA |= (1 << 4);
    	}
    }

    return 0;
}
#define F_CPU 16000000L
//#define __AVR_ATmega168__

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <util/delay.h>


#include <drivers/indicator.h>
#include <drivers/Analog_to_digital_converter.h>


#define TIM1_OCR_PRESC      ( 15 ) // 1,0s for presc 1024

#define SPS 9600UL
#define Trc 0.001f
#define K (SPS*Trc)


static uint16_t  timer_counter = 0;
unsigned int k1 = 100;

const int NUM_READ = 30;
int vector;
int ADC_vect;

int Uvh_result;

float k = 0.1;  // коэффициент фильтрации, 0.0-1.0



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



//  среднее арифметическое для int
int
midArifm( int vector )
{
	float sum = 0;                      // локальная переменная sum
	for (int i = 0; i < NUM_READ; i++)  // согласно количеству усреднений
		sum += vector;                  // суммируем значения с любого датчика в переменную sum
	return (sum / NUM_READ);
}

/*
// бегущее среднее
float
expRunningAverage( float newVal )
{
	static float filVal = 0;

	filVal += (newVal - filVal) * k;

	return filVal;
}
*/

/*
////// бегущее среднее с адаптивным коэффициентом
float
expRunningAverageAdaptive ( int newVal ) {
	static float filVal = 0;
	float k;
  // резкость фильтра зависит от модуля разности значений
	if (abs(newVal - filVal) > 1.5) k = 0.9;
	else k = 0.03;

	filVal += (newVal - filVal) * k;

	return filVal;
}
*/


int
expRunningAverageAdaptive ( int newVal ) {
	static float filVal = 0;
	float k;
  // резкость фильтра зависит от модуля разности значений
	if (abs(newVal - filVal) > 1.5) k = 0.9;
	else k = 0.03;

	filVal += (newVal - filVal) * k;

	return filVal;
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
    adc_init();

    sei();

    while( 1 )
    {

    	Uvh_result = adc_value_get();

//    	if ( Uvh_result < 10 )
//    	{
//    		k1 = 100;
//    	}
//    	else
//    	{
//    		k1 = 10;
//    	}

//    	vector =  Uvh_result * k1;

//    	ADC_vect = expRunningAverage ( vector );
//    	ADC_vect = midArifm ( Uvh_result );

    	ADC_vect = expRunningAverageAdaptive ( Uvh_result );


    	ind_print_dec ( ADC_vect );
    }

    return 0;
}

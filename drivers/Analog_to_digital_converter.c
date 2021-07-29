/*
 * Analog_to_digital_converter.c
 *
 *  Created on: 27 èþë. 2021 ã.
 *      Author: Y.Virsky
 */


#include <inttypes.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#include "Analog_to_digital_converter.h"


float Uvh = 0;

const float Koef = 5.38; 			//5.26


static uint16_t
ADC_convert (void)
{
	ADCSRA |= (1 << ADSC);  //launch ADC
	while( (ADCSRA & (1<<ADSC)) ) ;

	return (uint16_t) ADC;
}


uint16_t
adc_value_get( void )
{
	uint16_t  adc_value;

	adc_value = ADC_convert();

//	Uvh = ( adc_value * 5.00 * Koef) / 1024;

	return adc_value;
}


void
adc_init( void )
{
	ADCSRA = (1 << ADPS0) | (1 << ADPS1) | (1 << ADPS2);		//frequency of discrediting = 125k Hz

	ADMUX = (1 << MUX1) | (1 << MUX0);										//use ADC2

	ADCSRA |= (1 << ADEN);										//we allow the ADC to work
}

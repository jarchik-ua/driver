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

unsigned int adc_value;
float Uvh = 0;

const float Koef = 5.38; 			//5.26


void
ADC_Init( void )
{
	ADCSRA |= (1 << ADEN);										//we allow the ADC to work

	ADCSRA |= (1 << ADPS0) | (1 << ADPS1) | (1 << ADPS2);		//frequency of discrediting = 125k Hz

	ADMUX &= ~((1 << REFS1) | (1 << REFS0));

	ADMUX &= ~(1 << ADLAR); 									//right-hand alignment

	ADMUX &= ~((1 << MUX3) | (1 << MUX2) | (1 << MUX0));
	ADMUX |= (1 << MUX1);										//use ADC2
}


unsigned int
ADC_convert (void)
{
	ADCSRA |= (1 << ADSC);										//launch ADC
	while((ADCSRA & (1<<ADSC)));

	return (unsigned int) ADC;
}

float
Uvh_res ( void )
{
	adc_value = ADC_convert();

	Uvh = ( adc_value * 5.00 * Koef) / 1024;

	return Uvh;
}

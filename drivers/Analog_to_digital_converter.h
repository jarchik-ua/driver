/*
 * Analog_to_digital_converter.h
 *
 *  Created on: 27 èþë. 2021 ã.
 *      Author: Y.Virsky
 */

#ifndef DRIVERS_ANALOG_TO_DIGITAL_CONVERTER_H_
#define DRIVERS_ANALOG_TO_DIGITAL_CONVERTER_H_



void ADC_Init( void );
unsigned int ADC_convert ( void );
float Uvh_res ( void );


#endif /* DRIVERS_ANALOG_TO_DIGITAL_CONVERTER_H_ */

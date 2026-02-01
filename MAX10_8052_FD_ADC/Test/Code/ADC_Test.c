#include <stdio.h>
#include <stdlib.h>
// Special function register declarations for the MAX10-8052
#include <MAX10_8052.h>

#define CLK 33333333L
#define BAUD 115200L
#define TIMER_2_RELOAD (0x10000L-(CLK/(32L*BAUD)))
#define LOW(X)  (X%0x100)
#define HIGH(X) (X/0x100)

//  ~C51~  --code-loc 0x0000

__sfr __at (0xA1) ADC_C;
__sfr __at (0xA2) ADC_L;
__sfr __at (0xA3) ADC_H;


unsigned char _c51_external_startup(void)
{
	RCAP2H=HIGH(TIMER_2_RELOAD);
	RCAP2L=LOW(TIMER_2_RELOAD);
	T2CON=0x34; // #00110100B
	SCON=0x52; // Serial port in mode 1, ren, txrdy, rxempty

	return 0;
}

void main (void)
{
	// Turn LEDs off
	LEDRA=0x00;
	LEDRB=0x00;
	
	//Reset ADC
	printf("ADC test.\r\n\r\n");
	ADC_C=0x80; // Reset the ADC. Some delay may be needed
	while(1)
	{
		ADC_C=0x00;
		printf("%01x%02x ", ADC_H, ADC_L);
		ADC_C=0x01;
		printf("%01x%02x ", ADC_H, ADC_L);
		ADC_C=0x02;
		printf("%01x%02x ", ADC_H, ADC_L);
		ADC_C=0x03;
		printf("%01x%02x ", ADC_H, ADC_L);
		ADC_C=0x04;
		printf("%01x%02x ", ADC_H, ADC_L);
		ADC_C=0x05;
		printf("%01x%02x ", ADC_H, ADC_L);
		ADC_C=0x06;
		printf("%01x%02x ", ADC_H, ADC_L);
		ADC_C=0x07;
		printf("%01x%02x\r", ADC_H, ADC_L);
	}
	
}

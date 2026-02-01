//  ~C51~  

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <MAX10_8052.h>

#define CLK 33333333L
#define BAUD 115200L
#define TIMER_2_RELOAD (0x10000L-(CLK/(32L*BAUD)))
#define LOW(X)  (X%0x100)
#define HIGH(X) (X/0x100)

volatile unsigned char xdata __at (0x8000) rxcount;
volatile unsigned char xdata __at (0x8001) rxbuff[254];
volatile unsigned char xdata __at (0x8100) txcount;
volatile unsigned char xdata __at (0x8101) txbuff[254];

unsigned char xdata buff [256];

code unsigned char seven_seg[] = { 0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8,
                                   0x80, 0x90, 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E };

void main (void)
{
	int j;
	
	LEDRA=0;
	LEDRB=0;
	
	sprintf(txbuff, "******************************************************************************\r\n");
	txcount=strlen(txbuff);
	while(txcount!=0);
	sprintf(txbuff, "Hello, World!\r\n");
	txcount=strlen(txbuff);
	while(txcount!=0);
	sprintf(txbuff, "Another line for you!\r\n");
	txcount=strlen(txbuff);
	while(txcount!=0);
	sprintf(txbuff, "******************************************************************************\r\n");
	txcount=strlen(txbuff);
	while(txcount!=0);
	
	sprintf(txbuff, "\r\n");
	for (j=0; j<100; j++)
	{
		sprintf(buff, "The number is %03d\r\n", j);
		strcat(txbuff, buff);
	}
	txcount=1;
	while(txcount!=0);
	
	while(1)
	{
		if(KEY_1==0)
		{
			sprintf(txbuff, "KEY_1=0\r\n");
			txcount=strlen(txbuff);
			while(txcount!=0);
			while(KEY_1==0);
		}
		if(KEY_2==0)
		{
			sprintf(txbuff, "KEY_2=0\r\n");
			txcount=strlen(txbuff);
			while(txcount!=0);
			while(KEY_2==0);
		}
		if(KEY_3==0)
		{
			sprintf(txbuff, "KEY_3=0\r\n");
			txcount=strlen(txbuff);
			while(txcount!=0);
			while(KEY_3==0);
		}
		if(KEY_4==0)
		{
			sprintf(txbuff, "KEY_4=0\r\n");
			txcount=strlen(txbuff);
			while(txcount!=0);
			while(KEY_4==0);
		}
	}

}

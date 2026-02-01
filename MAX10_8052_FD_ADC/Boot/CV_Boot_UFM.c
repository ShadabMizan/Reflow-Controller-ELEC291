/*  MAX10-8052 bootloader using User Flash Memory (UFM1)

	Copyright (C) 2009-2024  Jesus Calvino-Fraga, jesusc (at) ece.ubc.ca
	   
	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation; either version 2, or (at your option) any
	later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

//  ~C51~  --code-loc 0xf000

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <MAX10_8052.h>

#define MEMORY_KEY 0x7fff
#define PAGE_SIZE 64

#define EQ(A,B) !strcmp((A),(B))

code unsigned char hexval[] = "0123456789ABCDEF";

#define CLK 33333333L
#define BAUD 115200L
#define TIMER_2_RELOAD (0x10000L-(CLK/(32L*BAUD)))
#define LOW(X)  (X%0x100)
#define HIGH(X) (X/0x100)

#define MAXBUFF 64
idata unsigned char buff[MAXBUFF];
bit getchar_echo=0;

typedef union
{
    unsigned char  byte[4];
    unsigned long  l;
} value_t;

unsigned long Read_UFM_control (unsigned char addr)
{
	value_t result;
	//avmm_csr_addr    => UFM_CONTROL_CMD_out_r(0)				
	//avmm_csr_read    => UFM_CONTROL_CMD_out_r(1)
	//avmm_csr_write   => UFM_CONTROL_CMD_out_r(2)

	UFM_CONTROL_CMD=addr & 0b_001; // read=0, write=0	
	UFM_CONTROL_CMD|=0b_010; // read=1
	UFM_CONTROL_CMD=0b_000; // read=0, write=0

	result.byte[3]=UFM_CONTROL3;
	result.byte[2]=UFM_CONTROL2;
	result.byte[1]=UFM_CONTROL1;
	result.byte[0]=UFM_CONTROL0;

	return result.l;
}

void Write_UFM_control (unsigned char addr, unsigned long value)
{
	value_t mybytes;
	//avmm_csr_addr    => UFM_CONTROL_CMD_out_r(0)				
	//avmm_csr_read    => UFM_CONTROL_CMD_out_r(1)
	//avmm_csr_write   => UFM_CONTROL_CMD_out_r(2)
	
	mybytes.l=value;
	UFM_CONTROL3=mybytes.byte[3];
	UFM_CONTROL2=mybytes.byte[2];
	UFM_CONTROL1=mybytes.byte[1];
	UFM_CONTROL0=mybytes.byte[0];

	UFM_CONTROL_CMD=addr & 0b_001; // read=0, write=0	
	UFM_CONTROL_CMD|=0b_100; // read=1
	UFM_CONTROL_CMD=0b_000; // read=0, write=0
}

#ifdef TESTING_UFM_FUNCTIONS
// Function here for testing.  More efficient assembly subroutine used instead.
void Read_UFM_data_bytes (unsigned long addr, unsigned char * mybytes)
{
	//avmm_data_burstcount => UFM_DATA_CMD_out_r(3 downto 0),
	//avmm_data_read       => UFM_DATA_CMD_out_r(4)
	//avmm_data_write      => UFM_DATA_CMD_out_r(5)
	//avmm_data_waitrequest   => UFM_DATA_STATUS_in_r(0)
	//avmm_data_readdatavalid => UFM_DATA_STATUS_in_r(1)
	
	UFM_ADD0=addr%0x100;
	UFM_ADD1=addr/0x100;
	UFM_ADD2=0;

	UFM_DATA_CMD=0b_01_0001; // write=0, read=1, burstcount=0001b
	UFM_DATA_CMD=0b_00_0001; // read=0, write=0
	while((UFM_DATA_STATUS&0x02)!=0x02);// Wait for readdatavalid
	
	mybytes[3]=UFM_DATA3;
	mybytes[2]=UFM_DATA2;
	mybytes[1]=UFM_DATA1;
	mybytes[0]=UFM_DATA0;
}

// Function here for testing.  More efficient assembly subroutine used instead.
void Write_UFM_data_bytes (unsigned int addr, unsigned char * mybytes)
{
	//avmm_data_burstcount    => UFM_DATA_CMD_out_r(3 downto 0),
	//avmm_data_read          => UFM_DATA_CMD_out_r(4)
	//avmm_data_write         => UFM_DATA_CMD_out_r(5)
	//avmm_data_waitrequest   => UFM_DATA_STATUS_in_r(0)
	//avmm_data_readdatavalid => UFM_DATA_STATUS_in_r(1)

	UFM_ADD0=addr%0x100;
	UFM_ADD1=addr/0x100;
	UFM_ADD2=0;
	
	UFM_DATA3=mybytes[3];
	UFM_DATA2=mybytes[2];
	UFM_DATA1=mybytes[1];
	UFM_DATA0=mybytes[0];

	UFM_DATA_CMD=0b_00_0001;  // read=0, write=0, burstcount=0001b
	UFM_DATA_CMD|=0b_10_0001; // read=1, write=0, burstcount=0001b
	while((UFM_DATA_STATUS&0x01)==0x01);// Wait for write to finish
	UFM_DATA_CMD=0b_00_0001;  // read=0, write=0, burstcount=0000b
}
#endif

void inituart (void)
{
	RCAP2H=HIGH(TIMER_2_RELOAD);
	RCAP2L=LOW(TIMER_2_RELOAD);
	T2CON=0x34; // #00110100B
	SCON=0x52; // Serial port in mode 1, ren, txrdy, rxempty
}

void putchar (char c)
{
	if (c=='\n')
	{
		while (!TI);
		TI=0;
		SBUF='\r';
	}
	while (!TI);
	TI=0;
	SBUF=c;
}

char getchar (void)
{
	char c;
	
	while (!RI);
	RI=0;
	c=SBUF;
	if (getchar_echo==1) putchar(c);

	return c;
}

char getchare (void)
{
	char c;
	
	c=getchar();
	putchar(c);
	return c;
}

void sends (unsigned char * c)
{
	unsigned char n;
	while(n=*c)
	{
		putchar(n);
		c++;
	}
}

unsigned char chartohex(char c)
{
	if(c & 0x40) c+=9; //  a to f or A to F
	return (c & 0xf);
}

// Get a byte from the serial port without echo
unsigned char getbyte (void)
{
	volatile unsigned char j; // volatile variable eliminates some push/pop instrutions

	j=chartohex(getchare())*0x10;
	j|=chartohex(getchare());

	return j;
}

void EraseSector (void)
{
	// Enable write and erase to UFM1
	Write_UFM_control(1, 0x0f1fffffL); // (23 downto 20) <= '0001'
	// Wait for erase to finish
	while ((Read_UFM_control(0)&0x00000003L)!=0);
}

void Write_XRAM (unsigned int Address, unsigned char Value)
{
	*((unsigned char xdata *) Address)=Value;
}

unsigned char Read_XRAM (unsigned int Address)
{
	return *((unsigned char xdata *) Address);
}

// Should take less than 10ms.  The inner loop is executed 32768 times.  It takes 1+1+1+2+2=7 machine cycles
// per pass of the loop, or 210ns.  32768*219ns=7ms approximately.
void Clear_XRAM (void)
{
	XRAMUSEDAS=0x01; // 32k RAM accessed as xdata

	_asm
		; Save used registers
		push dpl
		push dph
		push acc
		clr a
		mov dpl, a
		mov dph, a
	Clear_XRAM_Loop:
		clr a
		movx @dptr, a
		inc dptr
		mov a, dph
		jnb acc.7, Clear_XRAM_Loop ; Check when dph is equal to 0x80 after increment
		pop acc
		pop dph
		pop dpl
	_endasm;
}

void Copy_Flash_to_XRAM (void)
{
	XRAMUSEDAS=0x01; // 32k RAM accessed as xdata

	_asm
		; Save used registers
		push dpl
		push dph
		push acc
		
		; Init pointers
		mov dptr, #0x0000
		mov _UFM_ADD0, #0x00
		mov _UFM_ADD1, #0x00
		mov _UFM_ADD2, #0x00
		
		; Copy loop
	ufm2xram_loop:
		mov _UFM_DATA_CMD, #0b_01_0001 ; // write=0, read=1, burstcount=0001b
		mov _UFM_DATA_CMD, #0b_00_0001 ; // read=0, write=0
	ufm2xram_wait:
		mov a, _UFM_DATA_STATUS
		jnb acc.1, ufm2xram_wait

		; Save the flash 32 bits to xram  
		mov a, _UFM_DATA0
		movx @dptr, a
		inc dptr
		mov a, _UFM_DATA1
		movx @dptr, a
		inc dptr
		mov a, _UFM_DATA2
		movx @dptr, a
		inc dptr
		mov a, _UFM_DATA3
		movx @dptr, a
		inc dptr
	
		; Increment destination address and check
		inc _UFM_ADD0
		mov a, _UFM_ADD0
		jnz ufm2xram_loop
		inc _UFM_ADD1
		mov a, _UFM_ADD1
		jnb acc.5, ufm2xram_loop ; UFM1 ends at 0x2000, so when bit 5 is '1' we are done.
		
		; Restore used registers
		pop acc
		pop dph
		pop dpl
	_endasm;
}

void Load_Ram_Fast_and_Run (void)
{
	Copy_Flash_to_XRAM();

	T2CON=0;
	SCON=0;
	RCAP2H=0;
	RCAP2L=0;

	_asm
		mov _XRAMUSEDAS, #0 ; 32k RAM accessed as code
		; RAM is loaded with user code.  Run it.
		mov sp, #7
		ljmp 0x0000
	_endasm;
}

void Load_Ram_Fast_and_Run_Debugger (void)
{
	Copy_Flash_to_XRAM();

	T2CON=0;
	SCON=0;
	RCAP2H=0;
	RCAP2L=0;
	LEDRA=0xff;
	LEDRB=0xff;

	_asm
		mov _XRAMUSEDAS, #0 ; 32k RAM accessed as code
		mov sp, #7

		; RAM is loaded with user code.  Run the debugger now.
		ljmp 0xc000
	_endasm;
}

void Copy_XRAM_to_UFM (void)
{
	_asm
		; Save used registers
		push dpl
		push dph
		push acc
		push b
		
		; Init pointers
		mov dptr, #0x0000
		mov _UFM_ADD0, #0x00
		mov _UFM_ADD1, #0x00
		mov _UFM_ADD2, #0x00
		
		; Copy loop
	xram2ufm_loop:
		; Load 32 bits from xram  
		movx a, @dptr
		mov _UFM_DATA0, a
		mov b, a
		inc dptr
		movx a, @dptr
		mov _UFM_DATA1, a
		orl b, a
		inc dptr
		movx a, @dptr
		mov _UFM_DATA2, a
		orl b, a
		inc dptr
		movx a, @dptr
		mov _UFM_DATA3, a
		orl a, b
		inc dptr
		
		jz xram2ufm_skip ; If all four bytes are zero, do not write to flash.  In the implementation
		                 ; of the interface to the UFM, both the input and output ports are inverted
		                 ; so 0x00 is stored as 0xff in the flash.  After erase, the flash is all 0xff.
		
	xram2ufm_write:		
		; Write to flash
		orl _UFM_DATA_CMD, #0b_10_0001 ;  read=1, write=0, burstcount=0001b
	xram2ufm_wait:
		mov a, _UFM_DATA_STATUS
		jb acc.0, xram2ufm_wait
		mov _UFM_DATA_CMD, #0b_00_0001 ;  read=0, write=0, burstcount=0000b
	xram2ufm_skip:
		
		; Increment destination address and check
		inc _UFM_ADD0
		mov a, _UFM_ADD0
		jnz xram2ufm_loop
		inc _UFM_ADD1
		mov a, _UFM_ADD1
		jnb acc.5, xram2ufm_loop ; UFM1 ends at 0x2000, so when bit 5 is '1' we are done.
		
		setb _LEDRA_1
		; Restore used registers
		pop b
		pop acc
		pop dph
		pop dpl
	_endasm;
}

void loadintelhex (void)
{
	volatile unsigned int address;
	volatile unsigned char j, k, size, type, checksum, n;
	volatile char echo;
	unsigned char savedcs;

	while(1)
	{
		n=getchare();

		if(n==(unsigned char)':')
		{
			echo='.'; // If everything works ok, send a period...
			size=getbyte();
			checksum=size;
			
			address=getbyte();
			checksum+=address;
			address*=0x100;
			n=getbyte();
			checksum+=n;
			address+=n;
			
			type=getbyte();
			checksum+=type;

			for(j=0; j<size; j++)
			{
				n=getbyte();
				if(j<MAXBUFF) buff[j]=n; // Don't overrun the buffer
				checksum+=n;
			}
			
			savedcs=getbyte();
			checksum+=savedcs;
			if(size>MAXBUFF) checksum=1; // Force a checksum error
	
			if(checksum==0) switch(type)
			{
				case 4: // Erase command.
					EraseSector();
					Clear_XRAM();
					LEDRA_1=1; // Flash erased
				break;

				case 0: // Write to XRAM
					for(k=0; k<j; k++)
					{
						Write_XRAM(address, buff[k]);
						address++;
					}
				break;
				
				case 3: // Send ID number command.
					sends("DE1");
				break;
				
				case 1: // End record: Write XRAM to flash
					putchar(echo); // Acknowledge inmediatly
					Copy_XRAM_to_UFM();
					LEDRA_2=1; // Flash loaded
				break;
				
				default: // Unknown command;
					echo='?';
					LEDRA_2=1;
				break;
			}
			else
			{
				echo='X'; // Checksum error
				LEDRA_1=1;
			}
			if(type!=1) putchar(echo);
		}
		else if(n==(unsigned char)'U')
		{
			LEDRA=0;
			LEDRB=0;
			LEDRA=1; // Bootloader running
		}
	}
}

unsigned int str2hex (char * s)
{
	unsigned int x=0;
	unsigned char i;
	while(*s)
	{
		if((*s>='0')&&(*s<='9')) i=*s-'0';
		else if ( (*s>='A') && (*s<='F') ) i=*s-'A'+10;
		else if ( (*s>='a') && (*s<='f') ) i=*s-'a'+10;
		else break;
		x=(x*0x10)+i;
		s++;
	}
	return x;
}

void OutByte (unsigned char x)
{
	putchar(hexval[x/0x10]);
	putchar(hexval[x%0x10]);
}

void OutWord (unsigned int x)
{
	OutByte(x/0x100);
	OutByte(x%0x100);
}

code unsigned char seven_seg[] = { 0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8,
                                   0x80, 0x90, 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E };

void Manual_Load (void)
{
	unsigned int add;
	unsigned char val, h_add, l_add;
	
	// Load RAM with the program in flash for manual edition
	Copy_Flash_to_XRAM();

	LEDRA=0;
	LEDRB=0;
 	
	add=0;
	
	while(1)
	{
		// Display address
		h_add=add/0x100;
		l_add=add%0x100;
		HEX5=seven_seg[h_add/0x10];
		HEX4=seven_seg[h_add%0x10];
		HEX3=seven_seg[l_add/0x10];
		HEX2=seven_seg[l_add%0x10];
		// Display the data at the address above
		val=Read_XRAM(add);
		HEX1=seven_seg[val/0x10];
		HEX0=seven_seg[val%0x10];

		if((KEY_2==0) && (KEY_1==1))
		{
			while (KEY_2==0); // Wait for key release
			if((SWB&0x01)==0x01) // Reading address low
			{
				add&=0x7f00;
				add|=SWA;	
			}
			else if((SWB&0x02)==0x02) // Reading address high
			{
				add&=0x00ff;
				add|=(SWA*0x100);	
			}
			else if ((SWB&0x03)==0) // Reading data
			{
				val=SWA;
				Write_XRAM(add, val);
			}
		}
		
		else if(KEY_4==0) // Increment address
		{
			while(KEY_4==0); // Wait for key release
			LEDRA_1=0;
			LEDRA_2=0;
			add++;
			if (add>0x7fff) add=0;
		}
		else if (KEY_3==0) // Decrement address
		{
			while(KEY_3==0); // Wait for key release
			LEDRA_1=0;
			LEDRA_2=0;
			add--;
			if (add>0x7fff) add=0x7fff;
		}
		else if ( (KEY_2==0) && (KEY_1==0) ) // Save RAM to flash
		{
			while( (KEY_2==0) && (KEY_1==0) ); // Wait for key release
			EraseSector();
			LEDRA_1=1;
			Copy_XRAM_to_UFM();
			LEDRA_2=1;
		}
	}
}

#define LetterD 0xA1
#define LetterE 0x86
#define LetterB 0x83
#define LetterU 0xC1
#define LetterG 0xC2
#define LetterO 0b_1010_0011
#define LetterT 0b_1000_0111
#define Dash    0b_1011_1111

void main (void)
{
	unsigned char d;
	
	// read and write are active high both for UFM data and control
	UFM_DATA_CMD=0x00;
	UFM_CONTROL_CMD=0x00;
	
	KEY_2=0; // Ground por key2
	KEY_3=0; // Ground por key3

	if( (KEY_1==1) && (KEY_3==1) && (KEY_4==1) ) Load_Ram_Fast_and_Run();

	if (KEY_4==0) // Run debugger?
	{
		HEX5=LetterD;
		HEX4=LetterE;
		HEX3=LetterB;
		HEX2=LetterU;
		HEX1=LetterG;
		HEX0=LetterG;
		
		// Wait for the activation keys release
		while(KEY_4==0);

		HEX0=0xff;
		HEX1=0xff;
		HEX2=0xff;
		HEX3=0xff;
		HEX4=0xff;
		HEX5=0xff;

		Load_Ram_Fast_and_Run_Debugger();
	}

	if (KEY_3==0)
	{
		HEX5=Dash;
		HEX4=Dash;
		HEX3=Dash;
		HEX2=Dash;
		HEX1=Dash;
		HEX0=Dash;
		
		while(KEY_3==0);
		
		Manual_Load();
	}
	
	XRAMUSEDAS=1; // 32k RAM accessed as xdata

	HEX3=LetterB;
	HEX2=LetterO;
	HEX1=LetterO;
	HEX0=LetterT;
	
	while(KEY_1==0); // Wait for key release
	
	LEDRA=1;// Bootloader running
	LEDRB=0;
 
	HEX0=0xff;
	HEX1=0xff;
	HEX2=0xff;
	HEX3=0xff;
	HEX4=0xff;
	HEX5=0xff;

	inituart();
	
	// Set the memory key to zero.  If it is changed using the memory editor,
	// then copy whatever is in xram to flash.
	Write_XRAM(MEMORY_KEY, 0x00);
	
	//Determine which mode is being used for communication
	while(1)
	{
		if (RI==1)
		{
			d=SBUF;
			RI=0;
			if(d==(unsigned char)'U') break;
			TI=0; // Echo what was received
			SBUF=d;
		}
		
		if(Read_XRAM(MEMORY_KEY)!=0x00)
		{
			LEDRA_1=0;
			LEDRA_2=0;
			Write_XRAM(MEMORY_KEY, 0x00);
			EraseSector();
			LEDRA_1=1;
			Copy_XRAM_to_UFM();
			LEDRA_2=1;
		}
	}

	loadintelhex();
}

void dummy_switch(void) __naked
{
	_asm
		CSEG at 0xFFE0
		mov _XRAMUSEDAS, #0x00 ; 32k RAM accessed as code
		nop
		ret
		
		CSEG at 0xffE8
		mov _XRAMUSEDAS, #0x01 ; 32k RAM accessed as xdata
		nop
		ret
	_endasm;
}

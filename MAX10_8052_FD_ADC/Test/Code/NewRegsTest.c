#include <stdio.h>
#include <stdlib.h>
// Special function register declarations for the MAX10-8052
#include <MAX10_8052.h>

#define CLK 33333333L
#define BAUD 115200L
#define TIMER_2_RELOAD (0x10000L-(CLK/(32L*BAUD)))
#define LOW(X)  (X%0x100)
#define HIGH(X) (X/0x100)
#define dotest(x) x=0x55; printf(#x"=0x%02x\r\n", x); x=0xAA; printf(#x"=0x%02x\r\n", x)

//  ~C51~  --code-loc 0x0000

typedef union
{
    unsigned char  byte[4];
    unsigned long  l;
} value_t;

unsigned char _c51_external_startup(void)
{
	RCAP2H=HIGH(TIMER_2_RELOAD);
	RCAP2L=LOW(TIMER_2_RELOAD);
	T2CON=0x34; // #00110100B
	SCON=0x52; // Serial port in mode 1, ren, txrdy, rxempty

	return 0;
}

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

unsigned long Read_UFM_data (unsigned long addr)
{
	value_t result;
	//avmm_data_burstcount => UFM_DATA_CMD_out_r(3 downto 0),
	//avmm_data_read       => UFM_DATA_CMD_out_r(4)
	//avmm_data_write      => UFM_DATA_CMD_out_r(5)
	//avmm_data_waitrequest   => UFM_DATA_STATUS_in_r(0)
	//avmm_data_readdatavalid => UFM_DATA_STATUS_in_r(1)
	
	result.l=addr;
	UFM_ADD0=result.byte[0];
	UFM_ADD1=result.byte[1];
	UFM_ADD2=result.byte[2];

	//UFM_DATA_CMD=0b_1_00_0001; // Clear readdatavalid and set burstcount=0001b	
	//UFM_DATA_CMD=0b_0_01_0001; // read=1, write=0
	UFM_DATA_CMD=0b_01_0001; // write=0, read=1, burstcount=0001b
	UFM_DATA_CMD=0b_00_0001; // read=0, write=0

	while((UFM_DATA_STATUS&0x02)!=0x02);// Wait for readdatavalid
	
	result.byte[3]=UFM_DATA3;
	result.byte[2]=UFM_DATA2;
	result.byte[1]=UFM_DATA1;
	result.byte[0]=UFM_DATA0;

	return result.l;
}

void Write_UFM_data (unsigned long addr, unsigned long value)
{
	value_t mybytes;
	//avmm_data_burstcount    => UFM_DATA_CMD_out_r(3 downto 0),
	//avmm_data_read          => UFM_DATA_CMD_out_r(4)
	//avmm_data_write         => UFM_DATA_CMD_out_r(5)
	//avmm_data_waitrequest   => UFM_DATA_STATUS_in_r(0)
	//avmm_data_readdatavalid => UFM_DATA_STATUS_in_r(1)

	mybytes.l=addr;
	UFM_ADD0=mybytes.byte[0];
	UFM_ADD1=mybytes.byte[1];
	UFM_ADD2=mybytes.byte[2];
	
	mybytes.l=value;
	UFM_DATA3=mybytes.byte[3];
	UFM_DATA2=mybytes.byte[2];
	UFM_DATA1=mybytes.byte[1];
	UFM_DATA0=mybytes.byte[0];

	UFM_DATA_CMD=0b_00_0001;  // read=0, write=0, burstcount=0001b
	UFM_DATA_CMD|=0b_10_0001; // read=1, write=0, burstcount=0001b
	while((UFM_DATA_STATUS&0x01)==0x01);// Wait for write to finish
	UFM_DATA_CMD=0b_00_0001;  // read=0, write=0, burstcount=0000b
}

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

void main (void)
{
	unsigned char mybytes[4];
	unsigned int j;
	
	// Turn LEDs off
	LEDRA=0x00;
	LEDRB=0x00;
	
	// read and write are active high both for UFM data and control
	UFM_DATA_CMD=0x00;
	UFM_CONTROL_CMD=0x00;
	
	printf("User Flash Memory test.\r\n");
	printf("flash_status_reg=0x%08lx\r\n", Read_UFM_control(0));
	printf("flash_control_reg=0x%08lx\r\n", Read_UFM_control(1));
	printf("flash_data(0)=0x%08lx\r\n", Read_UFM_data(0x0000L));
	printf("flash_data(1)=0x%08lx\r\n", Read_UFM_data(0x0001L));
	printf("flash_data(2)=0x%08lx\r\n", Read_UFM_data(0x0002L));
	printf("flash_status_reg=0x%08lx\r\n", Read_UFM_control(0));
	
	/*
	printf("\r\nErasing UFM1\r\n");
	// Enable write and erase to UFM1
	Write_UFM_control(1, 0x0f1fffffL); // (23 downto 20) <= '0001'
	// Wait for erase to finish
	while ((Read_UFM_control(0)&0x00000003L)!=0);
	printf("flash_status_reg=0x%08lx\r\n", Read_UFM_control(0));
	printf("flash_data(0)=0x%08lx\r\n", Read_UFM_data(0x0000L));
	printf("flash_data(1)=0x%08lx\r\n", Read_UFM_data(0x0001L));
	printf("flash_data(2)=0x%08lx\r\n", Read_UFM_data(0x0002L));

	printf("\r\nWriting to UFM1\r\n");
	// Enable write to UFM1
	// Write_UFM_control(1, 0x0f7fffffL); // (23 downto 20) <= '0111'
	Write_UFM_data(0x0000L, 0x12345678UL);
	Write_UFM_data(0x0001L, 0x55555555UL);
	Write_UFM_data(0x0002L, 0xAAAAAAAAUL);
	printf("flash_status_reg=0x%08lx\r\n", Read_UFM_control(0));
	printf("flash_data(0)=0x%08lx\r\n", Read_UFM_data(0x0000L));
	printf("flash_data(1)=0x%08lx\r\n", Read_UFM_data(0x0001L));
	printf("flash_data(2)=0x%08lx\r\n", Read_UFM_data(0x0002L));
	*/
	
	printf("\r\nErasing UFM1\r\n");
	// Enable write and erase to UFM1
	Write_UFM_control(1, 0x0f1fffffL); // (23 downto 20) <= '0001'
	// Wait for erase to finish
	while ((Read_UFM_control(0)&0x00000003L)!=0);
	printf("flash_status_reg=0x%08lx\r\n", Read_UFM_control(0));
	Read_UFM_data_bytes(0, mybytes);
	printf("flash_data(0)=0x%02x%02x%02x%02x\r\n", mybytes[3], mybytes[2], mybytes[1], mybytes[0]);
	Read_UFM_data_bytes(1, mybytes);
	printf("flash_data(1)=0x%02x%02x%02x%02x\r\n", mybytes[3], mybytes[2], mybytes[1], mybytes[0]);
	Read_UFM_data_bytes(2, mybytes);
	printf("flash_data(2)=0x%02x%02x%02x%02x\r\n", mybytes[3], mybytes[2], mybytes[1], mybytes[0]);

	printf("\r\nWriting to UFM1\r\n");
	mybytes[3]=0x12; mybytes[2]=0x34; mybytes[1]=0x56; mybytes[0]=0x78;
	Write_UFM_data_bytes(0, mybytes);	
	mybytes[3]=0x55; mybytes[2]=0x55; mybytes[1]=0x55; mybytes[0]=0x55;
	Write_UFM_data_bytes(1, mybytes);	
	mybytes[3]=0xaa; mybytes[2]=0xaa; mybytes[1]=0xaa; mybytes[0]=0xaa;
	Write_UFM_data_bytes(2, mybytes);
	
	for(j=0; j<292; j++); // Need some delay after writing to read.  275 fails.  300 works.
	//printf("\r\nReading back to UFM1\r\n");
	Read_UFM_data_bytes(0, mybytes);
	printf("flash_data(0)=0x%02x%02x%02x%02x\r\n", mybytes[3], mybytes[2], mybytes[1], mybytes[0]);
	Read_UFM_data_bytes(1, mybytes);
	printf("flash_data(1)=0x%02x%02x%02x%02x\r\n", mybytes[3], mybytes[2], mybytes[1], mybytes[0]);
	Read_UFM_data_bytes(2, mybytes);
	printf("flash_data(2)=0x%02x%02x%02x%02x\r\n", mybytes[3], mybytes[2], mybytes[1], mybytes[0]);
		
	/*
	dotest(UFM_ADD0);
	dotest(UFM_ADD1);
	dotest(UFM_ADD2);
	
	dotest(UFM_DATA0);
	dotest(UFM_DATA1);
	dotest(UFM_DATA2);
	dotest(UFM_DATA3);
	
	dotest(UFM_CONTROL0);
	dotest(UFM_CONTROL1);
	dotest(UFM_CONTROL2);
	dotest(UFM_CONTROL3);

	dotest(UFM_DATA_CMD);
	dotest(UFM_DATA_STATUS);
	dotest(UFM_CONTROL_CMD);
	*/
}

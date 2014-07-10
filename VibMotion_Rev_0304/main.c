#include <msp430.h>
#include "inc/hw_memmap.h"
#include "HAL/i2c.h"
#include "Sensors/ucs.h"
#include "Sensors/wdt.h"
#include "Sensors/gpio.h"
#include "Sensors/mpu9150.h"
#include "Sensors/uart.h"
#include "Sensors/pmm.h"

#include "clock_freq_defs.h"
#include "BasicSettings.h"

void setFreq(void);
void SetVcoreUp (unsigned int level);
void setBluetooth(void);
void initTimerB (void);
void initMPU9150 (void);
void sleepMPU9150(void);
void byteStuff (unsigned char* dataPkt, unsigned char len, unsigned char* outPkt, unsigned char* outLen);
void sendSensorData (void);


unsigned char msg;
unsigned char pkt [24] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
unsigned char outPkt [50];
static unsigned int pktNo = 0;
unsigned char sampleIsReady = 0;

#define LED1 BIT2
#define LED2 BIT3
#define LOWBYTE(v)   ((unsigned char) (v))
#define HIGHBYTE(v)  ((unsigned char) (((unsigned int) (v)) >> 8))

#define DLE	0x10
#define SOH 0x01
#define EOT	0x04
#define DISCON_TIMEOUT 10

void main(void) {

	unsigned char cled = 0;
	unsigned char isConnected = 0;
	unsigned int disConCounter = 0;

	WDTCTL = WDTPW+WDTHOLD;                   // Stop WDT

	/*char status = PMM_setVCore(__MSP430_BASEADDRESS_PMM__,
			PMM_CORE_LEVEL_3
	        );*/

	  // Enable regulator for the peripherals
	  GPIO_setAsOutputPin(__MSP430_BASEADDRESS_PORT1_R__,
	    GPIO_PORT_P1,
	    GPIO_PIN7
	    );
	  GPIO_setOutputLowOnPin (__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN7);


	setFreq();                                //set DCO=16MHz, SMCLK=MCLK=16M, ACLK=REFO=32K
	setBluetooth();
	GPIO_setAsInputPinWithPullDownresistor (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN6);

    //P1DIR |= BIT0;                            // ACLK set out to pins
    //P1SEL |= BIT0;
    //P2DIR |= BIT2;                            // SMCLK set out to pins
    //P2SEL |= BIT2;

	// setup BT connection status pin
    //GPIO_setAsInputPin (__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN2);
	GPIO_setAsInputPinWithPullUpresistor (__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN2);
    GPIO_interruptEdgeSelect (__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN2, GPIO_LOW_TO_HIGH_TRANSITION);
    GPIO_enableInterrupt (__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN2);

    // configure Vibrator ports -- remove for new SD boards
#if 0
    GPIO_setAsOutputPin (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN0 + GPIO_PIN1 + GPIO_PIN2);
    GPIO_setDriveStrength(__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN0 + GPIO_PIN1 + GPIO_PIN2, GPIO_FULL_OUTPUT_DRIVE_STRENGTH);
    GPIO_setOutputHighOnPin(__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN0 + GPIO_PIN1 + GPIO_PIN2);
    GPIO_setAsOutputPin (__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN7);
    GPIO_setDriveStrength(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN7, GPIO_FULL_OUTPUT_DRIVE_STRENGTH);
    GPIO_setOutputHighOnPin(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN7);
#endif
    // configure LED
    GPIO_setAsOutputPin (__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN3 + GPIO_PIN4);
    GPIO_setDriveStrength(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN3 + GPIO_PIN4, GPIO_FULL_OUTPUT_DRIVE_STRENGTH);
    GPIO_setOutputLowOnPin(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN3 + GPIO_PIN4);

    GPIO_setAsPeripheralModuleFunctionInputPin(__MSP430_BASEADDRESS_PORT4_R__,
        GPIO_PORT_P4,
        GPIO_PIN1 + GPIO_PIN2
        );

    while(1){
    	P1OUT &= ~BIT3;
    	__enable_interrupt();
    	__bis_SR_register(LPM3_bits+GIE);
  //  	__no_operation();
    	while((GPIO_getInputPinValue(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN2))==0);

    	isConnected = 1;
    	sampleIsReady = 0;

    	// configure int for MPU-9150 sample ready
    	//GPIO_setAsInputPin (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3);
    	GPIO_setAsInputPinWithPullUpresistor (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3);
    	//GPIO_interruptEdgeSelect (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3, GPIO_LOW_TO_HIGH_TRANSITION);
    	GPIO_interruptEdgeSelect (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3, GPIO_LOW_TO_HIGH_TRANSITION);
    	GPIO_enableInterrupt (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3);
    	//__enable_interrupt();

    	pktNo = 0;
    	cled = 0;
    	disConCounter = 0;
    	initTimerB ();
    	UCB1_MasterI2C_init (I2C_7bit_addr, I2C_CLK_SMCLK, 16000000/400000);
//    	__disable_interrupt();
    	initMPU9150 ();
//    	__enable_interrupt();
    	//GPIO_setAsInputPin (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3);
    	//GPIO_interruptEdgeSelect (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3, GPIO_LOW_TO_HIGH_TRANSITION);
    	//GPIO_enableInterrupt (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3);
    	__enable_interrupt();

    	//while(P1IN&BIT2){		// do while connection is established
    	while(isConnected){		// do while connection is established
        	//__bis_SR_register(LPM3_bits+GIE);
        	//GPIO_setAsInputPinWithPullUpresistor (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3);

        	while (!sampleIsReady){
        		// show RTS signal on RED LED
    			if (GPIO_getInputPinValue(__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN6))
    			{
    			    GPIO_setOutputHighOnPin(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN3);
    			}
    			else
    			{
    			    GPIO_setOutputLowOnPin(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN3);
    			}
    		}
        	/*
        	while ((TB0R & 0x03) != 0){
    			if (GPIO_getInputPinValue(__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3))
    			{
    			    GPIO_setOutputHighOnPin(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN4);
    			}
    			else
    			{
    			    GPIO_setOutputLowOnPin(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN4);
    			}
        	}*/


        	//GPIO_setAsInputPinWithPullDownresistor (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3);

    		sampleIsReady = 0;
    		sendSensorData ();
    		cled ++;
    		if (cled >= 100)
    		{
    			cled = 0;
    			GPIO_toggleOutputOnPin(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN4);
    		}
    		if (P1IN&BIT2)
    			disConCounter = 0;
    		else
    			disConCounter ++;
    		isConnected = (disConCounter < DISCON_TIMEOUT);

    		/*
    		while ((TB0R & 0x03) == 0){
    			if (GPIO_getInputPinValue(__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3))
    			{
    			    GPIO_setOutputHighOnPin(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN4);
    			}
    			else
    			{
    			    GPIO_setOutputLowOnPin(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN4);
    			}
        	}*/

    	}
    	GPIO_disableInterrupt (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3);
    	sleepMPU9150 ();
        GPIO_setOutputLowOnPin(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN3 + GPIO_PIN4);
   // 	disableTimer();
	}


//   	GPIO_toggleOutputOnPin(__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN3);

}

void initMPU9150 (void)	{
	unsigned char configData [1];
    UCB1_I2C_read (MPU6050_DEFAULT_ADDRESS, MPU6050_RA_WHO_AM_I, configData, 1);
	// wake up sensor
	configData [0]=0x04;
	UCB1_I2C_write (MPU6050_DEFAULT_ADDRESS, MPU6050_RA_PWR_MGMT_1, configData, 1);
	//set acc sensitivity to 2G
	configData [0]=0x00;
	UCB1_I2C_write (MPU6050_DEFAULT_ADDRESS, MPU6050_RA_ACCEL_CONFIG, configData, 1);
	//set DLPF to 94 Hz
	configData [0]=0x02;
	UCB1_I2C_write (MPU6050_DEFAULT_ADDRESS, MPU6050_RA_CONFIG, configData, 1);
	//set sampling to 200 Hz
	configData [0]=0x04;
	UCB1_I2C_write (MPU6050_DEFAULT_ADDRESS, MPU6050_RA_SMPLRT_DIV, configData, 1);
	//set gyro sensitivity to +/-250 deg/sec
	configData [0]=0x00;
	UCB1_I2C_write (MPU6050_DEFAULT_ADDRESS, MPU6050_RA_GYRO_CONFIG, configData, 1);
	//Configure int and enable I2C bypass
	configData [0]=0x32;
	UCB1_I2C_write (MPU6050_DEFAULT_ADDRESS, MPU6050_RA_INT_PIN_CFG, configData, 1);

	//Enable data ready int
	//configData [0]=0x01;
	//UCB1_I2C_write (MPU6050_DEFAULT_ADDRESS, MPU6050_RA_INT_ENABLE, configData, 1);

	// read magnetometer signature - should be 0x48h
    UCB1_I2C_read (AK8975_DEFAULT_ADDRESS, AK8975_REG_WIA, configData, 1);
	// start single measurement
	configData [0]=0x01;
    UCB1_I2C_write (AK8975_DEFAULT_ADDRESS, AK8975_REG_CNTL, configData, 1);

	//Enable data ready int
	configData [0]=0x01;
	UCB1_I2C_write (MPU6050_DEFAULT_ADDRESS, MPU6050_RA_INT_ENABLE, configData, 1);

}

void setFreq(void){
	////////////////////set ACLK/////////////////////
	P5SEL |= BIT4+BIT5;						 	// select P5.4 P5.5 as XT1 function
	UCSCTL6 &= ~(XT1OFF);                       // XT1 open
	UCSCTL6 |= XCAP_3;                          // select internal cap
	do
	{
		UCSCTL7 &= ~XT1LFOFFG;                  // clear XT1 error flag
	}while (UCSCTL7&XT1LFOFFG);                 // wait until XT1 is stable
	/////////////////////////////////////////////

	//////////////////set main clock/////////////////////
	PMM_setVCore(__MSP430_BASEADDRESS_PMM__, PMM_CORE_LEVEL_1);// set core voltage
	__bis_SR_register(SCG0);                  // Disable the FLL control loop
	UCSCTL0 = 0x0000;                         // Set lowest possible DCOx, MODx
	UCSCTL1 = DCORSEL_5;                  		// Select DCO range 16MHz operation
	UCSCTL2 = FLLD_0 + 487;        			// Set DCO Multiplier for 16MHz, DCO= 32.768Khz * (487+1) =15.990784Mhz
	UCSCTL4 = SELA__XT1CLK+SELM__DCOCLK+SELS__DCOCLKDIV;
	__bic_SR_register(SCG0);                  // Enable the FLL control loop

	// 32 x 32 x 25 MHz / 32,768 Hz ~ 780k MCLK cycles for DCO to settle
	__delay_cycles(782000);
	// Loop until XT1,XT2 & DCO stabilizes - In this case only DCO has to stabilize
	do
	{
	  UCSCTL7 &= ~(XT2OFFG + XT1LFOFFG + DCOFFG);
											  // Clear XT2,XT1,DCO fault flags
	  SFRIFG1 &= ~OFIFG;                      // Clear fault flags
	}while (SFRIFG1&OFIFG);                   // Test oscillator fault flag
}


void setBluetooth(void){
	char CTS=BIT5;
	char RTS=BIT6;
	char BT_reset=BIT0;


	P2DIR &= ~RTS;                    // Set P2.6 input                              (RTS to the blue tooth)
	P2DIR |= CTS;				      // Set P2.5 output							   (CTS to the blue tooth)
	P2OUT = 0x00;					  // Clear Transmission						   (P2 is the UART prot to blue tooth)
	P6DIR |= BT_reset;				  // Reset the Bluetooth module                   (Direction Output)
	P6OUT &= ~BT_reset;															 // (Output 0 to reset)

	volatile unsigned int i;            // volatile to prevent optimization
	i = 1000;                          // SW Delay
	do i--;
	while (i != 0);
	P6OUT |= BT_reset;
	i = 10000;                          // SW Delay
	do i--;
	while (i != 0);

	P4SEL = 0x30;						//P4.4,5 = UCA1RXD/TXD
	UCA1CTL1 |= UCSWRST;				//Put state machine in reset      (software reset enable)
	UCA1CTL1 |= UCSSEL_2;				//SMCLK                           (Also can use UCA1CTL1 |= UCSSEL_SMCLK)
	UCA1BR0 = 138;					//User's guide
	UCA1BR1 = 0;
	UCA1MCTL |= UCBRS_7 + UCBRF_0;     // no over sampling
 //* The baud rate is set to be 115200 here.

	UCA1CTL1 &= ~UCSWRST;            //(software reset disable)
//	UCA1IE |= UCTXIE;                //(Send interrupt enable)
}

void initTimerB (void)
{
    TB0R = 0;
	TB0CTL |= (CNTL_0 | TBSSEL_1 | TBCLR | MC_2 | ID_2);
    TB0EX0 = 7;
}
void sleepMPU9150(void){
	unsigned char configData [1];
	// sleep the  sensor
	configData [0]=0x00;
	UCB1_I2C_write (MPU6050_DEFAULT_ADDRESS, MPU6050_RA_PWR_MGMT_1, configData, 1);
}

void byteStuff (unsigned char* dataPkt, unsigned char len, unsigned char* outPkt, unsigned char* outLen)
{
	outPkt [0] = DLE;
	outPkt [1] = SOH;
	unsigned char j = 2;
	unsigned char i = 0;
	for (i = 0; i < len; i++)
	{
		if (dataPkt [i] != DLE)
			outPkt [j++] = dataPkt [i];
		else
		{
			outPkt [j++] = DLE;
			outPkt [j++] = DLE;
		}
	}
	outPkt [j++] = DLE;
	outPkt [j++] = EOT;

	*outLen = j;
}

void sendSensorData (void)
{
	unsigned char d = 0;

	pkt [0] = 0x00;
	unsigned temp=TB0R;
	pkt [21] = HIGHBYTE(temp);
	pkt [22] = LOWBYTE(temp);

	// Read acc data
	UCB1_I2C_read (MPU6050_DEFAULT_ADDRESS, MPU6050_RA_ACCEL_XOUT_H, &pkt[1], 6);
	// Read gyro data
	UCB1_I2C_read (MPU6050_DEFAULT_ADDRESS, MPU6050_RA_GYRO_XOUT_H, &pkt[7], 6);

    // check if data is ready to be read from magnetometer, if not leave last data unchanged
	UCB1_I2C_read (AK8975_DEFAULT_ADDRESS, AK8975_REG_ST1, &d, 1);
    if (d & 0x01)	// data of magentometer is ready to read
    {
        UCB1_I2C_read (AK8975_DEFAULT_ADDRESS, AK8975_REG_HXL, &pkt[13], 6);
        // swap low byte and high byte to be the same as the packet format
        d = pkt [13];
        pkt [13] = pkt [14];
        pkt [14] = d;
        d = pkt [15];
        pkt [15] = pkt [16];
        pkt [16] = d;
        d = pkt [17];
        pkt [17] = pkt [18];
        pkt [18] = d;
    }

    // if single measurement is not is progress, start the next conversion
	UCB1_I2C_read (AK8975_DEFAULT_ADDRESS, AK8975_REG_CNTL, &d, 1);
	if (d == 0)
	{
		d = 0x01;
		UCB1_I2C_write (AK8975_DEFAULT_ADDRESS, AK8975_REG_CNTL, &d, 1);
	}


	pktNo++;

	pkt [19] = HIGHBYTE(pktNo);
	pkt [20] = LOWBYTE(pktNo);

	pkt [23] = 0xff;

	unsigned char outLen = 0;
	byteStuff (&pkt [1], 22, outPkt, &outLen);

	if (!(P2IN & BIT6))	// BT RTS is cleared and BT can receive data
	{
		char i;
		for(i=0;i<outLen;i++){
			while (!(UCA1IFG&UCTXIFG));
			//while (P2IN & BIT6);
			UCA1TXBUF = outPkt[i];
		}
	}
}

#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR (void) {
	GPIO_clearInterruptFlag (__MSP430_BASEADDRESS_PORT1_R__, GPIO_PORT_P1, GPIO_PIN2);
    LPM3_EXIT;
}


#pragma vector = PORT2_VECTOR
__interrupt void PORT2_ISR (void) {
//	unsigned char pkt [24];
	//static unsigned int pktNo = 0;
	GPIO_clearInterruptFlag (__MSP430_BASEADDRESS_PORT2_R__, GPIO_PORT_P2, GPIO_PIN3);
   	sampleIsReady = 1;
    LPM3_EXIT;
}

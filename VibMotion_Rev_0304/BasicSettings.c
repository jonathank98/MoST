#include <msp430.h>
#include "clock_freq_defs.h"
#include "BasicSettings.h"


void setFreq16MHz(void){
	     UCSCTL3 = SELREF_2;                       // Set DCO FLL reference = REFO
	     UCSCTL4 |= SELA_2 + SELS_4;                // Set ACLK = REFO,SCLK=dcodiv,MCLK = dcodiv(default)

	     __bis_SR_register(SCG0);                  // Disable the FLL control loop
	     UCSCTL0 = 0x0000;                         // Set lowest possible DCOx, MODx
	     UCSCTL1 = DCORSEL_16MHZ;                      // Select DCO range  operation
	     UCSCTL2 = FLLD_1 + DCO_MULT_16MHZ;                   // Set DCO Multiplier for 25MHz


	     // Worst-case settling time for the DCO when the DCO range bits have been
	     // changed is n x 32 x 32 x f_MCLK / f_FLL_reference. See UCS chapter in 5xx
	     // UG for optimization.
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
/*
void halBoardSetSystemClock(unsigned char systemClockSpeed)
{
    unsigned char setDcoRange, setVCore;
    unsigned int  setMultiplier;

    halBoardGetSystemClockSettings( systemClockSpeed, &setDcoRange,
        &setVCore, &setMultiplier);

    //halBoardSetVCore( setVCore );

    __bis_SR_register(SCG0);                  // Disable the FLL control loop
    UCSCTL0 = 0x00;                           // Set lowest possible DCOx, MODx
    UCSCTL1 = setDcoRange;                    // Select suitable range

    UCSCTL2 = setMultiplier + FLLD_1;         // Set DCO Multiplier

    __bic_SR_register(SCG0);                  // Enable the FLL control loop

    // Worst-case settling time for the DCO when the DCO range bits have been
    // changed is n x 32 x 32 x f_FLL_reference. See UCS chapter in 5xx UG
    // for optimization.
    // 32 x 32 x / f_FLL_reference (32,768 Hz) = .03125 = t_DCO_settle
    // t_DCO_settle / (1 / 25 MHz) = 781250 = counts_DCO_settle
    __delay_cycles(781250);

    // Loop until XT1,XT2 & DCO fault flag is cleared
    do
    {
    	UCSCTL7 &= ~(XT2OFFG +XT1LFOFFG + DCOFFG);
        // Clear XT2,XT1,DCO fault flags
        SFRIFG1 &= ~OFIFG;                      // Clear fault flags
    }while (SFRIFG1&OFIFG);                   // Test oscillator fault flag
}




static void halBoardGetSystemClockSettings(unsigned char systemClockSpeed,
                                           unsigned char *setDcoRange,
                                           unsigned char *setVCore,
                                           unsigned int  *setMultiplier)
{
    switch (systemClockSpeed)
    {
    case SYSCLK_1MHZ:
        *setDcoRange = DCORSEL_1MHZ;
        *setVCore = VCORE_1MHZ;
        *setMultiplier = DCO_MULT_1MHZ;
        break;
    case SYSCLK_4MHZ:
        *setDcoRange = DCORSEL_4MHZ;
        *setVCore = VCORE_4MHZ;
        *setMultiplier = DCO_MULT_4MHZ;
        break;
    case SYSCLK_8MHZ:
        *setDcoRange = DCORSEL_8MHZ;
        *setVCore = VCORE_8MHZ;
        *setMultiplier = DCO_MULT_8MHZ;
        break;
    case SYSCLK_12MHZ:
        *setDcoRange = DCORSEL_12MHZ;
        *setVCore = VCORE_12MHZ;
        *setMultiplier = DCO_MULT_12MHZ;
        break;
    case SYSCLK_16MHZ:
        *setDcoRange = DCORSEL_16MHZ;
        *setVCore = VCORE_16MHZ;
        *setMultiplier = DCO_MULT_16MHZ;
        break;
    case SYSCLK_20MHZ:
        *setDcoRange = DCORSEL_20MHZ;
        *setVCore = VCORE_20MHZ;
        *setMultiplier = DCO_MULT_20MHZ;
        break;
    case SYSCLK_25MHZ:
        *setDcoRange = DCORSEL_25MHZ;
        *setVCore = VCORE_25MHZ;
        *setMultiplier = DCO_MULT_25MHZ;
        break;
    }
}
*/

/** 
 * @file USCI_I2C_Regs.h
 * 
 * @detail Description : 
 * Generic I2C definitions
 * 
 * @author E. Macias / D. Torres / S. Ravindran
 * @author Texas Instruments, Inc
 * @date December, 2011
 * @version 1.0 - Initial version
 * @note Built with IAR Embedded Workbench: 5.20.1 and CCS Version 5.1.0.09000
 **/

#ifndef USCI_I2C_DEFINITIONS_H_
#define USCI_I2C_DEFINITIONS_H_

// F5529  Family: USCI_I2C_B0, USCI_I2C_B1
#if defined(__MSP430F5528__) || defined(__MSP430F5529__)
  #if (USCI_I2C_MODULE == USCI_I2C_B0)
	#define UCBxCTL0		 UCB0CTL0		/* USCI Control Register 0 */	
    #define UCBxCTL1    	 UCB0CTL1		/* USCI Control Register 1 */
    #define UCBxBR0     	 UCB0BR0		/* USCI Baud Rate 0 */
    #define UCBxBR1     	 UCB0BR1		/* USCI Baud Rate 1 */
    #define UCBxSTAT    	 UCB0STAT		/* USCI Status Register */
    #define UCBxRXBUF   	 UCB0RXBUF		/* USCI Receive Buffer */
    #define UCBxTXBUF   	 UCB0TXBUF		/* USCI Transmit Buffer */
    #define UCBxIE 		     UCB0IE   		/* USCI Interrupt Enable Register */
    #define UCBxIFG		     UCB0IFG    	/* USCI Interrupt Flags Register */                        
    #define UCBxIV	    	 UCB0IV		    /* USCI Interrupt Vector Register */
    #define UCBxRXIE         BIT0
    #define UCBxTXIE         BIT1
    #define UCBxRXIFG        BIT0
    #define UCBxTXIFG        BIT1
    #define UCBxI2CSA		 UCB0I2CSA
    #define USCI_Bx_VECTOR   USCI_B0_VECTOR
    // Pin Definitions
    #define PxDIR_SDA		 P3DIR
    #define PxDIR_SCL		 P3DIR
    #define PxOUT_SDA		 P3OUT
    #define PxOUT_SCL		 P3OUT
    #define PxSEL_SDA		 P3SEL
    #define PxSEL_SCL		 P3SEL
    #define SDA_BIT			 BIT0
    #define SCL_BIT 		 BIT1
  #elif (USCI_I2C_MODULE == USCI_I2C_B1)
	#define UCBxCTL0		 UCB1CTL0		/* USCI Control Register 0 */	
    #define UCBxCTL1    	 UCB1CTL1		/* USCI Control Register 1 */
    #define UCBxBR0     	 UCB1BR0		/* USCI Baud Rate 0 */
    #define UCBxBR1     	 UCB1BR1		/* USCI Baud Rate 1 */
    #define UCBxSTAT    	 UCB1STAT		/* USCI Status Register */
    #define UCBxRXBUF   	 UCB1RXBUF		/* USCI Receive Buffer */
    #define UCBxTXBUF   	 UCB1TXBUF		/* USCI Transmit Buffer */
    #define UCBxIE 		     UCB1IE   		/* USCI Interrupt Enable Register */
    #define UCBxIFG		     UCB1IFG    	/* USCI Interrupt Flags Register */                        
    #define UCBxIV	    	 UCB1IV		    /* USCI Interrupt Vector Register */
    #define UCBxRXIE         BIT0
    #define UCBxTXIE         BIT1
    #define UCBxRXIFG        BIT0
    #define UCBxTXIFG        BIT1  
    #define UCBxI2CSA		 UCB1I2CSA
    #define USCI_Bx_VECTOR   USCI_B1_VECTOR
    // Pin Definitions
    #define PxDIR_SDA		 P4DIR
    #define PxDIR_SCL		 P4DIR
    #define PxOUT_SDA		 P4OUT
    #define PxOUT_SCL		 P4OUT
    #define PxSEL_SDA		 P4SEL
    #define PxSEL_SCL		 P4SEL
    #define SDA_BIT			 BIT1
    #define SCL_BIT 		 BIT2
  #else
    #error "Incorrect USCI_I2C_MODULE defined"
  #endif

#endif

#endif /*USCI_I2C_DEFINITIONS_H_*/

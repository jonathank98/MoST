/** 
 *	\page doc_page_placeholder Place title here
 *
 *  \section desc_sec Description
 *  Place description here 
 *
 *  \section intro_sec Introduction
 *  
 *	Describe this file
 *
 *
 * \section disclaimer_sec Disclaimer
 *
 * THIS PROGRAM IS PROVIDED "AS IS". TI MAKES NO WARRANTIES OR
 * REPRESENTATIONS, EITHER EXPRESS, IMPLIED OR STATUTORY,
 * INCLUDING ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE, LACK OF VIRUSES, ACCURACY OR
 * COMPLETENESS OF RESPONSES, RESULTS AND LACK OF NEGLIGENCE.
 * TI DISCLAIMS ANY WARRANTY OF TITLE, QUIET ENJOYMENT, QUIET
 * POSSESSION, AND NON-INFRINGEMENT OF ANY THIRD PARTY
 * INTELLECTUAL PROPERTY RIGHTS WITH REGARD TO THE PROGRAM OR
 * YOUR USE OF THE PROGRAM.
 *
 * IN NO EVENT SHALL TI BE LIABLE FOR ANY SPECIAL, INCIDENTAL,
 * CONSEQUENTIAL OR INDIRECT DAMAGES, HOWEVER CAUSED, ON ANY
 * THEORY OF LIABILITY AND WHETHER OR NOT TI HAS BEEN ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGES, ARISING IN ANY WAY OUT
 * OF THIS AGREEMENT, THE PROGRAM, OR YOUR USE OF THE PROGRAM.
 * EXCLUDED DAMAGES INCLUDE, BUT ARE NOT LIMITED TO, COST OF
 * REMOVAL OR REINSTALLATION, COMPUTER TIME, LABOR COSTS, LOSS
 * OF GOODWILL, LOSS OF PROFITS, LOSS OF SAVINGS, OR LOSS OF
 * USE OR INTERRUPTION OF BUSINESS. IN NO EVENT WILL TI'S
 * AGGREGATE LIABILITY UNDER THIS AGREEMENT OR ARISING OUT OF
 * YOUR USE OF THE PROGRAM EXCEED FIVE HUNDRED DOLLARS
 * (U.S.$500).
 *
 * Unless otherwise stated, the Program written and copyrighted
 * by Texas Instruments is distributed as "freeware".  You may,
 * only under TI's copyright in the Program, use and modify the
 * Program without any charge or restriction.  You may
 * distribute to third parties, provided that you transfer a
 * copy of this license to the third party and the third party
 * agrees to these terms by its first use of the Program. You
 * must reproduce the copyright notice and any other legend of
 * ownership on each copy or partial copy, of the Program.
 *
 * You acknowlege and agree that the Program contains
 * copyrighted material, trade secrets and other TI proprietary
 * information and is protected by copyright laws,
 * international copyright treaties, and trade secret laws, as
 * well as other intellectual property laws.  To protect TI's
 * rights in the Program, you agree not to decompile, reverse
 * engineer, disassemble or otherwise translate any object code
 * versions of the Program to a human-readable form.  You agree
 * that in no event will you alter, remove or destroy any
 * copyright notice included in the Program.  TI reserves all
 * rights not specifically granted under this license. Except
 * as specifically provided herein, nothing in this agreement
 * shall be construed as conferring by implication, estoppel,
 * or otherwise, upon you, any license or other right under any
 * TI patents, copyrights or trade secrets.
 *
 * You may not use the Program in non-TI devices.
 * 
 * The ECCN is EAR99. 
 * 
 */

/** \file filename.h
 *
 *	@brief Describe File here
 *  @author Texas Instruments Inc.
 *	@date Aug 2012
 *	@version Version 0.1 - beta release
 *  @note Built with CCS Version 5.2.1.00018
*/
#include "msp430.h"
#include "I2C.h"


/* ***************************************************************************
 * UCB1_MasterI2C_init
 *  Initialize the I2C module in Master mode
 *
 * \param addr_mode: 7/10-bit addressing mode (I2C_7bit_addr or I2C_10bit_addr)
 *        clock_src: Clock Source (I2C_CLK_UCLKI, I2C_CLK_ACLK, I2C_CLK_SMCLK)
 *        prescaler: I2C clock prescaler
 *
*/
char UCB1_MasterI2C_init (unsigned char addr_mode, unsigned char clock_src, unsigned short prescaler)
{
	char comres = 0;

  	// Enable SW reset
  	UCB1CTL1 = UCSWRST;
  	
  	// I2C Single Master, synchronous mode, 7/10 bits
  	UCB1CTL0 = UCMST + UCMODE_3 + UCSYNC + (addr_mode & (UCA10 | UCSLA10));
  	
  	 // Select Clock and hold SW reset 
  	UCB1CTL1 = (clock_src & UCSSEL_3) + UCSWRST;
  	
  	// set prescaler
  	UCB1BRW = prescaler;
  	
  	// Clear SW reset, resume operation
  	UCB1CTL1 &= ~UCSWRST;
  	
  	// Enable NACK interrupts
  	UCB1IE = UCNACKIE;
  	
  	return(comres);
}

char UCB1_I2C_write(unsigned char slave_addr, unsigned char reg, unsigned char *data, unsigned char byteCount)
{
	unsigned char comres = 0;

	//WAIT FOR PREVIOUS TRAFFIC TO CLEAR
	while(UCB1STAT & UCBBUSY);
		
	// LOAD THE DEVICE SLAVE ADDRESS
	UCB1I2CSA = slave_addr;
	
	// ENABLE TRANSMIT, GENERATE START BIT                  
  	UCB1CTL1 |= UCTR + UCTXSTT;
  	
  	// WAIT FOR FIRST INT 
  	while(!(UCB1IFG & UCTXIFG));
  	
  	// LOAD THE REGISTER ADDRESS
  	UCB1TXBUF = reg;

  	// NOW WAIT FOR START BIT TO COMPLETE
  	while(UCB1CTL1 & UCTXSTT);

   	// CHECK IF SLAVE ACK/NACK 	
  	if(UCB1IFG & UCNACKIFG)
  	{
  		// IF NACK, SET STOP BIT AND EXIT
  		UCB1CTL1 |= UCTXSTP;
		return(USCI_I2C_STATUS_SLAVE_NACK);
  	}
   	
   	// NOW WRITE ONE OR MORE DATA BYTES
  	while(1)
  	{
	  	 // WAIT FOR NEXT INT AFTER REGISTER BYTE
	  	while(!(UCB1IFG & UCTXIFG));
	  	
	  	// IF NOT DATA TO FOLLOW, THEN WE ARE DONE
	  	if(byteCount == 0 )
	  	{
	 		UCB1CTL1 |= UCTXSTP;
			//UCB1IE &= ~UCTXIE;
			return(comres);	
	  	}
	  	// IF MORE, SEND THE NEXT BYTE
	  	else
	  		UCB1TXBUF = *data++;
	  		byteCount--;
  	
  	}


}
char UCB1_I2C_read(unsigned char slave_addr, unsigned char reg, unsigned char *data, unsigned char byteCount)
{
	unsigned char comres = 0;

	//WAIT FOR PREVIOUS TRAFFIC TO CLEAR
	while(UCB1STAT & UCBBUSY);
		
	// LOAD THE DEVICE SLAVE ADDRESS
	UCB1I2CSA = slave_addr;
	
	// ENABLE TRANSMIT, GENERATE START BIT                  
  	UCB1CTL1 |= UCTR + UCTXSTT;
  	
  	// WAIT FOR FIRST INT 
  	while(!(UCB1IFG & UCTXIFG));
  	
  	// LOAD THE REGISTER ADDRESS
  	UCB1TXBUF = reg;

  	// NOW WAIT FOR START BIT TO COMPLETE
  	while(UCB1CTL1 & UCTXSTT);
  	
   	// CHECK IF SLAVE ACK/NACK 	
  	if(UCB1IFG & UCNACKIFG)
  	{
  		// IF NACK, SET STOP BIT AND EXIT
  		UCB1CTL1 |= UCTXSTP;
		return(USCI_I2C_STATUS_SLAVE_NACK);
  	}
  
   	// NOW PREPARE TO READ DATA FROM SLAVE
   	// TURN OFF TRANSMIT (ENABLE RECEIVE)
   	UCB1CTL1 &= ~UCTR;
   	
   	// GENERATE (RE-)START BIT                  
  	UCB1CTL1 |= UCTXSTT;
  	
  	// WAIT FOR START BIT TO COMPLETE
  	while(UCB1CTL1 & UCTXSTT);
  	
  	// CHECK IF SLAVE ACK/NACK 	
  	if(UCB1IFG & UCNACKIFG)
  	{
  		// IF NACK, SET STOP BIT AND EXIT
  		UCB1CTL1 |= UCTXSTP;
		return(USCI_I2C_STATUS_SLAVE_NACK);
  	}
  	
   	// NOW READ ONE OR MORE DATA BYTES
  	while(byteCount)
  	{
  		// IF READING 1 BYTE (OR LAST BYTE), GENERATE STOP BIT NOW TO MEET SPEC
  		if(byteCount-- == 1)
 			UCB1CTL1 |= UCTXSTP;
   			
  		 		
	  	 // WAIT FOR NEXT RX INT
	  	while(!(UCB1IFG & UCRXIFG));
	  	
	  	// READ THE BYTE
	  	*data++ = UCB1RXBUF;
  	}

	return(comres);
}

char UCB1_I2C_read_only(unsigned char slave_addr, unsigned char reg, unsigned char *data, unsigned char byteCount)
{
	unsigned char comres = 0;

	//WAIT FOR PREVIOUS TRAFFIC TO CLEAR
	while(UCB1STAT & UCBBUSY);
		
	// LOAD THE DEVICE SLAVE ADDRESS
	UCB1I2CSA = slave_addr;
	
   	// TURN OFF TRANSMIT (ENABLE RECEIVE)
   	UCB1CTL1 &= ~UCTR;
   	
   	// GENERATE START BIT                  
  	UCB1CTL1 |= UCTXSTT;
  	
  	// WAIT FOR START BIT TO COMPLETE
  	while(UCB1CTL1 & UCTXSTT);
  	
  	// CHECK IF SLAVE ACK/NACK 	
  	if(UCB1IFG & UCNACKIFG)
  	{
  		// IF NACK, SET STOP BIT AND EXIT
  		UCB1CTL1 |= UCTXSTP;
		return(USCI_I2C_STATUS_SLAVE_NACK);
  	}
  	
   	// NOW READ ONE OR MORE DATA BYTES
  	while(byteCount)
  	{
  		// IF READING 1 BYTE (OR LAST BYTE), GENERATE STOP BIT NOW TO MEET SPEC
  		if(byteCount-- == 1)
 			UCB1CTL1 |= UCTXSTP;
   			
  		 		
	  	 // WAIT FOR NEXT RX INT
	  	while(!(UCB1IFG & UCRXIFG));
	  	
	  	// READ THE BYTE
	  	*data++ = UCB1RXBUF;
  	}

	return(comres);
}
